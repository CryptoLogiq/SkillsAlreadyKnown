-- Reviewed rank-one advice; source context: scripts/research/eco-spells-forever.lua.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

-- true allows every specialization within that role.
SAK.RankOneRules = {
  DRUID = {
    [339] = {
      contexts = {
        dps = {
          feral = true,
        },
        tank = {
          guardian = true,
        },
      },
      reason = "Le rang 1 conserve une immobilisation de secours en Farouche. Les rangs suivants améliorent le contrôle.",
    },
  },
  PALADIN = {
    [465] = {
      contexts = {
        dps = {
          retribution = true,
        },
      },
      reason = "Aura de dévotion : le rang 1 peut suffire pendant le leveling Vindicte, hors rôle tank.",
    },
    [633] = {
      contexts = {
        dps = {
          retribution = true,
        },
      },
      reason = "Imposition des mains : le guide Vindicte propose de conserver le rang 1 pendant le leveling.",
    },
    [6940] = {
      contexts = {
        dps = {
          retribution = true,
        },
      },
      reason = "Le rang 1 de Bénédiction de sacrifice conserve l'usage de transfert de dégâts ; les rangs suivants restent utiles.",
    },
  },
  PRIEST = {
    [2006] = {
      contexts = {
        heal = true,
      },
      reason = "Résurrection : le rang 1 permet de ressusciter ; les rangs suivants rendent davantage de vie et de mana.",
    },
    [8122] = {
      contexts = {
        heal = {
          discipline = true,
        },
      },
      reason = "Cri psychique : le rang 1 garde un contrôle de secours ; les rangs suivants peuvent toucher davantage de cibles.",
    },
    [9484] = {
      contexts = {
        heal = {
          discipline = true,
        },
      },
      reason = "Entraves : le rang 1 conserve un contrôle de base ; les rangs suivants améliorent sa durée.",
    },
  },
  WARLOCK = {
    [704] = {
      contexts = {
        dps = true,
      },
      reason = "Le rang 1 de Malédiction de témérité conserve l'effet empêchant la fuite, sans rechercher son effet offensif maximal.",
    },
    [1120] = {
      contexts = {
        dps = true,
      },
      reason = "Drain d'âme : le rang 1 suffit pour récupérer un fragment en fin de combat. Ce conseil ne compare pas les dégâts.",
    },
    [5676] = {
      contexts = {
        dps = {
          affliction = true,
        },
      },
      reason = "Douleur brûlante : le guide Affliction propose le rang 1 comme petit sort de finition. Ce conseil ne s'applique pas à Démonologie.",
    },
  },
}
