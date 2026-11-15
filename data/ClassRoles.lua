-- Roles and specializations currently supported by Skills & More.
-- Tree icon names: talentsforever.com/data.json, Chris Baldwin, CC BY 4.0.
-- Edit this table to maintain the class choices and beginner explanations.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end

SAK.ClassRoles = {
  roles = {
    tank = { name = "Tank", description = L("Encaisser les attaques et garder les ennemis sur soi pour protéger le groupe.") },
    heal = { name = L("Heal"), description = L("Soigner les alliés pour maintenir le groupe en vie.") },
    dps = { name = "DPS", description = L("Infliger des dégâts pour éliminer les ennemis.") },
  },
  activities = {
    pvp = {
      name = "PvP",
      description = L("Joueur contre joueur : combattre d'autres joueurs. C'est une activité, pas un rôle ; toutes les classes peuvent la pratiquer."),
      availableToAllClasses = true,
    },
  },
  classes = {
    DRUID = {
      talentTrees = {
        { name = L("Équilibre"), specs = { "balance" }, icon = "Interface\\Icons\\spell_nature_starfall" },
        { name = L("Farouche"), specs = { "feral", "guardian" }, icon = "Interface\\Icons\\ability_racial_bearform" },
        { name = L("Restauration"), specs = { "restoration" }, icon = "Interface\\Icons\\spell_nature_healingtouch" },
      },
      name = L("Druide"),
      specializations = {
        balance = L("Équilibre"),
        feral = L("Farouche DPS"),
        guardian = L("Farouche tank"),
        restoration = L("Restauration"),
      },
      roles = {
        tank = { "guardian" }, -- Ours : encaisser et protéger.
        heal = { "restoration" },
        dps = { "balance", "feral" }, -- Félin pour Farouche DPS.
      },
    },
    HUNTER = {
      talentTrees = {
        { name = L("Maîtrise des bêtes"), specs = { "beast-mastery" }, icon = "Interface\\Icons\\ability_hunter_beasttaming" },
        { name = L("Précision"), specs = { "marksmanship" }, icon = "Interface\\Icons\\ability_marksmanship" },
        { name = L("Survie"), specs = { "survival" }, icon = "Interface\\Icons\\ability_hunter_swiftstrike" },
      },
      name = L("Chasseur"),
      specializations = {
        ["beast-mastery"] = L("Maîtrise des bêtes"),
        marksmanship = L("Précision"),
        survival = L("Survie"),
      },
      roles = { dps = { "beast-mastery", "marksmanship", "survival" } },
    },
    MAGE = {
      talentTrees = {
        { name = L("Arcanes"), specs = { "arcane" }, icon = "Interface\\Icons\\spell_holy_magicalsentry" },
        { name = L("Feu"), specs = { "fire" }, icon = "Interface\\Icons\\spell_fire_firebolt02" },
        { name = L("Givre"), specs = { "frost" }, icon = "Interface\\Icons\\spell_frost_frostbolt02" },
      },
      name = "Mage",
      specializations = { arcane = L("Arcanes"), fire = L("Feu"), frost = L("Givre") },
      roles = { dps = { "arcane", "fire", "frost" } },
    },
    PALADIN = {
      talentTrees = {
        { name = L("Sacré"), specs = { "holy" }, icon = "Interface\\Icons\\spell_holy_holybolt" },
        { name = "Protection", specs = { "protection" }, icon = "Interface\\Icons\\spell_holy_devotionaura" },
        { name = L("Vindicte"), specs = { "retribution" }, icon = "Interface\\Icons\\spell_holy_auraoflight" },
      },
      name = "Paladin",
      specializations = { holy = L("Sacré"), protection = "Protection", retribution = L("Vindicte") },
      roles = { tank = { "protection" }, heal = { "holy" }, dps = { "retribution" } },
    },
    PRIEST = {
      talentTrees = {
        { name = "Discipline", specs = { "discipline" }, icon = "Interface\\Icons\\spell_holy_wordfortitude" },
        { name = L("Sacré"), specs = { "holy" }, icon = "Interface\\Icons\\spell_holy_guardianspirit" },
        { name = L("Ombre"), specs = { "shadow" }, icon = "Interface\\Icons\\spell_shadow_shadowwordpain" },
      },
      name = L("Prêtre"),
      specializations = { discipline = "Discipline", holy = L("Sacré"), shadow = L("Ombre") },
      roles = { heal = { "discipline", "holy" }, dps = { "shadow" } },
    },
    ROGUE = {
      talentTrees = {
        { name = L("Assassinat"), specs = { "assassination" }, icon = "Interface\\Icons\\ability_rogue_eviscerate" },
        { name = "Combat", specs = { "combat" }, icon = "Interface\\Icons\\ability_backstab" },
        { name = L("Finesse"), specs = { "subtlety" }, icon = "Interface\\Icons\\ability_stealth" },
      },
      name = L("Voleur"),
      specializations = { assassination = L("Assassinat"), combat = "Combat", subtlety = L("Finesse") },
      roles = { dps = { "assassination", "combat", "subtlety" } },
    },
    SHAMAN = {
      talentTrees = {
        { name = L("Élémentaire"), specs = { "elemental" }, icon = "Interface\\Icons\\spell_nature_lightning" },
        { name = L("Amélioration"), specs = { "enhancement" }, icon = "Interface\\Icons\\spell_nature_lightningshield" },
        { name = L("Restauration"), specs = { "restoration" }, icon = "Interface\\Icons\\spell_nature_magicimmunity" },
      },
      name = L("Chaman"),
      specializations = { elemental = L("Élémentaire"), enhancement = L("Amélioration"), restoration = L("Restauration") },
      roles = { heal = { "restoration" }, dps = { "elemental", "enhancement" } },
    },
    WARLOCK = {
      talentTrees = {
        { name = "Affliction", specs = { "affliction" }, icon = "Interface\\Icons\\spell_shadow_deathcoil" },
        { name = L("Démonologie"), specs = { "demonology" }, icon = "Interface\\Icons\\spell_shadow_metamorphosis" },
        { name = "Destruction", specs = { "destruction" }, icon = "Interface\\Icons\\spell_shadow_rainoffire" },
      },
      name = L("Démoniste"),
      specializations = { affliction = "Affliction", demonology = L("Démonologie"), destruction = "Destruction" },
      roles = { dps = { "affliction", "demonology", "destruction" } },
    },
    WARRIOR = {
      talentTrees = {
        { name = L("Armes"), specs = { "arms" }, icon = "Interface\\Icons\\ability_rogue_eviscerate" },
        { name = L("Fureur"), specs = { "fury" }, icon = "Interface\\Icons\\ability_warrior_innerrage" },
        { name = "Protection", specs = { "protection" }, icon = "Interface\\Icons\\inv_shield_06" },
      },
      name = L("Guerrier"),
      specializations = { arms = L("Armes"), fury = L("Fureur"), protection = "Protection" },
      roles = { tank = { "protection" }, dps = { "arms", "fury" } },
    },
  },
}

if SAK.Localization then
  SAK.Localization.RegisterTable(SAK.ClassRoles)
end
