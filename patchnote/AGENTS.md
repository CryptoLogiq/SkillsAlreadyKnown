# Agent de rédaction des patchnotes

Ta seule responsabilité dans ce dossier est de décrire les changements utilisables
par les joueurs. Lis le code et les tests pour vérifier les faits, puis modifie
uniquement les entrées de patchnotes demandées. Ne change pas le gameplay, les
scripts, les bibliothèques ou les numéros de version de ta propre initiative.

## Contenu

- Écris en français, avec des phrases courtes, concrètes et compréhensibles.
- `additions` : fonctionnalités accessibles, où les trouver et ce qu’elles permettent.
- `fixes` : problème visible corrigé et résultat pour le joueur.
- N’inclus ni refactor, modules, API, tables, dépendances, scripts, chemins locaux,
  déploiement DEV, compte de tests ou détails de diagnostic internes.
- Les commandes et noms d’onglets sont utiles quand le joueur peut les utiliser.
- Ne promets pas une compatibilité ou une correction visuelle non vérifiée.
- Décris un changement une seule fois. Omet les catégories vides dans le rendu.

## Versions et format

Chaque fichier Lua renvoie une table lisible : `version`, `status`, éventuellement
`basedOn`, puis `additions` et `fixes` (listes de textes). Les fichiers publiés
portent leur version, par exemple `0.3.3.lua`, et `status = "released"`.
`Unreleased.lua` contient les changements non publiés avec `status = "development"`
et `basedOn` égal à la dernière version publiée. Ne leur invente pas de date ni
de numéro de sortie. Lors d’une publication demandée, transfère ces notes dans
le fichier de la nouvelle version et repars d’une entrée Unreleased vide.

Ces tables sont la source de l’historique en jeu. Le script
`python3 scripts/generate-patchnotes.py` assemble `data/Patchnotes.lua` ; ne modifie
pas cette copie générée à la main. Les scripts d’installation et de packaging
l’actualisent aussi. Le dossier de rédaction est exclu de l’addon livré.

## Export CurseForge

Le packaging exporte toujours les notes de la version du ZIP dans
release/latest/patchnote.md, à côté du ZIP courant. Le Markdown est généré depuis
ces tables Lua par generate-patchnotes.py --format markdown : ne pas maintenir
une deuxième copie manuelle et ne pas exporter Unreleased comme notes de livraison.
Conserver le numéro de version, les catégories d’ajouts et de corrections non
vides et uniquement les informations utiles aux joueurs. Les archives historiques
restent conservées ; latest ne contient que la copie de la livraison courante.
