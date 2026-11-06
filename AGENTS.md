# SkillsAlreadyKnown Agent Notes

## Workspace Layout

- Development repository: `DevAddOns/SkillsAlreadyKnown`
- Installed/test copy: `~/Games/Heroic/Prefixes/Battle.net/drive_c/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns/SkillsAlreadyKnown_dev`

Do development work in `DevAddOns/SkillsAlreadyKnown`. The `Interface/AddOns/SkillsAlreadyKnown_dev`
folder is reserved for local development tests. The published CurseForge addon
uses `Interface/AddOns/SkillsAlreadyKnown` and must never be overwritten by the
local install script.

## Local Testing

From `DevAddOns/SkillsAlreadyKnown`, run:

```bash
./scripts/install-local.sh
```

Use `./scripts/install-local.sh --dry-run` to preview changes. Set `SAK_WOW_ROOT`
to override the default Heroic client directory (`_forever_`). The development
repository no longer needs to be inside the WoW installation.

This syncs the addon into the client's `Interface/AddOns/SkillsAlreadyKnown_dev` while excluding Git,
GitHub workflow files, scripts, release archives, and development-only metadata.

## Packaging

From `DevAddOns/SkillsAlreadyKnown`, run:

```bash
./scripts/package.sh
```

The package script creates `release/SkillsAlreadyKnown-<version>.zip` from the addon
contents and excludes dev-only files.

Do not overwrite an already prepared/published package when preparing a new package
for the user. Version bumps are done when packaging a deliverable zip, not for every
individual file edit made during the same task.

Use patch versions for minor fixes and polish within the current feature line, for
example `0.3.1`, `0.3.2`, `0.3.3`, etc. Continue that sequence until the user asks
to publish/package the accumulated changes. Use the next minor version, such as
`0.4.0`, only for a larger feature set. After `0.4.0`, continue minor fixes as
`0.4.1`, `0.4.2`, etc. Keep existing zips so every delivered package remains
traceable.

## CurseForge

CurseForge installation/update tests target only the published copy in
`Interface/AddOns/SkillsAlreadyKnown`. Local installs must always create
`Interface/AddOns/SkillsAlreadyKnown_dev` with a matching `SkillsAlreadyKnown_dev.toc`,
a `[DEV]` title, and separate namespace, frame names, saved variables and asset paths.
Apply development renaming only to the staged install copy. Published packages
must retain the original addon name. The official copy must skip all module initialization when the DEV copy is
enabled for the current character, regardless of addon load order. Keep this
guard in Core and every feature module. Do not persistently disable the official
addon: it resumes after DEV is disabled and the UI is reloaded. Older published
versions without this guard must still be disabled manually during DEV tests.

## Addon Behavior

- Known trainer spells are displayed with dark grey text and a darker background.
- Level-locked trainer spells display only the spell name in red. Requirement text should
  keep the game's normal coloring.
- Trainable spells get a green outline and a subtle green/dark background.
- Trainer and grimoire icons can receive overlays/badges for learned, learnable,
  or already-owned-book states.
- Warlock pet grimoires are highlighted in merchant windows:
  - Already learned grimoires show `[Already Learned!]`, a darker book overlay, and tooltip text.
  - Learnable grimoires use yellow text/outline plus the custom `assets/learnable-plus.tga` marker.
  - Pet icons are overlaid on grimoire icons to identify the target demon.
- Bag, bank, and guild bank item buttons may be annotated when a pet grimoire is recognized:
  - Learned grimoires receive the learned book overlay and pet icon.
  - Learnable grimoires receive the yellow outline and plus marker.
  - Item locations seen in bags, bank, or guild bank are saved locally to help spot duplicates.
- `/sak` opens the summary window and forces a refresh.
- `/sak debug` opens a copyable diagnostics window with player spellbook scan data,
  trainer service IDs, and trainer row mapping details.
