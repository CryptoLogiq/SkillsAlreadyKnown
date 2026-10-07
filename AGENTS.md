# SkillsAlreadyKnown Agent Notes

## Workspace Layout

- Development repository: `DevAddOns/SkillsAlreadyKnown`
- Installed/test copy: `Interface/AddOns/SkillsAlreadyKnown`

Do development work in `DevAddOns/SkillsAlreadyKnown`. The `Interface/AddOns/SkillsAlreadyKnown`
folder is managed by WoW/CurseForge/local install tests and can be overwritten.

## Local Testing

From `DevAddOns/SkillsAlreadyKnown`, run:

```bash
./scripts/install-local.sh
```

This syncs the addon into `Interface/AddOns/SkillsAlreadyKnown` while excluding Git,
GitHub workflow files, scripts, release archives, and development-only metadata.

## Packaging

From `DevAddOns/SkillsAlreadyKnown`, run:

```bash
./scripts/package.sh
```

The package script creates `release/SkillsAlreadyKnown-<version>.zip` from the addon
contents and excludes dev-only files.

## CurseForge

CurseForge installation/update tests should target only the installed/test copy in
`Interface/AddOns/SkillsAlreadyKnown`. If CurseForge rewrites that folder, keep using
the dev repo as the source of truth and reinstall locally with `./scripts/install-local.sh`
when needed.

## Addon Behavior

- Known trainer spells are displayed with dark grey text and a darker background.
- Level-locked trainer spells display only the spell name in red. Requirement text should
  keep the game's normal coloring.
- Trainable spells get a green outline and a subtle green/dark background.
- Spell icons are intentionally left untouched.
- Warlock pet grimoires are highlighted in merchant windows:
  - Already learned grimoires show `[Already Learned!]`, a darker book overlay, and tooltip text.
  - Learnable grimoires use yellow text/outline plus the custom `assets/learnable-plus.tga` marker.
  - Pet icons are overlaid on grimoire icons to identify the target demon.
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
- Keep tooltip strings concise and consistent with the addon name, e.g. `[Already Learned!]`.
- The addon is split into small modules loaded by `SkillsAlreadyKnown.toc`:
  - `Core.lua`: shared namespace, constants, saved variables, text/ID helpers, pet metadata.
  - `Visuals.lua`: reusable row, outline, overlay, icon, badge, and text painting helpers.
  - `ClassTrainer.lua`: class trainer service scanning and row coloring.
  - `PetGrimoires.lua`: warlock pet spell persistence and merchant grimoire highlighting.
  - `Main.lua`: slash commands, event routing, and cross-module refresh orchestration.
- Add future features, such as profession trainers, as new modules that reuse `Core.lua`
  and `Visuals.lua` rather than expanding an existing feature module.

## Git Notes

The repository uses `core.fileMode=false` locally because the WoW/Wine filesystem may
flip executable bits on normal files.
