# Changelog

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

- Refactored the addon into Core, Visuals, ClassTrainer, PetGrimoires, and Main modules.
- Added shared in-game debug windows with colored previews and clean copyable bug-report exports.
- Added class trainer icon markers for already known and learnable spells.
- Added inventory detection for learnable warlock pet grimoires already owned in bags.
- Owned grimoires now show `[Already in your Bag]`, green outline, and tooltip guidance.
- Improved `/sak`, `/sak debug`, `/sak pet`, and `/sak petdebug` diagnostics.

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

## 0.1.0

- Initial release for WoW Forever / Camelot.
- Grey text and subdued background for already-known trainer spells.
- Red spell names for trainer spells locked by character level.
- Green outline and subtle background for trainer spells learnable now.
- Uses trainer API state instead of localized text matching.
