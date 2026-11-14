-- Roles and specializations currently supported by Skills & More.
-- Edit this table to maintain the class choices and beginner explanations.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end

SAK.ClassRoles = {
  roles = {
    tank = { name = "Tank", description = "Encaisser les attaques et garder les ennemis sur soi pour protéger le groupe." },
    heal = { name = "Heal", description = "Soigner les alliés pour maintenir le groupe en vie." },
    dps = { name = "DPS", description = "Infliger des dégâts pour éliminer les ennemis." },
  },
  activities = {
    pvp = {
      name = "PvP",
      description = "Joueur contre joueur : combattre d'autres joueurs. C'est une activité, pas un rôle ; toutes les classes peuvent la pratiquer.",
      availableToAllClasses = true,
    },
  },
  classes = {
    DRUID = {
      talentTrees = {
        { name = "Équilibre", specs = { "balance" } },
        { name = "Farouche", specs = { "feral", "guardian" } },
        { name = "Restauration", specs = { "restoration" } },
      },
      name = "Druide",
      specializations = {
        balance = "Équilibre",
        feral = "Farouche DPS",
        guardian = "Farouche tank",
        restoration = "Restauration",
      },
      roles = {
        tank = { "guardian" }, -- Ours : encaisser et protéger.
        heal = { "restoration" },
        dps = { "balance", "feral" }, -- Félin pour Farouche DPS.
      },
    },
    HUNTER = {
      talentTrees = {
        { name = "Maîtrise des bêtes", specs = { "beast-mastery" } },
        { name = "Précision", specs = { "marksmanship" } },
        { name = "Survie", specs = { "survival" } },
      },
      name = "Chasseur",
      specializations = {
        ["beast-mastery"] = "Maîtrise des bêtes",
        marksmanship = "Précision",
        survival = "Survie",
      },
      roles = { dps = { "beast-mastery", "marksmanship", "survival" } },
    },
    MAGE = {
      talentTrees = {
        { name = "Arcanes", specs = { "arcane" } },
        { name = "Feu", specs = { "fire" } },
        { name = "Givre", specs = { "frost" } },
      },
      name = "Mage",
      specializations = { arcane = "Arcanes", fire = "Feu", frost = "Givre" },
      roles = { dps = { "arcane", "fire", "frost" } },
    },
    PALADIN = {
      talentTrees = {
        { name = "Sacré", specs = { "holy" } },
        { name = "Protection", specs = { "protection" } },
        { name = "Vindicte", specs = { "retribution" } },
      },
      name = "Paladin",
      specializations = { holy = "Sacré", protection = "Protection", retribution = "Vindicte" },
      roles = { tank = { "protection" }, heal = { "holy" }, dps = { "retribution" } },
    },
    PRIEST = {
      talentTrees = {
        { name = "Discipline", specs = { "discipline" } },
        { name = "Sacré", specs = { "holy" } },
        { name = "Ombre", specs = { "shadow" } },
      },
      name = "Prêtre",
      specializations = { discipline = "Discipline", holy = "Sacré", shadow = "Ombre" },
      roles = { heal = { "discipline", "holy" }, dps = { "shadow" } },
    },
    ROGUE = {
      talentTrees = {
        { name = "Assassinat", specs = { "assassination" } },
        { name = "Combat", specs = { "combat" } },
        { name = "Finesse", specs = { "subtlety" } },
      },
      name = "Voleur",
      specializations = { assassination = "Assassinat", combat = "Combat", subtlety = "Finesse" },
      roles = { dps = { "assassination", "combat", "subtlety" } },
    },
    SHAMAN = {
      talentTrees = {
        { name = "Élémentaire", specs = { "elemental" } },
        { name = "Amélioration", specs = { "enhancement" } },
        { name = "Restauration", specs = { "restoration" } },
      },
      name = "Chaman",
      specializations = { elemental = "Élémentaire", enhancement = "Amélioration", restoration = "Restauration" },
      roles = { heal = { "restoration" }, dps = { "elemental", "enhancement" } },
    },
    WARLOCK = {
      talentTrees = {
        { name = "Affliction", specs = { "affliction" } },
        { name = "Démonologie", specs = { "demonology" } },
        { name = "Destruction", specs = { "destruction" } },
      },
      name = "Démoniste",
      specializations = { affliction = "Affliction", demonology = "Démonologie", destruction = "Destruction" },
      roles = { dps = { "affliction", "demonology", "destruction" } },
    },
    WARRIOR = {
      talentTrees = {
        { name = "Armes", specs = { "arms" } },
        { name = "Fureur", specs = { "fury" } },
        { name = "Protection", specs = { "protection" } },
      },
      name = "Guerrier",
      specializations = { arms = "Armes", fury = "Fureur", protection = "Protection" },
      roles = { tank = { "protection" }, dps = { "arms", "fury" } },
    },
  },
}
