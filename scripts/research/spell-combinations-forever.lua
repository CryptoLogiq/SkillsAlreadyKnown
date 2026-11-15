-- Maintained research, original paraphrases. No automatic import into runtime hints.
-- Missing IDs are intentional; resolve from the current Forever client before promotion.
return {
  reviewed = "2026-11-15",
  edition = "WoW Forever",
  runtime = "research-only; not loaded by the TOC",
  policy = "Une aide ciblée sur le sort principal ; pas de conseil générique sur chaque sort. Shortlist = proposition, pas activation.",
  classes = {
    DRUID = {
      {
        key = "hot-swiftmend",
        spells = {
          {
            name = "Swiftmend",
            id = 18562,
          },
          {
            name = "Rejuvenation",
          },
          {
            name = "Regrowth",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Prompte guérison demande une Récupération ou un Rétablissement actif sur la cible et apporte un soin immédiat.",
        conditions = {
          "Talent Prompte guérison appris ; soin sur la durée présent sur la cible.",
        },
        caution = "Dans Forever, le soin sur la durée n’est plus consommé. Ne pas reprendre le conseil Classic de systématiquement attendre sa dernière seconde.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/druid/restoration/overview-pve-healer",
          "https://www.wowhead.com/forever/spell=18562/swiftmend",
        },
      },
      {
        key = "natures-swiftness-healing-touch",
        spells = {
          {
            name = "Nature's Swiftness",
          },
          {
            name = "Healing Touch",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Rapidité de la nature permet de lancer immédiatement un Toucher guérisseur pour répondre à une urgence.",
        conditions = {
          "Talent Rapidité de la nature appris et disponible.",
        },
        caution = "Ce n’est pas un bonus de soin automatique ni une garantie de sauver la cible. Réserver l’aide au bouton du talent.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/druid/restoration/rotation-cooldowns-pve-healer",
        },
      },
    },
    HUNTER = {
      {
        key = "monkey-mongoose",
        spells = {
          {
            name = "Mongoose Bite",
            id = 1495,
          },
          {
            name = "Aspect of the Monkey",
            id = 13163,
          },
        },
        status = "mechanical-inference",
        selection = "reserve",
        summary = "Sans talent qui modifie son déclenchement, Morsure de la mangouste devient disponible après une esquive ; Aspect du singe augmente les chances d’esquiver.",
        conditions = {
          "Combattre au corps à corps ; tenir compte des talents de Survie qui modifient cette condition.",
        },
        caution = "Lien déduit de deux mécanismes explicites ; ne pas conseiller de subir des attaques volontairement ni de remplacer systématiquement un autre aspect.",
        sources = {
          "https://www.wowhead.com/forever/spell=1495/mongoose-bite",
          "https://www.wowhead.com/forever/spell=13163/aspect-of-the-monkey",
          "https://www.wowhead.com/forever/guide/classes/hunter/survival/dps-abilities",
        },
      },
      {
        key = "readiness-traps",
        spells = {
          {
            name = "Readiness",
            id = 23989,
          },
          {
            name = "Freezing Trap",
          },
        },
        status = "mechanical-inference",
        selection = "verify-in-game",
        summary = "Promptitude réinitialise les temps de recharge des autres compétences du chasseur ; les pièges sont un cas utile à vérifier en jeu.",
        conditions = {
          "Promptitude apprise ; vérifier le piège et les restrictions réelles du client Forever.",
        },
        caution = "Le texte global de réinitialisation ne prouve pas tous les détails du partage de recharge ou du placement des pièges. Aucun conseil de double piège automatique.",
        sources = {
          "https://www.wowhead.com/forever/spell=23989/readiness",
        },
      },
    },
    MAGE = {
      {
        key = "frozen-ice-lance",
        spells = {
          {
            name = "Ice Lance",
            id = 1240047,
            rank = 6,
            idScope = "reference-rank-not-base-id",
          },
          {
            name = "Frost Nova",
            id = 122,
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Javelot de glace inflige davantage de dégâts à une cible gelée. Nova de givre permet d’obtenir cet état si la cible y est sensible.",
        conditions = {
          "La cible doit être gelée : un simple ralentissement ne suffit pas.",
        },
        caution = "Ne pas figer le multiplicateur : les rangs et versions des pages affichent des valeurs différentes. Ne pas promettre de geler un boss insensible.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/mage/frost/dps-abilities",
          "https://www.wowhead.com/forever/spell=1240047/ice-lance",
        },
      },
      {
        key = "fingers-of-frost-ice-lance",
        spells = {
          {
            name = "Fingers of Frost",
          },
          {
            name = "Ice Lance",
          },
        },
        status = "documented",
        selection = "merge-into-ice-lance",
        summary = "Avec le talent Doigts de givre, son déclenchement permet de bénéficier des interactions sur cible gelée, même contre une cible qui ne peut pas être immobilisée.",
        conditions = {
          "Talent Doigts de givre appris ; effet réellement actif.",
        },
        caution = "À intégrer comme précision conditionnelle de la même astuce Javelot, pas comme une seconde aide sur tous les sorts de givre.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/mage/frost/dps-abilities",
          "https://www.wowhead.com/forever/guide/classes/mage/frost/rotation-cooldowns-pve-dps",
        },
      },
    },
    PALADIN = {
      {
        key = "seal-judgement",
        spells = {
          {
            name = "Judgement",
            id = 20271,
          },
          {
            name = "Seal: chosen by player",
          },
        },
        status = "documented",
        selection = "already-shipped",
        summary = "Jugement nécessite un sceau actif : rappeler son activation si le joueur ne comprend pas pourquoi le sort est indisponible.",
        conditions = {
          "Sceau actif ; les autres conditions habituelles du sort restent nécessaires.",
        },
        caution = "Déjà présent dans data/SpellHints.lua. Dans Forever, Jugement ne consomme pas le sceau ; ne pas suggérer de le réactiver après chaque Jugement.",
        sources = {
          "https://www.wowhead.com/forever/spell=20271/judgement",
        },
      },
      {
        key = "divine-favor-heal",
        spells = {
          {
            name = "Divine Favor",
            id = 20216,
          },
          {
            name = "Holy Light",
          },
          {
            name = "Flash of Light",
          },
          {
            name = "Holy Shock",
            id = 20473,
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Faveur divine augmente fortement la probabilité de critique du prochain sort admissible : Lumière sacrée, Éclair lumineux ou Horion sacré.",
        conditions = {
          "Talent Faveur divine appris ; choisir un des sorts explicitement concernés.",
        },
        caution = "Ne pas étendre le bonus à tous les sorts sacrés ou garantir qu’un sort offensif touche sa cible.",
        sources = {
          "https://www.wowhead.com/forever/spell=20216/divine-favor",
        },
      },
      {
        key = "lights-vigil-holy-shock",
        spells = {
          {
            name = "Light's Vigil",
          },
          {
            name = "Holy Shock",
            id = 20473,
          },
        },
        status = "documented",
        selection = "verify-in-game",
        summary = "La marque de Veille de la Lumière interagit avec le prochain Horion sacré sur la même cible : effet de groupe sur allié ou effet offensif sur ennemi.",
        conditions = {
          "Talent appris ; marque et Horion sur la même cible.",
        },
        caution = "Revalider l’ID exact, le nom français du client et les effets de la version courante avant affichage. Pas de montants ou de pourcentages copiés de la bêta.",
        sources = {
          "https://www.wowhead.com/forever/news/paladin-class-deep-dive-in-wow-forever-383440",
        },
      },
    },
    PRIEST = {
      {
        key = "inner-focus-large-heal",
        spells = {
          {
            name = "Inner Focus",
          },
          {
            name = "Prayer of Healing",
          },
          {
            name = "Greater Heal",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Focalisation améliorée permet d’économiser le coût d’un gros soin admissible, par exemple Prière de soins ou Soins supérieurs, avec un bonus de critique si le sort peut critiquer.",
        conditions = {
          "Talent appris et disponible ; prochain sort admissible.",
        },
        caution = "Afficher sur le talent plutôt que répéter le conseil sur chaque soin. Ne pas dire que toutes les actions consomment le bonus.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/priest/discipline/rotation-cooldowns-pve-healer",
          "https://www.wowhead.com/forever/guide/classes/priest/discipline/healer-abilities",
        },
      },
      {
        key = "holy-fire-free-nova",
        spells = {
          {
            name = "Searing Light",
            id = 14909,
          },
          {
            name = "Holy Fire",
          },
          {
            name = "Holy Nova",
            id = 15237,
          },
        },
        status = "documented",
        selection = "already-covered-by-aoe",
        summary = "Avec Lumière incendiaire, les dégâts périodiques de Flammes sacrées peuvent permettre une Nova sacrée gratuite.",
        conditions = {
          "Talent appris ; attendre le déclenchement au lieu de supposer le bonus permanent.",
        },
        caution = "Relation déjà reliée dans AreaTalents et son détail AOE. Éviter de la redoubler dans un autre bloc d’aide.",
        sources = {
          "https://www.wowhead.com/forever/spell=14909/searing-light",
          "https://www.wowhead.com/forever/guide/classes/priest/holy/healer-abilities",
        },
      },
      {
        key = "weakened-soul-shield",
        spells = {
          {
            name = "Power Word: Shield",
          },
          {
            name = "Weakened Soul",
            id = 6788,
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Âme affaiblie empêche de remettre Mot de pouvoir : Bouclier sur la cible pendant cet effet.",
        conditions = {
          "Vérifier le débuff présent et les talents qui modifient le comportement.",
        },
        caution = "C’est un prérequis d’utilisation, pas une combinaison offensive. À garder en réserve pour une demande de conseils d’indisponibilité.",
        sources = {
          "https://www.wowhead.com/forever/spell=6788/weakened-soul",
          "https://www.wowhead.com/forever/guide/classes/priest/discipline/healer-abilities",
        },
      },
    },
    ROGUE = {
      {
        key = "cold-blood-finisher",
        spells = {
          {
            name = "Cold Blood",
            id = 14177,
          },
          {
            name = "Eviscerate",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Sang froid peut préparer une Éviscération avec une forte probabilité de critique ; l’intérêt dépend aussi des points de combo disponibles.",
        conditions = {
          "Talent Sang froid appris ; prochain coup appartenant à sa liste de techniques admissibles.",
        },
        caution = "Le bonus n’assure pas de toucher. Une autre attaque admissible peut utiliser le bonus avant le coup prévu.",
        sources = {
          "https://www.wowhead.com/forever/spell=14177/cold-blood",
        },
      },
      {
        key = "gouge-bandage",
        spells = {
          {
            name = "Gouge",
          },
          {
            name = "First Aid bandage",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Sur une cible sensible, Suriner peut laisser un court répit pour se soigner avec un bandage.",
        conditions = {
          "Cible contrôlable ; bandage utilisable ; éviter les dégâts qui brisent le contrôle.",
        },
        caution = "Conseil situationnel de survie, pas une garantie : dégâts périodiques et autres ennemis peuvent interrompre cette fenêtre.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/rogue/combat/dps-leveling-tips",
        },
      },
    },
    SHAMAN = {
      {
        key = "fire-totem-fire-nova",
        spells = {
          {
            name = "Fire Nova",
            id = 408341,
          },
          {
            name = "Active Fire totem",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Nova de feu se déclenche autour du totem de feu actif : placer le totem près des ennemis plutôt que se fier à la position du chaman.",
        conditions = {
          "Totem de feu actif et correctement placé.",
        },
        caution = "Ne pas confondre avec l’ancien Totem Nova de feu de Classic. Les contraintes de portée et les autres prérequis restent applicables.",
        sources = {
          "https://www.wowhead.com/forever/spell=408341/fire-nova",
          "https://www.wowhead.com/forever/guide/classes/shaman/restoration/overview-pve-healer",
        },
      },
      {
        key = "riptide-chain-heal",
        spells = {
          {
            name = "Riptide",
            id = 408521,
          },
          {
            name = "Chain Heal",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Remous sur la cible de départ améliore les Salves de guérison lancées directement sur elle.",
        conditions = {
          "Talent Remous appris ; cibler le porteur de l’effet, pas simplement un allié voisin.",
        },
        caution = "Ne pas affirmer que le soin sur la durée est consommé. Le soin initial de Remous a changé pendant la bêta ; ce conseil porte seulement sur la synergie.",
        sources = {
          "https://www.wowhead.com/forever/spell=408521/riptide",
          "https://www.wowhead.com/forever/guide/classes/shaman/restoration/overview-pve-healer",
        },
      },
      {
        key = "natures-swiftness-healing-wave",
        spells = {
          {
            name = "Nature's Swiftness",
          },
          {
            name = "Healing Wave",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Rapidité de la nature permet un soin de Vague de soins instantané pour répondre à une urgence.",
        conditions = {
          "Talent appris ; vérifier les sorts admissibles dans la version courante.",
        },
        caution = "Conseil uniquement sur le bouton du talent, pas sur tous les rangs de soins.",
        sources = {
          "https://www.wowhead.com/forever/guide/restoration-shaman-healing-guide-for-wow-forever-35071",
        },
      },
      {
        key = "flame-shock-lava-burst",
        spells = {
          {
            name = "Lava Burst",
            id = 408490,
          },
          {
            name = "Flame Shock",
          },
        },
        status = "conflicting-or-removed",
        selection = "excluded",
        summary = "Ancienne combinaison trouvée : Horion de flammes augmente les dégâts d’Explosion de lave.",
        conditions = {
          "Ne pas activer : des notes de développement plus récentes annoncent le retrait d’Explosion de lave.",
        },
        caution = "Le simple maintien d’une fiche de sort dans une base ne prouve pas que le sort soit accessible. Vérifier le client et les notes actuelles.",
        sources = {
          "https://www.wowhead.com/forever/spell=408490/lava-burst",
          "https://www.wowhead.com/forever/news/wow-forever-official-development-notes-and-class-tuning-383704",
        },
      },
    },
    WARLOCK = {
      {
        key = "immolate-conflagrate",
        spells = {
          {
            name = "Conflagrate",
            id = 1293818,
          },
          {
            name = "Immolate",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Conflagration demande ton Immolation sur la cible. Sans l’amélioration appropriée, elle la consomme ; à rang maximal, Ombre et flammes change ce comportement.",
        conditions = {
          "Immolation du joueur sur la cible ; distinguer présence et rang du talent Ombre et flammes.",
        },
        caution = "Ne pas conseiller systématiquement d’attendre la dernière seconde : le talent peut rendre ce conseil inadapté.",
        sources = {
          "https://www.wowhead.com/forever/spell=1293818/conflagrate",
          "https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps",
        },
      },
      {
        key = "immolate-incinerate",
        spells = {
          {
            name = "Incinerate",
          },
          {
            name = "Immolate",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Incinérer fait davantage de dégâts sur une cible affectée par Immolation.",
        conditions = {
          "Incinérer appris ; Immolation présente sur la cible.",
        },
        caution = "Ne pas utiliser un ancien ID de Retail/SoD ou un pourcentage supposé avant de vérifier le sort Forever réellement appris.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps",
          "https://www.wowhead.com/forever/guide/classes/warlock/destruction/dps-abilities",
        },
      },
      {
        key = "shadow-and-flame-cross-buffs",
        spells = {
          {
            name = "Shadow and Flame",
          },
          {
            name = "Conflagrate",
          },
          {
            name = "Shadowburn",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Avec Ombre et flammes, Conflagration renforce les dégâts d’ombre et Brûlure de l’ombre renforce les dégâts de feu.",
        conditions = {
          "Talent appris ; ses effets et chances dépendent du rang.",
        },
        caution = "Mécanique de spécialisation plus avancée : conserver en réserve pour éviter d’encombrer les infobulles de base.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps",
        },
      },
    },
    WARRIOR = {
      {
        key = "shield-block-revenge",
        spells = {
          {
            name = "Shield Block",
            id = 2565,
          },
          {
            name = "Revenge",
          },
        },
        status = "documented",
        selection = "shortlist",
        summary = "Maîtrise du blocage favorise un blocage, qui peut rendre Revanche utilisable ; Revanche peut aussi se déclencher après une esquive ou une parade.",
        conditions = {
          "Bouclier équipé et conditions de posture/attaque remplies.",
        },
        caution = "Activer Maîtrise du blocage ne signifie pas qu’une attaque a déjà été bloquée. Ne pas promettre un déclenchement si personne ne frappe le guerrier.",
        sources = {
          "https://www.wowhead.com/forever/guide/classes/warrior/protection/tank-abilities",
          "https://www.wowhead.com/forever/spell=2565/shield-block",
        },
      },
      {
        key = "dodge-overpower",
        spells = {
          {
            name = "Overpower",
            id = 11585,
            rank = 4,
            idScope = "reference-rank-not-base-id",
          },
          {
            name = "Battle Stance",
          },
        },
        status = "documented",
        selection = "reserve",
        summary = "Fulgurance devient disponible après une esquive de la cible et nécessite la posture appropriée.",
        conditions = {
          "L’ennemi a esquivé ; vérifier la posture de combat et l’équipement.",
        },
        caution = "C’est une condition de déclenchement, pas une combinaison à forcer. Garder en réserve pour les aides sur les boutons grisés.",
        sources = {
          "https://www.wowhead.com/forever/spell=11585/overpower",
          "https://www.wowhead.com/forever/guide/classes/warrior/protection/tank-abilities",
        },
      },
    },
  },
}
