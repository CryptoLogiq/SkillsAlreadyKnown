-- Spell-use hints share the existing badge renderer and category switches.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local L = SAK.L or function(key) return key end
local Usage = {}
SAK.SpellUsage = Usage
local displays = setmetatable({}, { __mode = "k" })
local tooltipMarks = setmetatable({}, { __mode = "k" })
local driver
local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end
local function watchDisplays()
  if driver then return end
  driver = CreateFrame("Frame")
  driver:SetScript("OnUpdate", function()
    for owner, display in pairs(displays) do
      if not visible(owner) or not visible(display.anchor) or not SAK.DisplayEnabled("icons")
        or not SAK.DisplayEnabled(display.tag) or not SAK.DisplayEnabled(display.zone) then
        display:Hide()
      end
    end
  end)
end

-- Names returned by the client exclude rank subtext and follow its language.
local function spellName(id)
  for _, api in pairs({ modern = C_Spell and C_Spell.GetSpellName, legacy = GetSpellInfo }) do
    local ok, name = pcall(api, id)
    if ok and type(name) == "string" and name ~= "" then return name end
  end
end

local function baseSpell(id)
  local api = C_Spell and C_Spell.GetBaseSpell or FindBaseSpellByID
  if not api then return id end
  local ok, baseID = pcall(api, id)
  if ok and type(baseID) == "number" and baseID > 0 then return baseID end
  return id
end

local function matchingEntry(catalogue, class, id)
  local entries = catalogue and catalogue[class]
  if not entries then return end
  if entries[id] then return entries[id] end
  local name
  local familyID = baseSpell(id)
  for baseID, entry in pairs(entries) do
    for _, alias in ipairs(entry.aliases or {}) do if alias == id then return entry end end
    if not entry.exactOnly then
      -- Prefer native family IDs; names cover clients without a rank-chain API.
      if familyID == baseSpell(baseID) then return entry end
      for _, alias in ipairs(entry.aliases or {}) do
        if familyID == baseSpell(alias) then return entry end
      end
      name = name or spellName(id)
      if name and spellName(baseID) == name then return entry end
    end
  end
end

