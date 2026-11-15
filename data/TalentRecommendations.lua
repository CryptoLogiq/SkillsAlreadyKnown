-- Only explicit theorycrafter build recommendations are active.
-- A spell tooltip or popularity percentage is not build evidence.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
SAK.TalentRecommendations = {
  reviewed = "2026-11-15",
  classes = {
    PALADIN = {
      [1310905] = {
        spellID = 1310905, nodeID = 110872, name = "Consecrated Ground",
        basis = "theorycraft-build",
        choices = {
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_SHOCKPROT",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Shockprot Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
        context = "TALENT_BUILD_SITUATIONAL",
      },
      [1237268] = {
        spellID = 1237268, nodeID = 105704, name = "Holy Conduit",
        basis = "theorycraft-build",
        choices = {
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_SHOCKPROT",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Shockprot Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
        context = "TALENT_BUILD_SITUATIONAL",
      },
      [1311606] = {
        spellID = 1311606, nodeID = 105323, name = "Holy Shock",
        basis = "theorycraft-build",
        choices = {
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_SHOCKPROT",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Shockprot Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
        context = "TALENT_BUILD_SITUATIONAL",
      },
      [26022] = {
        spellID = 26022, nodeID = 105699, name = "Pursuit of Justice",
        basis = "theorycraft-build",
        choices = {
          {
            role = "heal", spec = "holy", build = "TALENT_BUILD_RAID",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/holy/talent-builds-pve-healer", author = "Harreks",
            section = "Best Holy Paladin PvE Raid Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_RAID_DUNGEON",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Standard Build; Best Protection Paladin PvE Dungeon Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
      },
      [9452] = {
        spellID = 9452, nodeID = 105702, name = "Vindication",
        basis = "theorycraft-build",
        choices = {
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_RETPROT_DUNGEON",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Retprot Build; Best Protection Paladin PvE Dungeon Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
      },
      [20174] = {
        spellID = 20174, nodeID = 105637, name = "Guardian's Favor",
        basis = "theorycraft-build",
        choices = {
          {
            role = "tank", spec = "protection", build = "TALENT_BUILD_DUNGEON",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank", author = "Riyani",
            section = "Best Protection Paladin PvE Dungeon Build", guideUpdated = "2026/11/04", reviewed = "2026-11-15",
          },
        },
      },
      [20375] = {
        spellID = 20375, nodeID = 105696, name = "Seal of Command",
        basis = "theorycraft-build",
        choices = {
          {
            role = "dps", spec = "retribution", build = "TALENT_BUILD_STANDARD_RET",
            source = "https://www.wowhead.com/forever/guide/classes/paladin/retribution/talent-builds-pve-dps", author = "Surveillant",
            section = "Retribution (Unsealed Wrath) PvE DPS Raid Build", guideUpdated = "2026/11/13", reviewed = "2026-11-15",
          },
        },
      },
    },
  },
}
