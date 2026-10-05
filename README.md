# SkillsAlreadyKnown

Small WoW Forever addon that makes class trainer and pet grimoire lists easier to scan.

## What It Does

- Known trainer spells are shown in grey.
- Spells locked by character level are shown in red.
- Spells that can be learned now get a green outline.
- Icons are left untouched.
- Warlock pet grimoires show learned, learnable, and locked states with pet-aware markers.

The addon uses trainer API state such as `available`, `used`, level requirements, and saved pet spell data instead of relying only on localized text.

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

```text
/sak pet
/sak petdebug
```

Shows saved pet spell information and grimoire diagnostics.

## License

MIT
