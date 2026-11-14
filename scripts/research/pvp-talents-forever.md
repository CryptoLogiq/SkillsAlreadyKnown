# Repères PvP / PvE — Forever

Revue : 2026-11-14. Source active : `data/ContentUsage.lua`.
Couverture : neuf classes, 79 talents sélectionnés, 39 familles de sorts.
Ce catalogue n’est pas un inventaire classé de tous les talents de Forever.
Les éléments non vérifiés restent volontairement sans marqueur.

Les guides Forever de Wowhead ont été consultés pour comparer les usages PvE/PvP :

- Druide : Restauration, talents et builds.
- Chasseur : Survie et Maîtrise des bêtes, talents et builds.
- Mage : Givre et Arcanes, talents et builds.
- Paladin : Protection et Vindicte, talents et builds.
- Prêtre : Discipline et Ombre, talents et builds.
- Voleur : Combat, talents et builds.
- Chaman : Élémentaire et Restauration, talents et builds.
- Démoniste : Destruction, talents et builds ; Affliction, leveling.
- Guerrier : Armes et Fureur, talents et builds.

Les URL exactes restent dans les tables de chaque classe. Les liens de sorts
sont conservés avec les familles de sorts. Les identifiants des talents et leurs
nœuds ont été rapprochés de la structure de talents du client Forever référencée
par les données locales (1.60.1.70755). Aucun fichier tiers n’est chargé ou livré
comme source runtime. Les sorts du maître sont appariés par ID, puis par nom
localisé fourni par le client pour les rangs suivants. Fear et Intercept utilisent
les ancres confirmées par les liens Forever des guides (6215 et 20617).

## Interprétation

- `pvp` : avantage principalement recherché contre les joueurs ; un usage PvE
  reste possible. Ce n’est pas un verdict « inutile en PvE ».
- `mixed` : intérêt en PvE (y compris progression et donjons) et PvP. Un talent de
  contrôle ne devient pas PvP exclusif simplement parce qu’un boss y est immunisé.
- Aucun tag situationnel ni classement de puissance. Le joueur choisit son build.
- La catégorie est notre synthèse éditoriale des effets et usages documentés,
  pas une classification officielle fournie telle quelle par Wowhead.
- Les guides comportent des choix variables et certains builds ont été déplacés
  après les modifications des arbres. Ne pas recopier leur ordre de points comme
  une preuve d’identité ou comme une recommandation obligatoire.
- Une définition de nœud renvoyée par le client prend priorité sur l’ancienne
  correspondance stockée. Si elle désigne un sort non renseigné, aucun tag.

## Maintenance

Vérifier ID, classe, arbre, effet et source avant tout ajout. Conserver les
explications originales courtes en français. Actualiser la date après revue.
Tester les deux activités, les noms localisés, les rangs, les lignes recyclées,
la disparition des fenêtres et les options ; une capture en jeu reste nécessaire
pour confirmer l’emplacement sur les boutons natifs.