function Usage.ForSpell(class, id)
  if type(id) ~= "number" then return end
  local override = SAK.BadgeRules and SAK.BadgeRules.Resolve(class, id, "usage")
  if override == "none" then return end
  if override then
    return { spellID = id, tag = override, name = SAK.BadgeRules.SpellName(id), reason = SAK.BadgeRules.Reason() }
  end
  local found = {}
  for _, catalogue in ipairs({ SAK.ClassSkills or {}, SAK.SurvivalAdvice or {}, SAK.AreaSpells or {}, SAK.AreaTalents or {}, SAK.UtilitySpells or {}, SAK.RoleStances or {} }) do
    local entry = matchingEntry(catalogue, class, id)
    if entry then found[#found + 1] = entry end
  end
  if #found == 0 then return end
  if #found == 1 then return found[1] end
  -- Combine independent uses, keeping the maintained tables immutable.
  local result, tags, seen, reasons = {}, {}, {}, {}
  for _, entry in ipairs(found) do
    for key, value in pairs(entry) do if result[key] == nil then result[key] = value end end
    for _, tag in ipairs(entry.tags or { entry.tag }) do
      if not seen[tag] then tags[#tags + 1] = tag; seen[tag] = true end
    end
    if entry.reason then reasons[#reasons + 1] = entry.reason end
  end
  if #tags == 1 and not result.role then return found[1] end
  result.tags, result.reason = tags, table.concat(reasons, " ")
  return result
end

-- A spell can explicitly interrupt AND generate threat; category toggles are independent.
function Usage.ForDisplay(class, id)
  local entry = Usage.ForSpell(class, id)
  if not entry then return end
  local tags = {}
  for _, tag in ipairs(entry.tags or { entry.tag }) do
    if SAK.DisplayEnabled(tag) then tags[#tags + 1] = tag end
  end
  if #tags == 0 then return end
  if #tags == 1 and tags[1] == entry.tag and not entry.tags then return entry end
  local result = {}
  for key, value in pairs(entry) do result[key] = value end
  result.tag, result.tags = tags[1], tags
  local labels, width = {}, 0
  for _, tag in ipairs(tags) do
    labels[#labels + 1] = tag:upper()
    width = width + SAK.ContentTags.BadgeWidth(tag)
  end
  result.badgeText, result.width = table.concat(labels, " / "), width + (#tags - 1) * 8
  return result
end

function Usage.ForTalent(class, id, nodeID)
  if id and SAK.BadgeRules and SAK.BadgeRules.Resolve(class,id,"usage") ~= nil then
    return Usage.ForSpell(class,id)
  end
  for _, catalogue in ipairs({ SAK.AreaTalents or {}, SAK.SurvivalAdvice or {} }) do
    for spellID, entry in pairs(catalogue[class] or {}) do
      if spellID == id or (nodeID and entry.nodeID == nodeID) then
        if SAK.BadgeRules and SAK.BadgeRules.Resolve(class,spellID,"usage") ~= nil then return Usage.ForSpell(class,spellID) end
        return entry
      end
    end
  end
  return id and Usage.ForSpell(class, id)
end

function Usage.EssentialSkill(class, family)
  for id in pairs(family.ids) do
    local entry = Usage.ForSpell(class, id)
    if entry and entry.tag == "class" then return entry end
  end
end

function Usage.ProtectPurchase(class, family, rank)
  for id in pairs(family.ids) do
    local entry = Usage.ForSpell(class, id)
    if entry and (entry.tag == "aoe" or entry.tag == "class" or (entry.tag == "survival" and rank == 1)) then return true end
  end
  return false
end

function Usage.Paint(owner, anchor, id, zone, offset)
  if not owner then return end
  local display = displays[owner]
  local _, class = UnitClass("player")
  local entry = id and Usage.ForDisplay(class, id)
  if not SAK.DisplayEnabled("icons") or not SAK.DisplayEnabled(zone)
    or (entry and not SAK.DisplayEnabled(entry.tag)) then entry = nil end
  if not entry or not SAK.ContentTags or not visible(owner) or not visible(anchor) then
    if display then display:Hide() end
    return
  end
  if not display then display = SAK.ContentTags.CreateBadge(); displays[owner] = display end
  watchDisplays()
  display.anchor, display.zone, display.tag = anchor, zone, entry.tag
  SAK.ContentTags.PrepareBadge(display, owner, entry)
  display:ClearAllPoints()
  if zone == "iconsSpellbook" then
    -- Compensate for transparent rank-texture padding so the labels touch visually.
    display:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, -6)
  else
    display:SetPoint("LEFT", anchor, "RIGHT", offset or 2, 0)
  end
  display:Show()
end

local requestedSpells = {}
local function nativeSpellText(id)
  local api = C_Spell and C_Spell.GetSpellDescription or GetSpellDescription
  if api then
    local ok, text = pcall(api, id)
    if ok and type(text) == "string" and text ~= "" then return text end
  end
end

function Usage.AddRelatedSpells(tooltip, entry)
  if not entry or entry.tag ~= "aoe" or not entry.relatedSpells then return end
  tooltip:AddLine(L("AOE_RELATED_HEADER"), 1, 0.82, 0.05, true)
  for _, id in ipairs(entry.relatedSpells) do
    local name = spellName(id)
    local texture = SAK.SpellTexture and SAK.SpellTexture(id)
    local description = nativeSpellText(id)
    if (not name or not description) and not requestedSpells[id]
      and C_Spell and C_Spell.RequestLoadSpellData then
      requestedSpells[id] = true
      C_Spell.RequestLoadSpellData(id)
    end
    name = name or string.format(L("AOE_RELATED_UNKNOWN"), id)
    local subtext = C_Spell and C_Spell.GetSpellSubtext or GetSpellSubtext
    if subtext then
      local ok, rank = pcall(subtext, id)
      if ok and type(rank) == "string" and rank ~= "" then name = name .. " (" .. rank .. ")" end
    end
    local icon = texture and string.format("|T%s:18:18:0:0|t ", texture) or ""
    tooltip:AddLine(icon .. name, 1, 1, 1, true)
    tooltip:AddLine(description or L("AOE_RELATED_PENDING"), 0.8, 0.85, 0.9, true)
  end
end

function Usage.AddTooltip(tooltip, id)
  if not tooltip or not tooltip.AddLine or not SAK.DisplayEnabled("text") then return end
  local _, class = UnitClass("player")
  local entry = Usage.ForDisplay(class, id)
  if entry and SAK.DisplayEnabled(entry.tag) and tooltipMarks[tooltip] ~= id then
    if tooltipMarks[tooltip] == nil and tooltip.HookScript then
      tooltip:HookScript("OnTooltipCleared", function(self) tooltipMarks[self] = false end)
    end
    tooltipMarks[tooltip] = id
    local label = entry.badgeText or entry.tag:upper()
    tooltip:AddLine(label .. " — " .. entry.reason, 0.4, 1, 0.85, true)
    Usage.AddRelatedSpells(tooltip, entry)
  end
end
