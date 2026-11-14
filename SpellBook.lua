-- SkillsAlreadyKnown: learned player spell ranks, independent of trainer rows.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end
local Book = {}
SAK.SpellBook = Book
local entries, dirty = {}, true
local entriesByID = {}
local displays = setmetatable({}, { __mode = "k" })
local hookedRoots = setmetatable({}, { __mode = "k" })
local queued, driver, elapsed, discovery = false, nil, 0, nil
local legend
local stats = { scans = 0, refreshes = 0, scanned = 0 }
Book.renderRevision = "spellbook-categories-8"

-- Detached frames must clear the book's entire native rendering tree, not just
-- its row's numerical frame level. Keep these mouse-transparent and below tooltips.
local strataOrder = { BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4,
  DIALOG = 5, FULLSCREEN = 6, FULLSCREEN_DIALOG = 7, TOOLTIP = 8 }
local function prepareOverlay(display, owner)
  local strata, level, current = "HIGH", 0, owner
  for _ = 1, 16 do
    if not current then break end
    local candidate = current.GetFrameStrata and current:GetFrameStrata()
    if strataOrder[candidate] and strataOrder[candidate] > strataOrder[strata] then strata = candidate end
    if current.GetFrameLevel then level = math.max(level, current:GetFrameLevel()) end
    local parent = current.GetParent and current:GetParent()
    if parent == current then break end
    current = parent
  end
  display:SetFrameStrata(strata)
  display:SetFrameLevel(math.min(level + 20, 65535))
  if owner.GetEffectiveScale and UIParent.GetEffectiveScale then
    display:SetScale(owner:GetEffectiveScale() / UIParent:GetEffectiveScale())
  end
end


Book.PrepareOverlay = prepareOverlay

local function bank()
  if C_SpellBook and C_SpellBook.GetSpellBookItemInfo and Enum and Enum.SpellBookSpellBank then
    return Enum.SpellBookSpellBank.Player
  end
  return BOOKTYPE_SPELL or "spell"
end

local knownSpell = SAK.IsPlayerSpellKnown

local function futureSlot(index, b)
  local api = C_SpellBook and C_SpellBook.GetSpellBookItemLevelLearned
  if not api or not UnitLevel then return false end
  local ok, required = pcall(api, index, b)
  local level = UnitLevel("player")
  return ok and type(required) == "number" and type(level) == "number" and level > 0 and required > level
end

local function read(index)
  local b = bank()
  local info, name, sub, id, passive
  if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
    local ok, value = pcall(C_SpellBook.GetSpellBookItemInfo, index, b)
    if ok then info = value end
  end
  if type(info) == "table" then
    local kind = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.Spell
    if (kind and info.itemType ~= kind) or info.isUnlearned or info.isOffSpec
      or info.isPassive or info.isLearned == false then return nil end
    id, name, sub, passive = info.spellID or info.actionID, info.name, info.subName, info.isPassive
  elseif GetSpellBookItemInfo then
    local ok, kind, value = pcall(GetSpellBookItemInfo, index, b)
    if not ok or kind ~= "SPELL" then return nil end
    id = value
  end
  if type(id) ~= "number" or id <= 0 then return nil end
  if knownSpell(id) == false or futureSlot(index, b) then return nil end
  if (not name or not sub or sub == "") and GetSpellBookItemName then
    local ok, n, r = pcall(GetSpellBookItemName, index, b)
    if ok then name, sub = name or n, (sub and sub ~= "") and sub or r end
  end
  if (not name or not sub or sub == "") and C_SpellBook and C_SpellBook.GetSpellBookItemName then
    local ok, n, r = pcall(C_SpellBook.GetSpellBookItemName, index, b)
    if ok then name, sub = name or n, (sub and sub ~= "") and sub or r end
  end
  if C_Spell and C_Spell.GetSpellSubtext and (not sub or sub == "") then
    local ok, value = pcall(C_Spell.GetSpellSubtext, id); if ok then sub = value end
  end
  if GetSpellInfo and (not name or not sub or sub == "") then
    local ok, n, r = pcall(GetSpellInfo, id)
    if ok then name, sub = name or n, (sub and sub ~= "") and sub or r end
  end
  if IsPassiveSpell then
    local ok, value = pcall(IsPassiveSpell, id); if ok then passive = value end
  end
  local rank = SAK.RankNumber(sub)
  local ranked = rank ~= nil
  -- Spell subtext may describe a category (e.g. Invocation / Summon / Raciale),
  -- not a rank. Keep learned active spells in that case, without inventing a rank.
  -- A label explicitly announcing an unreadable rank still fails closed.
  if not rank and sub and sub ~= "" then
    local text = SAK.NormalizeText(sub)
    local label = type(RANK) == "string" and SAK.NormalizeText(RANK:gsub("%%[ds]", "")) or ""
    if text:match("^rang") or text:match("^rank") or (label ~= "" and text:find(label, 1, true)) then return nil end
  end
  rank = rank or 1
  if passive or type(name) ~= "string" or SAK.CleanText(name) == "" or rank < 1 then return nil end
  return { slot = index, id = id, name = SAK.CleanText(name), rank = rank, ranked = ranked }
