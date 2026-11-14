# Traductions

Tous les textes destinés aux joueurs sont définis dans en-EN.lua et fr_FR.lua,
avec exactement les mêmes clés. Pour un nouveau texte, choisir une clé stable et
explicite (LANGUAGE_LABEL, LEARNED_RANK, etc.) ; sa formulation appartient aux
valeurs des catalogues. La logique appelle L("LANGUAGE_LABEL") sans phrase en dur.
Les anciennes clés constituées de phrases françaises restent compatibles, mais
ne servent pas de modèle aux nouveaux ajouts.

Préférer les phrases complètes avec paramètres %s / %d aux fragments assemblés.
Conserver les paramètres et échappements de couleurs/textures dans les deux langues.
Ne traduire ni identifiants, ni noms d’API, ni chemins, ni noms fournis par le jeu.
Les logs internes de debug peuvent rester en anglais dans le code ; les commandes
et boutons destinés à l’utilisateur restent traduits.

Respecter disabledByDev et la négociation de langue de Localization.lua. Un choix
manuel est enregistré mais appliqué après rechargement. Vérifier la parité des
catalogues, les paramètres et la couverture avec les tests de localisation.
