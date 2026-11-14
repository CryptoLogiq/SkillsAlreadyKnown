# SkillsAlreadyKnown Agent Notes

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
- Packaging: `./scripts/package.sh` keeps `release/SkillsAlreadyKnown-<version>.zip`
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
