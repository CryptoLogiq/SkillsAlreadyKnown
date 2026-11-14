# Skills & More

See what to learn, compare spell ranks and save training gold while leveling in **WoW Forever**.

## Screenshots

These screenshots show an older version and will be updated to reflect Skills & More.

![Class trainer](https://raw.githubusercontent.com/CryptoLogiq/SkillsAlreadyKnown/main/assets/trainer-preview.png)

![Warlock pet grimoires](https://raw.githubusercontent.com/CryptoLogiq/SkillsAlreadyKnown/main/assets/spellsbookmarks_trainer.png)

![Already-owned grimoire](https://raw.githubusercontent.com/CryptoLogiq/SkillsAlreadyKnown/main/assets/spellsbookmarks_in_possesion_tooltip_updated.png)

## Spell markers

| Marker | Meaning |
| --- | --- |
| **NEW +** | Learnable now. |
| **✓** | Already learned. |
| **NEXT** | Next learning milestone, with a yellow outline and background. |
| **NOT NOW** | Not yet available. |
| **BEST** | Highest rank you have learned, even if it is the only one. |
| **LOW** | An older rank: you already know a higher one. |
| **BUY NEW RANK** | An accessible higher rank remains to learn. |
| **ECO** | Rank 1 can suffice for the recommended use while leveling. |
| **OPTIONAL** | A spell or extra rank whose purchase can wait for your selected roles. |
| **RECENT** | Part of your latest recorded learning. |

Trainer markers use green, yellow, red or grey outlines. NEW + can also glow. In the spellbook, OPTIONAL appears beside BEST when applicable. Hover spells for explanations, including ECO and OPTIONAL advice on action bars.

**ECO saves training gold, not guaranteed mana.** OPTIONAL does not mean useless. Advice covers selected spells and must suit every role you choose. Selecting PvP suspends ECO and OPTIONAL. BUY NEW RANK uses TrainerSpells or information from the trainer you have opened; it does not check your gold.

## Recent learning

**RECENT** appears just below spell and talent icons in supported views. Your latest learned spells, pet abilities, talent ranks and recipes are listed in **Recent learning** and saved between sessions. A trainer visit without learning anything keeps the previous list; new learning replaces it. Learning outside a trainer visit is also tracked.

On first use, already-known spells from your latest accessible level tier are selected when their required levels are available. Your next learning replaces this initial selection. Custom profession windows may require consulting the list in the options.

## Roles and specializations

Choose your roles and specializations in **Talent Spec and Role**. Only roles available to your class are offered; PvP is a separate activity.

On first use, a specialization is suggested from your spent talent points, or from the solo leveling recommendation if no tree dominates. Review the summaries, then select **Confirm my choices → OK** to activate your advice. Closing or choosing **Later** keeps the proposal inactive and offers it again next time you log in or reload.

Role labels appear beside talent-tree titles and the active spellbook school. Hover for a specialization overview, advantages and drawbacks. **LEVELING** identifies the main solo leveling recommendation. Before level 10, spellbook school tabs also show these summaries.

**PVP** and **PVE PVP** mark selected talents and learnable trainer spells, with explanations on hover. Unmarked entries have no recommendation.

## Books and recipes

Warlock pet grimoires show learned or learnable status, a yellow **+** when appropriate, and demon icons at merchants and in your bags. Merchants also flag books you already own. Summon each demon once to record its learned spells. Book markers then stay available whichever demon is active; a bright gold border highlights books for your summoned demon. Pet spellbooks use BEST, LOW, BUY NEW RANK and RECENT, with upgrade alerts limited to ranks available at your pet’s level.

**ALREADY KNOWN** marks learned recipes in bags and group or raid loot-roll windows when the game's tooltip confirms them. It never chooses a loot roll for you.

## Settings

Open **Options → AddOns → Skills & More**, or type `/sam settings`.

- **Language** — automatic game-client detection, French or English; reload to apply changes.
- **Display** — control icons, outlines, text and backgrounds, with separate display zones.
- **Talent Spec and Role** — choose roles, specializations and leveling advice.
- **Recent learning** — review your latest learning.
- **Diagnostics** — copy support reports.
- **Reset** — restore defaults or reopen the first-use window, with confirmation.
- **Patchnotes** — browse features and fixes by version.

Settings apply immediately and are saved per character. The minimap button opens settings with a left click or the summary with a right click. You can hide it in **Display**, or use the launcher through HidingBar or Titan Panel.

## Commands

| Command | Opens |
| --- | --- |
| `/sam` | Summary and refresh. |
| `/sam settings` | Settings. |
| `/sam debug` | Class trainer report. |
| `/sam bookdebug` | Spellbook report. |
| `/sam pet` | Saved pet spells. |
| `/sam petdebug` | Pet grimoire report. |
| `/sam conflicts` | Compatibility report. |

For a bug report, reproduce the issue with the relevant window open, then share its **Copy Export** report.

## Compatibility

Bag markers are confirmed with **Blizzard bags** and **EllesmereUI Bags**. Other bag addons are not yet confirmed.

DarkMode and TrainerSpells have dedicated compatibility handling. With TrainerSpells active, its trainer text stays unchanged. Its class list can show ECO / OPTIONAL, PVP / PVE PVP and RECENT when space allows; toggle these markers in **Display**.

## Installation

Place `SkillsAlreadyKnown` in `World of Warcraft/_forever_/Interface/AddOns`, then enable it in the game's AddOns list.

By **CryptoLogiq** · [MIT License](https://github.com/CryptoLogiq/SkillsAlreadyKnown/blob/main/LICENSE)
