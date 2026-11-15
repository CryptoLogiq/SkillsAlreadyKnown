-- Tooltip recommendations stay separate from usage badges and purchase policy.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local L = SAK.L or function(key) return key end
local Advice = {}
SAK.TalentAdvice = Advice
local marks = setmetatable({}, { __mode = "k" })

local function nativeName(id)
  local api = C_Spell and C_Spell.GetSpellName or GetSpellInfo
  if not api then return end
  local ok, name = pcall(api, id)
  if ok and type(name) == "string" and name ~= "" then return name end
end

local function verified(entry)
  if not entry or entry.basis ~= "theorycraft-build" then return false end
  for _, choice in ipairs(entry.choices or {}) do
    if not choice.source or not choice.author or not choice.section or not choice.reviewed or not choice.build then return false end
  end
  return #entry.choices > 0
end

function Advice.Find(class, id, nodeID)
  local catalogue = SAK.TalentRecommendations
  local entries = catalogue and catalogue.classes[class]
  if not entries then return end
  if verified(entries[id]) then return entries[id] end
  local name = id and nativeName(id)
  for baseID, entry in pairs(entries) do
    if verified(entry) and ((nodeID and entry.nodeID == nodeID) or (name and nativeName(baseID) == name)) then
      return entry
    end
  end
end

local function specIcon(data, spec)
  for _, tree in ipairs(data.talentTrees) do
    for _, key in ipairs(tree.specs) do
      if key == spec then return tree.icon end
    end
  end
end

local function supported(data, choice)
  for _, spec in ipairs(data.roles[choice.role] or {}) do
    if spec == choice.spec then return true end
  end
  return false
end

function Advice.Labels(class, entry)
  local data = SAK.ClassRoles and SAK.ClassRoles.classes[class]
  if not data then return {} end
  local roleCount = 0
  for _ in pairs(data.roles) do roleCount = roleCount + 1 end
  local icons = not SAK.DisplayEnabled or SAK.DisplayEnabled("icons")
  local roleLabels = SAK.PlayerRoles and SAK.PlayerRoles.RoleLabels()
  local labels, seen = {}, {}
  for _, choice in ipairs(entry.choices) do
    if supported(data, choice) and not seen[choice.spec] then
      seen[choice.spec] = true
      local label = data.specializations[choice.spec]
      local icon = icons and specIcon(data, choice.spec)
      if icon then label = "|T" .. icon .. ":18:18|t " .. label end
      if roleCount > 1 then
        local role = roleLabels and roleLabels[choice.role] or SAK.ClassRoles.roles[choice.role].name
        if not icons then role = role:gsub("|T.-|t%s*", "") end
        label = role .. " — " .. label
      end
      label = label .. " (" .. L(choice.build) .. ")"
      labels[#labels + 1] = label
    end
  end
  return labels
end

function Advice.AddTooltip(tooltip, id, nodeID)
  if not tooltip or not tooltip.AddLine then return end
  if SAK.DisplayEnabled and (not SAK.DisplayEnabled("text") or not SAK.DisplayEnabled("iconsTalents")) then return end
  local _, class = UnitClass("player")
  local entry = Advice.Find(class, id, nodeID)
  if not entry or marks[tooltip] == entry then return end
  local labels = Advice.Labels(class, entry)
  if #labels == 0 then return end
  if marks[tooltip] == nil and tooltip.HookScript then
    tooltip:HookScript("OnTooltipCleared", function(self) marks[self] = false end)
  end
  marks[tooltip] = entry
  tooltip:AddLine(string.format(L("TALENT_ADVICE_RECOMMENDED"), table.concat(labels, " / ")), 0.45, 1, 0.6, true)
  if entry.context then tooltip:AddLine(L(entry.context), 0.8, 0.85, 0.9, true) end
end
