-- Shared PvP/PvE advice and small native badges; no purchase or talent automation.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local Tags = {}
SAK.ContentTags = Tags
local indices = {}
local spellNames = {}
local nodeSpells = {}
local trainerDisplays = setmetatable({}, { __mode = "k" })
local talentDisplays = setmetatable({}, { __mode = "k" })
local driver, elapsed
local talentStats = { visited = 0, matched = 0 }
local labels = {
  pvp = { text = "PVP", width = 30, color = { 1, 0.35, 0.4 }, description = L("Principalement intéressant contre les joueurs. Cela n’exclut pas un usage PvE.") },
  mixed = { text = "PVE PVP", width = 60, color = { 0.35, 0.85, 1 }, description = L("Utile en PvE et contre les joueurs, selon ta spécialisation et le combat.") },
}

local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function enabled(zone)
  return not SAK.DisplayEnabled or (SAK.DisplayEnabled("icons")
    and SAK.DisplayEnabled("contentTags") and SAK.DisplayEnabled(zone))
end

local function spellName(id)
  if spellNames[id] then return spellNames[id] end
  local name
  if C_Spell and C_Spell.GetSpellInfo then
    local ok, info = pcall(C_Spell.GetSpellInfo, id)
    if ok and type(info) == "table" then name = info.name end
  end
  if not name and GetSpellInfo then
    local ok, result = pcall(GetSpellInfo, id)
    if ok then name = result end
  end
  if type(name) == "string" and name ~= "" then
    spellNames[id] = name
    return name
  end
end

local function indexClass(class)
  if indices[class] then return indices[class] end
  local data = SAK.ContentUsage.classes[class]
  if not data then return nil end
  local index = { spells = {}, nodes = {}, entries = {}, names = {}, resolvedNames = {} }
  for _, list in ipairs({data.talents, data.spells}) do
    for _, entry in ipairs(list) do
      index.spells[entry.spellID] = entry
      if entry.nodeID then index.nodes[entry.nodeID] = entry end
      index.entries[#index.entries + 1] = entry
    end
  end
  indices[class] = index
  return index
end

function Tags.ForSpell(class, id)
  local index = indexClass(class)
  if not index or type(id) ~= "number" then return nil end
  if index.spells[id] then return index.spells[id] end

  -- Resolve additional ranks with the game's localized names, never research text.
  local name = spellName(id)
  if not name then return nil end
  for _, entry in ipairs(index.entries) do
    if not index.resolvedNames[entry.spellID] then
      local localized = spellName(entry.spellID)
      if localized then
        local previous = index.names[localized]
        if previous == false or (previous and previous.tag ~= entry.tag) then
          index.names[localized] = false
        else
          index.names[localized] = entry
        end
        index.resolvedNames[entry.spellID] = true
      end
    end
  end
  return index.names[name] or nil
end

function Tags.ForNode(class, nodeID)
  local index = indexClass(class)
  return index and index.nodes[nodeID]
end

local function tooltip(display)
  local entry = display.entry
  if not entry or not GameTooltip or (SAK.DisplayEnabled and not SAK.DisplayEnabled("text")) then return end
  local spec = labels[entry.tag]
  GameTooltip:SetOwner(display, "ANCHOR_RIGHT")
  GameTooltip:AddLine(spellName(entry.spellID) or entry.name, 1, 0.82, 0.05)
  GameTooltip:AddLine(spec.text .. " — " .. spec.description, spec.color[1], spec.color[2], spec.color[3], true)
  GameTooltip:AddLine(entry.reason, 1, 1, 1, true)
  GameTooltip:AddLine(L("Repère d’usage, pas une obligation de talent ou d’achat."), 0.8, 0.8, 0.8, true)
  GameTooltip:Show()
end

local function createBadge()
  local display = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  display:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  display:SetBackdropColor(0.025, 0.02, 0.015, 0.95)
  display:SetBackdropBorderColor(0.8, 0.63, 0.25, 1)
  display.text = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  display.text:SetAllPoints(display)
  display:EnableMouse(true)
  display:SetScript("OnEnter", tooltip)
  display:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  display:SetScript("OnHide", function(self)
    if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() == self then GameTooltip:Hide() end
  end)
  return display
end

Tags.CreateBadge = createBadge

local strataOrder = { BACKGROUND=1, LOW=2, MEDIUM=3, HIGH=4, DIALOG=5, FULLSCREEN=6, FULLSCREEN_DIALOG=7, TOOLTIP=8 }
local function prepare(display, owner, entry)
  local spec = labels[entry.tag]
  local level, strata, current = 0, "HIGH", owner
  for _ = 1, 16 do
    if not current then break end
    if current.GetFrameLevel then level = math.max(level, current:GetFrameLevel()) end
    local candidate = current.GetFrameStrata and current:GetFrameStrata()
    if strataOrder[candidate] and strataOrder[candidate] > strataOrder[strata] then strata = candidate end
    current = current.GetParent and current:GetParent()
  end
  display:SetFrameStrata(strata)
  display:SetFrameLevel(math.min(level + 30, 65535))
  if owner.GetEffectiveScale and UIParent.GetEffectiveScale then
    display:SetScale(owner:GetEffectiveScale() / UIParent:GetEffectiveScale())
  end
  display.entry = entry
  display:SetSize(spec.width, 15)
  display.text:SetText(spec.text)
  display.text:SetTextColor(spec.color[1], spec.color[2], spec.color[3])
end

Tags.PrepareBadge = prepare

function Tags.BadgeWidth(kind)
  return labels[kind] and labels[kind].width or 0
end

function Tags.HideTrainer(row)
  local display = trainerDisplays[row]
  if display then
    display.entry = nil
    display:Hide()
  end
end

function Tags.PaintTrainer(row, service)
  local _, class = UnitClass("player")
  local entry = service and service.serviceType == "available" and Tags.ForSpell(class, service.spellID)
  if not entry or not enabled("iconsTrainer") or not visible(row) then
    Tags.HideTrainer(row)
    return
  end
  local display = trainerDisplays[row]
  if not display then
    display = createBadge()
    trainerDisplays[row] = display
  end
  prepare(display, row, entry)
  local anchor = row.sakTrainerAdvice
  if not visible(anchor) then anchor = row.sakTrainerBadge end
  display:ClearAllPoints()
  if visible(anchor) then
    display:SetPoint("LEFT", anchor, "RIGHT", 2, 0)
  else
    display:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -2)
  end
  display:Show()
