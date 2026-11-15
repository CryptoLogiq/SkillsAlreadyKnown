-- Role orientation for reviewed forms, stances and comparable effects.
-- Uses ClassRoles role keys; never changes a player's chosen role or specialization.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
SAK.RoleStances = {
  DRUID = {
    [5487] = {
      spellID = 5487, name = "Bear Form",
      role = "tank", tag = "tank", reason = L("STANCE_BEAR"),
      source = "https://www.wowhead.com/forever/spell=5487", reviewed = "2026-11-15",
    },
    [9634] = {
      spellID = 9634, name = "Dire Bear Form",
      role = "tank", tag = "tank", reason = L("STANCE_BEAR"),
      source = "https://www.wowhead.com/forever/spell=9634", reviewed = "2026-11-15",
    },
    [768] = {
      spellID = 768, name = "Cat Form",
      role = "dps", tag = "dps", reason = L("STANCE_CAT"),
      source = "https://www.wowhead.com/forever/spell=768", reviewed = "2026-11-15",
    },
    [24858] = {
      spellID = 24858, name = "Moonkin Form",
      role = "dps", tag = "dps", reason = L("STANCE_MOONKIN"),
      source = "https://www.wowhead.com/forever/spell=24858", reviewed = "2026-11-15",
    },
  },
  PALADIN = {
    [465] = {
      spellID = 465, name = "Devotion Aura",
      role = "tank", tag = "tank", reason = L("STANCE_DEVOTION"),
      source = "https://www.wowhead.com/forever/spell=465", reviewed = "2026-11-15",
    },
    [7294] = {
      spellID = 7294, name = "Retribution Aura",
      role = "dps", tag = "dps", reason = L("STANCE_RETRIBUTION"),
      source = "https://www.wowhead.com/forever/spell=7294", reviewed = "2026-11-15",
    },
    [19746] = {
      spellID = 19746, name = "Concentration Aura",
      role = "heal", tag = "heal", reason = L("STANCE_CONCENTRATION"),
      tags = { "heal", "dps" },
      source = "https://www.wowhead.com/forever/spell=19746", reviewed = "2026-11-15",
    },
    [25780] = {
      spellID = 25780, name = "Righteous Fury",
      role = "tank", tag = "tank", reason = L("STANCE_RIGHTEOUS_FURY"),
      source = "https://www.wowhead.com/forever/spell=25780", reviewed = "2026-11-15",
    },
    [20163] = {
      spellID = 20163, name = "Seal of Fury",
      role = "tank", tag = "tank", reason = L("STANCE_SEAL_FURY"),
      source = "https://www.wowhead.com/forever/spell=20163", reviewed = "2026-11-15",
    },
  },
  PRIEST = {
    [15473] = {
      spellID = 15473, name = "Shadowform",
      role = "dps", tag = "dps", reason = L("STANCE_SHADOW"),
      source = "https://www.wowhead.com/forever/spell=15473", reviewed = "2026-11-15",
    },
    [20711] = {
      spellID = 20711, name = "Spirit of Redemption",
      role = "heal", tag = "heal", reason = L("STANCE_REDEMPTION"),
      aliases = { 27827 }, exactOnly = true,
      source = "https://www.wowhead.com/forever/spell=20711", reviewed = "2026-11-15",
    },
  },
  WARRIOR = {
    [71] = {
      spellID = 71, name = "Defensive Stance",
      role = "tank", tag = "tank", reason = L("STANCE_DEFENSIVE"),
      source = "https://www.wowhead.com/forever/spell=71", reviewed = "2026-11-15",
    },
    [2457] = {
      spellID = 2457, name = "Battle Stance",
      role = "dps", tag = "dps", reason = L("STANCE_BATTLE"),
      source = "https://www.wowhead.com/forever/spell=2457", reviewed = "2026-11-15",
    },
    [2458] = {
      spellID = 2458, name = "Berserker Stance",
      role = "dps", tag = "dps", reason = L("STANCE_BERSERKER"),
      source = "https://www.wowhead.com/forever/spell=2458", reviewed = "2026-11-15",
    },
  },
}
if SAK.Localization then SAK.Localization.RegisterTable(SAK.RoleStances) end
