# SkillsAlreadyKnown Agent Notes

## ABSOLUTE PRIORITY: preserve work and develop on dev

Before any edit, staging or commit, verify the authoritative repository, current
branch and working-tree/index state. Work on `dev`; `main` is reserved for explicitly
requested publication. This check takes precedence over convenience or speed.
Never discard local work to change branches: no hard reset, forced checkout,
clean, branch overwrite or automatic stash/pop. Preserve staged and unstaged
changes. Switch/create dev only when that preserves them; if a conflict prevents
it, stop dependent changes and ask the owner how to proceed. Never continue
editing main as a workaround. Do not merge, push, tag or publish implicitly.


Reconciled against the working code on **2026-11-13**. This is the developer guide;
player documentation belongs in README.md. Existing local changes are intentional:
do not revert, stage everything, commit, bump versions or publish without a request.

## Workspace, DEV installation and releases

- Authoritative source: `/mnt/Stockage/_Github_/DevAddOns/SkillsAlreadyKnown`.
  The older `/mnt/Stockage/_Github_/SkillsAlreadyKnown` checkout is not the selected
  development source. Always set the working directory explicitly.
- Local client: `~/Games/Heroic/Prefixes/Battle.net/drive_c/Program Files (x86)/World of Warcraft/_forever_`.
- Local testing: `./scripts/install-local.sh`; preview with `--dry-run`.
  `SAK_WOW_ROOT` overrides the client directory.
- The script manages **only** `Interface/AddOns/SkillsAlreadyKnown_dev`, with its
  own TOC, `[DEV]` title, namespace, frame names, saved variables and asset paths.
  Never overwrite the official `Interface/AddOns/SkillsAlreadyKnown` copy.
- DEV renaming must process addon-owned Lua files **recursively**, including
  `data/`, while leaving every `libs/` file byte-identical. Rename only the staged
  copy; source and public packages retain the original addon name.
- A previous root-only glob left `data/LevelingAdvice.lua` pointing at the official
  namespace, silently emptying DEV's OPTIONAL catalogue. Validate the **installed**
  tables and rule counts, not just source-tree tests, whenever adding nested data.
- Core and every runtime module/data file must honor `disabledByDev`. The official
  copy skips initialization when DEV is enabled, regardless of load order, without
  persistently changing addon settings. Old published versions lacking the guard
  may still need manual disabling during tests.
- Packaging: `./scripts/package.sh` keeps `release/SkillsAndMore-<version>.zip`
  and publishes the upload copy plus `patchnote.md` under `release/latest/`.
  Scripts, research, agent files and other development metadata are excluded from
  installs and archives; vendored libraries and active data are included.
- Keep delivered archives; never overwrite one. Bump the version when preparing
  a requested deliverable, not after each edit. Use patch increments within a
  feature line and a minor increment for a larger feature release.
- Git uses `core.fileMode=false` because WoW/Wine may flip executable bits.

## User preferences and documentation audience

- Prefer readable **Lua tables** for maintained game data. Group by class and
  specialization, keep one field per line when entries are complex, and retain
  spell names beside numeric IDs where available. Do not restore CSV-based editing
  or require an export/generation step for normal maintenance.
- Connect related tables through stable class/spec/role keys and numeric spell IDs.
  Keep one authoritative definition for each fact; consumers may build indexes in
  memory but must not maintain duplicate generated catalogues inside feature code.
- Separate data, policy and rendering. Add focused feature modules instead of
  growing unrelated modules or hardcoding class-specific UI strings in renderers.
- Player wording uses **« rôle »**, not « profil ». Keep internal saved-variable
  keys/API names compatible; terminology changes do not require a data migration.
- Explain decisions in plain French for beginners. Keep English badge labels
  consistent: ECO, BEST, LOW, OPTIONAL, BUY NEW RANK, NEW +, NEXT, NOT NOW.
- README.md, CHANGELOG.md, CurseForge descriptions and proposed public commit
  messages are concise **player-facing** material: behavior, compatibility and
  useful commands. No deployment scripts, personal paths, Wine/Heroic setup,
  staging/namespace details, packaging mechanics or agent workflows.
- Developer instructions belong here or in CONTRIBUTING.md. These files are
  public in Git even though excluded from release archives. Keep local licensed
  extracts ignored, rather than assuming everything under scripts/ is private.
- The user rejected embedding the README in an About tab. Do not revive that UI.
- Advice is informational. Never buy/train automatically, hide spells, assign game
  roles or spend talent points. A first-use suggestion is authorized: only when
  no role settings exist and the prompt has not been seen, use the unique dominant
  active talent tree; otherwise use the first solo leveling recommendation. Below
  level 10, always use the leveling recommendation. Never replace saved choices.
  Farouche defaults to DPS because its shared tree does not establish a tank role.

## Runtime modules and table connections

The TOC is authoritative for load order. Libraries load first, Core before data,
and active data before its policy/rendering consumers.

| Module/table | Responsibility and consumers |
| --- | --- |
| `Core.lua` | Namespace, saved variables, stable-ID/text helpers, constants and badge assets. |
| `data/ClassRoles.lua` | One definition of class names, specialization keys/labels, supported Tank/Heal/DPS mappings, PvP activity, role explanations and talent-tree grouping. Used by RankPolicy, Settings and TalentRoles. |
| `data/LevelingAdvice.lua` | Editable purchase rules grouped by class/spec: role, source URL, spell name/baseID, category, minRank/optional maxRank and reason. RankPolicy flattens only in memory. |
| `data/TalentSummaries.lua` | Original French gameplay summaries, advantages/drawbacks, source URLs and review dates for all class/spec roles. Used by TalentRoles. |
| `data/LevelingRecommendations.lua` | Per-class solo/group leveling suggestions using ClassRoles specialization keys, contextual explanations and Forever sources. Used by TalentRoles. |
| `PlayerRoles.lua` | Saved role choices, migration, supported specializations and preference changes. RankPolicy retains compatibility aliases. |
| `data/RankOneAdvice.lua` | Reviewed strict rank-one rules, keyed by class and stable spell ID. |
| `RankPolicy.lua` | ECO/OPTIONAL scope, purchase advice and all-selected-role agreement. Exposes `PurchaseCatalogue`; retains settings prompt entry points. |
| `RankAvailability.lua` | Accessible missing-rank checks using the optional live TrainerSpells catalogue or currently available observed trainer services. Never loads local research extracts. |
| `SpellRanks.lua` | Pure classification of learned spell families and purchase advice. |
| `SpellBook.lua` | Learned spell scan, view adapters, detached badges, compact legend and `/sam bookdebug`. |
| `SpellTooltips.lua` | Spellbook, external spell and trainer tooltip annotations; retains Book tooltip entry points. |
| `TalentRoles.lua` | Native talent-title discovery, role labels, placement and visibility. |
| `TalentTooltips.lua` | Role, leveling and gameplay explanations for talent labels. |
| `ClassTrainer.lua` | Trainer API scan, service-to-row matching and shared Blizzard/TrainerSpells row rendering. |
| `PetGrimoires.lua` / `Inventory.lua` | Demon spell persistence, merchant books and recognized inventory/bank/guild-bank overlays. |
| `Visuals.lua` / `Glow.lua` | Reusable visual helpers and NEW +-only proc halo. |
| `Compatibility.lua` / `Diagnostics.lua` | Conditional adapters and bounded observational reports. |
| `DebugWindows.lua` | Copyable report windows, sanitization and report formatting. |
| `Settings.lua` / `Main.lua` | Shared AceConfig model; slash commands and explicit refresh orchestration. |
| `Events.lua` | Game event subscriptions and timed module refresh routing. Loaded last. |

Current audit snapshot: nine classes, 28 specialization/role descriptions, 165 active
purchase rules and 81 research records. These are coverage observations, not limits
on future maintenance. Preserve stable keys such as `guardian` and `beast-mastery`.
Farouche's single talent tree connects both `feral` (DPS) and `guardian` (tank).

## Sources, provenance and research boundaries

### Maintained recommendations and explanatory text

- Prefer **Wowhead Forever** pages under `https://www.wowhead.com/forever/`.
  Search often returns Retail, TBC/Wrath or other Classic versions: do not use
  them as substitutes for Forever recommendations. Check edition, date and scope.
- Source URLs and review dates belong with the relevant Lua data. Keep editorial
  interpretation distinct from statements explicitly made by the guide.
- Gameplay descriptions are original French paraphrases, not copied guide prose.
  If a strengths/weaknesses section is empty or incomplete, use only the described
  gameplay and retain an `editorialNote`; do not invent a Wowhead ranking.
- Each talent summary explains the playstyle, then concludes with **Avantages** /
  **Inconvénients**. No promises of guaranteed damage, invitations or future balance.
- Leveling suggestions distinguish solo and group play. Mention mana, equipment,
  pets, early wand use or later talent milestones when relevant. They are beginner
  suggestions, not a fastest-spec tier list and not automatic talent selection.
- Overview URL pattern: `/forever/guide/classes/<class>/<spec>/overview-pve-<dps|healer|tank>`.
  Feral tank uses `druid/feral/overview-pve-tank`, not a fabricated guardian URL.
- Research inventory: `scripts/research/eco-spells-forever.lua` (return-value table,
  not loaded by the addon) and the older explanatory `.txt`. Some historical notes
  still refer to the former CSV; the maintained Lua table takes precedence.
- Original research includes `a_verifier`, `a_conserver`, build-dependent cases
  and pet grimoires. Do not import every record as an unconditional OPTIONAL/ECO
  rule. Promote candidates after checking IDs, ranks and applicable context.
- Mind Soothe rank 1 has a target-level limitation: do not declare it universally
  rank-one sufficient. Likewise, emergency heals/controls/defensives do not become
  dispensable solely because a broad guide list mentions them.

Useful entry points already consulted (full per-spec links remain in the tables):