- `/sak pet` opens active pet saved spell counts in the shared debug window.
- `/sak petdebug` opens the copyable grimoire/pet debug window.

## Implementation Notes

- Prefer trainer API state over localized text parsing.
- Main trainer APIs used include `GetTrainerServiceInfo`, `GetTrainerServiceLevelReq`,
  and `C_TooltipInfo.GetTrainerService`.
- Modern ScrollBox rows may expose only the base spell name. Matching therefore needs to
  respect visible order and spell IDs when available.
- Do not trust `data.id` as the trainer service index without validating it against the
  visible row.
- A previous bug mapped higher-rank trainer rows to already-known lower ranks. Be careful
  when changing service matching.
- Prioritize stable IDs over localized text whenever the client exposes them.
- Pet grimoire detection intentionally uses layered data:
  1. Save pet spellbook data by ID and by localized name.
  2. Match merchant grimoires by merchant spell ID when already migrated.
  3. Fall back to localized spell name + rank only when needed.
  4. When a localized fallback confirms a learned grimoire, save the merchant spell ID
     back into `SkillsAlreadyKnownDB.petSpells[petKey].byID`.
- Do not filter out large pet spellbook IDs. WoW Forever can expose internal pet/action IDs
  such as `100663xxx`, `117440xxx`, or `3238xxxx`; they are useful for diagnostics and should
  not be discarded just because they look unlike classic spell IDs.
- Store pet metadata with pet spell data: `petKey` and display `petName`.
- Store recognized pet grimoire item metadata by `itemID` in `SkillsAlreadyKnownDB.petGrimoires`
  so bags/banks can be annotated without requiring the pet vendor window to be open.
- EllesmereUI Bags integration uses `EUI_Bags.RegisterItemOverlayIcon`. Keep
  state on addon-owned frames parented to `button._textOverlay`, never on its
  secure item buttons. Copy location fields; callback data tables are reused.
- Store seen item locations in `SkillsAlreadyKnownDB.itemStorage`, but treat bank and guild bank
  data as "last seen" because they are only reliable after the player opens those windows.
- Keep tooltip strings concise and consistent with the addon name, e.g. `[Already Learned!]`.
- The addon is split into small modules loaded by `SkillsAlreadyKnown.toc`:
  - `Core.lua`: shared namespace, constants, saved variables, text/ID helpers, pet metadata.
  - `Visuals.lua`: reusable row, outline, overlay, icon, badge, and text painting helpers.
  - `ClassTrainer.lua`: class trainer service scanning and row coloring.
  - `PetGrimoires.lua`: warlock pet spell persistence and merchant grimoire highlighting.
  - `Inventory.lua`: bag, bank, and guild bank item overlays for recognized books/recipes.
  - `Main.lua`: slash commands, event routing, and cross-module refresh orchestration.
- Add future features, such as profession trainers, as new modules that reuse `Core.lua`
  and `Visuals.lua` rather than expanding an existing feature module.

## Git Notes

The repository uses `core.fileMode=false` locally because the WoW/Wine filesystem may
flip executable bits on normal files.

## Public documentation and release communication

- README.md, CHANGELOG.md, CurseForge descriptions/release notes, and suggested
  public commit messages are for players. Describe gameplay behavior, visible
  fixes, compatibility, and commands useful in game.
- Do not include local development scripts or their changes, shell commands,
  personal installation paths, Heroic/Wine setup, SAK_WOW_ROOT, dry-run options,
  DEV deployment/isolation, packaging mechanics, or internal agent workflows in
  player-facing documentation or suggested public commit messages.
- Keep developer setup and script documentation in CONTRIBUTING.md and AGENTS.md.
  These files and scripts are excluded from release packages. This separation
  concerns the intended audience; tracked developer files remain public in Git.
- Before preparing a commit, release zip, or publication, review player-facing
  documentation and any proposed public message for developer-only material.
- Describe bag compatibility precisely: Blizzard and EllesmereUI bags are
  confirmed in game; other bag addons require validation.
