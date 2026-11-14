-- Presentation des roles, conseils de leveling et resumes des talents.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local TalentTooltips = {}
SAK.TalentTooltips = TalentTooltips

function TalentTooltips.TreeNames(class)
  local data = SAK.ClassRoles.classes[class]
  local names = {}
  if not data then return names end
  local function add(name, tree, index)
    if type(name) == "string" and name ~= "" then
      names[SAK.NormalizeText(SAK.CleanText(name))] = { tree = tree, index = index }
    end
  end
  for index, tree in ipairs(data.talentTrees) do
    add(tree.name, tree, index)
    if SAK.Localization then
      for _, name in ipairs(SAK.Localization.NameVariants(tree.name)) do add(name, tree, index) end
    end
    if GetTalentTabInfo then
      local ok, first, second = pcall(GetTalentTabInfo, index)
      if ok then add(type(first) == "string" and first or second, tree, index) end
    end
  end
  return names
end

function TalentTooltips.IsLevelingTree(class, specs)
  local advice = SAK.LevelingRecommendations and SAK.LevelingRecommendations[class]
  local preferred = advice and advice.solo[1]
  for _, spec in ipairs(specs or {}) do
    if spec == preferred then return true end
  end
  return false
end

local function addRoles(tooltip, roles)
  for _, role in ipairs(roles) do
    local entry = SAK.ClassRoles.roles[role]
    tooltip:AddLine(entry.name .. " — " .. entry.description, 1, 1, 1, true)
  end
end

local function addLevelingAdvice(tooltip, class, specs)
  if not TalentTooltips.IsLevelingTree(class, specs) then
    return
  end
  tooltip:AddLine(" ")
  tooltip:AddLine(L("[LEVELING] — choix conseillé pour progresser en solo"), 1, 0.82, 0.05, true)
end

local function addSummary(tooltip, summary)
  tooltip:AddLine(summary.summary, 1, 1, 1, true)
  tooltip:AddLine(L("Avantages"), 0.3, 1, 0.3)
  for _, text in ipairs(summary.advantages) do
    tooltip:AddLine("- " .. text, 0.85, 0.95, 0.85, true)
  end

  tooltip:AddLine(L("Inconvénients"), 1, 0.45, 0.35)
  for _, text in ipairs(summary.drawbacks) do
    tooltip:AddLine("- " .. text, 0.95, 0.85, 0.85, true)
  end
end

local function addSpecializations(tooltip, owner)
  local summaries = SAK.TalentSummaries and SAK.TalentSummaries[owner.class]
  for _, spec in ipairs(owner.specs) do
    local summary = summaries and summaries[spec]
    if summary then
      tooltip:AddLine(" ")
      if #owner.specs > 1 then
        local label = SAK.ClassRoles.classes[owner.class].specializations[spec]
        tooltip:AddLine(label, 1, 0.82, 0.05)
      end
      addSummary(tooltip, summary)
    end
  end
end

function TalentTooltips.Show(owner)
  if not GameTooltip then
    return
  end

  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  GameTooltip:AddLine(owner.treeName, 1, 0.82, 0.05)
  addRoles(GameTooltip, owner.roles)
  addLevelingAdvice(GameTooltip, owner.class, owner.specs)
  addSpecializations(GameTooltip, owner)
  GameTooltip:Show()
end

function TalentTooltips.Hide()
  if GameTooltip then
    GameTooltip:Hide()
  end
end

function TalentTooltips.SpecializationText(class, spec)
  local summary = SAK.TalentSummaries and SAK.TalentSummaries[class]
  summary = summary and summary[spec]
  if not summary then
    return ""
  end

  local lines = {}
  if TalentTooltips.IsLevelingTree(class, { spec }) then
    lines[#lines + 1] = L("|cffffd100[LEVELING] — choix conseillé pour progresser en solo|r")
    lines[#lines + 1] = ""
  end
  lines[#lines + 1] = summary.summary
  lines[#lines + 1] = ""
  lines[#lines + 1] = L("|cff4dff4dAvantages|r")
  for _, text in ipairs(summary.advantages) do
    lines[#lines + 1] = "- " .. text
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = L("|cffff7359Inconvénients|r")
  for _, text in ipairs(summary.drawbacks) do
    lines[#lines + 1] = "- " .. text
  end
  return table.concat(lines, "\n")
end

function TalentTooltips.AddTreeSummary(tooltip, class, tree)
  tooltip:AddLine(" ")
  tooltip:AddLine("Skills & More", 1, 0.82, 0.05)
  addLevelingAdvice(tooltip, class, tree.specs)
  addSpecializations(tooltip, { class = class, specs = tree.specs })
end