| Topic | Source |
| --- | --- |
| Hunter leveling and spec choices | https://www.wowhead.com/forever/guide/classes/hunter/leveling-guide |
| Priest solo/healing choices | https://www.wowhead.com/forever/guide/classes/priest/leveling-guide |
| Discipline leveling | https://www.wowhead.com/forever/guide/classes/priest/discipline/healer-leveling-tips |
| Mage safety vs mana | https://www.wowhead.com/forever/guide/classes/mage/frost/dps-leveling-tips and https://www.wowhead.com/forever/guide/classes/mage/arcane/dps-leveling-tips |
| Feral leveling | https://www.wowhead.com/forever/guide/classes/druid/feral/dps-leveling-tips |
| Retribution leveling | https://www.wowhead.com/forever/guide/classes/paladin/retribution/dps-leveling-tips |
| Combat leveling | https://www.wowhead.com/forever/guide/classes/rogue/combat/dps-leveling-tips |
| Enhancement leveling | https://www.wowhead.com/forever/guide/classes/shaman/enhancement/dps-leveling-tips |
| Warlock leveling choices | https://www.wowhead.com/forever/guide/classes/warlock/affliction/dps-leveling-tips and https://www.wowhead.com/forever/guide/classes/warlock/demonology/dps-leveling-tips |
| Warrior leveling choices | https://www.wowhead.com/forever/guide/classes/warrior/arms/dps-leveling-tips and https://www.wowhead.com/forever/guide/classes/warrior/fury/dps-leveling-tips |

### Rank mechanics and native UI

- `scripts/research/spell-ranks-forever-notes.txt` preserves scope and references:
  - https://worldofwarcraft.blizzard.com/en-us/news/24315281/wow-forever-hotfixes-november-10-2026
  - https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-november-2/2360696/1
- Equalized mana costs for named spells do not prove the same rule for every spell.
  ECO concerns training gold, **not guaranteed mana savings**. Do not turn old-rank
  power/proc restrictions into a universal hit-chance penalty.
- Compare native UI with Forever/Camelot-specific sources, including
  https://github.com/Gethe/wow-ui-source where applicable. Retail geometry alone
  is insufficient; prefer observed client frame/API evidence.
- Vendored library versions, licenses and upstream revisions are in `libs/README.md`.
  Keep the upstream files unmodified. LibStub negotiates versions: reuse equal/newer,
  upgrade older registrations; never downgrade or rename shared libraries for DEV.

### TrainerSpells local extraction

- Installed TrainerSpells **1.1.12** supplied the Forever research extraction.
  Its source LICENSE allows personal local use but not redistribution. Keep
  extracts ignored by Git, out of the TOC and excluded from installs/packages.
- `scripts/research/extract-trainerspells-all.py` with
  `scripts/research/extract-trainerspells-all.lua` reads all
  `data/forever` tables into `scripts/research/trainerspells-local/`.
  The output includes readable `classes/`, raw tables, quest definitions, manifest,
  source hashes, README and the original LICENSE. Every table is round-trip checked.
- Snapshot: 37 files, nine classes / 1,363 trainer entries, 51 quest-spell entries,
  plus weapons, trainers, professions, recipes and pet data.
- `scripts/research/extract-trainerspells-pets.lua` writes the separate ignored
  `scripts/research/pets-trainerspells-local/` collection. Snapshot: 59 demon entries,
  45 hunter-trainer entries, 31 hunter abilities / 149 ranks, 18 families, 672 beasts.
- Preserve omitted ranks/names, zero levels and empty location/teaching lists.
  Source grimoire/teaching IDs may differ from actual pet-action IDs.
- Do not confuse player learning levels, pet-required levels, beast min/max levels
  and profession skill thresholds. Match teaching beasts by exact ability IDs,
  not family membership alone.
- Source class tables are shared across specializations. Do not invent spec
  memberships, names or rank chains from numeric ID order. Preserve suspicious
  self-references/missing prerequisites as unresolved, not as verified links.
- Runtime BUY NEW RANK support is an independent reader of the optional live
  `TrainerSpellsBuiltin` tables, declared via OptionalDeps, not a packaged copy of
  the licensed research dataset. Without it, current available trainer observations
  are the fallback; remembered levels alone do not establish continued eligibility.

## Roles, settings and player terminology

- `data/ClassRoles.lua` drives supported role choices. Hide unsupported role groups
  instead of showing useless disabled choices. A single possible specialization
  is auto-selected and displayed as text; keep dropdowns when a choice is needed.
- Tank = protect/hold enemies; Heal = heal allies; DPS = deal damage. PvP is a
  separate **activity**, available to every class, with its class-spec choices.
  Do not present it as a fourth combat role or infer unsupported Forever builds.
- Keep the tab names **Affichage / Talent Spec and Role / Diagnostics**. The stable
  role-tab key is `spellbook`; first-use settings open this tab directly.
- Multiple roles can remain checked. Preserve each unchecked role's specialization
  so rechecking restores it. Recommendations must suit **every** enabled role/spec;
  one role's need vetoes savings advice from another. PvP suspends ECO/OPTIONAL.
- Saved shape: `levelingProfile.roles[role] = { enabled, spec }`, plus class, eco,
  optional and buyRank preferences. Legacy top-level role/spec fields are only
  compatibility summaries. Migrate old selections without losing intent/settings.
- `SetRoleEnabled` is independent; `SetRole` is an exclusive convenience. Never
  infer the selected spec from the visible talent tree or call UnitSetRole.
- First-use choice is per character. Cancel/close defers without activating advice;
  only accepting the recap stops automatic reopening. Defer opening during combat. `/sam settings` opens the game AddOns
  category; `/sam profile` remains a backward-compatible alias, not player wording.
- Share one AceConfig model between startup and game options. Register once, use
  addon-specific app/category keys and support late Settings loading, modern APIs,
  legacy BlizOptionsGroup, and standalone fallback. Main owns slash commands.
- AceConfigDialog owns widget creation/release. Do not permanently reskin pooled
  AceGUI widgets, patch upstream internals or add global widget/color hooks.
- Report buttons call report functions directly, close our dialog/game options
  before opening copyable reports, and avoid protected panel work during combat.

## Spell classification and purchase advice

| Marker | Meaning |
| --- | --- |
| ECO | Verified rank 1 suffices for the recommended leveling use for the selected roles. It is not a damage-maximization or mana-saving claim. |
| BEST | Highest **learned** rank, even alone; not necessarily the final game rank. |
| LOW | Below another rank the player has **already learned**. Never caused by an unbought/future rank. |
| OPTIONAL | Additional badge to the **right of BEST**. The spell purchase or extra rank can wait for the selected roles/context. |
| BUY NEW RANK | Replaces BEST on the highest learned rank when an accessible, unlearned upgrade is needed outside ECO/OPTIONAL advice. |

- `data/LevelingAdvice.lua` is the active purchase catalogue; sources are at the
  specialization level. data/RankOneAdvice.lua retains the explicit strict rank-one
  anchors. Do not merge approximate candidate lists into those stricter ECO rules.
- Match stable IDs first. Later ranks can be linked using client API names resolved
  from actual IDs and a verified base ID; never a truncated trainer row label or
  numeric ordering. Cache successful resolutions only; unknown data fails closed.
- `OptionalAdvice` and `UpgradeCanWait` currently apply below level 60; the strict
  `RankOneAdvice` function does not impose that same global cap. Document actual
  per-policy behavior rather than inventing a universal cap without changing/tests.
- Display preferences for ECO/OPTIONAL are independent. Hiding their badges must
  not turn an optional extra-rank purchase into a required BUY NEW RANK alert.
- OPTIONAL has typed scope: `spell`, `higher-ranks`, `rank-one`. Carry it through
  learned states, missing-rank suggestions and unlearned trainer tooltips. Do not
  infer the type from free-form reason text or assume every rank range means rank 1.
- Rank-one tooltip: **« OPTIONAL — seuls les rangs supplémentaires sont facultatifs. »**
  Explain that rank 1 suffices for the recommended use and the spell itself remains
  useful; higher ranks may improve effects. Other deferrable ranks get their own
  wording without claiming universal rank-one sufficiency.
- Whole-spell OPTIONAL keeps its short explanation and situational note. Do not
  display raw research reasons listing unrelated spell uses. Keep the conditions
  in policy data. Gold wording: **« Reporter cet achat permet d'économiser de l'or
  pendant le leveling. »** ECO-specific advice and BUY rank/level details remain.
- Spell tooltips outside the book (action bars, compatible spell links and trainer
  services) resolve exact IDs, use modern TooltipDataProcessor or legacy hooks,
  respect the text gate and deduplicate on each tooltip lifecycle. No duplicate
  advice from spellbook/action hooks. Unknown/pet IDs are not guessed.
- Agony is not an ECO spell. Kilrogg ID 126 must support BEST + OPTIONAL in a valid
  Warlock role setup. Extra Drain Soul ranks may be optional for shard generation;
  the spell itself is not dispensable. Searing Pain advice differs by specialization.

## Learned scans and accessible upgrades

- Scan all learned player slots, not just visible pages. Exclude future/unlearned,
  passive and off-spec entries. Validate learned IDs through available knowledge APIs
  and future-level requirements; ordinary SPELL metadata alone may include futures.
- Nonempty subtext can be a **category**, e.g. Invocation/Summon/Raciale. Keep active
  spells in those cases with `ranked=false`; do not treat every category as a bad
  rank. Explicit unreadable rank labels still fail closed, including localized RANK.
- Ambiguous same-name/same-rank IDs or mixed ranked/unranked families fail closed.
  Never infer a higher-rank order from an unranked spell. LOW must not reappear just
  because the game exposes unavailable higher ranks in a scan.
- RankAvailability requires a higher numeric rank, matching spell family, confirmed
  unlearned ID, current player-level eligibility and satisfied race/faction and
  prerequisites. Skip unknown knowledge/names/ranks and self-referencing requirements.
- A missing required intermediate rank blocks jumping to its successor. Prices
  are not checked; describe BUY as an accessible training opportunity, not proof
  the player can afford it. Refresh after learning, leveling and provider loading.
- Live observed services contribute metadata, but fallback eligibility requires
  current `available` service state. Clear that state on TRAINER_CLOSED.
- `/sam bookdebug` includes render revision, active data-rule count, chosen
  roles/specs, scan data, row mapping, layers/alpha and candidate upgrade IDs/ranks.
  An empty catalogue in DEV is evidence to inspect staging/load order, not blame
  role settings without checking the installed data.

## Spellbook overlays, legend and compatibility

- Keep badges on addon-owned, mouse-transparent UIParent frames. Read native
  spell-button fields without changing their icons, text, attributes, secure state,
  casts or drag behavior. Recycled/unknown slots, pet tabs and hidden books clear them.
