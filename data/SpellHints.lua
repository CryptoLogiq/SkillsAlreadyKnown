-- Beginner hints identify spells by stable IDs, independently of rank badges.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
SAK.SpellHints = {
  PALADIN = {
    [20271] = {
      spellID = 20271,
      textKey = "SPELL_HINT_JUDGEMENT_SEAL",
      source = "https://www.wowhead.com/forever/spell=20271/judgement",
      reviewed = "2026-11-15",
    },
  },
  DRUID = {
    [18562] = {
      spellID = 18562, name = "Swiftmend",
      textKey = "COMBO_SWIFTMEND",
      relatedSpells = { 774, 8936 },
      source = "https://www.wowhead.com/forever/spell=18562", reviewed = "2026-11-15",
    },
    [17116] = {
      spellID = 17116, name = "Nature's Swiftness",
      textKey = "COMBO_DRUID_SWIFTNESS",
      relatedSpells = { 5185 },
      source = "https://www.wowhead.com/forever/spell=17116", reviewed = "2026-11-15",
    },
  },

  HUNTER = {
    [1495] = {
      spellID = 1495, name = "Mongoose Bite",
      textKey = "COMBO_MONGOOSE",
      relatedSpells = { 13163 },
      source = "https://www.wowhead.com/forever/spell=1495", reviewed = "2026-11-15",
    },
  },

  MAGE = {
    [1240047] = {
      spellID = 1240047, name = "Ice Lance",
      textKey = "COMBO_ICE_LANCE",
      relatedSpells = { 122 },
      source = "https://www.wowhead.com/forever/spell=1240047", reviewed = "2026-11-15",
    },
  },

  PRIEST = {
    [14751] = {
      spellID = 14751, name = "Inner Focus",
      textKey = "COMBO_INNER_FOCUS",
      relatedSpells = { 596, 2060 },
      source = "https://www.wowhead.com/forever/spell=14751", reviewed = "2026-11-15",
    },
  },

  ROGUE = {
    [14177] = {
      spellID = 14177, name = "Cold Blood",
      textKey = "COMBO_COLD_BLOOD",
      relatedSpells = { 2098 },
      source = "https://www.wowhead.com/forever/spell=14177", reviewed = "2026-11-15",
    },
  },

  SHAMAN = {
    [408341] = {
      spellID = 408341, name = "Fire Nova",
      textKey = "COMBO_FIRE_NOVA",
      relatedSpells = { 8190 },
      source = "https://www.wowhead.com/forever/spell=408341", reviewed = "2026-11-15",
    },
    [408521] = {
      spellID = 408521, name = "Riptide",
      textKey = "COMBO_RIPTIDE",
      relatedSpells = { 1064 },
      source = "https://www.wowhead.com/forever/spell=408521", reviewed = "2026-11-15",
    },
    [16188] = {
      spellID = 16188, name = "Nature's Swiftness",
      textKey = "COMBO_SHAMAN_SWIFTNESS",
      relatedSpells = { 331 },
      source = "https://www.wowhead.com/forever/spell=16188", reviewed = "2026-11-15",
    },
  },

  WARLOCK = {
    [1293818] = {
      spellID = 1293818, name = "Conflagrate",
      textKey = "COMBO_CONFLAGRATE",
      relatedSpells = { 348 },
      source = "https://www.wowhead.com/forever/spell=1293818", reviewed = "2026-11-15",
    },
  },

  WARRIOR = {
    [6572] = {
      spellID = 6572, name = "Revenge",
      textKey = "COMBO_REVENGE",
      relatedSpells = { 2565 },
      source = "https://www.wowhead.com/forever/spell=6572", reviewed = "2026-11-15",
    },
  },

}
