# Changelog

## Unreleased

### Features

- Add French and English translations, automatic client-language detection and a saved language choice in the options. Reload to apply language changes.

## 0.4.0

### Features

- Rename the addon to Skills & More, with By CryptoLogiq in the options window.

- Open the addon with /sam and its existing subcommands.

- Identify trainer spells with NEW +, a learned check, NEXT and NOT NOW, with colored outlines and an optional NEW + glow.
- Compare learned spell ranks with BEST and LOW; spot accessible upgrades with BUY NEW RANK.
- Get role-based ECO and OPTIONAL purchase advice in the spellbook, at trainers and in spell tooltips.
- Track recent spell, talent and recipe learning with RECENT and a saved list. First use can highlight known spells from the latest accessible level tier.
- Flag learned recipes in bags and group or raid loot-roll windows with ALREADY KNOWN.
- Choose class-appropriate roles and specializations, with a first-use suggestion and confirmation before advice becomes active.
- Read specialization summaries, advantages, drawbacks and leveling recommendations in the options and talent-tree tooltips.
- See role labels in talent trees and the spellbook, LEVELING on the main solo recommendation, and PVP / PVE PVP on selected entries.
- Read specialization summaries from spellbook school tabs before level 10.
- Show purchase advice, usage markers and RECENT in the TrainerSpells class list when space allows.
- Control icons by display zone, and toggle outlines, text and backgrounds separately.
- Open settings from a minimap button, HidingBar or Titan Panel.
- Restore defaults or reopen the first-use window with confirmation and an optional reload.
- Browse patchnotes and copy support reports from the options.

### Fixes

- Prevent unlearned or future-level ranks from causing incorrect LOW markers.
- Restore OPTIONAL advice on eligible unranked spells, including Eye of Kilrogg, and clarify when only extra ranks can wait.
- Hide spellbook markers on other addons' tabs and restore them on return.
- Preserve specialization labels when DarkMode recolors titles; leave trainer text under TrainerSpells' control.
- Keep TrainerSpells list markers aligned while scrolling.
- Mark the next profession training step with NEXT, including its yellow background.
- Place talent usage markers and RECENT below icons to keep images and spent points visible.
- Make reset confirmations and first-use validation buttons accessible, and avoid repeatedly reopening a dismissed first-use window.

## 0.3.3

- Added inventory overlays for recognized warlock pet grimoires.
- Already learned grimoires show a darkened book overlay and the matching demon icon.
- Grimoires learnable by the active pet show a yellow outline and plus marker.
- Confirmed compatibility with Blizzard bags and EllesmereUI Bags, including grid and list views.
- Fixed grimoire level requirement detection in inventory.
- Improved marker updates when books move or pet spells change.
- Added last-seen item locations to help identify duplicates across bags, bank, and guild bank.

## 0.3.2

- Updated README documentation for owned grimoire and support report behavior.

## 0.3.1

- Changed owned grimoire labeling to `[Already in your Bag]`.
- Owned grimoire detection now works even when the related pet is not active.
- Improved support export workflow with a separate opaque export window.

## 0.3.0

- Added shared in-game debug windows with colored previews and clean copyable bug-report exports.
- Added class trainer icon markers for already known and learnable spells.
- Added inventory detection for learnable warlock pet grimoires already owned in bags.
- Owned grimoires now show `[Already in your Bag]`, green outline, and tooltip guidance.
- Improved `/sak`, `/sak debug`, `/sak pet`, and `/sak petdebug` diagnostics.

## 0.2.0

- Added warlock pet grimoire highlighting in merchant windows.
- Remembers learned spells separately for each demon.
- Adds pet icons, learned book overlays, and learnable markers to grimoire items.
- Adds tooltip hints for already learned, learnable, and pet unlock level information.
- Improved grimoire recognition across client languages.
- Added `/sak pet` and `/sak petdebug` diagnostics for pet spell data.

## 0.1.1

- Improved class trainer scroll performance.
- Reduced marker glitches while scrolling through trainer spells.

## 0.1.0

- Initial release for WoW Forever / Camelot.
- Grey text and subdued background for already-known trainer spells.
- Red spell names for trainer spells locked by character level.
- Green outline and subtle background for trainer spells learnable now.
