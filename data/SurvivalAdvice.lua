-- Reviewed survival tools: mitigation, immunity, escape, defensive control and emergency sustain.
-- Family markers do not claim rank 1 is sufficient or guarantee survival.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
SAK.SurvivalAdvice = {
  DRUID = {
    [339] = {
      spellID = 339, name = "Entangling Roots", tag = "survival",
      reason = L("SURVIVAL_DRUID_339"),
      source = "https://www.wowhead.com/forever/spell=339", reviewed = "2026-11-15",
    },
    [5211] = {
      spellID = 5211, name = "Bash", tag = "survival",
      reason = L("SURVIVAL_DRUID_5211"),
      source = "https://www.wowhead.com/forever/spell=5211", reviewed = "2026-11-15",
    },
    [1850] = {
      spellID = 1850, name = "Dash", tag = "survival",
      reason = L("SURVIVAL_DRUID_1850"),
      source = "https://www.wowhead.com/forever/spell=1850", reviewed = "2026-11-15",
    },
    [16689] = {
      spellID = 16689, name = "Nature's Grasp", tag = "survival",
      reason = L("SURVIVAL_DRUID_16689"),
      source = "https://www.wowhead.com/forever/spell=16689", reviewed = "2026-11-15",
    },
    [2893] = {
      spellID = 2893, name = "Abolish Poison", tag = "survival",
      reason = L("SURVIVAL_DRUID_2893"),
      source = "https://www.wowhead.com/forever/spell=2893", reviewed = "2026-11-15",
    },
    [22812] = {
      spellID = 22812, name = "Barkskin", tag = "survival",
      reason = L("SURVIVAL_DRUID_22812"),
      source = "https://www.wowhead.com/forever/spell=22812", reviewed = "2026-11-15",
    },
    [22842] = {
      spellID = 22842, name = "Frenzied Regeneration", tag = "survival",
      reason = L("SURVIVAL_DRUID_22842"),
      source = "https://www.wowhead.com/forever/spell=22842", reviewed = "2026-11-15",
    },
  },
  HUNTER = {
    [13163] = {
      spellID = 13163, name = "Aspect of the Monkey", tag = "survival",
      reason = L("SURVIVAL_HUNTER_13163"),
      source = "https://www.wowhead.com/forever/spell=13163", reviewed = "2026-11-15",
    },
    [5384] = {
      spellID = 5384, name = "Feign Death", tag = "survival",
      reason = L("SURVIVAL_HUNTER_5384"),
      source = "https://www.wowhead.com/forever/spell=5384", reviewed = "2026-11-15",
    },
    [781] = {
      spellID = 781, name = "Disengage", tag = "survival",
      reason = L("SURVIVAL_HUNTER_781"),
      source = "https://www.wowhead.com/forever/spell=781", reviewed = "2026-11-15",
    },
    [19263] = {
      spellID = 19263, name = "Deterrence", tag = "survival",
      reason = L("SURVIVAL_HUNTER_19263"),
      nodeID = 104986,
      source = "https://www.wowhead.com/forever/spell=19263", reviewed = "2026-11-15",
    },
    [1499] = {
      spellID = 1499, name = "Freezing Trap", tag = "survival",
      reason = L("SURVIVAL_HUNTER_1499"),
      source = "https://www.wowhead.com/forever/spell=1499", reviewed = "2026-11-15",
    },
    [5116] = {
      spellID = 5116, name = "Concussive Shot", tag = "survival",
      reason = L("SURVIVAL_HUNTER_5116"),
      source = "https://www.wowhead.com/forever/spell=5116", reviewed = "2026-11-15",
    },
    [2974] = {
      spellID = 2974, name = "Wing Clip", tag = "survival",
      reason = L("SURVIVAL_HUNTER_2974"),
      source = "https://www.wowhead.com/forever/spell=2974", reviewed = "2026-11-15",
    },
    [13809] = {
      spellID = 13809, name = "Frost Trap", tag = "survival",
      reason = L("SURVIVAL_HUNTER_13809"),
      source = "https://www.wowhead.com/forever/spell=13809", reviewed = "2026-11-15",
    },
  },
  MAGE = {
    [1953] = {
      spellID = 1953, name = "Blink", tag = "survival",
      reason = L("SURVIVAL_MAGE_1953"),
      source = "https://www.wowhead.com/forever/spell=1953", reviewed = "2026-11-15",
    },
    [1463] = {
      spellID = 1463, name = "Mana Shield", tag = "survival",
      reason = L("SURVIVAL_MAGE_1463"),
      source = "https://www.wowhead.com/forever/spell=1463", reviewed = "2026-11-15",
    },
    [130] = {
      spellID = 130, name = "Slow Fall", tag = "survival",
      reason = L("SURVIVAL_MAGE_130"),
      source = "https://www.wowhead.com/forever/spell=130", reviewed = "2026-11-15",
    },
    [122] = {
      spellID = 122, name = "Frost Nova", tag = "survival",
      reason = L("SURVIVAL_MAGE_122"),
      source = "https://www.wowhead.com/forever/spell=122", reviewed = "2026-11-15",
    },
    [11958] = {
      spellID = 11958, name = "Ice Block", tag = "survival",
      reason = L("SURVIVAL_MAGE_11958"),
      nodeID = 105769,
      source = "https://www.wowhead.com/forever/spell=11958", reviewed = "2026-11-15",
    },
    [11426] = {
      spellID = 11426, name = "Ice Barrier", tag = "survival",
      reason = L("SURVIVAL_MAGE_11426"),
      nodeID = 105762,
      source = "https://www.wowhead.com/forever/spell=11426", reviewed = "2026-11-15",
    },
    [543] = {
      spellID = 543, name = "Fire Ward", tag = "survival",
      reason = L("SURVIVAL_MAGE_543"),
      source = "https://www.wowhead.com/forever/spell=543", reviewed = "2026-11-15",
    },
    [6143] = {
      spellID = 6143, name = "Frost Ward", tag = "survival",
      reason = L("SURVIVAL_MAGE_6143"),
      source = "https://www.wowhead.com/forever/spell=6143", reviewed = "2026-11-15",
    },
    [118] = {
      spellID = 118, name = "Polymorph", tag = "survival",
      reason = L("SURVIVAL_MAGE_118"),
      source = "https://www.wowhead.com/forever/spell=118", reviewed = "2026-11-15",
    },
  },
  PALADIN = {
    [633] = {
      spellID = 633, name = "Lay on Hands", tag = "survival",
      reason = L("SURVIVAL_PALADIN_633"),
      source = "https://www.wowhead.com/forever/spell=633", reviewed = "2026-11-15",
    },
    [498] = {
      spellID = 498, name = "Divine Protection", tag = "survival",
      reason = L("SURVIVAL_PALADIN_498"),
      aliases = { 5573 },
      source = "https://www.wowhead.com/forever/spell=498", reviewed = "2026-11-15",
    },
    [642] = {
      spellID = 642, name = "Divine Shield", tag = "survival",
      reason = L("SURVIVAL_PALADIN_642"),
      aliases = { 1020 },
      source = "https://www.wowhead.com/forever/spell=642", reviewed = "2026-11-15",
    },
    [1022] = {
      spellID = 1022, name = "Blessing of Protection", tag = "survival",
      reason = L("SURVIVAL_PALADIN_1022"),
      source = "https://www.wowhead.com/forever/spell=1022", reviewed = "2026-11-15",
    },
    [1044] = {
      spellID = 1044, name = "Blessing of Freedom", tag = "survival",
      reason = L("SURVIVAL_PALADIN_1044"),
      source = "https://www.wowhead.com/forever/spell=1044", reviewed = "2026-11-15",
    },
    [853] = {
      spellID = 853, name = "Hammer of Justice", tag = "survival",
      reason = L("SURVIVAL_PALADIN_853"),
      source = "https://www.wowhead.com/forever/spell=853", reviewed = "2026-11-15",
    },
    [4987] = {
      spellID = 4987, name = "Cleanse", tag = "survival",
      reason = L("SURVIVAL_PALADIN_4987"),
      source = "https://www.wowhead.com/forever/spell=4987", reviewed = "2026-11-15",
    },
  },
  PRIEST = {
    [8122] = {
      spellID = 8122, name = "Psychic Scream", tag = "survival",
      reason = L("SURVIVAL_PRIEST_8122"),
      source = "https://www.wowhead.com/forever/spell=8122", reviewed = "2026-11-15",
    },
    [17] = {
      spellID = 17, name = "Power Word: Shield", tag = "survival",
      reason = L("SURVIVAL_PRIEST_17"),
      source = "https://www.wowhead.com/forever/spell=17", reviewed = "2026-11-15",
    },
    [586] = {
      spellID = 586, name = "Fade", tag = "survival",
      reason = L("SURVIVAL_PRIEST_586"),
      source = "https://www.wowhead.com/forever/spell=586", reviewed = "2026-11-15",
    },
    [6346] = {
      spellID = 6346, name = "Fear Ward", tag = "survival",
      reason = L("SURVIVAL_PRIEST_6346"),
      source = "https://www.wowhead.com/forever/spell=6346", reviewed = "2026-11-15",
    },
  },
  WARLOCK = {
    [755] = {
      spellID = 755, name = "Health Funnel", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_755"),
      source = "https://www.wowhead.com/forever/spell=755", reviewed = "2026-11-15",
    },
    [5782] = {
      spellID = 5782, name = "Fear", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_5782"),
      source = "https://www.wowhead.com/forever/spell=5782", reviewed = "2026-11-15",
    },
    [6789] = {
      spellID = 6789, name = "Death Coil", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_6789"),
      source = "https://www.wowhead.com/forever/spell=6789", reviewed = "2026-11-15",
    },
    [5484] = {
      spellID = 5484, name = "Howl of Terror", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_5484"),
      source = "https://www.wowhead.com/forever/spell=5484", reviewed = "2026-11-15",
    },
    [6229] = {
      spellID = 6229, name = "Shadow Ward", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_6229"),
      source = "https://www.wowhead.com/forever/spell=6229", reviewed = "2026-11-15",
    },
    [6201] = {
      spellID = 6201, name = "Create Healthstone", tag = "survival",
      reason = L("SURVIVAL_WARLOCK_6201"),
      source = "https://www.wowhead.com/forever/spell=6201", reviewed = "2026-11-15",
    },
  },
  ROGUE = {
    [5277] = {
      spellID = 5277, name = "Evasion", tag = "survival",
      reason = L("SURVIVAL_ROGUE_5277"),
      source = "https://www.wowhead.com/forever/spell=5277", reviewed = "2026-11-15",
    },
    [1856] = {
      spellID = 1856, name = "Vanish", tag = "survival",
      reason = L("SURVIVAL_ROGUE_1856"),
      source = "https://www.wowhead.com/forever/spell=1856", reviewed = "2026-11-15",
    },
    [2983] = {
      spellID = 2983, name = "Sprint", tag = "survival",
      reason = L("SURVIVAL_ROGUE_2983"),
      source = "https://www.wowhead.com/forever/spell=2983", reviewed = "2026-11-15",
    },
    [2094] = {
      spellID = 2094, name = "Blind", tag = "survival",
      reason = L("SURVIVAL_ROGUE_2094"),
      source = "https://www.wowhead.com/forever/spell=2094", reviewed = "2026-11-15",
    },
    [1776] = {
      spellID = 1776, name = "Gouge", tag = "survival",
      reason = L("SURVIVAL_ROGUE_1776"),
      source = "https://www.wowhead.com/forever/spell=1776", reviewed = "2026-11-15",
    },
    [1966] = {
      spellID = 1966, name = "Feint", tag = "survival",
      reason = L("SURVIVAL_ROGUE_1966"),
      source = "https://www.wowhead.com/forever/spell=1966", reviewed = "2026-11-15",
    },
  },
  SHAMAN = {
    [5730] = {
      spellID = 5730, name = "Stoneclaw Totem", tag = "survival",
      reason = L("SURVIVAL_SHAMAN_5730"),
      source = "https://www.wowhead.com/forever/spell=5730", reviewed = "2026-11-15",
    },
    [2484] = {
      spellID = 2484, name = "Earthbind Totem", tag = "survival",
      reason = L("SURVIVAL_SHAMAN_2484"),
      source = "https://www.wowhead.com/forever/spell=2484", reviewed = "2026-11-15",
    },
    [8143] = {
      spellID = 8143, name = "Tremor Totem", tag = "survival",
      reason = L("SURVIVAL_SHAMAN_8143"),
      source = "https://www.wowhead.com/forever/spell=8143", reviewed = "2026-11-15",
    },
    [2645] = {
      spellID = 2645, name = "Ghost Wolf", tag = "survival",
      reason = L("SURVIVAL_SHAMAN_2645"),
      source = "https://www.wowhead.com/forever/spell=2645", reviewed = "2026-11-15",
    },
  },
  WARRIOR = {
    [871] = {
      spellID = 871, name = "Shield Wall", tag = "survival",
      reason = L("SURVIVAL_WARRIOR_871"),
      source = "https://www.wowhead.com/forever/spell=871", reviewed = "2026-11-15",
    },
    [12975] = {
      spellID = 12975, name = "Last Stand", tag = "survival",
      reason = L("SURVIVAL_WARRIOR_12975"),
      nodeID = 105970,
      source = "https://www.wowhead.com/forever/spell=12975", reviewed = "2026-11-15",
    },
    [2565] = {
      spellID = 2565, name = "Shield Block", tag = "survival",
      reason = L("SURVIVAL_WARRIOR_2565"),
      source = "https://www.wowhead.com/forever/spell=2565", reviewed = "2026-11-15",
    },
    [676] = {
      spellID = 676, name = "Disarm", tag = "survival",
      reason = L("SURVIVAL_WARRIOR_676"),
      source = "https://www.wowhead.com/forever/spell=676", reviewed = "2026-11-15",
    },
    [5246] = {
      spellID = 5246, name = "Intimidating Shout", tag = "survival",
      reason = L("SURVIVAL_WARRIOR_5246"),
      source = "https://www.wowhead.com/forever/spell=5246", reviewed = "2026-11-15",
    },
  },
}
if SAK.Localization then SAK.Localization.RegisterTable(SAK.SurvivalAdvice) end
