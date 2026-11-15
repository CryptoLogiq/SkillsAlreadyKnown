# Suivi de développement

## Après la publication 0.4.1

- [ ] TrainerSpells : afficher la coche verte sur les compétences de familiers
  déjà apprises. Capture joueur : Marcheur du Vide, niveau 26 ; des compétences
  connues restent dans « Disponible maintenant » sans coche. Vérifier à la fois
  la reconnaissance des apprentissages et le rendu de la coche (la synchronisation
  des données seule ne suffit pas). Tester après invocation, changement de familier,
  défilement et rechargement, sans marquer les rangs encore inconnus.

  Correctif disponible dans DEV : familles traduites, IDs grimoires/compétences
  distincts et coche explicite sur les lignes du catalogue. Tests automatisés
  passés ; validation visuelle en jeu encore attendue.

## Astuces ciblées de combinaisons

Recherche dans scripts/research/spell-combinations-forever.lua : 23 cas pour neuf
classes. Garder une sélection courte ; ne pas importer tout le catalogue dans
les infobulles. Commencer par Javelot sur cible gelée (pas simplement ralentie),
Prompte guérison avec un soin sur la durée, Nova de feu avec un totem de feu,
Conflagration avec Immolation et Maîtrise du blocage vers Revanche. Vérifier les
IDs Forever et les talents avant intégration ; fusionner les variantes d’une même
astuce. Sélection intégrée : 12 astuces sur les sorts principaux, Jugement compris ; les autres cas restent en réserve.
