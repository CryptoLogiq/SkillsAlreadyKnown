# Préparation des commits

PRIORITÉ ABSOLUE : vérifier le dépôt, la branche et les modifications dans Git
avant toute édition ou préparation. Travailler sur dev ; main sert à publier sur
demande explicite. Préserver l’index et les changements non indexés. Aucun reset,
checkout forcé, clean, écrasement de branche ou stash/pop automatique. Si passer
sur dev risque de perdre du travail ou provoque un conflit, suspendre les actions
qui en dépendent et demander au propriétaire ; ne pas travailler sur main par défaut.


Appliquer ces consignes dès qu’un commit est demandé ou préparé. Elles complètent
le guide racine et les règles de patchnote/AGENTS.md.

## Documents destinés aux joueurs

- README.md, CHANGELOG.md, patchnote/*.lua et leurs textes dans la GUI décrivent
  uniquement les fonctions utilisables, leur emplacement et les bugs corrigés.
- Écrire court et concret. Aucun récit de développement, refactor, API, module,
  bibliothèque interne, script, copie DEV, chemin personnel ou compte de tests.
- Garder les explications de maintenance dans AGENTS.md, CONTRIBUTING.md et les
  documents internes appropriés. Conserver les notices et licences des bibliothèques.
- Réorganiser les ajouts accumulés ; ne pas empiler de paragraphes en fin de README.
  Respecter la langue du document et les noms réels des options en jeu.
- Séparer ajouts et corrections. Ne pas promettre une compatibilité non vérifiée.
  Distinguer les limites utiles aux joueurs des détails internes inutiles.

## Vérifications et périmètre

1. Lire le statut, les différences et les nouveaux fichiers ; préserver les
   modifications existantes et repérer les changements étrangers à la demande.
2. Actualiser les documents joueurs et les notes Unreleased sans inventer de
   version. Générer data/Patchnotes.lua depuis les notes, jamais à la main.
3. Vérifier les références du TOC, les images citées, les notices de licences,
   les exclusions des archives et l’absence de données locales privées dans le commit.
4. Exécuter les tests adaptés au périmètre, la vérification du générateur de
   patchnotes, les vérifications Lua et git diff --check. Pour une grosse série
   de changements, tester aussi une copie des seuls fichiers proposés au commit.
5. Examiner les fichiers qui seront ajoutés à l’index. Ne pas inclure archives,
   état du jeu, extractions tierces locales non redistribuables ou secrets.
6. Préparer un titre bref et un corps regroupant les fonctions joueurs et les
   corrections. Les résultats des tests peuvent figurer dans le compte rendu
   au propriétaire ; ils n’ont pas leur place dans les patchnotes joueurs.

« Préparer un commit » autorise la préparation des fichiers et de l’index, mais
ne demande pas de créer le commit, pousser, taguer, publier, changer de version
ou produire une archive. Faire ces actions lorsqu’elles sont demandées.
Demander au propriétaire seulement pour un vrai doute de périmètre, une décision
fonctionnelle ou une publication ; ne pas lui refaire confirmer ces préférences.

Les bibliothèques tierces restent identiques aux sources : conserver leurs fins
de ligne et leur mise en forme via les attributs Git, sans les reformater pour
faire passer une vérification d’espaces.

Les images du README doivent utiliser des URL GitHub absolues vers les fichiers
du dépôt pour fonctionner aussi lorsque le contenu est copié sur CurseForge.
Vérifier le dépôt distant, la branche et les fichiers ; rendre absolus également
les liens utiles comme la licence. Ne pas modifier une archive déjà générée.

Vérification obligatoire avant chaque commit ou modification du README : examiner
tous les liens Markdown et les attributs HTML src/href. Aucun chemin relatif
d’image ou de document du dépôt ne doit subsister. Cette préférence est permanente
et s’applique aussi lors d’une simple réorganisation des textes.

Ne jamais ajouter de sections repliables ou de listes déroulantes dans le README :
pas de details/summary ni de contenu à déplier. Les captures et informations restent
visibles sous des titres ordinaires. Vérifier aussi ce point avant chaque commit.

Les captures du README sont toujours en haut de page, juste après le titre et
la courte présentation, avant les fonctions et commandes. Garder les images
visibles, leurs liens GitHub complets et, si nécessaire, la mention d’obsolescence
juste au-dessus. Vérifier cet ordre lors de chaque préparation de commit.

Deux README publics à contrôler ensemble : README.md pour GitHub, avec installation
manuelle ; Readme_CurseForge.md pour la fiche CurseForge, sans installation ni
explication de développement. Le second est la référence à copier sur CurseForge.
Les deux gardent les captures en haut, les liens complets et le contenu visible.
Synchroniser les fonctions, commandes et limites utiles, sans recopier les détails
propres à GitHub dans la fiche du gestionnaire d’addons.

Pour une livraison demandée, le script de packaging doit produire release/latest/
avec un seul ZIP courant et un patchnote.md Markdown prêt pour CurseForge, issu
des notes Lua de cette version. Garder les archives versionnées inchangées dans
release/. Vérifier que le ZIP et ses notes correspondent. Pour republier une copie
existante dans latest sans la reconstruire : package.sh --refresh-latest.

## Branches

Développement et commits de travail sur dev ; publication sur main. Vérifier la
branche avant de préparer un commit. Conserver les changements locaux lors d’un
changement de branche ; aucun reset ni écrasement. La fusion vers main, le push,
les tags et la publication se font lorsqu’ils sont demandés, pas implicitement
avec une préparation de commit. Les liens publics du README restent sur main.

Les prochains builds utilisent SkillsAndMore-<version>.zip dans release/ et
release/latest/. Le dossier interne reste SkillsAlreadyKnown pour conserver les
mises à jour et sauvegardes. Ne pas renommer les archives déjà livrées implicitement.

## Textes dans le code

Aucun nouveau texte destiné aux joueurs en dur dans la logique : utiliser une clé
stable et lisible via L("CLE_DU_TEXTE"), avec ses valeurs dans les deux catalogues.
Ne pas ajouter de phrase française/anglaise comme clé ni de repli rédigé en dur.
Les anciennes clés basées sur des phrases sont héritées ; ne pas étendre ce modèle.
Utiliser des phrases complètes avec paramètres pour les messages dynamiques.
Seuls les textes internes de debug/support peuvent rester en anglais dans le code ;
les boutons et commandes de ces fenêtres restent traduits. Vérifier les ajouts et
la couverture des traductions avant de préparer le commit.


## Vérification GitHub / CurseForge avant livraison

Lire `scripts/curseforge/AGENTS.md`. Un push sur dev peut publier automatiquement
une bêta ; main et son tag de version servent aux versions stables. Préparer un
commit n'autorise pas le push. Contrôler les exclusions Git ET celles du paquet,
les fichiers réellement suivis et le contenu du ZIP. Aucun token dans le dépôt.
