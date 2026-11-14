-- Notes destinées aux joueurs.
return {
  version = "Unreleased",
  status = "development",
  basedOn = "0.4.0",
  additions = {
    "Un contour doré lumineux distingue les livres du familier actuellement invoqué.",
    "Les livres de familiers gardent leurs marqueurs quel que soit le démon actif. Le grimoire des familiers indique les rangs appris, les rangs accessibles à acheter et les apprentissages récents.",
    "Interface en français et en anglais, avec détection automatique de la langue du client et choix manuel dans les options.",
  },
  fixes = {
    "Les compétences de familiers déjà apprises sont reconnues dans la liste de TrainerSpells.",
    "La version officielle démarre correctement lorsque la copie DEV est présente mais non chargée.",
    "Le choix manuel de langue est correctement repris après un rechargement de l’interface.",
  },
}