end

local function nodeSpell(nodeID)
  if not C_Traits or not C_ClassTalents or not C_ClassTalents.GetActiveConfigID then return nil end
  local config = C_ClassTalents.GetActiveConfigID()
  if not config or not C_Traits.GetNodeInfo or not C_Traits.GetEntryInfo or not C_Traits.GetDefinitionInfo then return nil end
  nodeSpells[config] = nodeSpells[config] or {}
  if nodeSpells[config][nodeID] ~= nil then return nodeSpells[config][nodeID] or nil end
  local info = C_Traits.GetNodeInfo(config, nodeID)
  if not info then return nil end
  local entryID = info.activeEntry and info.activeEntry.entryID
  if not entryID and info.entryIDs and #info.entryIDs == 1 then entryID = info.entryIDs[1] end
  local entry = entryID and C_Traits.GetEntryInfo(config, entryID)
  local definition = entry and entry.definitionID and C_Traits.GetDefinitionInfo(entry.definitionID)
  local id = definition and definition.spellID
  if id then nodeSpells[config][nodeID] = id end
  return id
end

local function talentEntry(button, class)
  local nodeID = button.GetNodeID and button:GetNodeID() or button.nodeID
  if type(nodeID) == "number" and nodeID > 0 then
    local ok, id = pcall(nodeSpell, nodeID)
    if ok and id then return Tags.ForSpell(class, id) end
    return Tags.ForNode(class, nodeID)
  end
  local data = button.GetElementData and button:GetElementData() or button.talentInfo
  local id = button.spellID or (button.GetSpellID and button:GetSpellID())
  if not id and type(data) == "table" then
    id = data.spellID
    if not id and type(data.nodeID) == "number" then
      local ok, resolved = pcall(nodeSpell, data.nodeID)
      if ok and resolved then return Tags.ForSpell(class, resolved) end
      return Tags.ForNode(class, data.nodeID)
    end
  end
  if type(id) == "number" then return Tags.ForSpell(class, id) end
