# GitHub / CurseForge release rules

## Branches and credentials

- Preserve all local work; inspect branch, index and status before changes.
- Develop on dev. Its pushes publish betas when credentials are configured.
- Stable releases use vX.Y.Z tags whose commits belong to main and whose version
  matches the TOC. Never infer push/merge/tag authorization from commit preparation.
- Store the CurseForge API token only as the GitHub repository Actions secret
  CF_API_TOKEN (Settings > Secrets and variables > Actions > New repository secret).
  Do not use an Actions variable. Never print or request the token in chat.
- GITHUB_TOKEN is provided automatically. Missing CF credentials must leave a
  downloadable artifact without uploading. Manual workflow runs are build-only.
- Use one publication mechanism; do not enable a second CurseForge webhook that
  uploads the same release. See automatic-releases-fr.txt for the setup.

## Mandatory exclusion and payload review

- Inspect .gitignore, .pkgmeta, scripts/package.sh, scripts/install-local.sh and
  scripts/verify-ci-release.py together whenever the layout changes.
- .gitignore controls untracked Git files; it does not remove already tracked
  files. Check git ls-files and staged filenames for unintended private files.
- .pkgmeta controls the official package. Local rsync packaging/install filters
  must exclude the same developer/private content, including nested AGENTS.md.
- Keep workflows, scripts and maintained patchnote sources on GitHub, but exclude
  them from the addon ZIP. Never ship credentials, .env files, .aws, game state
  (WTF/Cache/Logs/Errors), editor files, agent instructions, research downloads,
  packager checkouts, build outputs or nested archives.
- Keep all TOC runtime files, data, translations, required assets and vendored
  libraries in Git and the package. Preserve library bytes and license files.
- Keep internal folder/TOC/DB identity SkillsAlreadyKnown; branded archive names
  are SkillsAndMore-<version>.zip. DEV installs only into SkillsAlreadyKnown_dev.

## Validation before publication

- Run relevant tests, Lua syntax checks, patchnote generation checks and packaging
  integration tests. Inspect the final ZIP, not merely its exclusion settings.
- Verify TOC version, CurseForge project ID, tagged revision, beta/stable channel,
  archive root, required TOC files and translations. No DEV namespace in releases.
- Generate runtime Lua and Markdown from maintained Lua patchnote tables. Beta
  notes describe pending changes; stable notes describe that exact version.
- Publish only the tested archive; release/latest contains the current ZIP and
  matching patchnote.md. Preserve older release archives; never silently rebuild
  or overwrite a delivered version. Tests must use temporary fixtures.
- CI uses the pinned official packager. Review upstream changes before updating
  action/tool pins. Checks must pass before any upload; PRs never publish.
- README/CurseForge text and patchnotes describe player features/fixes only.
  Keep automation/setup instructions here, in CONTRIBUTING.md or maintainer docs.
- Report the actual state: prepared, tested, committed, pushed and published are
  distinct. State missing setup explicitly; never claim publication from a build.

## Langues des changelogs publics

- Toujours exporter l'anglais intégral en premier, puis le français intégral.
- Même ordre pour les releases GitHub, CurseForge et les artefacts stables/bêta.
- Une seule source maintenue : notes Lua françaises et catalogues de traduction.
- Vérifier l'ordre et l'absence de repli français dans la partie anglaise avant
  publication. Une traduction manquante bloque la génération du Markdown.
- Une correction de Markdown ne doit pas reconstruire une archive déjà livrée
  ni déplacer un tag publié.