- Support modern ForEachDisplayedSpell, legacy SpellButton slots and version-sensitive
  EUI_ClassicSpellbook child slot/icon fields. Preserve the visible-only bounded
  refresh and late Ellesmere discovery; do not add permanent expensive global scans.
- User-confirmed render fix: at least HIGH strata, preserving higher host/ancestor
  strata, then level above the full host chain. Set strata before level and match
  effective scale relative to UIParent. Do not revert to MEDIUM or parent secure rows.
- The measured native book was 574 wide, levels 100/101/103, scale about 0.64.
  Regressions should model that, not only generic low-level/unscaled frames.
- Badge anchor is icon TOPRIGHT (+7,+7). Compact two-row ECO / BEST+OPTIONAL legend
  uses PagedSpellsFrame TOPRIGHT (-20,-24), height 56; skip narrow/unsupported views.
  Do not cover search, school tabs or first spell rows. Header text follows the text
  gate; sample icons follow icons independently.
- TrainerSpells can keep the native book shown while setting PagedSpellsFrame alpha
  to zero. Check content **effective visibility/alpha**, not just root IsVisible;
  hide all detached badges/legend on its page and restore on the native page.
- AttackAssignment uses lower-right icon controls; keep our badges upper-right and
  do not copy its code or overlap its controls.

## Talent role labels and descriptions

- `TalentRoles.lua` annotates the native `PlayerSpellsFrame.TalentsFrame` only.
  Match visible title FontStrings using native GetTalentTabInfo names/table names;
  do not infer child order, choose arbitrary talent buttons or modify protected UI.
- Labels sit to the **right of each tree title**, accounting for text justification
  and actual glyph width. Use the native group-finder texture
  `Interface\\LFGFrame\\UI-LFG-ICON-ROLES`, not portrait-role icons. In talents the
  icons are 32 px with large text; settings keep their compact native icon labels.
- Keep detached HIGH-or-higher overlays, native scale and visibility, cached title
  discovery and a bounded visible-only driver. Hide on page close/transparency or
  the global text gate. Hover explanations must not change saved selections.
- Farouche displays Tank + DPS, with separate bear and cat description sections.
- Tooltip order: role explanation; class-specific **Leveling conseillé** (Solo /
  En groupe with context); specialization gameplay; **Avantages**, **Inconvénients**
  as the concluding points. Sources/review metadata stay in the Lua tables.
- Standalone Talents Forever windows, gamepad modes and unknown custom talent
  replacements are not automatically supported. Inspect their actual frames before
  claiming compatibility. Mocked tests do not prove pixel-perfect in-game placement.

## Class trainers, books and inventory

- Prefer GetTrainerServiceInfo/GetTrainerServiceLevelReq/C_TooltipInfo.GetTrainerService
  over localized text. Match IDs and validated skillIndex plus visible order;
  unwrap data nodes. Never trust generic `data.id` as service index or spell ID.
  A past bug matched higher-rank rows to known lower ranks; preserve the safeguards.
- TrainerSpells replaces the visible ScrollBox and hides native rows. Observe
  ClassTrainerFrame_InitServiceButton without replacing its behavior; track and
  deduplicate native/initialized visible rows with the same renderer.
- NEW + = available, green outline/subtle green background; green check = known,
  grey outline/darker background. NEXT = next even-level milestone (+2 if even,
  +1 if odd), yellow outline/background. Other unavailable = NOT NOW/red outline.
  Clear mutually exclusive fills and badges when rows recycle or cannot be matched.
- Advice ECO/OPTIONAL appears **beside** the trainer's status badge for applicable
  purchases, including unlearned spells. NEW + means learnable, not mandatory.
- Only NEW + has a proc-style halo: shared bundled LibButtonGlow first, native
  fallback second, then our action-button-border alpha animation. Stop animations
  when hidden; do not restart running effects every refresh or animate other badges.
- Without TrainerSpells, known names can be grey and level-locked names red, while
  requirement strings keep game coloring. With TrainerSpells, never recolor/rewrite
  its trainer text, even on cleanup. Late loading must make prior text hooks inert.
- Pet grimoires: layered saved pet ID/name/rank matching, then migrate confirmed
  merchant IDs into `petSpells[petKey].byID`. Keep petKey/display petName metadata.
  Never reject large internal pet/action IDs just because they look nonclassic.
- Recognized item metadata is saved by itemID in `petGrimoires`. Known books use
  `[Already Learned!]`, dark overlay and demon icon; learnable books use yellow
  treatment and the book-plus asset. Merchants can flag already-owned books.
- Inventory covers recognized bag/bank/guild-bank buttons; itemStorage tracks last
  seen locations, not authoritative unopened bank contents. Blizzard/Ellesmere bags
  are confirmed; other bag addons need testing.
- Ellesmere bags use EUI_Bags.RegisterItemOverlayIcon with state on our frames under
  button._textOverlay, not its secure item buttons; copy reused callback data.

## Display gates and diagnostics

- Per-character displayOptions: icons, outlines, text, backgrounds; unset = enabled.
  Keep categories independent of role selection and each other.
- Icons hide badges, book/demon overlays and NEW + halo; outlines hide our borders;
  backgrounds hide our row fills. Leave native icons/default borders/panel skins alone.
- Text gates our colors, prefixes, counts, tooltip additions, book legend and talent
  role labels. GUI reference explanations and diagnostic windows remain readable.
- Restore only font colors/layers still owned by us, not another addon's later
  changes. Clear stored trainer colors when disabling text. No global color hooks.
- Compatibility.lua contains conditional adapters: standard path without optional
  addons; independent Ellesmere support with/without DarkMode.
- Inspected DarkMode 0.8.46 has no public exclusion API. Its dm_setup markers/reentry
  guards are version-sensitive adapters, not a stable API; restore guards on errors.
  Protect only our textures/allowed trainer-name painting, never native spell icons,
  requirements or other addons' settings. DarkMode GUI reskin work remains deferred.
- `/sam conflicts` and exported reports contain bounded, deduplicated session
  observations. Installed/shared-UI addons are candidates, not proof of conflicts.
- Do not replace global error handlers, disable addons/change CVars automatically,
  or persist logs. BugGrabber reads are current-session only. Preserve other tools.
- Commands: `/sam`, `/sam settings`, `/sam debug`, `/sam bookdebug`, `/sam pet`,
  `/sam petdebug`, `/sam conflicts` (and the compatibility alias `/samconflicts`).
  Debug exports include compatibility observations once, with manual isolation steps.

## Verification workflow

- Read related tables, policy and renderer together before changing behavior. Add
  meaningful regressions for classification/eligibility/integration changes; simple
  reversible wording edits need syntax/diff checks rather than new mirrored tests.
- Run affected checks from the development repository:

  | Area | Checks under `scripts/` |
  | --- | --- |
  | Roles, GUI and libraries | `test-first-use.lua`, `test-settings.lua`, `test-aceconfig.lua`, `test-bundled-libs.lua` |
  | Data/advice | `test-research-data.lua`, `test-trainer-advice.lua` |
  | Ranks, overlays and tooltips | `test-spellbook.lua`, `test-rank-availability.lua`, `test-spellbook-legend.lua` |
  | Talent UI | `test-talent-roles.lua` |
  | Trainers and effects | `test-class-trainer.lua`, `test-trainer-badges.lua`, `test-trainer-borders.lua`, `test-glow.lua` |
  | Compatibility and reports | `test-compatibility.lua`, `test-display-options.lua`, `test-diagnostics.lua` |

- Use `lua scripts/<test>.lua`, appropriate `luac -p` checks, and `git diff --check`.
  Do not repeat unrelated suites after they pass without new evidence.
- For new tables, verify TOC load order and every class/spec/role reference, source
  scope and unknown-value behavior. Check installed DEV namespace ownership and
  library byte identity after staging changes. Keep licensed local extracts out.
- Separate evidence levels: syntax/tests, actual installed-table checks, and user
  screenshots/live UI reports. Only the last establishes real in-game rendering.
  Ask for `/sam bookdebug` or the relevant export when evidence is missing; do not
  repeatedly declare a visual fix from mocks or blame preferences without inspecting.

## Readable Lua style

