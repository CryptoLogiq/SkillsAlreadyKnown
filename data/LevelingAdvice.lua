-- Conseils actifs : modifier directement cette table, sans regeneration CSV.
-- Classe > specialisation > sorts. baseID identifie le rang de reference.
-- minRank/maxRank bornent les achats conseilles ; reason explique le contexte.
-- Les cas non valides restent dans scripts/research/eco-spells-forever.lua.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end

SAK.LevelingAdvice = {
  -- DRUID
  DRUID = {
    ["balance"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/druid/balance/dps-leveling-tips",
      spells = {
        {
          baseID = 5211, -- Bash
          name = "Bash",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Utilitaire; conserver si interruption, fuite ou soutien de groupe. Pas ECO automatique."),
        },
        {
          baseID = 1850, -- Dash
          name = "Dash",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Utilitaire; conserver si interruption, fuite ou soutien de groupe. Pas ECO automatique."),
        },
        {
          baseID = 740, -- Tranquility
          name = "Tranquility",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Utilitaire; conserver si interruption, fuite ou soutien de groupe. Pas ECO automatique."),
        },
      },
    },
    ["feral"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/druid/feral/dps-leveling-tips",
      spells = {
        {
          baseID = 339, -- Entangling Roots
          name = "Entangling Roots",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Leveling Farouche; conserver le controle au rang 1."),
        },
        {
          baseID = 2893, -- Abolish Poison
          name = "Abolish Poison",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche DPS; poison selon contenu; Cower surtout inutile solo; pas une regle Equilibre ou soin."),
        },
        {
          baseID = 5225, -- Track Humanoids
          name = "Track Humanoids",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche DPS; poison selon contenu; Cower surtout inutile solo; pas une regle Equilibre ou soin."),
        },
        {
          baseID = 8998, -- Cower
          name = "Cower",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche DPS; poison selon contenu; Cower surtout inutile solo; pas une regle Equilibre ou soin."),
        },
        {
          baseID = 2908, -- Soothe Animal
          name = "Soothe Animal",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche DPS; poison selon contenu; Cower surtout inutile solo; pas une regle Equilibre ou soin."),
        },
        {
          baseID = 2912, -- Starfire
          name = "Starfire",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche DPS; poison selon contenu; Cower surtout inutile solo; pas une regle Equilibre ou soin."),
        },
      },
    },
    ["guardian"] = {
      role = "tank",
      source = "https://www.wowhead.com/forever/guide/classes/druid/feral/tank-leveling-tips",
      spells = {
        {
          baseID = 339, -- Entangling Roots
          name = "Entangling Roots",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Farouche tank; garder les premiers rangs; duree/fiabilite du controle a comparer."),
        },
        {
          baseID = 2637, -- Hibernate
          name = "Hibernate",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Premier rang utile; rangs suivants reportables, pas identiques en duree/cibles."),
        },
        {
          baseID = 2893, -- Abolish Poison
          name = "Abolish Poison",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
        {
          baseID = 5225, -- Track Humanoids
          name = "Track Humanoids",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
        {
          baseID = 8998, -- Cower
          name = "Cower",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
        {
          baseID = 2908, -- Soothe Animal
          name = "Soothe Animal",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
        {
          baseID = 2912, -- Starfire
          name = "Starfire",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
        {
          baseID = 740, -- Tranquility
          name = "Tranquility",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Farouche tank; usages hors forme et soutien de groupe peuvent justifier l'achat."),
        },
      },
    },
    ["restoration"] = {
      role = "heal",
      source = "https://www.wowhead.com/forever/guide/classes/druid/restoration/healer-leveling-tips",
      spells = {
        {
          baseID = 5211, -- Bash
          name = "Bash",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 1850, -- Dash
          name = "Dash",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 770, -- Faerie Fire
          name = "Faerie Fire",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 2637, -- Hibernate
          name = "Hibernate",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 8921, -- Moonfire
          name = "Moonfire",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 16689, -- Nature's Grasp
          name = "Nature's Grasp",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 2912, -- Starfire
          name = "Starfire",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
        {
          baseID = 5176, -- Wrath
          name = "Wrath",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Restauration soin; acheter les degats si leveling solo. Le guide cite des rangs tardifs, pas une preuve que le rang 1 suffit."),
        },
      },
    },
  },

  -- HUNTER
  HUNTER = {
    ["beast-mastery"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/hunter/beast-mastery/dps-leveling-tips",
      spells = {
        {
          baseID = 13163, -- Aspect of the Monkey
          name = "Aspect of the Monkey",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 19883, -- Track Humanoids
          name = "Track Humanoids",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 6197, -- Eagle Eye
          name = "Eagle Eye",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1543, -- Flare
          name = "Flare",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1494, -- Track Beasts
          name = "Track Beasts",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Le guide le cite comme facultatif mais souligne l'utilite des pistages en leveling."),
        },
      },
    },
    ["marksmanship"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/hunter/marksmanship/dps-leveling-tips",
      spells = {
        {
          baseID = 13163, -- Aspect of the Monkey
          name = "Aspect of the Monkey",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 19883, -- Track Humanoids
          name = "Track Humanoids",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 6197, -- Eagle Eye
          name = "Eagle Eye",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1543, -- Flare
          name = "Flare",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1494, -- Track Beasts
          name = "Track Beasts",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; report seulement si le joueur ne l'utilise pas."),
        },
      },
    },
    ["survival"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/hunter/survival/dps-leveling-tips",
      spells = {
        {
          baseID = 13163, -- Aspect of the Monkey
          name = "Aspect of the Monkey",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 19883, -- Track Humanoids
          name = "Track Humanoids",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 6197, -- Eagle Eye
          name = "Eagle Eye",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1543, -- Flare
          name = "Flare",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; Flare PvP; Monkey survie/melee, notamment Survie. Aucun classement general sur la seule specialisation."),
        },
        {
          baseID = 1494, -- Track Beasts
          name = "Track Beasts",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Pistage utile en quetes; report seulement si le joueur ne l'utilise pas."),
        },
      },
    },
  },

  -- MAGE
  MAGE = {
    ["arcane"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/mage/arcane/dps-leveling-tips",
      spells = {
        {
          baseID = 604, -- Dampen Magic
          name = "Dampen Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 1008, -- Amplify Magic
          name = "Amplify Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 130, -- Slow Fall
          name = "Slow Fall",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 1463, -- Mana Shield
          name = "Mana Shield",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 543, -- Fire Ward
          name = "Fire Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 6143, -- Frost Ward
          name = "Frost Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 2948, -- Scorch
          name = "Scorch",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
      },
    },
    ["fire"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/mage/fire/dps-leveling-tips",
      spells = {
        {
          baseID = 604, -- Dampen Magic
          name = "Dampen Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 1008, -- Amplify Magic
          name = "Amplify Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 130, -- Slow Fall
          name = "Slow Fall",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 1463, -- Mana Shield
          name = "Mana Shield",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 543, -- Fire Ward
          name = "Fire Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 6143, -- Frost Ward
          name = "Frost Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
        {
          baseID = 2948, -- Scorch
          name = "Scorch",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Liste optionnelle du guide; protections et chute lente utiles selon zone; Scorch a conserver si build/debuff le demande."),
        },
      },
    },
    ["frost"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/mage/frost/dps-leveling-tips",
      spells = {
        {
          baseID = 604, -- Dampen Magic
          name = "Dampen Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Faible priorite pendant le leveling Givre."),
        },
        {
          baseID = 1008, -- Amplify Magic
          name = "Amplify Magic",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Faible priorite pendant le leveling Givre."),
        },
      },
    },
  },

  -- PALADIN
  PALADIN = {
    ["holy"] = {
      role = "heal",
      source = "https://www.wowhead.com/forever/guide/classes/paladin/holy/healer-leveling-tips",
      spells = {
        {
          baseID = 20163, -- Seal of Fury
          name = "Seal of Fury",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Sacre soin; tanking hybride, generation de menace et controle changent les priorites."),
        },
        {
          baseID = 25780, -- Righteous Fury
          name = "Righteous Fury",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Sacre soin; tanking hybride, generation de menace et controle changent les priorites."),
        },
        {
          baseID = 20164, -- Seal of Justice
          name = "Seal of Justice",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Sacre soin; tanking hybride, generation de menace et controle changent les priorites."),
        },
        {
          baseID = 2878, -- Turn Undead
          name = "Turn Undead",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Sacre soin; tanking hybride, generation de menace et controle changent les priorites."),
        },
      },
    },
    ["protection"] = {
      role = "tank",
      source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/tank-leveling-tips",
      spells = {
        {
          baseID = 20164, -- Seal of Justice
          name = "Seal of Justice",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon contenu; aucune extrapolation a une ligne vide du tableau."),
        },
        {
          baseID = 19876, -- Shadow Resistance Aura
          name = "Shadow Resistance Aura",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon contenu; aucune extrapolation a une ligne vide du tableau."),
        },
        {
          baseID = 19888, -- Frost Resistance Aura
          name = "Frost Resistance Aura",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon contenu; aucune extrapolation a une ligne vide du tableau."),
        },
        {
          baseID = 19891, -- Fire Resistance Aura
          name = "Fire Resistance Aura",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon contenu; aucune extrapolation a une ligne vide du tableau."),
        },
      },
    },
    ["retribution"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/paladin/retribution/dps-leveling-tips",
      spells = {
        {
          baseID = 465, -- Devotion Aura
          name = "Devotion Aura",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Leveling Vindicte du guide, pas tank ni soin; rangs superieurs peuvent avoir des benefices."),
        },
        {
          baseID = 633, -- Lay on Hands
          name = "Lay on Hands",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Leveling Vindicte du guide, pas tank ni soin; rangs superieurs peuvent avoir des benefices."),
        },
        {
          baseID = 6940, -- Blessing of Sacrifice
          name = "Blessing of Sacrifice",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Rang 1 pour usage anti-controle PvP; peut etre reporte entierement en solo."),
        },
        {
          baseID = 20163, -- Seal of Fury
          name = "Seal of Fury",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Seulement si aucun tanking prevu."),
        },
        {
          baseID = 20164, -- Seal of Justice
          name = "Seal of Justice",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Leveling solo Vindicte; utilitaire ou contenu morts-vivants/PvP a prendre en compte."),
        },
        {
          baseID = 19746, -- Concentration Aura
          name = "Concentration Aura",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Leveling solo Vindicte; utilitaire ou contenu morts-vivants/PvP a prendre en compte."),
        },
        {
          baseID = 2878, -- Turn Undead
          name = "Turn Undead",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Leveling solo Vindicte; utilitaire ou contenu morts-vivants/PvP a prendre en compte."),
        },
        {
          baseID = 879, -- Exorcism
          name = "Exorcism",
          minRank = 2,
          category = "optionnel_selon_usage",
          reason = L("A maintenir si combats contre morts-vivants ou demons."),
        },
      },
    },
  },

  -- PRIEST
  PRIEST = {
    ["discipline"] = {
      role = "heal",
      source = "https://www.wowhead.com/forever/guide/classes/priest/discipline/healer-leveling-tips",
      spells = {
        {
          baseID = 2006, -- Resurrection
          name = "Resurrection",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Rang 1 permet un usage de base; les rangs superieurs restent utiles, notamment cibles/duree/PvP."),
        },
        {
          baseID = 8122, -- Psychic Scream
          name = "Psychic Scream",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Rang 1 permet un usage de base; les rangs superieurs restent utiles, notamment cibles/duree/PvP."),
        },
        {
          baseID = 9484, -- Shackle Undead
          name = "Shackle Undead",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Rang 1 permet un usage de base; les rangs superieurs restent utiles, notamment cibles/duree/PvP."),
        },
      },
    },
    ["holy"] = {
      role = "heal",
      source = "https://www.wowhead.com/forever/guide/classes/priest/holy/healer-leveling-tips",
      spells = {
        {
          baseID = 2006, -- Resurrection
          name = "Resurrection",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Soin en groupe; les degats peuvent compter en solo. Ne pas marquer le premier achat de Resurrection."),
        },
        {
          baseID = 2944, -- Devouring Plague
          name = "Devouring Plague",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Soin en groupe; les degats peuvent compter en solo. Ne pas marquer le premier achat de Resurrection."),
        },
        {
          baseID = 605, -- Mind Control
          name = "Mind Control",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Soin en groupe; les degats peuvent compter en solo. Ne pas marquer le premier achat de Resurrection."),
        },
        {
          baseID = 1706, -- Levitate
          name = "Levitate",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Utilitaire; ce sort n'est pas une economie de rangs multiples."),
        },
      },
    },
    ["shadow"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/priest/shadow/dps-leveling-tips",
      spells = {
        {
          baseID = 605, -- Mind Control
          name = "Mind Control",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
        {
          baseID = 2006, -- Resurrection
          name = "Resurrection",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
        {
          baseID = 586, -- Fade
          name = "Fade",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
        {
          baseID = 9484, -- Shackle Undead
          name = "Shackle Undead",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
        {
          baseID = 14752, -- Divine Spirit
          name = "Divine Spirit",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
        {
          baseID = 2060, -- Greater Heal
          name = "Greater Heal",
          minRank = 2,
          category = "rangs_reportables",
          reason = L("Report possible en leveling Ombre; capacite sur cibles de haut niveau, menace, soin/groupe a verifier. Pas equivalence de tous les rangs."),
        },
      },
    },
  },

  -- ROGUE
  ROGUE = {
    ["assassination"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/rogue/assassination/dps-leveling-tips",
      spells = {
        {
          baseID = 921, -- Pick Pocket
          name = "Pick Pocket",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
        {
          baseID = 1725, -- Distract
          name = "Distract",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
      },
    },
    ["combat"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/rogue/combat/dps-leveling-tips",
      spells = {
        {
          baseID = 921, -- Pick Pocket
          name = "Pick Pocket",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
        {
          baseID = 1725, -- Distract
          name = "Distract",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
      },
    },
    ["subtlety"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/rogue/subtlety/dps-leveling-tips",
      spells = {
        {
          baseID = 921, -- Pick Pocket
          name = "Pick Pocket",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
        {
          baseID = 1725, -- Distract
          name = "Distract",
          minRank = 1,
          category = "reviewed_utility",
          reason = L("Utilitaire situationnel ; conserve son intérêt pour le butin ou les déplacements en camouflage."),
        },
      },
    },
  },

  -- SHAMAN
  SHAMAN = {
    ["elemental"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/shaman/elemental/dps-leveling-tips",
      spells = {
        {
          baseID = 8033, -- Frostbrand Weapon
          name = "Frostbrand Weapon",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 8181, -- Frost Resistance Totem
          name = "Frost Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 6196, -- Far Sight
          name = "Far Sight",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 8184, -- Fire Resistance Totem
          name = "Fire Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 10595, -- Nature Resistance Totem
          name = "Nature Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 15107, -- Windwall Totem
          name = "Windwall Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
      },
    },
    ["restoration"] = {
      role = "heal",
      source = "https://www.wowhead.com/forever/guide/classes/shaman/restoration/healer-leveling-tips",
      spells = {
        {
          baseID = 8033, -- Frostbrand Weapon
          name = "Frostbrand Weapon",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 8181, -- Frost Resistance Totem
          name = "Frost Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 6196, -- Far Sight
          name = "Far Sight",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 8184, -- Fire Resistance Totem
          name = "Fire Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 10595, -- Nature Resistance Totem
          name = "Nature Resistance Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
        {
          baseID = 15107, -- Windwall Totem
          name = "Windwall Totem",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Resistances selon zone/groupe; Frostbrand selon PvP; pas de skip si besoin specifique."),
        },
      },
    },
  },

  -- WARLOCK
  WARLOCK = {
    ["affliction"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/warlock/affliction/dps-leveling-tips",
      spells = {
        {
          baseID = 1120, -- Drain Soul
          name = "Drain Soul",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour generation de fragments en fin de combat pendant leveling; reevaluer usages de degats."),
        },
        {
          baseID = 704, -- Curse of Recklessness
          name = "Curse of Recklessness",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour empecher la fuite ou retirer l'effet de Fear; premier achat lui-meme situationnel."),
        },
        {
          baseID = 5676, -- Searing Pain
          name = "Searing Pain",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Finisher rapide optionnel pour le parcours Affliction seulement."),
        },
        {
          baseID = 1714, -- Curse of Tongues
          name = "Curse of Tongues",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 755, -- Health Funnel
          name = "Health Funnel",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5697, -- Unending Breath
          name = "Unending Breath",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 698, -- Ritual of Summoning
          name = "Ritual of Summoning",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 126, -- Eye of Kilrogg
          name = "Eye of Kilrogg",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5500, -- Sense Demons
          name = "Sense Demons",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 710, -- Banish
          name = "Banish",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 6229, -- Shadow Ward
          name = "Shadow Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 702, -- Curse of Weakness
          name = "Curse of Weakness",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 5138, -- Drain Mana
          name = "Drain Mana",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 132, -- Detect Invisibility
          name = "Detect Invisibility",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 1098, -- Subjugate Demon
          name = "Subjugate Demon",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 6353, -- Soul Fire
          name = "Soul Fire",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 6366, -- Create Firestone
          name = "Create Firestone",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Faible apport Affliction; guide privilegie Spellstone a partir de 36."),
        },
      },
    },
    ["demonology"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/warlock/demonology/dps-leveling-tips",
      spells = {
        {
          baseID = 1120, -- Drain Soul
          name = "Drain Soul",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour generation de fragments en fin de combat pendant leveling; reevaluer usages de degats."),
        },
        {
          baseID = 704, -- Curse of Recklessness
          name = "Curse of Recklessness",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour empecher la fuite ou retirer l'effet de Fear; premier achat lui-meme situationnel."),
        },
        {
          baseID = 1714, -- Curse of Tongues
          name = "Curse of Tongues",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 755, -- Health Funnel
          name = "Health Funnel",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5697, -- Unending Breath
          name = "Unending Breath",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 698, -- Ritual of Summoning
          name = "Ritual of Summoning",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 126, -- Eye of Kilrogg
          name = "Eye of Kilrogg",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5500, -- Sense Demons
          name = "Sense Demons",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 710, -- Banish
          name = "Banish",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 6229, -- Shadow Ward
          name = "Shadow Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 686, -- Shadow Bolt
          name = "Shadow Bolt",
          minRank = 2,
          category = "optionnel_selon_usage",
          reason = L("Ouverture possible; filler du parcours repose sur Drain Life/Searing Pain; pas regle Destruction."),
        },
        {
          baseID = 702, -- Curse of Weakness
          name = "Curse of Weakness",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 5138, -- Drain Mana
          name = "Drain Mana",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 132, -- Detect Invisibility
          name = "Detect Invisibility",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 1098, -- Subjugate Demon
          name = "Subjugate Demon",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 6353, -- Soul Fire
          name = "Soul Fire",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
      },
    },
    ["destruction"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/warlock/destruction/dps-leveling-tips",
      spells = {
        {
          baseID = 1120, -- Drain Soul
          name = "Drain Soul",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour generation de fragments en fin de combat pendant leveling; reevaluer usages de degats."),
        },
        {
          baseID = 704, -- Curse of Recklessness
          name = "Curse of Recklessness",
          minRank = 2,
          category = "rang_1_suffisant",
          reason = L("Pour empecher la fuite ou retirer l'effet de Fear; premier achat lui-meme situationnel."),
        },
        {
          baseID = 1714, -- Curse of Tongues
          name = "Curse of Tongues",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 755, -- Health Funnel
          name = "Health Funnel",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5697, -- Unending Breath
          name = "Unending Breath",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 698, -- Ritual of Summoning
          name = "Ritual of Summoning",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 126, -- Eye of Kilrogg
          name = "Eye of Kilrogg",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5500, -- Sense Demons
          name = "Sense Demons",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 710, -- Banish
          name = "Banish",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 6229, -- Shadow Ward
          name = "Shadow Ward",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Casting adverse/PvP; soin demon; quetes sous-marines; donjons et controle: condition par usage, pas par seule spe."),
        },
        {
          baseID = 5676, -- Searing Pain
          name = "Searing Pain",
          minRank = 2,
          category = "optionnel_selon_usage",
          reason = L("Option PvP; ne pas copier cette regle en Demonologie avec Demonic Brand."),
        },
        {
          baseID = 702, -- Curse of Weakness
          name = "Curse of Weakness",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 5138, -- Drain Mana
          name = "Drain Mana",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 132, -- Detect Invisibility
          name = "Detect Invisibility",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 1098, -- Subjugate Demon
          name = "Subjugate Demon",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
        {
          baseID = 6353, -- Soul Fire
          name = "Soul Fire",
          minRank = 1,
          category = "optionnel_leveling",
          reason = L("Report propose par le guide de leveling; Rain of Fire/Hellfire exige validation securite et AoE avant recommandation automatique."),
        },
      },
    },
  },

  -- WARRIOR
  WARRIOR = {
    ["arms"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/warrior/arms/dps-leveling-tips",
      spells = {
        {
          baseID = 694, -- Mocking Blow
          name = "Mocking Blow",
          minRank = 2,
          category = "optionnel_selon_usage",
          reason = L("Hors tanking; conserver si besoin de reprise ponctuelle."),
        },
      },
    },
    ["fury"] = {
      role = "dps",
      source = "https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips",
      spells = {
        {
          baseID = 694, -- Mocking Blow
          name = "Mocking Blow",
          minRank = 2,
          maxRank = 5,
          category = "rangs_reportables",
          reason = L("Le guide donne explicitement cette plage; conserver le premier rang si utile."),
        },
        {
          baseID = 1464, -- Slam
          name = "Slam",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Parcours Fureur du guide; ne pas appliquer a Armes utilisant Improved Slam."),
        },
      },
    },
    ["protection"] = {
      role = "tank",
      source = "https://www.wowhead.com/forever/guide/classes/warrior/protection/tank-leveling-tips",
      spells = {
        {
          baseID = 7384, -- Overpower
          name = "Overpower",
          minRank = 2,
          maxRank = 3,
          category = "rangs_reportables",
          reason = L("Plage explicite du guide; usages de posture/build a confirmer."),
        },
        {
          baseID = 1464, -- Slam
          name = "Slam",
          minRank = 1,
          category = "optionnel_selon_usage",
          reason = L("Parcours Protection bouclier; pas regle DPS."),
        },
      },
    },
  },

}

if SAK.Localization then
  SAK.Localization.RegisterTable(SAK.LevelingAdvice)
end
