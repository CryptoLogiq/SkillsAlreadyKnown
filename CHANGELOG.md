# Changelog

## 0.3.3

- Added EllesmereUI Bags integration through its item overlay API for grid and list views.
- Validated grimoire overlays in game with Blizzard bags and EllesmereUI Bags; other bag addons remain unverified.
- Fixed modern bag button enumeration and preserved grimoire level requirements during inventory detection.
- Refresh inventory markers after pet spell synchronization and item information updates.
- Local installs now use an isolated `SkillsAlreadyKnown_dev` copy with separate saved variables and a `[DEV]` title.
- Official builds now skip initialization when DEV is enabled for the current character.
- Updated local scripts for the Heroic/Battle.net installation, with `SAK_WOW_ROOT` override and `--dry-run` support.
- Packaging now preserves existing release archives instead of overwriting them.
- Added bag, bank, and guild bank overlays for recognized warlock pet grimoires.
- Known grimoires in inventory now show the learned book overlay and pet icon.
- Learnable grimoires in inventory now show the yellow outline and plus marker.
- Saved recognized grimoire item metadata and last-seen storage locations locally to help spot duplicates.

## 0.3.2

- Updated README documentation for owned grimoire and support report behavior.

## 0.3.1

- Changed owned grimoire labeling to `[Already in your Bag]`.
- Owned grimoire detection now works even when the related pet is not active.
- Improved support export workflow with a separate opaque export window.
- Added packaging notes to avoid overwriting prepared release zips.

## 0.3.0

- Refactored the addon into Core, Visuals, ClassTrainer, PetGrimoires, and Main modules.
- Added shared in-game debug windows with colored previews and clean copyable bug-report exports.
- Added class trainer icon markers for already known and learnable spells.
- Added inventory detection for learnable warlock pet grimoires already owned in bags.
- Owned grimoires now show `[Already in your Bag]`, green outline, and tooltip guidance.
- Improved `/sak`, `/sak debug`, `/sak pet`, and `/sak petdebug` diagnostics.
- Improved local install/package workflow and development notes.

## 0.2.0

- Added warlock pet grimoire highlighting in merchant windows.
- Tracks learned pet spells per pet with SavedVariables.
- Adds pet icons, learned book overlays, and learnable markers to grimoire items.
- Adds tooltip hints for already learned, learnable, and pet unlock level information.
- Stores merchant spell IDs after detection to improve behavior across client languages.
- Added `/sak pet` and `/sak petdebug` diagnostics for pet spell data.

## 0.1.1

- Improved class trainer scroll performance.
- Reduced visual glitches when trainer rows are recycled while scrolling.
- Added cached trainer service lookup to avoid repeated API work.
- Improved local packaging and install scripts for development/testing.

## 0.1.0

- Initial release for WoW Forever / Camelot.
- Grey text and subdued background for already-known trainer spells.
- Red spell names for trainer spells locked by character level.
- Green outline and subtle background for trainer spells learnable now.
- Uses trainer API state instead of localized text matching.