Follow the small modules and explicit orchestration used in the owner's
[Base-code-love2d](https://github.com/CryptoLogiq/Base-code-love2d)
(`main.lua`, `core/init_core.lua`) and
[Fight-Club](https://github.com/CryptoLogiq/Fight-Club) (`Core/core.lua`).
These references were inspected in local clones; use WoW's TOC for loading,
not their Love2D loader.

- Write for an intermediate Lua programmer: explicit flow comes before brevity.
  Use two-space indentation, camelCase for locals/private helpers and the existing
  PascalCase convention for public module methods. Keep existing public names.
- Give each module one responsibility; expose functions on the shared SAK module table.
  Start runtime files with the namespace and disabledByDev guard; keep private
  helpers local and avoid adding globals beyond the addon namespace.
- Use descriptive local names and named helpers with early returns. Prefer one
  statement per line over compressed branches and nested conditional expressions.
- Keep comments short: explain a compatibility constraint or a non-obvious reason,
  rather than restating the code. Avoid generic frameworks for simple routing.
- Keep class/spec/spell rules in readable Lua tables and connect them by stable
  keys. Do not duplicate authoritative data in renderers.
- Preserve saved-variable keys and public entry points during refactors. Load
  dependencies before consumers in the TOC and matching test fixtures.
- Core owns the shared tri-state spell-known helper; nil means unavailable, not false.
- Name API return values by meaning (for example legacyPoints and modernPoints),
  using `_` for unused values. Explain differing client signatures briefly.
- For nontrivial option definitions and gameplay data, put fields on separate
  lines. Small constant tuples may stay compact. Avoid nested `and/or` expressions
  when a plain `if` makes fallback behavior easier to follow.
- Keep user-facing French and stable internal keys separate. Reuse the existing
  data for settings and tooltips; do not copy summary prose into GUI definitions.
- Apply these conventions to new or touched code. Do not churn unrelated modules
  or vendor libraries merely to enforce formatting. Refactors preserve behavior;
  changed behavior needs a focused regression test.

Run all `scripts/test-*.lua` after cross-module refactors, plus syntax checks and
`git diff --check`. Test event routing with `scripts/test-events.lua`.

First-use regression: `lua scripts/test-first-use.lua`. The settings summaries reuse
`data/TalentSummaries.lua` through TalentTooltips; keep the three tree groups in
ClassRoles order, including both Farouche role summaries.

Settings maintenance: the Réinitialisation tab confirms both actions. ResetDefaults
resets display and role/advice preferences, then seeds current default roles.
RestartFirstUse preserves display options, clears role selection and reopens the
startup flow through LaunchReport. Both refuse mutation during combat and preserve
petSpells, petGrimoires and itemStorage. Test with `scripts/test-settings-reset.lua`.

Startup replay persists `replayStartupOnLogin` after an explicit restart. On login,
Events routes it through the combat-deferred startup prompt even when a role exists.
Settings.Open consumes it when opening the startup window; ResetDefaults clears it.

Both reset execute options retain AceConfig confirmation before mutation. After a
successful action, OfferReload shows a native popup with Reload / Later. Only
accept invokes ReloadUI; cancel/Escape preserves saved changes and the replay flag.

Icon categories use displayOptions iconsSpellbook, iconsTrainer, iconsMerchant,
iconsInventory and iconsTalents (default true). The global icons switch wins.
Shared merchant/item painters accept a category so inventory never inherits the
merchant toggle. Talent category hides informational role labels and their tooltip;
other categories affect markers only, preserving text, backgrounds and outlines.

Launcher.lua owns the LibDataBroker launcher and LibDBIcon button. Initialize via
Events after login/addon loads; registration is idempotent. Minimap hide/position
live in DB.minimap, independent of content icon preferences. Hiding the minimap
button must not unregister the broker. ResetDefaults updates its saved table in
place and restores position. DEV uses a separate broker name through staging.

AceConfig confirmations must use `confirm = true` and `confirmText = "message"`.
A string in `confirm` is a handler method name, not literal text, and prevents the
reset action from executing when that method does not exist. Keep libraries intact.

## Explicit consent for startup roles

- `levelingDraft` contains proposed/edited roles and advice preferences. It is saved
  across reloads but never used by RankPolicy or runtime spell annotations.
- Settings reads/writes the selection APIs; runtime APIs continue reading only
  `levelingProfile`. Never make a draft active when opening or closing a window.
- Validate the complete selection with a snapshot, show the class/roles/specs and
  advice preferences in a centered OK/Annuler recap, and commit only on OK.
- Cancel, Escape and Plus tard preserve the draft without setting profilePromptSeen.
  MaybePrompt repeats whenever there is no active role selection, even if an old
  seen flag exists. Successful confirmation clears draft/replay and marks seen.
- Old `initialSuggestion` profiles lacking `confirmed` migrate into the draft.
  Previously manual profiles without that marker keep their existing behavior.
- Resets clear both active and draft choices, seed a new inactive proposal and
  retain pet/inventory records. This supersedes earlier immediate-activation notes.
- Regression: `lua scripts/test-role-confirmation.lua`, plus first-use/settings/reset
  tests. Check Cancel, reload, incomplete choices and combat as well as accepting.

## Player patchnotes

`patchnote/AGENTS.md` governs player-only editorial notes. Maintain readable
per-version Lua tables there, with additions and fixes. Unreleased is explicitly
development, never a claimed publication. `scripts/generate-patchnotes.py` assembles
`data/Patchnotes.lua` in descending semantic-version order. Do not hand-edit the
generated table. Settings renders it in Patchnotes. Packaging generates before
staging; local install generates directly into staging (including dry runs).
Exclude the editorial folder, keep the runtime table, and preserve old archives.
No version bump, publication or package overwrite is implied by editing notes.

StartupFooter.lua renders addon-owned buttons directly on the standalone
window, using the same parent/template/height as AceGUI Close. Later is left,
Confirm center and Close stays right. Hide the status bar only while our dialog
owns the shared frame and restore it on release. The independent refresh driver
must detect delayed window visibility; do not stop it when the buttons are hidden.
Do not modify third-party library sources. Keep inline actions as fallback.

Startup auto-opening is checked once per loaded session by RankPolicy. Events
requests it on PLAYER_LOGIN; PLAYER_REGEN_ENABLED only resumes an already pending
opening. Closing keeps the draft for the next login/reload but must never reopen
it during normal play. Explicit RestartFirstUse opens directly and remains usable.

## PvP / PvE usage guidance

`data/ContentUsage.lua` is the maintained source: 79 reviewed talent entries and
39 spell-family anchors across all nine classes at this revision. This is a
curated catalogue, not a claim to classify every talent. Only `pvp` and `mixed`
are exposed: PVP means primarily relevant against players, never PvE-forbidden;
PVE PVP means useful in both. Unknown entries have no tag. Sources and reasoning
must be explicit; no inferred generic mixed default or copied private catalogue.

`ContentTags.lua` builds class-scoped indexes; ID matches precede localized live
name/rank matches. The modern trait definition overrides a stored node hint,
including when the live spell is unclassified. Do not interpret generic frame IDs
as talent/spell IDs. Recycle/hide addon-owned badges without modifying native
talent buttons. Preserve tooltips on stable refresh; invalidate node caches on
talent/config/spell changes. Native hidden/transparent talent views hide badges.

Trainer tags apply only to available services and follow validated service IDs
from ClassTrainer. Anchor after NEW + and any ECO/OPTIONAL marker. Clear recycled
rows and hide detached frames when the owner disappears. These tags do not change
role selections, ECO/OPTIONAL rules, costs or purchasing behavior. Respect global
icons, contentTags and zone preferences; explanations respect the text preference.
Settings has the toggle and legend. `/sam conflicts` reports match counts.
Check `scripts/test-content-tags.lua` and trainer tests; validate actual placement
in game separately from mock checks.

SpellBookTabs.lua appends existing TalentSummaries to school-tab tooltips only
while player level is 1–9 and text annotations are enabled. Match class tree names
from ClassRoles and localized talent API names, not generic tab indexes or addon
IDs. Preserve native tooltip contents, deduplicate until tooltip clears, and check
owner/visibility before deferred callbacks. Ignore General, professions and foreign
tabs. Ellesmere classic tabs use its ShowWidgetTooltip adapter with the same data,
without changing protected button fields or replacing scripts.

LEVELING uses the first solo recommendation in LevelingRecommendations for every
class. TalentTooltips.IsLevelingTree is shared by the native role badge and tooltip
renderers. Mark exactly that tree, not all solo alternatives or group choices.
Talent and spellbook-tab tooltips describe only their own tree: never inject the
class-wide solo/group recommendations into an unrelated specialization tooltip.
Farouche may show both of its own role summaries. Role badge LEVELING follows
icon/zone preferences; text summaries remain shared with the GUI and tab adapters.

Talent PVP/PVE PVP badges match the visible talent icon width and touch its bottom
edge without overlapping the icon, leaving rank counters clear. Fit label font size without wrapping
and restore its base font when icons grow. Trainer badge geometry is separate.

SpellBookRoles.lua places a compact shared TalentRoles.CreateRoleDisplay to the
left of the active native school title. TreeNames lives in TalentTooltips and is
shared with SpellBookTabs; class roles still come from ClassRoles. Prefer the
visible large school heading over small tab text. Use Book.PrepareOverlay for
layering/scale, hide on foreign/transparent/general/pet views, and keep role info
independent of player selections. Test with scripts/test-spellbook-roles.lua.

ProfessionTrainer.lua resolves the native GetTrainerServiceStepIndex milestone.
ClassTrainer flags that validated service as professionStep and uses NEXT/yellow
for an unavailable next rank, regardless of character-level spacing. Available
still wins as NEW +; used remains known. Do not choose the lowest skill-requirement
recipe or parse localized rank names. Include the separate skillStepButton in row
painting. Missing/invalid APIs leave existing unavailable behavior unchanged.

DarkMode inserts inline |c... color codes into native titles. Compare school/tree
names using NormalizeText(CleanText(value)), including cached-title validation
and tab tooltips. Never rewrite or strip colors on the native font string itself.

RecipeKnowledge.lua reads profession recipe tooltips without hover. Confirm only
the localized ITEM_SPELL_KNOWN line (strip colors for comparison). Restrict to the
recipe item class and non-generic-book subclasses; do not mark pet grimoires,
gear or toys as profession recipes. Unknown/incomplete/missing tooltip data
returns nil, never "learnable". Cache positives only; invalidate on spell/skill/
recipe changes. Use C_TooltipInfo.GetHyperlink or a separate hidden scan tooltip.
Never touch the visible GameTooltip during scans. Request missing item data and
retry after native events; no profession-window scan is required.

Inventory passes bag recipe items to this renderer after its pet-book classifier.
Rolls use GroupLootFrameN and GroupLootContainer.rollFrames, deduplicated by frame,
and read GetLootRollItemLink from the current rollID. Use detached mouse-transparent
frames; never change dice buttons, managed-container layout or choose a roll.
Preserve independent iconsInventory/iconsLoot zones and the recipes/global icons
switches. Clear recycled/hidden items immediately. Native loot skins may be
supported; unrelated replacement roll windows need explicit adapters.
Artwork is assets/recipe-already-known.tga; source/prompt stay under scripts/artwork.
Test with scripts/test-recipes.lua and inventory/display/compatibility checks.

## TrainerSpells catalogue badges

`TrainerSpellsBadges.lua` reads visible `TrainerSpellsScrollBox` rows through
`GetElementData().entry.spellID` and shares RankPolicy purchase advice and
ContentTags factories. Render only ECO / OPTIONAL and PVP / PVE PVP, never
duplicate its availability indicators. Respect icons, iconsTrainerSpells and
contentTags settings. Skip pet/profession/header rows and purchase advice for
quest rewards. Detached overlays use unused name-field space without modifying
foreign texts or anchors; hide when too narrow, recycled or closed. Test with
`scripts/test-trainerspells-list.lua`; retain diagnostics for narrow rows.

TrainerSpells row reuse/layout is checked each rendered frame using lightweight
row snapshots; refresh immediately on changes. Keep policy rescans periodic for
unchanged rows. Do not restore a polling-only 150 ms delay during scrolling.

## Recent learning

- `RecentLearning.lua` owns per-character `recentLearning` lists: spells, recipes,
  talents. Stable numeric IDs only; spell ranks stay separate. Baseline spell and
  active talent snapshots at login never classify existing skills as recent.
- Confirm explicit LEARNED_SPELL_IN_SKILL_LINE / NEW_RECIPE_LEARNED events;
  spellbook differences during a trainer visit cover missing spell events. Ignore
  empty/unavailable scans. A visit without actual learning preserves the old list;
  the first confirmed learning in a new visit replaces it. Keep a short closing
  grace period for delayed events, guarded against a newer trainer visit.
- Confirm talent rank increases using active ranks, never preview ranks; changing
  talent configs/groups establishes a baseline. Talent and recipe learning outside
  trainers is grouped in a short event batch. Store names/ranks alongside IDs for
  the settings journal; never parse localized learning chat messages.
- `RecentVisuals.lua` owns detached native framed RECENT labels, separate from
  existing rank/status markers. Respect icons, recent and zone flags; recipes use
  iconsProfessions. Hide for pooled rows, hidden/transparent foreign views and
  unknown IDs. SpellBook invokes Paint; TrainerSpells reserves measured label
  space. Native talent nodes and modern/legacy recipe rows have focused adapters.
  Do not promise compatibility with arbitrary custom profession windows.
- SpellTooltips adds a deduplicated RECENT line, following text/recent preferences.
  Settings > Apprentissages récents is the complete persisted journal. Disabling
  markers must not erase learning data. Test with test-recent-learning.lua and
  test-recent-visuals.lua, plus the existing spellbook/TrainerSpells/settings suite.

### First-use RECENT defaults

`Recent.InitializeDefaults` seeds an empty history once with known spells from
its latest accessible level tier. Reuse `RankAvailability.KnownTier` and the same
class catalogue as upgrades; native GetSpellBookItemLevelLearned supplies a
fallback. Filter exact known IDs, race/faction and future levels. Do not seed
unknown purchases, professions or talent points from character level alone.
Freeze the initial character level while waiting for delayed data; retry on book
updates or TrainerSpells load. Existing history and completed initialization win
across reloads/level-ups. Record real learning through the normal batch path,
which replaces the inferred selection. Tooltips/journal identify this as an
initial selection, not observed purchases. Test test-recent-defaults.lua.

RECENT icon overlays anchor TOP to icon BOTTOM with zero gap, matching talent
usage labels. Text-only catalogue/recipe rows retain their inline placement.

## Commit preparation workflow

For every commit preparation, read and follow `scripts/commit/AGENTS.md`.
Player-facing README, changelog, patchnotes and GUI prose contain only usable
features and visible fixes; implementation and testing details belong in developer
documents or the owner-facing report. Preparing a commit includes reviewing and
staging its scope, not committing, pushing, tagging or publishing implicitly.

## Public branding

The displayed product name is **Skills & More**, credited **By CryptoLogiq** in
settings and launcher tooltips. Main slash command /sam, long alias /skillsandmore;
retain /skillsalreadyknown only as a legacy compatibility alias, not GUI wording.
The existing SkillsAlreadyKnown folder, TOC filename, namespace, AceConfig/LDB IDs,
frame IDs and per-character DB remain stable to preserve settings and installed
updates. Do not rename those blindly when changing public labels. DEV installers
must append [DEV] to the new visible title. Public summaries must cover current
RECENT, recipe, role, talent and profession features, not only trainer grimoires.

## Mandatory public README links

This is a standing user preference, not an optional cleanup: the README is also
copied to CurseForge and must work outside GitHub's repository renderer.

- Every README image uses a complete HTTPS URL to its GitHub-hosted image.
  Current pattern: https://raw.githubusercontent.com/CryptoLogiq/SkillsAlreadyKnown/main/assets/<filename>.
  Never restore relative image paths such as assets/image.png or ./assets/image.png.
- Repository document links, including LICENSE, also use complete GitHub URLs.
  Current license URL: https://github.com/CryptoLogiq/SkillsAlreadyKnown/blob/main/LICENSE.
- Verify the actual remote, branch and tracked target files when adding/changing
  links; do not infer a repository rename from the displayed Skills & More name.
- Before finishing a README edit or preparing a commit, inspect every Markdown
  image/link and HTML src/href. Fix relative repository references before reporting
  completion. Preserve the existing absolute URLs during unrelated wording edits.
- Apply this automatically without asking the owner to repeat the preference.

## No collapsed README content

Standing user preference: never use collapsible sections, dropdowns, accordions,
HTML details/summary or other click-to-reveal content in README files. All text
and images must remain visible immediately. Use ordinary headings instead.
Check for hidden/collapsed content during every README edit and commit review.

## README screenshots first

Standing user preference: put screenshots near the top of the README, immediately
after the product title and short introduction, before feature descriptions,
marker tables or commands. Keep images directly visible with absolute GitHub URLs.
When screenshots are obsolete, keep the notice directly above them until replaced.
Preserve this order in every README edit and commit review.

## Separate GitHub and CurseForge READMEs

Standing user preference: maintain two public documents with distinct audiences.
- `README.md` is the GitHub README and keeps manual installation instructions.
- `Readme_CurseForge.md` is the authoritative copy-ready CurseForge description:
  concise English player features and usage, no manual installation/folder setup
  because that audience uses an addon manager. No developer explanations.
- Apply screenshot-first ordering, visible/unfolded content, absolute GitHub links,
  accurate compatibility limits, current branding and commands to BOTH documents.
- Keep shared features/markers and screenshot notices consistent when editing
  either README. Do not blindly copy the GitHub installation section into CurseForge.
- `scripts/curseforge/description.txt` is an earlier draft; prefer the new dedicated
  README when preparing the project page. Do not overwrite existing release ZIPs
  for documentation-only edits.

## Latest CurseForge deliverables

Standing user requirement: every packaging run publishes the current ZIP and a
copy-ready Markdown `patchnote.md` together in `release/latest/`. Keep versioned
archives under release/ immutable. The latest folder contains one managed ZIP;
replace only generated addon ZIP copies and patchnote.md, preserving unrelated files.
Generate Markdown from the exact release's maintained Lua notes, using
`generate-patchnotes.py --format markdown`; never copy a stale hand-written draft,
Unreleased notes or developer details. Retain feature/fix headings and version.
`package.sh --refresh-latest` may republish an existing immutable archive without
rebuilding it, only after verifying its bundled patchnotes match the current sources.
No version bump for copying an existing release. Verify ZIP/notes pairing and
archive preservation using scripts/test-patchnote-generation.py. Point the owner
to release/latest/ for the upload ZIP and CurseForge Markdown.

## Branch workflow: dev and main

Standing user instruction: develop on `dev`; automatic betas come from `dev`,
stable releases come from `main`.
- Check the current branch before starting development or preparing a commit.
- Use `dev` for feature work, bug fixes, documentation and development commits.
  If necessary, create/switch to dev while preserving existing uncommitted work;
  never reset, discard changes or overwrite an existing branch to enforce this.
- `main` is the publication branch. Bring reviewed, tested changes from dev into
  main when publication is requested. Do not infer permission to merge, push,
  tag or publish from an ordinary development task or commit preparation.
- Release preparation can be done on dev. Publish the tested release from main;
  ensure version, release notes and artifacts match the published revision.
- Public README image/document URLs continue targeting main so they reference
  published files; do not replace them with dev URLs simply because work uses dev.

## Archive naming for upcoming builds

New archives use `SkillsAndMore-<version>.zip`, including the upload copy in
release/latest/. This filename change does not rename the internal addon folder,
TOC or saved variables: those remain SkillsAlreadyKnown for update compatibility.
Do not rename or rebuild existing 0.4.0 archives implicitly. The packager protects
both historical SkillsAlreadyKnown and new SkillsAndMore names for the same
version; --refresh-latest can copy either existing archive without rebuilding.
Latest cleanup recognizes both managed prefixes and preserves unrelated files.

## Localization: French and English

- Translation catalogs live in `traductions/fr_FR.lua` and `traductions/en-EN.lua`,
  loaded after Core and before Localization.lua and all feature/data modules.
  Both honor disabledByDev and keep exactly the same keys. Existing entries use
  French source phrases as legacy keys; new entries use meaningful stable IDs
  such as LANGUAGE_LABEL. Values belong in the catalogs, never inline in feature
  code. Keep readable Lua tables and use local
  `L = SAK.L or function(key) return key end` in consumers.
- Automatic default: any French client locale uses fr_FR; every other client uses
  en-EN. db.language stores auto/fr_FR/en-EN per character. A manual change requires
  reload: save the preference and offer Reload / Later, but keep the active locale
  stable until reload so data tables and live labels never mix languages.
- Localize addon UI, summaries, talent/class descriptions, purchase/usage advice,
  recent-learning explanations and patchnote rendering. Keep native game spell/item
  names, numeric IDs, role/spec keys, parsing patterns and API arguments untouched.
  Fixed badge words such as BEST, ECO and RECENT remain international markers.
- Runtime data descriptions use L; original patchnote Lua sources stay plain
  strings for Lua/Markdown generation, and Settings applies L when rendering them.
- Manual UI language can differ from client language: talent/book title matching
  must include Localization.NameVariants plus native API aliases in either case.
  Never localize identifiers or sacrifice matching to translate a displayed label.
- Add both catalog entries for each new user-facing string, including new release
  notes. Do not edit third-party libraries for translation. Raw technical support
  logs may stay English, but their action buttons follow the chosen language.
- Run scripts/test-localization.lua (actual TOC order, both locales, overrides,
  reload persistence and native title matching) and
  python3 scripts/test-localization-coverage.py (catalog parity, UI/history keys,
  placeholders and color escapes). Preserve catalog paths and namespace ownership
  in installed DEV copies. No release rebuild/version bump unless requested.

## Mandatory: no hardcoded player-facing text

Standing user rule: every new player-facing label, sentence, tooltip, popup,
button caption, summary or explanation must come from the translation catalogs.
Feature code calls the shared lookup with a meaningful stable key, for example
`L("LANGUAGE_LABEL")`; it must not contain the French/English wording itself or
an inline translated fallback. Define matching keys in both catalogs first.
Legacy French source-text keys already exist; do not copy that pattern for new
texts. Move wording into catalog values when revising such strings.

Use complete localized format strings for dynamic messages, for example
`string.format(L("LEARNED_RANK"), rank)`. Preserve placeholders and color/texture
escapes in both languages; avoid stitching translated sentence fragments together.
Native spell/item names remain game-provided, and stable IDs, API names, paths and
configuration keys are not player prose and must not be translated.

The sole runtime-prose exception is internal debug/support output: it may remain
hardcoded in English for developers. A normal player-facing explanation is not a
debug message merely because it is inconvenient to translate. Debug-window action
buttons and other user controls still use translations. Maintained patchnote data
is content, not feature logic: keep its source format and translate its GUI rendering.

Before finishing code changes or preparing a commit, audit added visible strings
and run the localization coverage checks. Extend those checks for new call sites;
never introduce untranslated player text while fixing another feature.

### Saved-variable loading order is mandatory for localization

WoW restores SavedVariables AFTER executing the addon's Lua files. Never capture
an active language preference at file scope and assume it is saved data. Call
Localization.Initialize on this addon's ADDON_LOADED before registering options,
with PLAYER_LOGIN as an idempotent fallback. Only then read db.language.
Register localized data/private text tables through RegisterTable and retranslate
them in place, preserving cached references. Rebuild derived purchase-catalogue
text after the base tables. Keep the active locale unchanged until a real reload
when the user selects a new preference. Tests must execute the TOC with no saved
DB, inject the persisted DB afterward and initialize, in BOTH language directions.
Testing with the DB preloaded misses the real startup bug.


## GitHub and CurseForge publication contract

Follow `scripts/curseforge/AGENTS.md` when editing packaging, workflows or preparing
any release. A push to dev is now an automatic beta publication trigger when the
repository secret is configured. Stable publication uses a version tag on main.
This does not authorize an unsolicited push, merge, tag or publication.
Check `.gitignore`, `.pkgmeta`, both local rsync exclusion lists and the ZIP
validator together. Git exclusions do not determine CurseForge package contents.
Never put tokens in source, logs, archives or chat. Use the repository Actions
secret `CF_API_TOKEN`; `GITHUB_TOKEN` is supplied by GitHub Actions.


TrainerSpells pet knowledge: PetGrimoires.SyncTrainerSpellsKnown bridges confirmed
saved pet IDs/ranks into the optional provider's learnedSpellsPet table, using its
own catalogue family keys. Preserve provider positives and unverified entries;
never mark a future rank learned. Exact IDs connect localized family names; named
rank fallback is limited to the matched family. Cache by snapshot revision and
provider table identities; refresh only on new positive knowledge. Empty transient
pet scans must not erase saved knowledge. Test scripts/test-pet-trainerspells.lua.


Pet learning follows the shared spell process: books use player-level eligibility
and saved per-family knowledge, never an active-demon filter. Scan each summoned
pet to establish its baseline; switching pets alone is not a learning event.
Use the shared SpellRanks classifier for separate player/pet spellbook banks;
pet upgrades come from matched live TrainerSpells pet families or observed books,
are bounded by pet level and respect the BUY toggle. Do not apply player role
purchase advice to pet spells. RECENT uses the pets category in the existing
learning batches (including merchant visits), shared visuals and persisted history.
Do not erase histories on empty visits or transient pet books. Check
scripts/test-pet-process.lua and the existing learning, spellbook and item suites.

Active-pet book highlighting uses a separate additive native gold border in
Visuals.PaintMerchantPetIcon, shared by bags and merchants. Respect icons/category
and outlines settings; hide on recycled/unknown/inactive-pet books. It must not
filter learned/learnable markers or reuse the trainer NEW+ proc host.


SURVIVAL: data/SurvivalAdvice.lua now contains 56 reviewed spell families across
nine classes, expanded from the initial 12-entry trial. Per-entry Forever sources
and review dates are maintained beside the data; the old optional-spell audit
is historical research, not the coverage limit. No exhaustive guarantee is implied. Keep spell-ID
anchors and localized name resolution for later ranks; no item-name substring match.
SpellUsage.lua shares ContentTags' native frame renderer and cleans detached badges
when owners/anchors hide. Display.survival is independent of PvP usage tags, and
respects per-zone/global icon switches. Spellbook markers sit after rank/OPTIONAL;
TrainerSpells reserves measured space; trainer markers follow usage badges.
The first purchase of these spells is protected from OPTIONAL regardless of badge
visibility; extra-rank ECO/OPTIONAL advice stays independent. Descriptions must not
claim rank 1 suffices just because the spell is defensive. Keep FR/EN semantic keys,
update the GUI legend and test scripts/test-survival.lua plus existing UI suites.


AOE shares SpellUsage.lua with SURVIVAL. data/AreaSpells.lua is the readable
spell-family catalogue (21 reviewed area/cleave families across nine classes).
Match exact IDs first, then game-resolved localized names for other ranks. Its
AOE display toggle is independent of SURVIVAL and PvP hints. Tag area spells and
cleave/multitarget attacks by actual usage; tooltip text distinguishes their scope.
Keep recognized area families out of LevelingAdvice OPTIONAL rules at every rank;
SpellUsage.ProtectPurchase also guards against future accidental reintroduction.
Hiding badges must not change purchase policy. Maintain the same spellbook,
trainer, TrainerSpells, external-tooltip, localization and recycling paths.
The old Survival.lua module was generalized to SpellUsage.lua; do not duplicate
its renderer. Tests cover both categories in scripts/test-survival.lua.


Talent AoE coverage: data/AreaTalents.lua holds 21 reviewed active/improvement
entries across nine classes, with spell and native node anchors. Structure was
checked against locally installed TalentsForeverBook build 1.60.1.70755; do not
redistribute that addon's dataset or assume every custom talent's mechanics from
its name. SpellUsage.ForTalent shares runtime usage data. ContentTags resolves
native identities once and draws independent usage badges below icons, stacking
below PvP advice when both apply. IconsTalents/global icons gate both; disabling
PvP hints alone must leave AoE visible. Clear markers on hidden/recycled nodes.
Passive improvements have explicit wording and must not imply a new AoE attack.
Forever Fire Nova uses 408341, replacing removed Classic Fire Nova Totem 1535.
Sources: https://www.wowhead.com/forever/guide/classes/shaman/elemental/overview-pve-dps
and https://www.wowhead.com/forever/talent-calc/mage . Generic throughput talents
are not automatically AoE; unknown/custom effects remain unmarked pending their
current in-game tooltip. Tests: scripts/test-content-tags.lua and test-survival.lua.


CLASS is a shared SpellUsage category backed by data/ClassSkills.lua, initially
Drain Soul (1120) and its name-resolved higher ranks. It marks an essential class
mechanic, not mandatory rank upgrades. EssentialSkill suppresses OPTIONAL at all
ranks independently of display toggles. rankOneUtility entries retain ECO on rank
1 and BEST on the highest learned rank; SpellRanks must not restore OPTIONAL via
FindUpgrade's waitReason or demand BUY for that utility. Keep original rank-one
advice data as an economy explanation, not a claim that the spell is dispensable.
Check scripts/test-class-skills.lua; use existing renderer, tooltips and category
settings for all views. Do not classify every class spell as essential by default.


Tooltip badge strips: TooltipBadges.lua repeats rank/OPTIONAL, usage, PvP and RECENT
markers on addon-owned frames parented to each spell tooltip. Reuse existing rank
textures and ContentTags' renderer; preserve texture aspect ratio. Collect respects
global icons, iconsTooltips and category preferences independently of tooltip prose.
Native tooltip layout is untouched. Wrap to tooltip width, clamp the strip and
place below the tooltip only when scaled screen-top space is insufficient. Clear
on OnTooltipCleared/OnHide so recycled spell/item tooltips cannot retain badges;
reuse frames and hooks and never add mouse-intercepting overlays. Hook through
shared SpellTooltips entry points for native book/trainer and external spells.
Test scripts/test-tooltip-badges.lua, existing spellbook/UI/localization suites.


User badge editor: BadgeRules.lua stores sparse per-class entries in account-wide
SkillsAlreadyKnownAccountDB.badgeRules and per-character SkillsAlreadyKnownDB.badgeRules.
The former is explicitly declared in SavedVariables, the latter stays in the
existing SavedVariablesPerCharacter. DEV namespace rewriting isolates both stores.
Only current-class entries apply. Resolve per field: character exact ID, character
all-ranks family, class exact ID, class family, then shipped data. Match other ranks
through game-resolved names; never numeric ordering or truncated UI names. Nil
inherits, "none" explicitly removes a category. Usage (AOE/SURVIVAL/CLASS), combat
(PVP/mixed) and advice (ECO/OPTIONAL) are independent categories. Unknown IDs are
validated/retried; never save a silently invalid ID. All ranks defaults true for new
rules. One broad family rule per scope avoids ambiguous matches; precise exceptions
remain. BadgeEditor.lua edits drafts until Save and offers confirmed scoped removal.
The current class, selected scope, effective values and inherited source are visible.
Rules invalidate shared views; tooltips, trainers, spellbook, talent nodes and
TrainerSpells use the same overrides. Custom advice is labelled as a personal choice
and can override the supplied defaults. BEST/LOW/BUY/RECENT/learned status remain
computed. ResetDefaults clears only character overrides, preserving shared class
rules; the editor removes shared rules explicitly. No automatic push or release.
Tests: test-badge-editor.lua, test-custom-badge-policy.lua, real AceConfig schema,
localization, packaging and DEV isolation. Semantic translation keys compare format
placeholders between FR/EN values, while legacy source-text keys retain their checks.


TrainerSpells demon checks: its native pet rows have no petKey/petLabel, and
training IDs (e.g. 20382) differ from learned ability IDs (e.g. 19438). Detect rows
through TrainerSpells_PetData, then paint TRAINER_BADGES.known independently of
player advice, usage tags or RECENT. Core.GetPetNames retains summonID, enabling
canonical provider families to match saved localized names. Compare native spell
names and required ranks only within that identified family; never infer another
pet's rank. Some Forever action IDs are packed; name/rank evidence must not depend
on an exact-ID match. Read missing modern subtext from compatible APIs; exclude
unlearned/non-spell modern rows. PetGrimoires' provider sync retries boundedly for
late data and repairs replaced native knowledge caches while preserving positives.
Tests reproduce French Voidwalker with distinct training/ability IDs, future ranks,
foreign-cache replacement and native rows without family flags. Changing these
paths must retain the player-list behavior and icon category switches.


DEV tooltip identity: Core.isDev comes only from the actual loaded addon name's
_dev suffix, never branch/version text or the presence of a DEV folder. The DEV
copy puts an orange DEV badge first in spell-tooltip strips, including when other
appearance badges are disabled. Official builds must never display it. Keep this
maintainer aid out of public README/CurseForge patchnotes. Reuse TooltipBadges and
ContentTags; cover source and staged namespace behavior with dev-isolation and
tooltip-badge tests. The DEV installer must remain isolated from the official copy.


Optional developer UI lives in DevTools.lua. A single Display checkbox controls
per-character devToolsEnabled (default false). Factories own the hidden development
section in Display and replay-first-use button; Settings retains ordinary reset/default
controls and the player summary. Debug slash handlers and summary command listings
route through the same gate; disabled commands explain how to enable tools instead
of opening reports. Previously built callbacks must also respect the current gate.
Turning tools off closes diagnostic/export windows while retaining the player
summary. This is a UI/command module, not the DEV addon identity: Core.isDev and the
orange tooltip DEV label are independent and must stay visible for a real DEV copy.
Passive bounded compatibility observations remain available for support. No second
addon folder/TOC, dependency or reload is needed. New debug buttons belong in this
module; do not scatter hidden conditions through player features. Test with
scripts/test-devtools.lua, existing reset/diagnostic routing tests and real AceConfig.


Standing navigation preference: use native Options > AddOns parent/subcategories,
like Questie's left-hand list, instead of internal horizontal tabs. Settings registers
an overview parent plus one panel per top-level player section, feeding each exact
AceConfig path through AddToBlizOptions. Register once; keep native category IDs
and open Display directly for /sam settings. The modern capability check requires
RegisterCanvasLayoutSubcategory. The legacy fallback creates parented BlizOptionsGroup
frames and feeds the same per-section paths without modifying Ace3. Standalone
fallback uses tree navigation; first-use still opens the spellbook/role path alone.
Developer tools live inline in Display, gated by the existing checkbox, so disabling
them never leaves a blank native subcategory. Keep all content, confirmation flows,
DEV identity and settings persistence unchanged. See test-settings-navigation.lua,
legacy settings tests and real AceConfig validation. Relevant upstream behavior:
libs/AceConfig-3.0/AceConfigDialog-3.0/AceConfigDialog-3.0.lua AddToBlizOptions;
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_Settings_Shared/Blizzard_Category.lua .

Cached localization tables must support semantic keys after file-scope lookup has
already turned them into French OR English values. Localization's reverse lookup
resolves both catalogues before retranslation at ADDON_LOADED. Do not restrict it
to English values: French-client + English override otherwise leaves custom
OPTIONAL and usage explanations in French. Test actual external tooltip hooks,
all OPTIONAL scopes, both override directions and cached usage advice; native
game tooltip text stays in the game's language.

Indirect AoE talent explanations must identify WHY the badge applies and list
the affected area spells. AreaTalents.relatedSpells contains reviewed spell IDs,
with source/review date beside the relationship; never guess links from names
or IDs. All 17 current indirect/spread entries are linked; active area talents
keep their own native description without redundant self-links. SpellUsage shares
the related-spell renderer between spell tooltips and ContentTags badge tooltips.
Use native names/icons/descriptions with reference-rank subtext when available;
these remain in the client language while our explanation follows the addon
language. Do not substitute maximum-rank damage or promise owned ranks. Missing
data gets a localized pending description and bounded load request, reread on
next hover. Never paste Wowhead descriptions into runtime tables. A custom AOE
override must not invent related spells or revive removed classifications.
Tests: scripts/test-area-relations.lua, localization, content-tags and tooltip suites.

## Selective spell-combination hints

Standing user preference: hints explain a few specific, useful interactions, not
generic rotations or advice on every tooltip. Research catalogue:
`scripts/research/spell-combinations-forever.lua` (23 records across nine classes,
reviewed 2026-11-15). It is developer research, excluded from runtime/packages.
Each record separates documented mechanics, editorial/mechanical inference and
conflicting/removed cases; shortlist/reserve is not automatic activation.
Before promoting into data/SpellHints.lua, verify current Forever spell IDs/ranks,
required talents and the exact tooltip(s) that should receive the short hint.
Omitted IDs and reference-rank IDs are intentional; never infer a base rank from
numeric order. Localize only the promoted player wording with semantic keys.
Prefer one main tooltip, merge related conditions into that hint and avoid
duplicating existing CLASS/AOE explanations. Do not replicate a hint on every
spell in a combination. If a talent is required, say so and verify it before
presenting its effect as available. Frozen is not merely slowed; Improved Blizzard
slowing alone is not proof of a frozen target. Generic cooldown stacking is not
a reason to add a beginner hint. No automatic casts/macros or false live aura state.
Classic/SoD/Retail and historical user comments are not evidence for Forever.
Current research excludes Flame Shock/Lava Burst from proposed hints because
more recent development notes announce removal despite older spell/guide pages.
Swiftmend no longer consumes its HoT in Forever; do not import the Classic advice.
Research-only work is not a player feature: do not add it to public patchnotes.

Player customization navigation: the native sidebar category is Custom, with
childGroups=tab and Spell badges as its first child (custom.args.spellBadges).
Future editable player rules belong as sibling tabs there, not additional native
sidebar categories. Keep the native top-level navigation for other sections.
This changes only settings grouping, never saved rule keys/scope or behavior.

## Utility badges and selective combination hints

Runtime UtilitySpells.lua is a readable nine-class catalogue with 24 reviewed
spell families (some classes intentionally have no entry). KICK requires a real
interrupt, not just a stun/silence; TAUNT covers taunts and temporary forced
attacks with an explicit distinction from threat matching; AGGRO requires explicit
additional-threat wording/effects, not all damage/healing or a tank recommendation.
Sources/review dates live beside entries. Pet Growl/Torment are threat, not forced
taunts. Seal of Fury's TAUNT description is conditional on Judgement; activating
the seal alone does not taunt. Exclude unverified SoD leftovers such as Way of Earth
and do not invent a taunt for generic Earth Shock. Bear Feral Charge is exact-only:
its Cat variant does not interrupt. No AGGRO inferred from Maul/Demoralizing Shout.

Usage.ForSpell keeps classification/overrides independent of display. ForDisplay
filters the active tags and produces a compact cumulative label/width; all tooltip,
book, trainer and TrainerSpells renderers use it. Category switches are independent;
KICK/TAUNT/AGGRO never alter purchase policy. ProtectPurchase's first-rank rule is
limited to SURVIVAL; AOE/CLASS retain their existing guards. Custom supports the
three new usage values and filters; saving an override replaces the shipped usage
classification in the selected scope. Do not mutate catalogue tags while filtering.

SpellHints.lua now holds 12 primary-spell tips, including the existing Judgement
reminder; the rest of the 23-case research catalogue is not automatically imported.
Resolve exact IDs first, then native names within current class for other ranks;
unknown names fail closed. All hints have semantic translation keys, sources and
related spell IDs; text is looked up at hover time after saved locale restoration.
Display.combinations and global text gate hints independently of badges. No claims
of actual aura/proc/learned-talent availability: conditional talents are explicitly
worded as conditions. No every-spell rotation hints, automatic actions or spam.
Check tests/test scope in scripts/test-utility-hints.lua plus localization, native
UI, custom rules, tooltip and existing pet suites before finishing changes.

RoleStances.lua records 14 reviewed form/stance/effect orientations using existing
ClassRoles role keys tank/heal/dps. Never assign a combat role or alter the saved
selection from a stance badge. Unreviewed shared armor, auras and travel forms do not receive
an invented combat role. Spirit of Redemption is an automatic post-death healing
form, not an activated posture. Do not invent Tree of Life or SoD tank forms for
Forever. Battle Stance's DPS explanation explicitly allows a tank to use it.
ForSpell merges role orientation with the original usage through a copy, retaining
AGGRO/TANK or TAUNT/TANK and both explanations. Display toggles are independent;
Custom usage overrides intentionally replace both shipped parts. No purchase policy
changes. Explicit aliases (Spirit of Redemption 27827) are recorded in RoleStances.
Maintain sources/review dates and validate roles against ClassRoles. Check
scripts/test-role-stances.lua, tooltip, customization and localization suites.

SURVIVAL completeness audit 2026-11-15: Divine Protection is keyed at 498 with
explicit alias 5573; Divine Shield at 642 aliases 1020. Keep these links even when
native spell names are not cached. Core defensive additions include immunities,
absorption, mitigation, escapes, defensive control and selected emergency sustain.
Do not automatically tag every heal/buff, risky offensive cooldown or self-sacrifice.
Source the actual Forever edition: Ice Block uses 11958 here, not another expansion's
45438. Four survival talents include reviewed native node anchors (Ice Block,
Ice Barrier, Deterrence, Last Stand), checked against local 1.60.1.70755 structure.
All sources/review dates live in data/SurvivalAdvice.lua; native API remains the
source of names, icons and actual rank values. No fabricated fixed percentages.
Usage.ForSpell combines independent catalogue tags through copies, preserving
SURVIVAL/AGGRO on Stoneclaw Totem and prior role/utility combinations. Identical
single-category matches retain the original authoritative first entry. Overrides
still win. Hiding a badge does not change policy, and SURVIVAL never establishes
rank-one sufficiency or disables higher-rank checks. Tests: survival-coverage,
survival, localization, native talents, custom policy and tooltip suites.

Usage categories (SURVIVAL/AOE/CLASS/KICK/TAUNT/AGGRO/role orientations) apply to every rank of a classified spell family. SpellUsage resolves native base IDs, explicit aliases, then localized native names without rank subtext. Never gate usage on BEST/LOW, purchased rank or rank-one advice. Keep exactOnly for mechanically different form variants, and preserve explicit custom per-rank exceptions. No guessed numeric chains.

Paladin aura orientations: Devotion TANK, Retribution DPS (also useful to tanks), Concentration HEAL/DPS (cast pushback support, not interrupt immunity). These describe use, never exclusive specialization requirements. Resistance auras have no invented exclusive role. All ranks inherit the classification.

## Local talent build backups
Run scripts/research/backup-talent-builds.py for a new timestamped snapshot under
scripts/research/talent-builds-local/ (ignored, excluded from installation/releases).
Talents Forever publishes data.json under CC BY 4.0: preserve Chris Baldwin attribution,
source export dates, hotfix/beta caveats, raw files and hashes. Derived per-class Lua
tables contain all 27 trees, per-specialization selection matrices and available top
build links; class builds/leveling HTML retains the full published context. A missing
top-list build is not a missing/invalid specialization. Popularity is not expert advice.
Wowhead direct requests currently return 403: record failure, do not claim a full
Wowhead archive or bypass access controls. Consult accessible Forever guides for
mechanics/context and add reviewed original interpretations separately.
Consecrated Ground 1310905 improves Holy damage against enemies entering Consecration,
not healing. It is an offensive/hybrid/PvP option, also present in a PvE hybrid build:
https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank .
AOE describes mechanics, not a recommendation for every Holy healer or proof of PvP-only use.

## Talent specialization suggestions: theorycrafter evidence only
Standing preference: ALWAYS show specialization and game icon. Multi-role classes also
show role logo/name; omit redundant DPS for single-role classes. Keep exact variant and
activity context, never infer intended role from a talent's physical tree.
The previous 100 mechanics-based editorial suggestions were rejected by the user.
They are quarantined in scripts/research/talent-builds-local/editorial-candidates.lua, NOT
loaded. Never reactivate them based on plausible utility, tree position, pick rates,
Talents Forever popularity, or aggregate player builds. Talents Forever's backup is
mechanical research, not evidence of an expert recommendation.
Active data/TalentRecommendations.lua now contains ONLY seven paladin anchors whose
inclusion is explicitly discussed in named Wowhead Forever theorycrafter guides.
Each choice needs basis=theorycraft-build at entry level, source URL, author, guide
update/review dates, exact build section, activity/variant label and supported spec/role.
TalentAdvice rejects entries without that provenance. Other classes remain without
recommendations until their actual builds are checked. No exhaustive-coverage claim.
Consecrated Ground is explicitly in Riyani's Shockprot (situational offensive tank)
and Surveillant's Holy-based Shockadin DPS guides; it is NOT a generic Protection or
Holy-healing recommendation. Active UI currently exposes only the verified supported
Protection/Shockprot mapping. Do not label Holy-based Shockadin as ordinary Retribution
just because its source page is filed under Retribution. Extend build/spec modeling
explicitly before activating that mapping; never silently change player role options.
Sources checked 2026-11-15:
- https://www.wowhead.com/forever/guide/classes/paladin/protection/talent-builds-pve-tank — Riyani, updated 2026/11/04.
- https://www.wowhead.com/forever/guide/classes/paladin/holy/talent-builds-pve-healer — Harreks, updated 2026/11/04.
- https://www.wowhead.com/forever/guide/classes/paladin/retribution/talent-builds-pve-dps — Surveillant, updated 2026/11/13.
AOE/SURVIVAL/etc describe mechanics and remain separate from recommended builds.
A build that omits a talent is not proof of no niche use; a niche guide is not proof
that every player of a role should take it. Preserve sources and exact scope.
SpellTooltips and ContentTags share TalentAdvice, which resolves IDs/node anchors and
native names for ranks, validates ClassRoles links, deduplicates per tooltip clear,
and respects text/icons/talent preferences and saved FR/EN overrides. Never alter
selected roles, purchase policy or custom usage badges from a recommendation.
Tree icon names are attributed to Talents Forever/Chris Baldwin (CC BY 4.0), using
native game textures. Downloaded descriptions/build snapshots are not shipped.
Test: scripts/test-talent-advice.lua, localization and native tooltip suites.

Spellbook placement preference: usage category labels sit on their own line ABOVE
BEST/LOW/ECO/BUY NEW RANK, left-aligned to the primary rank badge. Use a -6px
BOTTOMLEFT-to-TOPLEFT offset to compensate for transparent texture padding and
visually attach the category to its own rank badge (the former +2px floated too high).
Never append them horizontally after rank/OPTIONAL badges over the spell name.
Keep OPTIONAL beside BEST and RECENT below the icon. Trainer, talent-tree and
tooltip-strip positions are independent; do not move them with this book change.

## Recent spellbook sparkles
RecentSparkles.lua highlights only RECENT active PLAYER spellbook entries whose exact
rank ID is absent from action bars. Parent its own non-interactive host to the owned
rank overlay; never attach state/scripts to protected buttons. Native AutoCastShine
is capability-checked, with four animated native star4 textures as fallback. Hook
native scripts, do not replace the native effect's animation driver. This is a 2D
UI effect, not Naowh/Lueur's world-object CVar sparkle; do not copy their code/assets
or alter world CVars. No dependency/library addition is needed.
Read all player action pages, recognized GetMacroSpell results and guarded native
FindSpellActionButtons. Cache scans and invalidate on action/macro/spell/world events;
subscribe even when the first spell is already assigned, so removing it is noticed.
Missing APIs fail closed. Complex conditional macros are explicitly not guaranteed.
Do not equate a lower-rank placement to the newly learned rank. Do not glow passive
talents, recipes or pet entries; their RECENT badges retain existing behavior.
recentSparkles defaults true, independent from RECENT text but gated by recent,
icons and iconsSpellbook; its settings checkbox is disabled when those are off.
Stop on assignment, recycled rows, non-RECENT state, hidden/transparent foreign tabs
and disabled preferences. Preserve RECENT history and all action bars unchanged.
Tests: scripts/test-recent-sparkles.lua and the spellbook/preferences/localization suites.
References: native ActionButtonUtil / FindSpellActionButtons APIs in Gethe/wow-ui-source;
AutoCastShine capability usage in https://github.com/p3lim-wow/Molinari/blob/master/addon.lua ;
native star4 texture in https://github.com/SFX-WoW/Masque/blob/main/Core/Regions/Cooldown.lua .

## Learning sparkle extension
Standing user requirement: particles surround ONLY the icon, never the full merchant
row, item tooltip, or loot panel. Reuse RecentSparkles.PaintIcon with its own detached
UIParent host, native/fallback renderer and visibility cleanup. The existing spellbook
RECENT/missing-bar rule is unchanged. learningSparkles is a separate default-on switch,
gated by global icons and the respective trainer/merchant/loot category. It does not
depend on RECENT; stopping particles never removes the RECENT history/badge.
Visuals.PaintTrainerBadge connects ONLY kind=new (NEW +), covering both class and
profession trainer services. Preserve the existing NEW +-only proc border. Missing
icon means no effect; do not substitute a whole protected row as the anchor.
RecipeKnowledge.IsUnlearned requires a recipe item class/subclass, cached exact
item title, full localized ITEM_SPELL_TRIGGER_ONUSE line and no native known marker.
Absence of ITEM_SPELL_KNOWN on incomplete data is not proof. This reports unknown,
not affordability, skill eligibility or guaranteed learnability. Keep the native
positive IsKnown contract unchanged; invalidate unlearned cache with skill learning.
Supported views: merchant item buttons (correct page, no buyback or zero stock),
native group-roll icons and native LootFrame item icons. Scan without user hover,
using modern tooltip data or the separate hidden legacy scanner; never GameTooltip.
Do not modify roll/buy decisions. Known badges and glitter cleanup are independent,
so clearing a known badge must not immediately clear a valid unknown-recipe effect.
Test scripts/test-learning-sparkles.lua, test-recent-sparkles.lua, recipe, trainer,
profession, preference and localization suites. No added library or copied addon code.

## RECENT first-use tracking and blue particles
UnusedSpells.lua tracks confirmed player UNIT_SPELLCAST_SUCCEEDED events; no failed
cast, keypress, click or pet event is proof. RecentLearning stores used=true on the
exact RECENT player spell entry, preserving it across reload and duplicate learning
events. Learning another rank uses its own ID; do not mark an entire family used.
No long-term all-spells history: replacing RECENT naturally replaces its use flags.
Historical use before this feature existed cannot be inferred; tooltip wording says
no successful use recorded, not proof that the player has never used the spell.
Gold in book = RECENT rank absent from bars (recentSparkles); blue = assigned RECENT
rank with no successful use recorded (unusedSparkles), in book AND supported action
buttons. First use removes blue, not RECENT. Removing a spell from a bar can restore
the separate gold missing-bar hint. Effects and text have independent usual gates.
Reuse RecentSparkles renderer with style.option/color instead of a second particle
engine. Initialize action/macro invalidation before book opening; preserve the native
effect's scripts. Unused.Refresh skips slot scans if no unused records or disabled.
Read public action/.GetAttribute('action') and icon fields only. Support Blizzard
ActionButton/MultiBar prefixes and verified EABButton1..180 (EllesmereUIActionBars
EUI_ActionBars_Secure.lua); no addon code/assets copied. Never write attributes,
replace scripts, move buttons or cast for the user. Unrecognized bars/macros fail
closed. Owned hosts stay non-interactive and confined to icon bounds.
Settings: unusedSparkles and iconsActionBars; global icons/recent still gate them.
SpellTooltips adds the localized blue explanation through spell/book hooks and a
secure SetAction post-hook resolving the actual slot/macro, with normal dedup/clear.
Tests: test-unused-spells.lua, recent-learning, recent-sparkles, tooltip and settings
suites. Verify installed DEV namespace/TOC; no publication without explicit request.

Dedicated stance/form/aura bars count as placement, not ordinary GetActionInfo slots.
UnusedSpells.StanceSpell reads GetShapeshiftFormInfo (modern fourth ID / legacy fifth
ID), bounds GetNumShapeshiftForms and uses the spellbook's verified highest learned
family member for automatically upgrading dedicated aura bars. Do not extend that
rank substitution to manually placed action slots. RecentSparkles includes these
IDs even if normal action APIs are absent and invalidates on UPDATE_SHAPESHIFT_FORM
and UPDATE_SHAPESHIFT_FORMS. Paint only native StanceButton/ShapeshiftButton icon
regions; EllesmereUIActionBars_Bars.lua confirms it reuses StanceButton1-N.
Post-hook GameTooltip.SetShapeshift for the same unused explanation. Removed forms
and unavailable APIs clear/fail closed. A form being available or an active flag
alone does not mark another rank used; keep confirmed player cast tracking.
Tests: test-unused-spells.lua covers modern/legacy return layouts, aura-rank
resolution, stance tooltips, first-use cleanup and removal of native form buttons.
