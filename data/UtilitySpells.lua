-- Only reviewed interruption/forced-attack/explicit threat effects; not all damage generates AGGRO badges.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
SAK.UtilitySpells = {
  DRUID = {
    [16979] = {
      spellID = 16979, name = "Feral Charge (Bear)", exactOnly = true,
      tag = "kick", tags = { "kick" },
      reason = L("UTILITY_BEAR_KICK"),
      source = "https://www.wowhead.com/forever/spell=16979", reviewed = "2026-11-15",
    },
    [6795] = {
      spellID = 6795, name = "Growl",
      tag = "taunt", tags = { "taunt" },
      reason = L("UTILITY_TAUNT"),
      source = "https://www.wowhead.com/forever/spell=6795", reviewed = "2026-11-15",
    },
    [5209] = {
      spellID = 5209, name = "Challenging Roar",
      tag = "taunt", tags = { "taunt" },
      reason = L("UTILITY_FORCED_ATTACK"),
      source = "https://www.wowhead.com/forever/spell=5209", reviewed = "2026-11-15",
    },
  },
  HUNTER = {
    [20736] = {
      spellID = 20736, name = "Distracting Shot",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=20736", reviewed = "2026-11-15",
    },
    [2649] = {
      spellID = 2649, name = "Growl (pet)",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_PET_THREAT"),
      source = "https://www.wowhead.com/forever/spell=2649", reviewed = "2026-11-15",
    },
  },
  MAGE = {
    [2139] = {
      spellID = 2139, name = "Counterspell",
      tag = "kick", tags = { "kick", "aggro" },
      reason = L("UTILITY_KICK_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=2139", reviewed = "2026-11-15",
    },
  },
  PALADIN = {
    [20163] = {
      spellID = 20163, name = "Seal of Fury",
      tag = "taunt", tags = { "taunt" },
      reason = L("UTILITY_SEAL_TAUNT"),
      source = "https://www.wowhead.com/forever/spell=20163", reviewed = "2026-11-15",
    },
    [25780] = {
      spellID = 25780, name = "Righteous Fury",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_THREAT_BUFF"),
      source = "https://www.wowhead.com/forever/spell=25780", reviewed = "2026-11-15",
    },
  },
  PRIEST = {
  },
  ROGUE = {
    [1766] = {
      spellID = 1766, name = "Kick",
      tag = "kick", tags = { "kick" },
      reason = L("UTILITY_KICK"),
      source = "https://www.wowhead.com/forever/spell=1766", reviewed = "2026-11-15",
    },
  },
  SHAMAN = {
    [8042] = {
      spellID = 8042, name = "Earth Shock",
      tag = "kick", tags = { "kick", "aggro" },
      reason = L("UTILITY_KICK_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=8042", reviewed = "2026-11-15",
    },
    [5730] = {
      spellID = 5730, name = "Stoneclaw Totem",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_TOTEM_THREAT"),
      source = "https://www.wowhead.com/forever/spell=5730", reviewed = "2026-11-15",
    },
  },
  WARLOCK = {
    [19244] = {
      spellID = 19244, name = "Spell Lock",
      tag = "kick", tags = { "kick" },
      reason = L("UTILITY_PET_KICK"),
      source = "https://www.wowhead.com/forever/spell=19244", reviewed = "2026-11-15",
    },
    [3716] = {
      spellID = 3716, name = "Torment",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_PET_THREAT"),
      source = "https://www.wowhead.com/forever/spell=3716", reviewed = "2026-11-15",
    },
    [5676] = {
      spellID = 5676, name = "Searing Pain",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=5676", reviewed = "2026-11-15",
    },
  },
  WARRIOR = {
    [71] = {
      spellID = 71, name = "Defensive Stance", tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_DEFENSIVE_THREAT"),
      source = "https://www.wowhead.com/forever/spell=71/defensive-stance", reviewed = "2026-11-15",
    },
    [6552] = {
      spellID = 6552, name = "Pummel",
      tag = "kick", tags = { "kick" },
      reason = L("UTILITY_KICK"),
      source = "https://www.wowhead.com/forever/spell=6552", reviewed = "2026-11-15",
    },
    [72] = {
      spellID = 72, name = "Shield Bash",
      tag = "kick", tags = { "kick" },
      reason = L("UTILITY_SHIELD_KICK"),
      source = "https://www.wowhead.com/forever/spell=72", reviewed = "2026-11-15",
    },
    [355] = {
      spellID = 355, name = "Taunt",
      tag = "taunt", tags = { "taunt" },
      reason = L("UTILITY_TAUNT"),
      source = "https://www.wowhead.com/forever/spell=355", reviewed = "2026-11-15",
    },
    [694] = {
      spellID = 694, name = "Mocking Blow",
      tag = "taunt", tags = { "taunt", "aggro" },
      reason = L("UTILITY_FORCED_THREAT"),
      source = "https://www.wowhead.com/forever/spell=694", reviewed = "2026-11-15",
    },
    [1161] = {
      spellID = 1161, name = "Challenging Shout",
      tag = "taunt", tags = { "taunt" },
      reason = L("UTILITY_FORCED_ATTACK"),
      source = "https://www.wowhead.com/forever/spell=1161", reviewed = "2026-11-15",
    },
    [78] = {
      spellID = 78, name = "Heroic Strike",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=78", reviewed = "2026-11-15",
    },
    [6572] = {
      spellID = 6572, name = "Revenge",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=6572", reviewed = "2026-11-15",
    },
    [7386] = {
      spellID = 7386, name = "Sunder Armor",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=7386", reviewed = "2026-11-15",
    },
    [23924] = {
      spellID = 23924, name = "Shield Slam",
      tag = "aggro", tags = { "aggro" },
      reason = L("UTILITY_AGGRO"),
      source = "https://www.wowhead.com/forever/spell=23924", reviewed = "2026-11-15",
    },
  },
}
if SAK.Localization then SAK.Localization.RegisterTable(SAK.UtilitySpells) end
