# SkillsAlreadyKnown

Small WoW Forever addon that makes the class trainer list easier to scan.

## What It Does

- Known trainer spells are shown in grey.
- Spells locked by character level are shown in red.
- Spells that can be learned now get a green outline.
- Icons are left untouched.

The addon uses trainer API state such as `available`, `used`, and level requirements instead of matching localized text, so it should behave cleanly across client languages.

## Preview

![Trainer preview](assets/trainer-preview.png)

## Compatibility

Built for WoW Forever / Camelot:

```toc
## Interface: 16001
## AllowLoadGameType: camelot
```

## Install

Place the folder here:

```text
World of Warcraft/_classic_beta_/Interface/AddOns/SkillsAlreadyKnown
```

Then enable **Skills Already Known** in the in-game AddOns list and reload/restart the client.

## Command

```text
/sak
```

Forces a refresh and prints the current color legend.

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

## License

MIT
