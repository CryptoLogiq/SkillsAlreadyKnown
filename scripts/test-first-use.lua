-- Run: lua scripts/test-first-use.lua
local root = arg[1] or "."
local class, level, points, legacy = "MAGE", 25, {0, 12, 3}, false
UnitClass = function() return class, class end
UnitLevel = function() return level end
GetActiveTalentGroup = function() return 2 end
GetTalentTabInfo = function(index, inspect, pet, group)
  assert(inspect == false and pet == false and group == 2)
  if legacy then return "Tree", "icon", points[index] end
  return index, "Tree", 12345, "background", points[index]
end
for _, file in ipairs({"Core.lua", "data/ClassRoles.lua", "data/LevelingRecommendations.lua",
  "data/TalentSummaries.lua", "PlayerRoles.lua", "TalentTooltips.lua", "RankPolicy.lua", "Settings.lua"}) do
  assert(loadfile(root .. "/" .. file))()
end
local s = SkillsAlreadyKnown
local function reset(nextClass, nextLevel, nextPoints)
  SkillsAlreadyKnownDB = nil
  class, level, points = nextClass, nextLevel, nextPoints
end
local function selected(role, spec)
  assert(s.PlayerRoles.InitializeFirstUse())
  assert(s.PlayerRoles.IsSelectionRoleEnabled(role))
  assert(not s.PlayerRoles.GetProfile() and not s.PlayerRoles.IsRoleEnabled(role))
  assert(s.PlayerRoles.SelectionSpec(role) == spec)
  assert(not s.EnsureDB().profilePromptSeen)
end
selected("dps", "fire")
assert(s.EnsureDB().levelingDraft.initialSuggestion == "talents")
points = {20, 0, 0}
assert(not s.PlayerRoles.InitializeFirstUse())
assert(s.PlayerRoles.SelectionSpec("dps") == "fire")
reset("MAGE", 9, {30, 0, 0}); selected("dps", "frost")
reset("MAGE", 25, {5, 5, 0}); selected("dps", "frost")
reset("PALADIN", 25, {12, 0, 0}); selected("heal", "holy")
reset("PALADIN", 25, {0, 12, 0}); selected("tank", "protection")
reset("DRUID", 25, {0, 12, 0}); selected("dps", "feral")
legacy = true
reset("WARLOCK", 25, {0, 0, 12}); selected("dps", "destruction")
legacy = false
reset("MAGE", 25, {nil, nil, nil}); selected("dps", "frost")
reset("MAGE", 25, {0, 0, 0})
s.EnsureDB().profilePromptSeen = true
assert(s.PlayerRoles.InitializeFirstUse())
reset("MAGE", 25, {0, 12, 0})
local opens = 0
s.Settings.Open = function(firstUse)
  assert(firstUse and s.PlayerRoles.SelectionSpec("dps") == "fire")
  opens = opens + 1
end
s.RankPolicy.MaybePrompt()
s.RankPolicy.MaybePrompt()
assert(opens == 1)
assert(s.PlayerRoles.ConfirmSelection(s.PlayerRoles.SelectionSnapshot()))
s.RankPolicy.MaybePrompt()
assert(opens == 1)
local options = s.Settings.Options()
local groups = options.args.spellbook.args.summaries.args
for index, tree in ipairs(s.ClassRoles.classes.MAGE.talentTrees) do
  local group = groups["tree" .. index]
  assert(group.name == tree.name)
  for _, spec in ipairs(tree.specs) do
    local text = group.args[spec].name()
    local summary = s.TalentSummaries.MAGE[spec]
    assert(text:find(summary.summary, 1, true))
    assert(text:find(summary.advantages[1], 1, true))
    assert(text:find(summary.drawbacks[1], 1, true))
  end
end
print("PASS: dominant active tree, old/Forever APIs, under-10 leveling, ties, missing data, hybrid roles, saved choices, one-time prompt and all three shared summaries")
