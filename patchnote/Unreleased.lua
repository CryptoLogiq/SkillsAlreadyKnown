-- Notes destinées aux joueurs.
return {
  version = "Unreleased",
  status = "development",
  basedOn = "0.4.1",
  additions = {
    "De nouveaux repères distinguent les usages des sorts : CLASS, AOE, SURVIVAL, KICK, TAUNT et AGGRO. Les infobulles expliquent leurs conditions ; plusieurs usages peuvent se cumuler.",
    "Les formes, postures et auras renseignées affichent TANK, HEAL ou DPS, notamment les auras du paladin. Ces indications ne changent pas le rôle choisi.",
    "Dans le grimoire, RECENT scintille en doré si le sort manque dans les barres, puis en bleu après placement tant qu’aucune utilisation réussie n’est enregistrée. Le suivi est conservé après rechargement et le badge RECENT reste après utilisation.",
    "Les étincelles bleues apparaissent aussi sur les barres Blizzard et EllesmereUI reconnues, y compris les barres de postures, formes et auras. L’infobulle explique le repère.",
    "Les icônes NEW + scintillent chez les maîtres de classe et de métiers. Les recettes non apprises reconnues scintillent chez les marchands et dans le butin, uniquement autour de leur icône. Ces effets se règlent dans Affichage.",
    "Dans Custom → Badges des sorts, personnalise les marqueurs d’usage, PvP et d’achat de ta classe, ou ajoute un sort par son ID. Les choix peuvent concerner ce personnage ou toute la classe sur le compte, avec Tous les rangs coché par défaut.",
    "Les badges peuvent apparaître au-dessus des infobulles. Dans le grimoire, les catégories sont placées juste au-dessus de BEST, LOW ou ECO pour dégager le nom du sort.",
    "Une sélection d’astuces explique des combinaisons utiles : Jugement avec un sceau, Javelot de glace sur cible gelée, Prompte guérison avec un soin sur la durée, Nova de feu avec un totem de feu et Conflagration avec Immolation.",
    "Certains talents du paladin indiquent les spécialisations conseillées avec leur icône et le contexte précis du build du guide. Les variantes situationnelles sont distinguées du build standard.",
    "Les talents qui améliorent des sorts de zone présentent les sorts concernés avec leurs icônes et descriptions du jeu. Leur repère AOE décrit la mécanique, pas une obligation de choisir le talent.",
    "Les rubriques de réglages sont accessibles dans la colonne de gauche d’Options → AddOns, sous Skills & More, pour laisser davantage de place au contenu.",
  },
  fixes = {
    "Les explications des badges et des conseils d’usage suivent la langue choisie, y compris hors du grimoire.",
    "Dans TrainerSpells, les compétences de démons mémorisées affichent leur coche de sort appris, même avec des noms traduits ou des grimoires portant un autre ID.",
    "Les sorts de zone reconnus ne sont plus conseillés comme des achats OPTIONAL. Drain d’âme porte CLASS et conserve les conseils de rang adaptés sans être présenté comme un sort facultatif.",
    "Les catégories d’usage restent reconnues sur les différents rangs d’un sort. Protection divine est notamment reconnue à ses deux rangs.",
  },
}
