-- First-use RECENT inference uses real level catalogue filtering and persistence.
local db, playerLevel, provider, nativeLevels
local known = { [140] = true, [160] = true, [180] = true, [999] = true }
UnitClass = function() return 'Mage', 'MAGE' end
UnitLevel = function() return playerLevel end
UnitRace = function() return 'Humain', 'Human' end
UnitFactionGroup = function() return 'Alliance' end
C_Timer = { After = function() end }
C_Spell = { GetSpellName = function(id) return 'Spell ' .. id end }
Enum = { SpellBookSpellBank = { Player = 0 } }
C_SpellBook = {
  GetNumSpellBookSkillLines = function() return 1 end,
  GetSpellBookSkillLineInfo = function() return { itemIndexOffset = 0, numSpellBookItems = 4 } end,
  GetSpellBookItemInfo = function(slot) return { spellID = ({140,160,180,999})[slot] } end,
  GetSpellBookItemLevelLearned = function(slot) return nativeLevels and nativeLevels[({140,160,180,999})[slot]] end,
}
local function load()
  TrainerSpellsBuiltin = provider
  SkillsAlreadyKnown = {
    EnsureDB = function() return db end,
    IsPlayerSpellKnown = function(id) return known[id] == true end,
  }
  dofile('RankAvailability.lua')
  dofile('RecentLearning.lua')
  SkillsAlreadyKnown.RecentLearning.HandleEvent('PLAYER_LOGIN')
  return SkillsAlreadyKnown.RecentLearning
end
local data = { MAGE = {
  [14] = { [140] = { rank = 1 } },
  [16] = { [160] = { rank = 2 }, [161] = { rank = 1 } },
  [17] = { [170] = { rank = 1, race = 'Orc' } },
  [18] = { [180] = { rank = 3 } },
} }
db, playerLevel, provider = {}, 17, data
local recent = load()
assert(recent.Contains('spells', 160))
assert(not recent.Contains('spells', 140) and not recent.Contains('spells', 180))
assert(not recent.Contains('spells', 161) and not recent.Contains('spells', 999))
assert(db.recentLearning.initialTier == 16 and db.recentLearningBootstrapped)
assert(recent.Summary():find('sélection initiale', 1, true))
playerLevel = 20
recent = load()
assert(recent.Contains('spells', 160) and not recent.Contains('spells', 180), 'Never reseed after reload or level-up')
recent.HandleEvent('TRAINER_SHOW')
recent.HandleEvent('LEARNED_SPELL_IN_SKILL_LINE', 200)
assert(recent.Contains('spells', 200) and not recent.Contains('spells', 160))
assert(not db.recentLearning.initialTier, 'Real learning replaces inferred defaults')
-- Data loaded later must use the initial level, not the new current level.
db, playerLevel, provider = {}, 17, nil
recent = load()
assert(not db.recentLearningBootstrapped)
playerLevel = 19
TrainerSpellsBuiltin = data
SkillsAlreadyKnown.RankAvailability.MarkDirty()
recent.HandleEvent('ADDON_LOADED', 'TrainerSpells')
assert(recent.Contains('spells', 160) and not recent.Contains('spells', 180))
-- Native spellbook level data is sufficient without TrainerSpells.
db, playerLevel, provider, nativeLevels = {}, 17, nil, { [140] = 14, [160] = 16, [180] = 18, [999] = 1 }
recent = load()
assert(recent.Contains('spells', 160) and db.recentLearning.initialTier == 16)
-- Preserve existing history even if initialization was never previously marked.
db = { recentLearning = { spells = { [50] = { name = 'Existing history' } }, recipes = {}, talents = {} } }
recent = load()
assert(recent.Contains('spells', 50) and not recent.Contains('spells', 160))
-- A known older tier must not be misrepresented as the latest accessible tier.
db, provider, nativeLevels = {}, data, nil
known[160] = nil
recent = load()
assert(not recent.Contains('spells', 140) and next(db.recentLearning.spells) == nil)
print('PASS: one-time latest-tier defaults, exact known IDs, race, future levels, delayed data and native fallback')
