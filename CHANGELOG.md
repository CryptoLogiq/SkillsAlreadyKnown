# Changelog

## Unreleased

## 0.5.0

### Features

- New markers distinguish spell uses: CLASS, AOE, SURVIVAL, KICK, TAUNT and AGGRO. Tooltips explain their conditions; several uses can combine.
- Supported forms, stances and auras show TANK, HEAL or DPS, including Paladin auras. These hints do not change the selected role.
- In the spellbook, RECENT sparkles gold while a spell is missing from action bars, then blue after placement until a successful use is recorded. Tracking survives reload and the RECENT badge remains after use.
- Blue sparkles also appear on supported Blizzard and EllesmereUI bars, including stance, form and aura bars. The tooltip explains the hint.
- NEW + icons sparkle at class and profession trainers. Recognized unlearned recipes sparkle at merchants and in loot, only around their icon. These effects can be toggled in Display.
- In Custom → Spell badges, customize your class’s usage, PvP and purchase markers, or add a spell by ID. Choices can apply to this character or the class across the account, with All ranks checked by default.
- Badges can appear above tooltips. In the spellbook, categories sit just above BEST, LOW or ECO to keep spell names clear.
- Selected hints explain useful combinations: Judgement with a Seal, Ice Lance against a frozen target, Swiftmend with a heal over time, Fire Nova with a Fire totem and Conflagrate with Immolate.
- Selected Paladin talents show recommended specializations with their icons and the guide’s precise build context. Situational variants are distinguished from the standard build.
- Talents that improve area spells show the affected spells with their game icons and descriptions. Their AOE marker describes the mechanic, not a requirement to choose the talent.
- Settings sections appear in the left-hand list of Options → AddOns under Skills & More, leaving more room for their content.

### Bug fixes

- Badge explanations and usage advice follow the selected language, including outside the spellbook.
- In TrainerSpells, recorded demon abilities show their learned check even with translated names or grimoires using a different ID.
- Recognized area spells are no longer recommended as OPTIONAL purchases. Drain Soul shows CLASS and retains appropriate rank advice without being presented as an optional spell.
- Usage categories remain recognized across a spell’s ranks. Divine Protection is recognized at both ranks.

## 0.4.1

### Features

- Choose French or English in the options, with automatic client-language detection.
- Track pet spell ranks, available upgrades and recent learning in supported views.
- Keep pet book markers visible for every demon; a bright gold border highlights books for the active pet.

### Bug fixes

- The official addon starts when the DEV copy is installed but not loaded.
- The selected language is restored correctly after reloading.
- TrainerSpells recognizes recorded pet abilities as already learned.

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
