-- Audit de recherche du 14 novembre 2026. Ne pilote pas les marqueurs en jeu.
-- Couverture : chaque sort unique de LevelingAdvice + controle explicite de Blink.
-- Les classes de survie et recommandations sont notre interpretation des usages.
-- Une source de classe donne le contexte; elle ne certifie pas chaque rang Forever.
return {
  reviewedAt = "2026-11-14",
  status = "review-only",
  limits = {
    "Classic/Hardcore sert de comparaison; ne pas importer ses chiffres de mana, toucher ou niveaux dans Forever.",
    "Situationnel ne signifie ni obligatoire partout ni inutile. Aucun consensus unanime revendique.",
    "Retirer OPTIONAL du premier achat ne valide pas automatiquement ECO ou les rangs suivants.",
    "Blink/1953 absent du catalogue actif : diagnostiquer le badge en jeu avant attribution a cette liste.",
  },
  sources = {
    druid = "https://www.wowhead.com/forever/guide/classes/druid/feral/tank-leveling-tips",
    hunter = "https://www.wowhead.com/ptr/news/druid-and-hunter-class-deep-dives-in-world-of-warcraft-forever-383190",
    mage = "https://www.icy-veins.com/wow-forever/frost-mage-leveling/",
    mageClassic = "https://www.wowhead.com/classic/guide/classes/mage/hardcore-leveling-tips",
    paladin = "https://www.wowhead.com/forever/guide/classes/paladin/holy/healer-abilities",
    priest = "https://www.wowhead.com/classic/guide/classes/priest/hardcore-leveling-tips",
    rogue = "https://www.reddit.com/r/wowforever/comments/1xme7ni/what_are_your_best_rogue_tips_and_tricks/",
    shaman = "https://www.reddit.com/r/wowforever/comments/1xvvl05/what_totems_are_must_haves_on_your_spell_bar_for/",
    warlock = "https://www.wowhead.com/forever/guide/classes/warlock/destruction/dps-leveling-tips",
    warlockPlayers = "https://www.reddit.com/r/wowforever/comments/1xp7na1/warlocks_you_guys_found_a_new_leveling_build/",
    warrior = "https://www.reddit.com/r/wowhardcore/comments/1x4lvld/using_a_shield_for_warrior_leveling/",
  },
  classes = {
    DRUID = {
      [339] = {
        name = "Entangling Roots",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Immobilisation de secours; ne pas garantir que le rang 1 convient à toutes les cibles Forever.",
        source = "druid",
        currentRules = {
          { spec = "feral", minRank = 2, category = "rang_1_suffisant" },
          { spec = "guardian", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [740] = {
        name = "Tranquility",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Soin de secours canalisé pour soi/groupe; situationnel, interrompable, mais pas simplement offensif.",
        source = "druid",
        currentRules = {
          { spec = "balance", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [770] = {
        name = "Faerie Fire",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [1850] = {
        name = "Dash",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Fuite et mobilité; ne pas présenter le premier achat comme facultatif.",
        source = "druid",
        currentRules = {
          { spec = "balance", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [2637] = {
        name = "Hibernate",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle de certains types de créatures; efficacité et durée des rangs à vérifier dans Forever.",
        source = "druid",
        currentRules = {
          { spec = "guardian", minRank = 2, category = "rangs_reportables" },
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [2893] = {
        name = "Abolish Poison",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Dissipation de poison pour soi ou un allié; conserver dans le kit défensif de base.",
        source = "druid",
        currentRules = {
          { spec = "feral", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [2908] = {
        name = "Soothe Animal",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Prévention des engagements avec des bêtes; utile selon la zone, pas une fuite universelle.",
        source = "druid",
        currentRules = {
          { spec = "feral", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [2912] = {
        name = "Starfire",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "feral", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [5176] = {
        name = "Wrath",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [5211] = {
        name = "Bash",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Interruption et étourdissement pour se dégager; protéger le premier achat, revoir les rangs qui améliorent le contrôle.",
        source = "druid",
        currentRules = {
          { spec = "balance", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [5225] = {
        name = "Track Humanoids",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Repérage d’humanoïdes en forme féline; pas une défense active.",
        currentRules = {
          { spec = "feral", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [8921] = {
        name = "Moonfire",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [8998] = {
        name = "Cower",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Réduction de menace en groupe; pas une fuite solo.",
        currentRules = {
          { spec = "feral", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [16689] = {
        name = "Nature's Grasp",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Contrôle défensif lorsque des ennemis atteignent le druide; revoir les rangs plutôt que les reporter automatiquement.",
        source = "druid",
        currentRules = {
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
      [16914] = {
        name = "Hurricane",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "guardian", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 2, category = "rangs_reportables" },
        },
      },
    },
    HUNTER = {
      [1494] = {
        name = "Track Beasts",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Repérage de bêtes; prévention indirecte, pas une défense active.",
        currentRules = {
          { spec = "beast-mastery", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "marksmanship", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "survival", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1543] = {
        name = "Flare",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Détection furtive, surtout selon contenu/PvP.",
        currentRules = {
          { spec = "beast-mastery", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "marksmanship", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "survival", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [6197] = {
        name = "Eagle Eye",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "beast-mastery", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "marksmanship", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "survival", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [13163] = {
        name = "Aspect of the Monkey",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Esquive et protection du familier dans Forever; utilité défensive même pour un chasseur à distance.",
        source = "hunter",
        currentRules = {
          { spec = "beast-mastery", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "marksmanship", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "survival", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [19883] = {
        name = "Track Humanoids",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Repérage d’humanoïdes; prévention indirecte.",
        currentRules = {
          { spec = "beast-mastery", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "marksmanship", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "survival", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
    },
    MAGE = {
      [130] = {
        name = "Slow Fall",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Évite une chute mortelle; outil de sécurité hors combat, sans justifier une obligation de lancement.",
        source = "mage",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [543] = {
        name = "Fire Ward",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Absorption de feu; utile seulement face aux dégâts correspondants; les rangs augmentent la protection.",
        source = "mageClassic",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [604] = {
        name = "Dampen Magic",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Défense contre la magie avec contrepartie sur les soins; pas un achat universellement inutile.",
        source = "mageClassic",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "frost", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1008] = {
        name = "Amplify Magic",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Améliore certains soins reçus mais augmente aussi les dégâts magiques reçus; contexte de combat indispensable.",
        source = "mageClassic",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "frost", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1463] = {
        name = "Mana Shield",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Bouclier de secours; coûte du mana et ne se maintient pas systématiquement, mais son apprentissage reste utile.",
        source = "mageClassic",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1953] = {
        name = "Blink",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Fuite, repositionnement et sortie de certains contrôles; protéger le premier achat. Absent des règles OPTIONAL actuelles.",
        source = "mage",
        currentRules = {
        },
      },
      [2948] = {
        name = "Scorch",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [6143] = {
        name = "Frost Ward",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Absorption de givre; utile face à cette école; les rangs augmentent la protection.",
        source = "mageClassic",
        currentRules = {
          { spec = "arcane", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "fire", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
    },
    PALADIN = {
      [465] = {
        name = "Devotion Aura",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduction des dégâts physiques; rang 1 reportable selon rôle ne signifie pas protection équivalente.",
        source = "paladin",
        currentRules = {
          { spec = "retribution", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [633] = {
        name = "Lay on Hands",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Soin d’urgence majeur; distinguer son acquisition des gains réels des rangs supérieurs.",
        source = "paladin",
        currentRules = {
          { spec = "retribution", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [879] = {
        name = "Exorcism",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "retribution", minRank = 2, category = "optionnel_selon_usage" },
        },
      },
      [2812] = {
        name = "Holy Wrath",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "retribution", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [2878] = {
        name = "Turn Undead",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle réservé aux morts-vivants; risque de ramener des ennemis avec la fuite.",
        source = "paladin",
        currentRules = {
          { spec = "holy", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "retribution", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [6940] = {
        name = "Blessing of Sacrifice",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Protection d’un allié par transfert de dégâts, avec risque pour le lanceur; gains des rangs à vérifier.",
        source = "paladin",
        currentRules = {
          { spec = "retribution", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [19746] = {
        name = "Concentration Aura",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Aide à lancer des sorts sous les coups; valeur de soutien et de soin selon la situation.",
        source = "paladin",
        currentRules = {
          { spec = "retribution", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [19876] = {
        name = "Shadow Resistance Aura",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduction des dégâts d’ombre selon les adversaires; utile au groupe même hors tank principal.",
        source = "paladin",
        currentRules = {
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [19888] = {
        name = "Frost Resistance Aura",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduction des dégâts de givre selon les adversaires; ne pas confondre situationnel et inutile.",
        source = "paladin",
        currentRules = {
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [19891] = {
        name = "Fire Resistance Aura",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduction des dégâts de feu selon les adversaires.",
        source = "paladin",
        currentRules = {
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [20163] = {
        name = "Seal of Fury",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "holy", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "retribution", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [20164] = {
        name = "Seal of Justice",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle et prévention de fuite selon les mécaniques Forever; pas une protection certaine à chaque combat.",
        source = "paladin",
        currentRules = {
          { spec = "holy", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "retribution", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [25780] = {
        name = "Righteous Fury",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "holy", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
    },
    PRIEST = {
      [586] = {
        name = "Fade",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Gestion de menace en groupe, pas une disparition de combat en solo; les rangs peuvent compter.",
        source = "priest",
        currentRules = {
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
      [605] = {
        name = "Mind Control",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle tactique exigeant et dépendant des cibles; pas une fuite simple pour débutant.",
        source = "priest",
        currentRules = {
          { spec = "holy", minRank = 2, category = "rangs_reportables" },
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
      [1706] = {
        name = "Levitate",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Sécurité contre les chutes et traversée de terrain; ne couvre pas tous les dégâts.",
        source = "priest",
        currentRules = {
          { spec = "holy", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [2006] = {
        name = "Resurrection",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "discipline", minRank = 2, category = "rang_1_suffisant" },
          { spec = "holy", minRank = 2, category = "rangs_reportables" },
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
      [2060] = {
        name = "Greater Heal",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
      [2944] = {
        name = "Devouring Plague",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "holy", minRank = 2, category = "rangs_reportables" },
        },
      },
      [8122] = {
        name = "Psychic Scream",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Contrôle de secours; les rangs supérieurs peuvent couvrir davantage de cibles. Attention aux ennemis qui fuient.",
        source = "priest",
        currentRules = {
          { spec = "discipline", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [9484] = {
        name = "Shackle Undead",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle des morts-vivants; durée et limites des rangs à vérifier avant ECO.",
        source = "priest",
        currentRules = {
          { spec = "discipline", minRank = 2, category = "rang_1_suffisant" },
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
      [14752] = {
        name = "Divine Spirit",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "shadow", minRank = 2, category = "rangs_reportables" },
        },
      },
    },
    ROGUE = {
      [921] = {
        name = "Pick Pocket",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "assassination", minRank = 1, category = "reviewed_utility" },
          { spec = "combat", minRank = 1, category = "reviewed_utility" },
          { spec = "subtlety", minRank = 1, category = "reviewed_utility" },
        },
      },
      [1725] = {
        name = "Distract",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Éviter une patrouille ou faciliter un passage furtif; utilité préventive confirmée par joueurs Forever.",
        source = "rogue",
        currentRules = {
          { spec = "assassination", minRank = 1, category = "reviewed_utility" },
          { spec = "combat", minRank = 1, category = "reviewed_utility" },
          { spec = "subtlety", minRank = 1, category = "reviewed_utility" },
        },
      },
    },
    SHAMAN = {
      [6196] = {
        name = "Far Sight",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [8033] = {
        name = "Frostbrand Weapon",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Ralentissement offensif pouvant aider à garder les distances; concurrence les autres améliorations d’arme.",
        source = "shaman",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [8181] = {
        name = "Frost Resistance Totem",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Résistance givre selon zone/rencontre.",
        source = "shaman",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [8184] = {
        name = "Fire Resistance Totem",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Résistance feu selon zone/rencontre.",
        source = "shaman",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [10595] = {
        name = "Nature Resistance Totem",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Résistance nature selon zone/rencontre; achat conditionnel, pas défense universelle.",
        source = "shaman",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [15107] = {
        name = "Windwall Totem",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Protection contre certains dégâts à distance; intérêt et mécanique Forever à confirmer.",
        source = "shaman",
        currentRules = {
          { spec = "elemental", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "restoration", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
    },
    WARLOCK = {
      [126] = {
        name = "Eye of Kilrogg",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [132] = {
        name = "Detect Invisibility",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Détection d’invisibilité; défense indirecte selon ennemis.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [686] = {
        name = "Shadow Bolt",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "demonology", minRank = 2, category = "optionnel_selon_usage" },
        },
      },
      [698] = {
        name = "Ritual of Summoning",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [702] = {
        name = "Curse of Weakness",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduit la pression physique sur le joueur ou le démon; confirmé par retours Forever, efficacité selon cible.",
        source = "warlockPlayers",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [704] = {
        name = "Curse of Recklessness",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Peut empêcher la fuite et donc des renforts, mais augmente le danger physique; pas une défense à maintenir automatiquement.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 2, category = "rang_1_suffisant" },
          { spec = "demonology", minRank = 2, category = "rang_1_suffisant" },
          { spec = "destruction", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [710] = {
        name = "Banish",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Neutralise certains démons/élémentaires; contrôle défensif contextuel.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [755] = {
        name = "Health Funnel",
        survival = "direct",
        recommendation = "protect-first-purchase; review-extra-ranks",
        reason = "Maintient le démon en vie, donc la protection qu’il fournit; coûte de la vie au démoniste.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1098] = {
        name = "Subjugate Demon",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Contrôle de démons selon contenu, avec risque de rupture; pas un bouton de survie universel.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [1120] = {
        name = "Drain Soul",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 2, category = "rang_1_suffisant" },
          { spec = "demonology", minRank = 2, category = "rang_1_suffisant" },
          { spec = "destruction", minRank = 2, category = "rang_1_suffisant" },
        },
      },
      [1714] = {
        name = "Curse of Tongues",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduit la pression des lanceurs de sorts; contrôle utile selon adversaires.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [5138] = {
        name = "Drain Mana",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [5500] = {
        name = "Sense Demons",
        survival = "indirect",
        recommendation = "optional-with-context",
        reason = "Détection de démons; renseignement plutôt que défense.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [5676] = {
        name = "Searing Pain",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 2, category = "rang_1_suffisant" },
          { spec = "destruction", minRank = 2, category = "optionnel_selon_usage" },
        },
      },
      [5697] = {
        name = "Unending Breath",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Prévient la noyade pendant les quêtes aquatiques; sécurité liée au terrain.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [5740] = {
        name = "Rain of Fire",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [6229] = {
        name = "Shadow Ward",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Absorption d’ombre; utile contre cette école, protection accrue aux rangs supérieurs.",
        source = "warlock",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "demonology", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "destruction", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [6353] = {
        name = "Soul Fire",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
          { spec = "demonology", minRank = 1, category = "optionnel_leveling" },
          { spec = "destruction", minRank = 1, category = "optionnel_leveling" },
        },
      },
      [6366] = {
        name = "Create Firestone",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "affliction", minRank = 1, category = "optionnel_leveling" },
        },
      },
    },
    WARRIOR = {
      [694] = {
        name = "Mocking Blow",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Détournement d’un ennemi pour protéger un allié; rôle de groupe, pas une défense solo générale.",
        source = "warrior",
        currentRules = {
          { spec = "arms", minRank = 2, category = "optionnel_selon_usage" },
          { spec = "fury", minRank = 2, category = "rangs_reportables" },
        },
      },
      [1464] = {
        name = "Slam",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "fury", minRank = 1, category = "optionnel_selon_usage" },
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [1680] = {
        name = "Whirlwind",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "protection", minRank = 1, category = "optionnel_selon_usage" },
        },
      },
      [6343] = {
        name = "Thunder Clap",
        survival = "situational",
        recommendation = "context-required; review-extra-ranks",
        reason = "Réduction de pression des attaques selon mécanique Forever; peut aussi affecter la menace.",
        source = "warrior",
        currentRules = {
          { spec = "fury", minRank = 3, category = "rangs_reportables" },
        },
      },
      [7384] = {
        name = "Overpower",
        survival = "not-survival",
        recommendation = "keep-role-specific-review",
        reason = "Effet principal offensif, confort ou service; ne pas le rendre prioritaire au seul titre de la survie.",
        currentRules = {
          { spec = "protection", minRank = 2, category = "rangs_reportables" },
        },
      },
    },
  },
}
