# Changelog

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
