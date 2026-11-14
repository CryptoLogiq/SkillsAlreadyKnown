-- Conseils de progression Forever pour débutants, adaptés des guides Wowhead.
-- Recommandations éditoriales contextualisées, pas un classement absolu de puissance.
-- Les identifiants de spécialisation renvoient à data/ClassRoles.lua.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end

SAK.LevelingRecommendations = {
  DRUID = {
    solo = { "feral" },
    soloReason = L("Farouche devient particulièrement intéressant avec la forme de félin et sa mobilité. Équilibre reste une alternative si tu préfères jouer à distance, en surveillant davantage la mana."),
    group = { "guardian", "restoration" },
    groupReason = L("Farouche tank pour encaisser en donjon, Restauration pour soigner un groupe régulier. Un parcours centré sur les soins convient moins aux quêtes en solo."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/druid/feral/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/druid/feral/tank-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/druid/balance/overview-pve-dps",
      "https://www.wowhead.com/forever/guide/classes/druid/restoration/healer-leveling-tips",
    },
    reviewed = "2026-11-13",
  },
  HUNTER = {
    solo = { "beast-mastery" },
    soloReason = L("Maîtrise des bêtes est un choix accessible pour débuter : le familier encaisse et apporte une part importante des dégâts. Précision et Survie sont aussi des parcours viables, selon ton style de jeu."),
    group = { "beast-mastery", "marksmanship", "survival" },
    groupReason = L("Les trois voies peuvent progresser en groupe. Choisis celle dont tu préfères le rythme et apprends à contrôler le familier et les distances."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/hunter/leveling-guide",
      "https://www.wowhead.com/forever/guide/classes/hunter/beast-mastery/dps-leveling-tips",
    },
    reviewed = "2026-11-13",
  },
  MAGE = {
    solo = { "frost", "arcane" },
    soloReason = L("Givre privilégie la sécurité grâce aux ralentissements et aux protections. Arcanes offre une alternative confortable pour les quêtes avec de bons outils de gestion de mana ; ce n'est pas le même compromis que dans Classic."),
    group = { "frost", "arcane" },
    groupReason = L("Givre apporte du contrôle ; Arcanes peut enchaîner les combats avec ses outils de mana. Feu reste une option si tu préfères son jeu autour des critiques."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/mage/frost/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/mage/arcane/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/mage/fire/overview-pve-dps",
    },
    reviewed = "2026-11-13",
  },
  PALADIN = {
    solo = { "retribution" },
    soloReason = L("Vindicte est un choix simple et autonome pour les quêtes, avec des attaques régulières, des protections et des soins personnels. Garde une arme adaptée et surveille ta mana."),
    group = { "protection", "holy" },
    groupReason = L("Protection pour tanker les donjons, Sacré pour soigner si tu progresses surtout accompagné. Vindicte convient si tu veux conserver un rôle de dégâts."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/paladin/retribution/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/paladin/protection/overview-pve-tank",
      "https://www.wowhead.com/forever/guide/classes/paladin/holy/overview-pve-healer",
    },
    reviewed = "2026-11-13",
  },
  PRIEST = {
    solo = { "shadow", "discipline" },
    soloReason = L("Ombre convient si tu privilégies les dégâts en solo et l'accès à la Forme d'ombre. Discipline est une alternative rassurante pour débuter, avec de la survie et de bons soins ; la baguette reste importante aux premiers niveaux."),
    group = { "discipline", "holy" },
    groupReason = L("Discipline permet d'alterner dégâts et soins avec souplesse ; Sacré convient à un parcours centré sur les soins du groupe. Ce dernier tue généralement plus lentement en solo."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/priest/leveling-guide",
      "https://www.wowhead.com/forever/guide/classes/priest/discipline/healer-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/priest/holy/healer-leveling-tips",
    },
    reviewed = "2026-11-13",
  },
  ROGUE = {
    solo = { "combat" },
    soloReason = L("Combat propose un parcours direct, avec des talents défensifs et des outils pour interrompre ou fuir un combat dangereux. Les armes, les poisons et l'utilisation des contrôles comptent beaucoup."),
    group = { "combat" },
    groupReason = L("Combat est un point de départ simple. Assassinat et Finesse restent des alternatives si tu préfères leurs mécanismes ; le conseil n'impose pas une spécialisation à tout le groupe."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/rogue/combat/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/rogue/assassination/overview-pve-dps",
      "https://www.wowhead.com/forever/guide/classes/rogue/subtlety/overview-pve-dps",
    },
    reviewed = "2026-11-13",
  },
  SHAMAN = {
    solo = { "enhancement" },
    soloReason = L("Amélioration est un choix pratique dès les premiers niveaux : ses attaques d'arme, ses renforcements et ses soins permettent une progression autonome. Élémentaire reste une alternative à distance, plus attentive à sa dépense de mana."),
    group = { "restoration" },
    groupReason = L("Restauration si tu progresses régulièrement en soignant un groupe. Amélioration ou Élémentaire conviennent pour jouer DPS tout en apportant les totems."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/shaman/enhancement/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/shaman/elemental/overview-pve-dps",
      "https://www.wowhead.com/forever/guide/classes/shaman/restoration/overview-pve-healer",
    },
    reviewed = "2026-11-13",
  },
  WARLOCK = {
    solo = { "affliction", "demonology" },
    soloReason = L("Affliction offre une progression régulière avec les dégâts sur la durée et les drains. Démonologie devient plus intéressante lorsque ses talents renforçant le démon sont obtenus ; son début de parcours est plus lent."),
    group = { "affliction", "demonology", "destruction" },
    groupReason = L("Les trois arbres permettent de jouer DPS en groupe. Destruction privilégie les dégâts directs ; Affliction et Démonologie restent de bons choix si tu continues aussi les quêtes en solo."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/warlock/affliction/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/warlock/demonology/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps",
    },
    reviewed = "2026-11-13",
  },
  WARRIOR = {
    solo = { "arms", "fury" },
    soloReason = L("Armes permet de se concentrer sur une bonne arme à deux mains. Fureur est une autre option, avec de nouveaux outils de récupération de vie, mais dépend fortement des armes et de l'équipement. Les deux demandent des combats bien choisis."),
    group = { "protection" },
    groupReason = L("Protection si tu progresses surtout en tankant les donjons. Armes ou Fureur conviennent pour jouer DPS, notamment avec un soigneur pour réduire les pauses."),
    sources = {
      "https://www.wowhead.com/forever/guide/classes/warrior/arms/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips",
      "https://www.wowhead.com/forever/guide/classes/warrior/protection/overview-pve-tank",
    },
    reviewed = "2026-11-13",
  },
}

if SAK.Localization then
  SAK.Localization.RegisterTable(SAK.LevelingRecommendations)
end