end

-- Interface conservee pour les consommateurs du grimoire.
Book.Classify = SAK.SpellRanks.Classify

function Book.MarkDirty() dirty = true end

function Book.Scan()
  stats.scans = stats.scans + 1
  local list, ranges, fallback = {}, {}, false
  if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo then
    local ok, count = pcall(C_SpellBook.GetNumSpellBookSkillLines)
    if ok and type(count) == "number" then
      for i = 1, count do
        local good, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, i)
        if good and info and not info.offSpecID and info.itemIndexOffset and info.numSpellBookItems then
          ranges[#ranges + 1] = { info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems }
        end
      end
    end
  elseif GetNumSpellTabs and GetSpellTabInfo then
    for i = 1, GetNumSpellTabs() do
      local _, _, offset, count = GetSpellTabInfo(i)
      if offset and count then ranges[#ranges + 1] = { offset + 1, offset + count } end
    end
  end
  if #ranges == 0 then ranges[1] = { 1, 1000 }; fallback = true end
  local seen = {}
  for _, range in ipairs(ranges) do
    local misses = 0
    for i = range[1], range[2] do
      local entry = read(i)
      if entry then
        misses = 0
        if not seen[i] then list[#list + 1] = entry; seen[i] = true end
      else misses = misses + 1 end
      if fallback and misses >= 50 then break end
    end
  end
  local _, class
  if UnitClass then _, class = UnitClass("player") end
  entries = Book.Classify(list, class)
  entriesByID = {}
  for _, state in pairs(entries) do entriesByID[state.id] = state end
  stats.scanned = #list
  dirty = false
  return entries
end

local function visible(frame)
  if not frame or (frame.IsVisible and not frame:IsVisible()) then return false end
  -- Addon tabs can keep native frames shown while making their content transparent.
  -- Our detached overlays must follow that content's effective visibility too.
  if frame.GetEffectiveAlpha then return frame:GetEffectiveAlpha() > 0 end
  local current = frame
  for _ = 1, 16 do
    if not current then break end
    if current.GetAlpha and current:GetAlpha() <= 0 then return false end
    local parent = current.GetParent and current:GetParent()
    if parent == current then break end
    current = parent
  end
  return true
end

local function modernContentVisible(book)
  return visible(book) and (not book.PagedSpellsFrame or visible(book.PagedSpellsFrame))
end

local function paint(owner, icon, state)
  if SAK.DisplayEnabled and (not SAK.DisplayEnabled("icons") or not SAK.DisplayEnabled("iconsSpellbook")) then state = nil end
  if not owner or not icon then return end
  if SAK.RecentVisuals then
    SAK.RecentVisuals.Paint(owner, icon, state and state.id, "spells", "iconsSpellbook")
  end
  local display = displays[owner]
  if not state or not visible(owner) or not visible(icon) then if display then display:Hide() end; return end
  if not display then
    -- Never add state, attributes or textures to protected spell buttons.
    display = CreateFrame("Frame", nil, UIParent)
    display:EnableMouse(false)
    display.texture = display:CreateTexture(nil, "OVERLAY", nil, 7)
    display.texture:SetAllPoints(display)
    if SAK.Compatibility then SAK.Compatibility.ProtectTexture(display.texture) end
    displays[owner] = display
  end
  local spec = SAK.SPELLBOOK_BADGES[state.kind]
  display:ClearAllPoints(); display:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 7, 7)
  display:SetSize(spec.width, spec.height)
  prepareOverlay(display, owner)
  display.texture:SetTexture(spec.texture)
  if SAK.Compatibility then SAK.Compatibility.ProtectTexture(display.texture) end
  if state.optionalReason then
    if not display.optionalTexture then
      display.optionalTexture = display:CreateTexture(nil, "OVERLAY", nil, 7)
      display.optionalTexture:SetSize(64, 16)
      display.optionalTexture:SetPoint("LEFT", display.texture, "RIGHT", 2, 0)
      display.optionalTexture:SetTexture(SAK.SPELLBOOK_BADGES.optional.texture)
      if SAK.Compatibility then SAK.Compatibility.ProtectTexture(display.optionalTexture) end
    end
    display.optionalTexture:SetShown(true)
  elseif display.optionalTexture then display.optionalTexture:SetShown(false) end
  display:Show()
end

local function renderModern(book, touched)
  if not modernContentVisible(book) or not book.ForEachDisplayedSpell then return end
  book:ForEachDisplayedSpell(function(row)
    local data = row.elementData
    local slot, b = row.slotIndex or (data and data.slotIndex), row.spellBank or (data and data.spellBank)
    local state = b == bank() and entries[slot] or nil
    if row.isUnlearned or row.isOffSpec then state = nil end
    local icon = row.Button and row.Button.Icon or row.Icon or row.icon
    touched[row] = true; paint(row, icon, state)
  end)
end

-- The modern book has spare header space to the right of its school title.
-- A detached, mouse-transparent legend never changes its layout or secure rows.
function Book.UpdateLegend(book)
  if not book or not modernContentVisible(book) or (SAK.DisplayEnabled and not SAK.DisplayEnabled("text")) then
    if legend then legend:Hide() end
    return
  end
  local anchor = book.PagedSpellsFrame
  local width = anchor and anchor.GetWidth and anchor:GetWidth()
  if not width or width < 500 then if legend then legend:Hide() end; return end
  if not legend then
    legend = CreateFrame("Frame", nil, UIParent)
    legend:EnableMouse(false)
    legend.rows = {}
    for i, kind in ipairs({ "eco", "best" }) do
      local texture = legend:CreateTexture(nil, "OVERLAY", nil, 7)
      texture:SetSize(40, 16)
      texture:SetPoint("TOPLEFT", legend, "TOPLEFT", 0, -((i - 1) * 28 + 4))
      texture:SetTexture(SAK.SPELLBOOK_BADGES[kind].texture)
      local label = legend:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetJustifyH("LEFT"); label:SetJustifyV("TOP")
      label:SetWordWrap(true); label:SetMaxLines(2); label:SetHeight(26)
      label:SetTextColor(1, 1, 1)
      label:SetShadowColor(0, 0, 0, 1); label:SetShadowOffset(1, -1)
      legend.rows[i] = { texture = texture, label = label, kind = kind }
    end
    local optional = legend:CreateTexture(nil, "OVERLAY", nil, 7)
    optional:SetSize(64, 16)
    optional:SetPoint("LEFT", legend.rows[2].texture, "RIGHT", 2, 0)
    optional:SetTexture(SAK.SPELLBOOK_BADGES.optional.texture)
    legend.optionalTexture = optional
    Book.legend = legend
  end
  width = math.min(360, width * 0.52)
  legend:ClearAllPoints(); legend:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -20, -24)
  legend:SetSize(width, 56)
  prepareOverlay(legend, anchor)
  -- Some replacement anchors do not expose their effective scale; use the book.
  if not anchor.GetEffectiveScale and book.GetEffectiveScale and UIParent.GetEffectiveScale then
    legend:SetScale(book:GetEffectiveScale() / UIParent:GetEffectiveScale())
  end
  local icons = not SAK.DisplayEnabled or (SAK.DisplayEnabled("icons") and SAK.DisplayEnabled("iconsSpellbook"))
  local optional = SAK.RankPolicy and SAK.RankPolicy.OptionalEnabled()
  legend.optionalTexture:SetShown(icons and optional)
  if SAK.Compatibility then SAK.Compatibility.ProtectTexture(legend.optionalTexture) end
  for i, row in ipairs(legend.rows) do
    row.texture:SetShown(icons)
    if SAK.Compatibility then SAK.Compatibility.ProtectTexture(row.texture) end
    row.label:ClearAllPoints()
    local inset = icons and (row.kind == "best" and optional and 112 or 48) or 0
    row.label:SetPoint("TOPLEFT", legend, "TOPLEFT", inset, -((i - 1) * 28))
    row.label:SetWidth(width - inset)
    local text = row.kind == "eco"
      and L("Rang suffisant pour pex (rôle).\nÉconomie d'or, pas de mana garantie.")
      or L("Plus haut rang appris, même seul.\nDégâts, soins et effets de ce rang.")
    if row.kind == "best" and optional then
      text = L("BEST : plus haut rang appris.\nOPTIONAL : achat facultatif (rôle).")
    end
    row.label:SetText((icons or (row.kind == "best" and optional)) and text or (row.kind:upper() .. " : " .. text))
  end
  legend:Show()
end

function Book.Refresh()
  if SAK.SpellBookRoles then
    SAK.SpellBookRoles.Refresh()
  end
  if SAK.SpellBookTabs then
    SAK.SpellBookTabs.Hook()
  end
  stats.refreshes = stats.refreshes + 1
  if dirty then Book.Scan() end
  local touched = {}
  local modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
  Book.UpdateLegend(modern)
  renderModern(modern, touched)
  if SpellBookFrame and visible(SpellBookFrame) then
    for i = 1, (SPELLS_PER_PAGE or 12) do
      local button = _G["SpellButton" .. i]
      if button then
        local slot = SpellBook_GetSpellBookSlot and SpellBook_GetSpellBookSlot(button)
        local state = SpellBookFrame.bookType == (BOOKTYPE_SPELL or "spell") and entries[slot] or nil
        touched[button] = true
        paint(button, button.icon or button.Icon or _G["SpellButton" .. i .. "IconTexture"], state)
      end
    end
  end
  -- Ellesmere's optional classic book has private, direct-child secure buttons.
  -- Read public slot/icon fields only; use our own unprotected overlay frames.
  local eui = EUI_ClassicSpellbook
  if eui and visible(eui) and eui.GetChildren then
    for _, button in ipairs({ eui:GetChildren() }) do
      if button.icon and button.slot then
        touched[button] = true; paint(button, button.icon, entries[button.slot])
      end
    end
  end
  for owner, display in pairs(displays) do if not touched[owner] then display:Hide() end end
end

function Book.DebugText()
  local lines = { "Skills & More — Spellbook runtime", "render=" .. Book.renderRevision, "",
    "icons=" .. tostring(not SAK.DisplayEnabled or SAK.DisplayEnabled("icons")) ..
    " text=" .. tostring(not SAK.DisplayEnabled or SAK.DisplayEnabled("text")),
    "optional=" .. tostring(SAK.RankPolicy and SAK.RankPolicy.OptionalEnabled()),
    "buyRank=" .. tostring(SAK.RankPolicy and SAK.RankPolicy.BuyRankEnabled()),
    "nativeContentActive=" .. tostring(modernContentVisible(PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame)),
    "bank=" .. tostring(bank()) .. " dirty=" .. tostring(dirty),
    "scans=" .. stats.scans .. " entries=" .. stats.scanned .. " refreshes=" .. stats.refreshes,
    "driver=" .. tostring(driver ~= nil) .. " eventRegistry=" .. tostring(Book.eventHooked == true),
  }
  local function value(frame, method)
    if not frame or type(frame[method]) ~= "function" then return "n/a" end
    local ok, result = pcall(frame[method], frame)
    return ok and tostring(result) or "error"
  end
  local function describe(label, frame)
    lines[#lines + 1] = label .. ": exists=" .. tostring(frame ~= nil) ..
      " shown=" .. value(frame, "IsShown") .. " visible=" .. value(frame, "IsVisible") ..
      " strata=" .. value(frame, "GetFrameStrata") .. " level=" .. value(frame, "GetFrameLevel") ..
      " alpha=" .. value(frame, "GetAlpha") .. " effectiveAlpha=" .. value(frame, "GetEffectiveAlpha") .. " width=" .. value(frame, "GetWidth") ..
      " scale=" .. value(frame, "GetEffectiveScale") ..
      " left=" .. value(frame, "GetLeft") .. " top=" .. value(frame, "GetTop") ..
      " height=" .. value(frame, "GetHeight")
  end
  local modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
  describe("UIParent", UIParent)
  describe("PlayerSpellsFrame", PlayerSpellsFrame)
  describe("SpellBookFrame", modern)
  describe("PagedSpellsFrame", modern and modern.PagedSpellsFrame)
  describe("legacy", SpellBookFrame)
  describe("EUI classic", EUI_ClassicSpellbook)
  describe("driver", driver)
  describe("legend", legend)
  if legend then
    for i, row in ipairs(legend.rows) do
      describe("legend icon " .. i, row.texture)
      lines[#lines + 1] = "legend texture " .. i .. "=" .. value(row.texture, "GetTexture")
      describe("legend text " .. i, row.label)
    end
  end
  lines[#lines + 1] = "nativeIterator=" .. tostring(modern and type(modern.ForEachDisplayedSpell) == "function")
  if modern and modern.ForEachDisplayedSpell then
    local rows = 0
    local ok, err = pcall(function()
      modern:ForEachDisplayedSpell(function(row)
        rows = rows + 1
        if rows <= 8 then
          local data = row.elementData or {}
          local slot, rowBank = row.slotIndex or data.slotIndex, row.spellBank or data.spellBank
          lines[#lines + 1] = "row=" .. rows .. " slot=" .. tostring(slot) .. " bank=" .. tostring(rowBank) ..
            " bankType=" .. type(rowBank) .. " icon=" .. tostring(row.Button and row.Button.Icon ~= nil) ..
            " state=" .. tostring(slot and entries[slot] and entries[slot].kind)
          describe("row " .. rows, row)
        end
      end)
    end)
    lines[#lines + 1] = "nativeRows=" .. rows .. (ok and "" or (" error=" .. tostring(err)))
  end
  if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
    for slot = 1, 8 do
      local ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, slot, bank())
      if ok and type(info) == "table" then
        lines[#lines + 1] = "API slot=" .. slot .. " id=" .. tostring(info.spellID or info.actionID) ..
          " name=" .. tostring(info.name) .. " sub=" .. tostring(info.subName) ..
          " type=" .. tostring(info.itemType) .. " passive=" .. tostring(info.isPassive) ..
          " offspec=" .. tostring(info.isOffSpec) .. " learned=" .. tostring(info.isLearned)
      else lines[#lines + 1] = "API slot=" .. slot .. " value=" .. tostring(info) end
    end
  end
  if SAK.RankAvailability and UnitClass then
    local _, class = UnitClass("player")
    lines[#lines + 1] = "rankCatalogue=" .. SAK.RankAvailability.SourceText(class)
  end
  if SAK.RankPolicy then
    local profile = SAK.RankPolicy.GetProfile()
    lines[#lines + 1] = "optionalCatalogueRules=" .. #(SAK.RankPolicy.PurchaseCatalogue or {})
    lines[#lines + 1] = "profile=" .. tostring(profile and profile.class)
    for _, role in ipairs({ "tank", "heal", "dps", "pvp" }) do
      lines[#lines + 1] = "profileRole=" .. role .. " enabled=" .. tostring(SAK.RankPolicy.IsRoleEnabled(role)) ..
        " spec=" .. tostring((SAK.RankPolicy.SelectedSpec(role)))
    end
  end
  local count, shown = 0, 0
  for _, display in pairs(displays) do
    count = count + 1
    if display.IsShown and display:IsShown() then shown = shown + 1 end
    if count <= 3 then
      describe("badge " .. count, display)
      lines[#lines + 1] = "badge texture " .. count .. "=" .. value(display.texture, "GetTexture")
    end
  end
  lines[#lines + 1] = "badges=" .. count .. " shown=" .. shown
  local slots = {}
  for slot in pairs(entries) do slots[#slots + 1] = slot end
  table.sort(slots)
  for i = 1, math.min(#slots, 100) do
    local slot, state = slots[i], entries[slots[i]]
    lines[#lines + 1] = "slot=" .. slot .. " id=" .. state.id .. " badge=" .. state.kind ..
      " rank=" .. state.rank .. " highest=" .. state.highest .. " highestID=" .. tostring(state.highestID) ..
      " known=" .. tostring(knownSpell(state.id)) .. " name=" .. tostring(state.name) ..
      " upgradeID=" .. tostring(state.upgrade and state.upgrade.id) .. " upgradeRank=" .. tostring(state.upgrade and state.upgrade.rank)
  end
  return table.concat(lines, "\n")
end

function Book.ShowDebugWindow()
  local function report()
    local ok, err = pcall(function() Book.Hook(); Book.Refresh() end)
    local text = Book.DebugText()
    if not ok then text = text .. "\nRefresh error: " .. tostring(err) end
    return text
  end
  SAK.ShowDebugTextWindow("SpellBook", "Skills & More — Spellbook Debug", report(), report)
end

function Book.QueueRefresh()
  if queued then return end
  queued = true
  if C_Timer and C_Timer.After then
    C_Timer.After(0, function() queued = false; Book.Hook(); Book.Refresh() end)
  else queued = false; Book.Refresh() end
end


function Book.Hook()
  if SAK.SpellBookTabs then
    SAK.SpellBookTabs.Hook()
  end
  if SAK.SpellTooltips then
    SAK.SpellTooltips.Hook()
  end
  if not discovery and EllesmereUI and EllesmereUI.IS_FOREVER and not EUI_ClassicSpellbook
    and C_Timer and C_Timer.NewTicker then
    discovery = C_Timer.NewTicker(1, function()
      if EUI_ClassicSpellbook then
        discovery:Cancel(); discovery = nil; Book.Hook(); Book.QueueRefresh()
      end
    end)
  end
  if not driver then
    driver = CreateFrame("Frame")
    driver:SetScript("OnUpdate", function(_, delta)
      elapsed = elapsed + delta
      if elapsed < 0.15 then return end
      elapsed = 0
      Book.Refresh()
    end)
    driver:Hide()
  end
  local function updateDriver()
    local modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
    driver:SetShown(visible(modern) or visible(SpellBookFrame) or visible(EUI_ClassicSpellbook))
    Book.QueueRefresh()
  end
  for _, root in pairs({ modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame,
    content = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame and PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame,
    legacy = SpellBookFrame, eui = EUI_ClassicSpellbook }) do
    if not hookedRoots[root] and root.HookScript then
      hookedRoots[root] = true
      root:HookScript("OnShow", updateDriver)
      root:HookScript("OnHide", updateDriver)
      if hooksecurefunc and root.SetAlpha then
        hooksecurefunc(root, "SetAlpha", Book.QueueRefresh)
      end
    end
  end
  -- Roots can be created after ADDON_LOADED (Ellesmere's on-demand book).
  -- PlayerSpells display events give immediate updates; the visible-only driver
  -- covers paging/search and private replacement lists without global hooks.
  if not Book.eventHooked and EventRegistry and EventRegistry.RegisterCallback then
    Book.eventHooked = true
    EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged", Book.QueueRefresh, Book)
    EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.Show", Book.QueueRefresh, Book)
  end
  local modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
  driver:SetShown(visible(modern) or visible(SpellBookFrame) or visible(EUI_ClassicSpellbook))
end

function Book.StateForSlot(slot)
  if dirty then
    Book.Scan()
  end
  return entries[slot]
end

function Book.StateForSpell(spellID)
  if dirty then
    Book.Scan()
  end
  return entriesByID[spellID]
end

Book.PlayerBank = bank
