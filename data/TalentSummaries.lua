-- Résumés éditoriaux en français, adaptés des guides Wowhead Forever.
-- Chaque entrée distingue le gameplay, les avantages et les limites.
-- Sources conservées pour maintenance ; aucun classement de puissance garanti.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end

SAK.TalentSummaries = {
  DRUID = {
    ["balance"] = {
      summary = "Équilibre joue à distance avec des sorts de nature et des arcanes, ainsi que des dégâts sur la durée. Les talents de Forever encouragent à alterner les grandes incantations selon les effets actifs. Le druide peut aussi interrompre son rythme offensif pour contrôler des ennemis ou apporter des soins de secours, au prix de temps et de mana.",
      advantages = {
        "Soutien varié : bonus, affaiblissements, contrôles et soins de secours.",
        "Alternance de sorts qui donne du rythme au jeu à distance.",
      },
      drawbacks = {
        "La mana reste une contrainte à surveiller pendant la progression.",
        "Cet arbre ne dispose pas d’une véritable interruption de sort.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/druid/balance/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["feral"] = {
      summary = "En forme de félin, Farouche utilise de l'énergie pour construire des points de combo, puis les dépenser sur ses attaques de finition. Forever ajoute des talents qui renforcent ses moments offensifs, sans reprendre à l'identique les changements de forme répétés de Classic. Le druide peut toujours sortir de sa forme ou passer en ours pour aider son groupe.",
      advantages = {
        "Dégâts de mêlée accompagnés de la polyvalence des formes du druide.",
        "Possibilité d’aider ponctuellement avec des soins ou la forme d’ours.",
      },
      drawbacks = {
        "L’énergie, les points de combo et les changements de forme demandent de l’attention.",
        "Aider dans un autre rôle ne remplace pas un équipement et des talents adaptés.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/druid/feral/overview-pve-dps",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
    ["guardian"] = {
      summary = "La version tank de Farouche utilise surtout la forme d'ours pour encaisser les attaques et garder les ennemis concentrés sur elle. Ses choix de talents et son équipement doivent privilégier cette fonction. La possibilité de changer de forme offre des solutions de secours, mais passer en félin ou lancer un soin ne remplace pas la préparation nécessaire à chaque rôle.",
      advantages = {
        "Fonctionnement de base abordable pour apprendre à tanker.",
        "Polyvalence des formes et capacité à s’adapter aux imprévus.",
      },
      drawbacks = {
        "L’équipement idéal pour tanker limite les performances dans les autres rôles.",
        "Exploiter toute la polyvalence du druide demande de l’expérience.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/druid/feral/overview-pve-tank",
      reviewed = "2026-11-13",
    },
    ["restoration"] = {
      summary = "Restauration s'appuie beaucoup sur des soins qui continuent d'agir pendant plusieurs secondes. Le joueur anticipe les dégâts, répartit ses effets sur les bons alliés et les complète avec des soins directs lorsque la situation l'exige. Sa force vient du suivi des cibles et de la préparation plutôt que d'une réaction identique à chaque perte de vie.",
      advantages = {
        "Bonne couverture des dégâts réguliers et soins ciblés disponibles en renfort.",
        "Outils précieux de soutien, de récupération de mana et de résurrection en combat.",
      },
      drawbacks = {
        "Les soins sur la durée demandent de l’anticipation et une bonne lecture du combat.",
        "Ne peut pas retirer tous les types d’effets néfastes, notamment magiques ou de maladie.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/druid/restoration/overview-pve-healer",
      reviewed = "2026-11-13",
    },
  },
  HUNTER = {
    ["beast-mastery"] = {
      summary = "Maîtrise des bêtes renforce la coopération entre le chasseur et son familier, qui prend une part importante dans les combats. Le chasseur utilise ses tirs, entretient les effets apportés par ses talents et dirige son compagnon. Le contrôle des distances, des pièges et du familier garde une grande importance même si les premières étapes sont assez accessibles.",
      advantages = {
        "Familier utile pour la progression en solo et pour ses capacités particulières.",
        "Bons moments de dégâts renforcés et plusieurs moyens de garder ses distances.",
      },
      drawbacks = {
        "Il faut surveiller le familier, son placement et son entretien.",
        "Les attaques à distance restent gênées si l’ennemi s’approche trop.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/hunter/beast-mastery/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["marksmanship"] = {
      summary = "Précision concentre une grande partie de son jeu sur les tirs du chasseur, avec des attaques puissantes qui demandent du temps pour être préparées. Le joueur doit bien choisir sa position et maintenir une distance adaptée avec les ennemis. Selon les talents retenus dans Forever, la place du familier peut changer : il ne faut pas supposer le fonctionnement d'une autre version du jeu.",
      advantages = {
        "Capacité à concentrer des dégâts importants avec les tirs préparés.",
        "Outils du chasseur pour ralentir, piéger et maintenir la distance.",
      },
      drawbacks = {
        "Les incantations et la distance minimale rendent le placement important.",
        "Les choix centrés sur le personnage peuvent réduire l’aide apportée par le familier.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/hunter/marksmanship/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["survival"] = {
      summary = "Survie propose un rythme offensif soutenu et utilise plus largement les possibilités du chasseur, à distance comme au corps à corps selon le combat et le choix de talents. Les pièges et les contrôles aident à gérer les déplacements ennemis. L'arbre prend davantage de relief une fois ses talents clés obtenus, plutôt que dès les tout premiers niveaux.",
      advantages = {
        "Rythme actif, avec des dégâts réguliers et de nombreux contrôles.",
        "Souplesse pour exploiter les outils du chasseur et les capacités du familier.",
      },
      drawbacks = {
        "L’arbre se construit progressivement avant de disposer de ses interactions importantes.",
        "Bien utiliser les différentes portées et gérer le matériel demande de l’attention.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/hunter/survival/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  MAGE = {
    ["arcane"] = {
      summary = "Arcanes fait de la mana une ressource à dépenser au bon moment : certains sorts augmentent la pression offensive mais rendent les enchaînements coûteux. Il faut alterner les phases de dépense avec des attaques plus économes et profiter des effets déclenchés par les talents. Le bon rythme dépend notamment de la durée du combat.",
      advantages = {
        "Bon potentiel de dégâts concentrés lors des moments importants.",
        "Outils intéressants pour économiser la mana et gérer les groupes d’ennemis.",
      },
      drawbacks = {
        "Une dépense trop rapide peut laisser le mage sans mana.",
        "Les priorités entre les sorts demandent davantage d’apprentissage.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/mage/arcane/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["fire"] = {
      summary = "Feu construit ses dégâts autour des coups critiques et des effets qu'ils déclenchent. Dans Forever, ces déclenchements accélèrent notamment les grosses incantations, tandis que certains effets sur la cible doivent être entretenus. Le joueur cherche à enchaîner ses attaques en profitant de ces occasions sans laisser tomber ses préparations.",
      advantages = {
        "Bon potentiel de dégâts à mesure que l’équipement progresse.",
        "Les critiques créent des enchaînements offensifs dynamiques.",
      },
      drawbacks = {
        "Une partie du résultat dépend de la fréquence des critiques.",
        "Il faut suivre les déclenchements et entretenir les effets nécessaires.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/mage/fire/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["frost"] = {
      summary = "Givre contrôle la distance avec des ralentissements et des immobilisations, puis exploite les occasions offertes par ses talents pour frapper plus fort. Ses protections permettent de mieux gérer les situations dangereuses. Le rythme de base reste accessible, mais tirer le meilleur de l'arbre demande de réagir aux effets temporaires qui apparaissent.",
      advantages = {
        "Nombreux contrôles et protections pour survivre.",
        "Bon contrôle des groupes grâce aux ralentissements de zone.",
      },
      drawbacks = {
        "Peu de récupération de vie pendant le combat.",
        "Les résistances au givre et les déclenchements manqués limitent son efficacité.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/mage/frost/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  PALADIN = {
    ["holy"] = {
      summary = "Sacré privilégie les soins tout en conservant les protections, bénédictions et auras du paladin. Forever ajoute des interactions permettant de mieux répondre aux dégâts de groupe, en plus des soins ciblés. Le fonctionnement de base est accessible, mais il faut progressivement apprendre à choisir les bons outils de soutien et à gérer ses sceaux.",
      advantages = {
        "Bonne capacité à protéger un allié en difficulté et à résister soi-même.",
        "Soins ciblés, soutien varié et nouveaux outils pour le groupe.",
      },
      drawbacks = {
        "Le nombre de bénédictions, sceaux et protections demande de l’apprentissage.",
        "Choisir le bon outil selon la situation reste plus important que répéter un seul soin.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/paladin/holy/overview-pve-healer",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
    ["protection"] = {
      summary = "Protection utilise un bouclier, des effets sacrés et ses auras pour encaisser et attirer l'attention des ennemis. Il est particulièrement à l'aise lorsque plusieurs adversaires restent regroupés autour de ses zones offensives. Contrairement aux tanks qui utilisent la rage, il doit aussi gérer sa mana pour continuer à lancer ses capacités pendant toute la rencontre.",
      advantages = {
        "Outils intéressants contre plusieurs ennemis et contre les dégâts magiques.",
        "Protections et soutien du paladin utiles au groupe.",
      },
      drawbacks = {
        "La reprise immédiate d’un ennemi peut demander une bonne préparation.",
        "La mana et les grosses pointes de dégâts restent des points de vigilance.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/paladin/protection/overview-pve-tank",
      reviewed = "2026-11-13",
    },
    ["retribution"] = {
      summary = "Vindicte est la voie de dégâts de mêlée du paladin : ses attaques avec une arme se combinent à des effets sacrés, aux sceaux et au Jugement. Il conserve les bénédictions, auras et protections qui lui permettent d'aider son groupe. Bien jouer consiste donc aussi à utiliser ce soutien au bon moment, sans abandonner inutilement sa pression offensive.",
      advantages = {
        "Dégâts sur une cible et sur des groupes, accompagnés d’un soutien varié.",
        "Plusieurs protections et outils de secours pour aider les alliés.",
      },
      drawbacks = {
        "L’équipement et la gestion d’une réserve de mana limitée ont un impact important.",
        "Le rôle DPS ne permet pas de remplacer automatiquement un tank ou un soigneur spécialisé.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/paladin/retribution/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  PRIEST = {
    ["discipline"] = {
      summary = "Discipline combine soins et absorption : les boucliers permettent d'éviter une partie des dégâts plutôt que de tout réparer ensuite. Le prêtre alterne ces protections avec ses soins et ses outils de soutien selon la situation. Il conserve assez de moyens offensifs et défensifs pour progresser seul, en plus de son rôle de soigneur en groupe.",
      advantages = {
        "Boucliers efficaces et bonne résistance personnelle.",
        "Soutien utile au groupe et progression solo accessible.",
      },
      drawbacks = {
        "Les soins sur plusieurs alliés sont moins développés que ses outils ciblés.",
        "Un bon résultat demande de choisir quand protéger et quand soigner.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/priest/discipline/overview-pve-healer",
      reviewed = "2026-11-13",
    },
    ["holy"] = {
      summary = "Sacré propose une large palette de soins pour répondre aux dégâts subis par un allié ou par le groupe. Forever ajoute notamment des outils qui soignent plusieurs personnes ou rebondissent entre les alliés, tout en conservant les soins directs classiques. Le joueur adapte son sort à l'urgence, au nombre de blessés et à sa réserve de mana.",
      advantages = {
        "Palette de soins variée, adaptée à de nombreuses situations de groupe.",
        "Bonus de groupe et outils défensifs utiles pendant la progression.",
      },
      drawbacks = {
        "Demande d’apprendre quel soin choisir plutôt que de répéter un seul sort.",
        "La gestion de la mana et des incantations reste importante.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/priest/holy/overview-pve-healer",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
    ["shadow"] = {
      summary = "Ombre transforme le prêtre en lanceur de sorts offensif : il maintient ses effets sur la cible et les complète avec ses attaques d'ombre. Son identité se développe progressivement avec les talents, en particulier avec la Forme d'ombre. Il apporte aussi du soutien indirect au groupe, mais ne joue pas comme un soigneur spécialisé lorsqu'il reste dans cette forme.",
      advantages = {
        "Bon potentiel en solo, avec plusieurs outils pour survivre.",
        "Effets offensifs accompagnés de soutien indirect au groupe.",
      },
      drawbacks = {
        "Le fonctionnement caractéristique de l’arbre arrive progressivement pendant le leveling.",
        "Les soins directs nécessitent de quitter la Forme d’ombre.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/priest/shadow/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  ROGUE = {
    ["assassination"] = {
      summary = "Assassinat construit des points de combo avec ses attaques, puis les dépense surtout pour entretenir ses principaux effets offensifs. Dans Forever, le rythme décrit par le guide repose davantage sur le suivi de ces effets que sur une longue liste de grandes capacités à déclencher. C'est une approche assez directe, mais qui demande de surveiller son énergie et ses renouvellements.",
      advantages = {
        "Fonctionnement de base accessible et priorités assez lisibles.",
        "Peu de grandes capacités offensives à synchroniser.",
      },
      drawbacks = {
        "Les effets essentiels doivent être renouvelés sans gaspiller les points de combo.",
        "Le nombre limité de grands bonus offensifs laisse moins de leviers pour une urgence.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/rogue/assassination/overview-pve-dps",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
    ["combat"] = {
      summary = "Combat favorise une approche directe du combat de mêlée, en construisant des points de combo pour entretenir sa vitesse d'attaque et lancer ses finitions. Il dispose de moments offensifs renforcés qu'il faut exploiter au bon moment. Les attaques automatiques occupent une place importante, et cet arbre dépend moins des poisons et saignements pour faire fonctionner son plan de jeu.",
      advantages = {
        "Bonnes possibilités de frapper plusieurs ennemis proches.",
        "Moments de dégâts renforcés et fonctionnement de base assez direct.",
      },
      drawbacks = {
        "La gestion de l’énergie impose parfois des temps d’attente.",
        "Le soutien au groupe repose surtout sur les dégâts, interruptions et outils du voleur.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/rogue/combat/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["subtlety"] = {
      summary = "Finesse s'appuie sur les saignements, les points de combo et l'utilisation du camouflage pour renforcer ses attaques. Le joueur entretient plusieurs effets, profite des ouvertures et peut réutiliser la disparition pour retrouver certaines attaques de camouflage. Dans Forever, cette voie ne se résume donc pas à préparer une seule grosse attaque d'ouverture.",
      advantages = {
        "Les saignements continuent d’agir lorsque le voleur doit momentanément s’éloigner.",
        "Outils de camouflage, de survie et de contrôle propres au voleur.",
      },
      drawbacks = {
        "Les ennemis insensibles aux saignements contrarient fortement son fonctionnement.",
        "Plusieurs effets et utilisations du camouflage sont à gérer en plus de l’énergie.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/rogue/subtlety/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  SHAMAN = {
    ["elemental"] = {
      summary = "Élémentaire combat à distance avec des éclairs et des sorts de feu, tout en soutenant le groupe grâce aux totems. Les attaques qui touchent plusieurs ennemis proches tiennent une place importante dans son arsenal. Le rythme offensif reste abordable, mais les gros enchaînements peuvent coûter beaucoup de mana et demandent de bien placer ses totems.",
      advantages = {
        "Bon potentiel contre les groupes d’ennemis.",
        "Totems et contrôles apportant du soutien au groupe.",
      },
      drawbacks = {
        "Les enchaînements offensifs peuvent rapidement consommer la mana.",
        "Le placement et la portée des totems demandent un suivi régulier.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/shaman/elemental/overview-pve-dps",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
    ["enhancement"] = {
      summary = "Amélioration associe les attaques de mêlée aux renforcements d'arme, aux totems et aux occasions de lancer des sorts sans leur préparation habituelle. Les attaques automatiques gardent une place importante, ce qui laisse le temps d'apprendre à gérer le soutien du groupe. À mesure que les talents arrivent, il faut aussi réagir aux charges et aux effets qui rendent certains sorts plus avantageux.",
      advantages = {
        "Jeu de base accessible et soutien important grâce aux totems.",
        "Mobilité et possibilités de dégâts contre plusieurs ennemis.",
      },
      drawbacks = {
        "Il faut gérer la mana, les charges offensives et le placement des totems.",
        "Une part de son utilité est commune aux autres spécialisations de chaman.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/shaman/enhancement/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["restoration"] = {
      summary = "Restauration soigne avec un mélange de soins directs, d'effets sur la durée et de soins qui rebondissent entre les alliés. Les totems complètent ce travail en apportant des bonus et du soutien. Forever enrichit cette base sans en changer l'idée principale : choisir le bon soin pour les blessés et maintenir ses outils de groupe en bonne position.",
      advantages = {
        "Soins ciblés et soins sur plusieurs alliés dans une même boîte à outils.",
        "Soutien des totems et nouveaux outils de récupération de mana.",
      },
      drawbacks = {
        "Le placement des alliés et des totems compte pour profiter du soutien.",
        "Une progression centrée sur les soins est surtout adaptée au jeu en groupe.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/shaman/restoration/overview-pve-healer",
      reviewed = "2026-11-13",
      editorialNote = "Avantages et limites synthétisés depuis le gameplay décrit ; la rubrique dédiée du guide est absente ou incomplète.",
    },
  },
  WARLOCK = {
    ["affliction"] = {
      summary = "Un lanceur de sorts à distance qui affaiblit ses ennemis avec des dégâts sur la durée, puis utilise ses drains entre les renouvellements. Il peut entretenir ses effets sur plusieurs adversaires tout en s'appuyant sur son démon. Son efficacité augmente quand les combats lui laissent le temps d'installer et de maintenir ces effets.",
      advantages = {
        "À l’aise sur les combats longs et contre plusieurs ennemis séparés.",
        "Les drains apportent de la récupération de vie et une bonne autonomie.",
      },
      drawbacks = {
        "Moins efficace quand les ennemis meurent avant que ses effets aient agi.",
        "Demande de surveiller plusieurs durées et plusieurs cibles.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warlock/affliction/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["demonology"] = {
      summary = "Cet arbre renforce le lien entre le démoniste et ses familiers : leurs dégâts, leur résistance et leurs bonus se complètent. Dans Forever, certains talents permettent de profiter d'un sacrifice tout en gardant un autre démon au combat. Le joueur entretient ses effets offensifs et doit aussi bien diriger et protéger son compagnon.",
      advantages = {
        "Bonne résistance et soutien du familier pour progresser en solo.",
        "Dégâts solides sur une cible et outils renforcés pour achever un ennemi.",
      },
      drawbacks = {
        "La perte ou le mauvais placement du démon pénalise les dégâts.",
        "Le choix du démon et des bonus doit rester adapté au combat.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warlock/demonology/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["destruction"] = {
      summary = "Destruction privilégie les sorts de feu et les dégâts directs, tout en maintenant certains effets sur la cible. Le jeu consiste à préparer ces effets, utiliser les attaques instantanées lorsqu'elles sont disponibles et compléter avec les sorts à incantation. Le démon reste présent, mais le rythme repose davantage sur les attaques du personnage.",
      advantages = {
        "Bonne capacité à concentrer rapidement ses dégâts.",
        "Les talents renforcent aussi les dégâts de feu contre des groupes.",
      },
      drawbacks = {
        "Les effets répartis sur plusieurs cibles sont moins renforcés qu’en Affliction.",
        "Certaines attaques de zone imposent de s’approcher et de surveiller sa vie.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warlock/destruction/overview-pve-dps",
      reviewed = "2026-11-13",
    },
  },
  WARRIOR = {
    ["arms"] = {
      summary = "Armes privilégie des coups puissants avec une arme à deux mains, tout en profitant de saignements et d'occasions d'attaquer. La rage gagnée au combat doit être utilisée au bon moment plutôt que dépensée sans réserve. Le guerrier dispose aussi de déplacements rapides et de contrôles qui l'aident à rester au contact de ses adversaires.",
      advantages = {
        "Bonne mobilité et capacité à concentrer ses attaques sur un moment précis.",
        "Outils intéressants contre plusieurs ennemis proches et pour contrôler une cible.",
      },
      drawbacks = {
        "Les attaques manquées peuvent provoquer un manque de rage.",
        "Récupération de vie limitée et gestion des ressources nécessaire sur la durée.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warrior/arms/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["fury"] = {
      summary = "Fureur joue sur le rythme des attaques de mêlée et la dépense de rage, avec des capacités qui renforcent temporairement la pression offensive. Les dégâts contre quelques ennemis regroupés font partie de ses points forts. Le joueur doit surveiller sa ressource, utiliser ses attaques prioritaires et choisir quand profiter de ses grands bonus offensifs.",
      advantages = {
        "Bonnes possibilités de dégâts sur quelques ennemis proches.",
        "Capacités offensives utiles pour accélérer les dégâts à un moment choisi.",
      },
      drawbacks = {
        "Les armes et les caractéristiques de l’équipement ont une grande importance.",
        "Certains grands bonus offensifs reviennent lentement et ne sont pas disponibles à chaque combat.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warrior/fury/overview-pve-dps",
      reviewed = "2026-11-13",
    },
    ["protection"] = {
      summary = "Protection utilise surtout une arme et un bouclier pour encaisser, réduire les dégâts subis et garder l'attention des ennemis. Le guerrier construit sa rage pendant le combat et la dépense pour maintenir sa menace et ses protections. Son rôle consiste aussi à placer les adversaires et à affaiblir leurs attaques pour sécuriser le groupe.",
      advantages = {
        "Outils solides de réduction des dégâts et de reprise rapide d’un ennemi.",
        "Affaiblissements et protections utiles pour sécuriser les combats.",
      },
      drawbacks = {
        "Il faut gérer la rage et les protections au rythme des attaques ennemies.",
        "L’efficacité offensive baisse lorsqu’il n’est pas activement en train d’encaisser.",
      },
      source = "https://www.wowhead.com/forever/guide/classes/warrior/protection/overview-pve-tank",
      reviewed = "2026-11-13",
    },
  },
}
