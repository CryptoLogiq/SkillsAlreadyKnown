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
- `/sak` forces a refresh and prints the color legend.
- `/sak debug` prints trainer row mapping diagnostics.

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

## Git Notes

The repository uses `core.fileMode=false` locally because the WoW/Wine filesystem may
flip executable bits on normal files.
