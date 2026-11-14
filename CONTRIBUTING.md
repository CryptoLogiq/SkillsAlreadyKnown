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

Local installs appear as **Skills & More [DEV]**, with their own TOC,
saved variables, namespace and asset paths. The published CurseForge folder
`SkillsAlreadyKnown` is never overwritten. Official builds containing the DEV
guard stay inactive when DEV is enabled for the current character, before
registering hooks or `/sam`. Disable DEV and reload the UI to
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

## GUI library

AceGUI-3.0 is bundled with its standard widgets. Retrieve the shared instance
with `LibStub("AceGUI-3.0")`; the TOC loads LibStub first, then the upstream XML.
Upstream core and widget version guards reuse equal/newer versions or upgrade
older shared instances. See `libs/README.md` for the pinned source and license.

The profile chooser and game options panel use AceConfigDialog on top of
AceGUI. Future UI code should use the documented
widget API and release unused widgets. Do not permanently reskin stock pooled
widgets shared with other addons. Use addon-owned wrappers or custom widget types
for optional EllesmereUI styling. DarkMode GUI work is deferred.

## Code organization

The module map in [AGENTS.md](AGENTS.md#runtime-modules-and-table-connections)
explains the data and runtime dependencies. The TOC defines their load order.
PlayerRoles owns saved choices; RankPolicy evaluates advice; SpellRanks classifies
learned ranks; SpellBook paints the native views. Tooltip modules build explanations,
and Events routes game events to the feature modules. Main keeps the commands and
shared refresh entry point. Existing public entry points remain compatible.

Use descriptive names, short functions, early returns and short comments explaining
constraints. This follows the owner's module style in
[Base-code-love2d](https://github.com/CryptoLogiq/Base-code-love2d) and
[Fight-Club](https://github.com/CryptoLogiq/Fight-Club), adapted to WoW's TOC loader.
Keep gameplay rules in readable Lua tables, linked by stable class/spec/spell keys.

Strict rank-one rules live in `data/RankOneAdvice.lua`; reviewed optional purchases
live in `data/LevelingAdvice.lua`. All selected roles must agree; PvP suspends
economy advice. LOW compares learned ranks, while BUY checks accessible unlearned
upgrades. Advice never hides services or changes purchasing behavior.

Run the regression scripts from the repository root:

```bash
for test in scripts/test-*.lua; do lua "$test" || exit 1; done
git diff --check
```

Mocks verify policy, rendering contracts, compatibility hooks and event routing.
Use the DEV install for the final visual check in game.

## Game options model

Settings.lua uses bundled AceConfig-3.0 and AceConfigDialog-3.0 to render the same
profile model in the startup window and Options > AddOns. /sam settings opens the
registered category; changes persist immediately through RankPolicy.SetRoleEnabled / SetSpecialization / SetEco.
The old manually assembled profile window has been removed. CallbackHandler is
bundled as Registry's dependency; no AceConsole command registration is used.
Library sources, versions and license provenance are in libs/README.md.

Checks: `lua scripts/test-aceconfig.lua`, `lua scripts/test-settings.lua`,
`lua scripts/test-spellbook.lua`. The first validates the actual upstream XML,
version negotiation and options schema; the others exercise profile changes,
modern/legacy menu registration, deferred opening and spell rank behavior.

## Maintaining spell advice

Edit `data/LevelingAdvice.lua` directly. It is the only runtime purchase catalogue,
loaded before RankPolicy.lua. Entries are grouped by class, then specialization;
each profile contains its role, source guide and list of spells. Spell entries
have a numeric `baseID`, readable `name`, `minRank`, optional `maxRank`, category
and contextual reason. Do not change an ID based on the display name alone.

Example: `MAGE.fire.spells` contains the Fire Mage purchase advice. Changing
`minRank` to 2 excludes the first purchase; `maxRank` limits an explicit range.
Role intersection, PvP suspension and level limits remain in RankPolicy.lua.

The broader research inventory is `scripts/research/eco-spells-forever.lua`.
It includes excluded and unverified candidates and is not loaded by the addon.
Promote a reviewed entry into the active table only after checking its ID and scope.
There is no CSV export or generated data block to keep in sync. Run
`lua scripts/test-trainer-advice.lua` and `lua scripts/test-research-data.lua`
after edits, plus the renderer tests when behavior changes.

## Class roles and specializations

Edit `data/ClassRoles.lua` for class names, supported Tank/Heal/DPS specialization
choices and beginner explanations. PvP is defined separately under `activities`
and available to every class. RankPolicy and the settings UI use this table;
do not duplicate these mappings in feature modules. Saved specialization keys
are stable identifiers, so keep them compatible when changing visible labels.

Startup selections are persisted in `levelingDraft` until the player accepts the
role/spec/advice recap. Settings uses PlayerRoles selection APIs; RankPolicy reads
only the active `levelingProfile`. Closing or cancelling never marks the prompt
complete. Keep both models separate when editing the GUI.

## Patchnotes in game

Edit `patchnote/Unreleased.lua` for player-visible features and fixes. Follow
`patchnote/AGENTS.md`; keep development details out. Released versions have their
own numbered Lua file. Generate the runtime history with
`python3 scripts/generate-patchnotes.py`; use `--check` to detect stale output.
The package script generates it automatically. Local installs generate into their
staging directory, so a dry run does not modify source files. The GUI Patchnotes
tab reads the generated table. Transfer Unreleased notes when preparing an
explicitly requested version; never relabel old releases or overwrite archives.

## PvP / PvE usage markers

Maintain `data/ContentUsage.lua`: class-scoped talent entries carry spellID, nodeID,
tree, readable name, tag (`pvp` / `mixed`) and original French reasoning. Spell
family anchors use the same tag/reason fields with their source URLs. Class source
lists link to Forever guides; classifications are editorial, not an official
Wowhead tag. Coverage and review limits are in
`scripts/research/pvp-talents-forever.md`. Do not default unknown entries to mixed.
ContentTags builds class indexes and resolves later ranks through live localized
spell names. Prefer a live trait definition over a reviewed node hint. No local
third-party extract is loaded or required. Run `test-content-tags.lua` and trainer
regressions after modifying these entries or their rendering.

## Latest upload files

`./scripts/package.sh` creates the immutable versioned archive in `release/`, then
copies it into `release/latest/` alongside `patchnote.md`. Upload that ZIP and paste
that Markdown into CurseForge's file notes. Notes come from the matching version
in `patchnote/`, the same source used by the in-game history.

Use `./scripts/package.sh --refresh-latest` to republish an existing archive into
latest without rebuilding it. This checks that its bundled notes still match the
sources. Existing versioned archives are never overwritten.
