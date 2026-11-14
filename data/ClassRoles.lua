-- Roles and specializations currently supported by Skills & More.
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
        { name = L("Équilibre"), specs = { "balance" } },
        { name = L("Farouche"), specs = { "feral", "guardian" } },
        { name = L("Restauration"), specs = { "restoration" } },
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
        { name = L("Maîtrise des bêtes"), specs = { "beast-mastery" } },
        { name = L("Précision"), specs = { "marksmanship" } },
        { name = L("Survie"), specs = { "survival" } },
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
        { name = L("Arcanes"), specs = { "arcane" } },
        { name = L("Feu"), specs = { "fire" } },
        { name = L("Givre"), specs = { "frost" } },
      },
      name = "Mage",
      specializations = { arcane = L("Arcanes"), fire = L("Feu"), frost = L("Givre") },
      roles = { dps = { "arcane", "fire", "frost" } },
    },
    PALADIN = {
      talentTrees = {
        { name = L("Sacré"), specs = { "holy" } },
        { name = "Protection", specs = { "protection" } },
        { name = L("Vindicte"), specs = { "retribution" } },
      },
      name = "Paladin",
      specializations = { holy = L("Sacré"), protection = "Protection", retribution = L("Vindicte") },
      roles = { tank = { "protection" }, heal = { "holy" }, dps = { "retribution" } },
    },
    PRIEST = {
      talentTrees = {
        { name = "Discipline", specs = { "discipline" } },
        { name = L("Sacré"), specs = { "holy" } },
        { name = L("Ombre"), specs = { "shadow" } },
      },
      name = L("Prêtre"),
      specializations = { discipline = "Discipline", holy = L("Sacré"), shadow = L("Ombre") },
      roles = { heal = { "discipline", "holy" }, dps = { "shadow" } },
    },
    ROGUE = {
      talentTrees = {
        { name = L("Assassinat"), specs = { "assassination" } },
        { name = "Combat", specs = { "combat" } },
        { name = L("Finesse"), specs = { "subtlety" } },
      },
      name = L("Voleur"),
      specializations = { assassination = L("Assassinat"), combat = "Combat", subtlety = L("Finesse") },
      roles = { dps = { "assassination", "combat", "subtlety" } },
    },
    SHAMAN = {
      talentTrees = {
        { name = L("Élémentaire"), specs = { "elemental" } },
        { name = L("Amélioration"), specs = { "enhancement" } },
        { name = L("Restauration"), specs = { "restoration" } },
      },
      name = L("Chaman"),
      specializations = { elemental = L("Élémentaire"), enhancement = L("Amélioration"), restoration = L("Restauration") },
      roles = { heal = { "restoration" }, dps = { "elemental", "enhancement" } },
    },
    WARLOCK = {
      talentTrees = {
        { name = "Affliction", specs = { "affliction" } },
        { name = L("Démonologie"), specs = { "demonology" } },
        { name = "Destruction", specs = { "destruction" } },
      },
      name = L("Démoniste"),
      specializations = { affliction = "Affliction", demonology = L("Démonologie"), destruction = "Destruction" },
      roles = { dps = { "affliction", "demonology", "destruction" } },
    },
    WARRIOR = {
      talentTrees = {
        { name = L("Armes"), specs = { "arms" } },
        { name = L("Fureur"), specs = { "fury" } },
        { name = "Protection", specs = { "protection" } },
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