end

local function iconFor(button)
  local icon = button.Icon or button.icon
  if type(icon) == "table" or type(icon) == "userdata" then return icon end
  return button
end

local function positionTalentBadge(display, button)
  local icon = iconFor(button)
  local width = icon.GetWidth and icon:GetWidth()
  if not width or width <= 0 then
    width = button.GetWidth and button:GetWidth()
  end
  if not width or width <= 0 then
    width = 40
  end
  if icon.GetEffectiveScale and button.GetEffectiveScale then
    width = width * icon:GetEffectiveScale() / button:GetEffectiveScale()
  end

  display:SetSize(width, math.max(11, math.min(15, width * 0.3)))
  display:ClearAllPoints()
  display:SetPoint("TOP", icon, "BOTTOM", 0, 0)

  -- Fit the full label inside the icon width without wrapping or truncating it.
  if not display.baseFont then
    display.baseFont, display.baseFontSize, display.fontFlags = display.text:GetFont()
  end
  display.text:SetFont(display.baseFont, display.baseFontSize, display.fontFlags)
  display.text:SetWordWrap(false)
  display.text:SetNonSpaceWrap(false)
  local textWidth = display.text:GetStringWidth()
  if textWidth > width - 6 then
    local size = math.max(6, display.baseFontSize * (width - 6) / textWidth)
    display.text:SetFont(display.baseFont, size, display.fontFlags)
  end
end

function Tags.RefreshTalents()
  talentStats.visited, talentStats.matched = 0, 0
  local root = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
  if not visible(root) or not enabled("iconsTalents") then
    for _, display in pairs(talentDisplays) do display:Hide() end
    return
  end
  local seen = {}
  local seenSpells = {}
  local _, class = UnitClass("player")
  local visited = 0
  local function visit(button, depth)
    if depth > 10 or visited >= 1000 or not visible(button) or (button.IsForbidden and button:IsForbidden()) then return end
    visited = visited + 1
    talentStats.visited = visited
    local ok, entry = pcall(talentEntry, button, class)
    if not ok then entry = nil end
    if entry and not seenSpells[entry.spellID] then
      seenSpells[entry.spellID] = true
      seen[button] = true
      talentStats.matched = talentStats.matched + 1
      local display = talentDisplays[button]
      if not display then
        display = createBadge()
        talentDisplays[button] = display
      end
      prepare(display, button, entry)
      positionTalentBadge(display, button)
      display:Show()
    end
    if button.GetChildren then
      for _, child in ipairs({button:GetChildren()}) do visit(child, depth + 1) end
    end
  end
  visit(root, 0)
  for button, display in pairs(talentDisplays) do
    if not seen[button] then display:Hide() end
  end
end

function Tags.Refresh()
  Tags.RefreshTalents()
  for row, display in pairs(trainerDisplays) do
    if display.entry and enabled("iconsTrainer") and visible(row) then
      display:Show()
    else
      display:Hide()
    end
  end
end

function Tags.Initialize()
  if driver then return end
  elapsed = 0
  driver = CreateFrame("Frame")
  driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.3 then
      elapsed = 0
      Tags.Refresh()
    end
  end)
end

function Tags.MarkDirty()
  nodeSpells = {}
end

function Tags.GetDiagnostics()
  local trainerShown = 0
  for _, display in pairs(trainerDisplays) do
    if visible(display) then trainerShown = trainerShown + 1 end
  end
  return { visited = talentStats.visited, matched = talentStats.matched, trainerShown = trainerShown }
end

if SAK.Localization then
  SAK.Localization.RegisterTable(labels)
end
