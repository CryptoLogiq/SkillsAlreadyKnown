#!/usr/bin/env python3
"""Extract all installed Forever tables for private local research (never distribute output)."""
import argparse, hashlib, json, shutil, subprocess
from pathlib import Path
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('source',type=Path,help='Installed TrainerSpells folder')
parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parent/'trainerspells-local')
args=parser.parse_args()
source=args.source.resolve();output=args.output.resolve()
files=sorted((source/'data'/'forever').glob('*.lua'))
if not files:parser.error('No data/forever/*.lua tables found')
for part in ('raw','classes'): (output/part).mkdir(parents=True,exist_ok=True)
engine=Path(__file__).with_suffix('.lua')
subprocess.run(['lua',str(engine),str(source),str(output),*(file.name for file in files)],check=True)
shutil.copy2(source/'LICENSE',output/'TrainerSpells-LICENSE.txt')
(output/'SourceHashes.json').write_text(json.dumps({file.name:hashlib.sha256(file.read_bytes()).hexdigest() for file in files},indent=2)+'\n')
(output/'README.md').write_text('''# TrainerSpells Forever — recherche locale complète

Ce dossier est ignoré par Git et exclu des installations et ZIP. La licence
source interdit sa redistribution ; conserver cette extraction pour consultation
locale. Aucun code d'interface TrainerSpells n'a été repris dans notre addon.

- Manifest.lua : fichiers extraits, version, totaux et anomalies de prérequis.
- classes/ : les neuf classes, par niveau puis par ID de sort. Chaque entrée
  conserve le rang lorsqu'il existe, prix en cuivre, prérequis, race/faction et
  tous les autres champs de la source. bySpellID retrouve toutes les offres.
- QuestSpells.lua : sorts de quête et détails, y compris conditions raciales.
- raw/ : données complètes de chaque table Forever, sans perte de champs : classes,
  familiers, créatures, maîtres, armes, portails, métiers, recettes et spécialisations
  de métiers présentes. namespace contient les tables affectées au namespace addon ;
  recipeCalls conserve les arguments des données enregistrées par callback.
- SourceHashes.json : empreintes SHA-256 des fichiers d'origine.

Les sorts de classe vendus au maître ne sont pas classés par spécialisation dans
la source : ils restent communs à la classe. Les prérequis présents sont conservés ;
aucune répartition par talent/spécialisation n'est inventée. Les niveaux de recettes
correspondent aux compétences de métiers et non au niveau du personnage.

La source peut omettre un rang, un nom ou une famille de sorts. Ne jamais supposer
qu'un ID supérieur, ou une ligne requires, suffit à identifier le rang suivant.
Les auto-références et prérequis absents des tables sont signalés dans chaque classe.
Les noms devront être résolus via les API du client et des ancrages stables.

Pour préparer l'affichage du grimoire, comparer séparément :
1. Le plus haut rang appris (BEST actuel).
2. Un rang supérieur accessible au niveau du joueur, sous réserve des prérequis,
   talents/race/faction et du mode d'apprentissage.
3. Le rang final du jeu, qui peut rester inaccessible à ce niveau.
4. Le conseil OPTIONAL, qui indique si l'achat peut attendre pour le profil choisi.

Cette extraction seule n'active aucun nouveau badge dans le jeu. Une connexion
future devra aussi traiter les sorts de quête/talent et les données manquantes.
Actualisation : python3 scripts/research/extract-trainerspells-all.py CHEMIN_TRAINERSPELLS
''')
print('Local output:',output)
