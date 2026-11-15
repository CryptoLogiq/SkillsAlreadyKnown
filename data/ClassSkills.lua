-- Core class utility is separate from the value of buying later ranks.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
SAK.ClassSkills = {
  WARLOCK = {
    [1120] = {
      spellID = 1120,
      name = "Drain Soul",
      tag = "class",
      rankOneUtility = true,
      reason = L("CLASS_DRAIN_SOUL"),
    },
  },
}
if SAK.Localization then SAK.Localization.RegisterTable(SAK.ClassSkills) end
