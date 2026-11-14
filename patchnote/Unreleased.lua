-- Notes destinées aux joueurs.
return {
  version = "Unreleased",
  status = "development",
  basedOn = "0.4.0",
  additions = {
    "Interface en français et en anglais, avec détection automatique de la langue du client et choix manuel dans les options.",
  },
  fixes = {
    "La version officielle démarre correctement lorsque la copie DEV est présente mais non chargée.",
    "Le choix manuel de langue est correctement repris après un rechargement de l’interface.",
  },
}
