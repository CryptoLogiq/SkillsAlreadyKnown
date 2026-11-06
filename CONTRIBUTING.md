# Contributing

## Local development scripts

Run these commands from the development repository (`DevAddOns/SkillsAlreadyKnown`):

```bash
./scripts/install-local.sh --dry-run
./scripts/install-local.sh
./scripts/package.sh
```

The install script defaults to the Heroic/Battle.net client at
`~/Games/Heroic/Prefixes/Battle.net/drive_c/Program Files (x86)/World of Warcraft/_forever_`.
It syncs only `Interface/AddOns/SkillsAlreadyKnown_dev` inside that client. Use
`--dry-run` to preview changes without writing files. To use another client:

```bash
SAK_WOW_ROOT="/path/to/World of Warcraft/_forever_" ./scripts/install-local.sh --dry-run
```

Both scripts run in the current terminal. Packaging creates
`release/SkillsAlreadyKnown-<version>.zip` and refuses to overwrite an existing
archive; update the TOC version when preparing the next deliverable.

Local installs appear as **Skills Already Known [DEV]**, with their own TOC,
saved variables, namespace and asset paths. The published CurseForge folder
`SkillsAlreadyKnown` is never overwritten. Official builds containing the DEV
guard stay inactive when DEV is enabled for the current character, before
registering hooks or `/sak`. Disable DEV and reload the UI to
resume the official copy. Older CurseForge releases without this guard still
need to be disabled manually when testing DEV.
Release packages keep the original addon name.

The scripts require Bash, rsync and Python 3. They run from the development
repository without requiring it to be located inside the WoW installation.

## Release

Manual local package:

```bash
scripts/package.sh
```

GitHub Actions package on version tags:

```bash
git tag v0.1.0
git push origin v0.1.0
```

For CurseForge upload through the workflow, add a repository secret named `CF_API_KEY`. After creating the CurseForge project, add the project id to `SkillsAlreadyKnown.toc` as `## X-Curse-Project-ID: ...`.
