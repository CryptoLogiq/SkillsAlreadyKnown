local db, timers = {}, {}
local spells, ranks, group = { [10] = 'Known' }, { [101] = 1, [102] = 0 }, 1
local function flush()
  local queued = timers; timers = {}
  for _, callback in ipairs(queued) do callback() end
end
C_Timer = { After = function(_, callback) timers[#timers + 1] = callback end }
C_Spell = { GetSpellName = function(id) return 'Spell ' .. id end }
Enum = { SpellBookSpellBank = { Player = 0 } }
C_SpellBook = {
  GetNumSpellBookSkillLines = function() return 1 end,
  GetSpellBookSkillLineInfo = function()
    local count = 0; for _ in pairs(spells) do count = count + 1 end
    return { itemIndexOffset = 0, numSpellBookItems = count }
  end,
  GetSpellBookItemInfo = function(index)
    local ids = {}; for id in pairs(spells) do ids[#ids + 1] = id end; table.sort(ids)
    local id = ids[index]
    return id and { spellID = id, name = spells[id] }
  end,
}
C_ClassTalents = { GetActiveConfigID = function() return group end }
C_Traits = {
  GetConfigInfo = function() return { treeIDs = { 1 } } end,
  GetTreeNodes = function() return { 101, 102 } end,
  GetNodeInfo = function(_, id) return { activeRank = ranks[id] } end,
}
SkillsAlreadyKnown = { EnsureDB = function() return db end }
dofile('RecentLearning.lua')
local recent = SkillsAlreadyKnown.RecentLearning
recent.Record('spells', 9)
assert(not recent.Contains('spells', 9), 'Ignore events before login')
recent.HandleEvent('PLAYER_LOGIN')
assert(not recent.Contains('spells', 10), 'Existing book is a baseline')
recent.HandleEvent('TRAINER_SHOW')
spells[20] = 'New rank'
recent.HandleEvent('SPELLS_CHANGED')
recent.HandleEvent('LEARNED_SPELL_IN_SKILL_LINE', 20)
recent.HandleEvent('NEW_RECIPE_LEARNED', 30)
assert(recent.Contains('spells', 20) and recent.Contains('recipes', 30))
recent.HandleEvent('TRAINER_CLOSED')
-- A delayed learning event still belongs to this visit.
recent.HandleEvent('LEARNED_SPELL_IN_SKILL_LINE', 21)
assert(recent.Contains('spells', 20) and recent.Contains('spells', 21))
flush()
recent.HandleEvent('TRAINER_SHOW')
recent.HandleEvent('TRAINER_CLOSED')
flush()
assert(recent.Contains('spells', 20) and recent.Contains('recipes', 30), 'Empty visit must preserve list')
recent.HandleEvent('TRAINER_SHOW')
spells[40] = 'Next visit'
recent.HandleEvent('TRAINER_UPDATE')
assert(recent.Contains('spells', 40) and not recent.Contains('spells', 20), 'New purchases replace old batch')
recent.HandleEvent('TRAINER_CLOSED')
-- Next visit must not be ended by the previous visit timer.
recent.HandleEvent('TRAINER_SHOW')
flush()
recent.HandleEvent('LEARNED_SPELL_IN_SKILL_LINE', 50)
recent.HandleEvent('NEW_RECIPE_LEARNED', 60)
assert(recent.Contains('spells', 50) and recent.Contains('recipes', 60))
recent.HandleEvent('TRAINER_CLOSED'); flush()
-- A reload preserves persisted records and never marks the baseline as new.
dofile('RecentLearning.lua')
recent = SkillsAlreadyKnown.RecentLearning
recent.HandleEvent('PLAYER_LOGIN')
assert(recent.Contains('spells', 50) and not recent.Contains('spells', 10))
ranks[102] = 1
recent.HandleEvent('PLAYER_TALENT_UPDATE')
assert(recent.Contains('talents', 102) and not recent.Contains('talents', 101))
flush()
ranks[102] = 2
recent.HandleEvent("PLAYER_TALENT_UPDATE")
assert(db.recentLearning.talents[102].rank == 2, "Track another point in the same talent")
flush()
ranks[101] = 0
recent.HandleEvent('PLAYER_TALENT_UPDATE')
assert(recent.Contains('talents', 102), 'Refunds are not learning')
group = 2; ranks[101] = 5
recent.HandleEvent('TRAIT_CONFIG_UPDATED'); flush()
assert(not recent.Contains('talents', 101), 'Changing talent groups is not learning')
recent.Record('spells', nil); recent.Record('spells', -1); recent.Record('unknown', 1)
assert(recent.Summary():find('Talents', 1, true))
-- An unavailable/empty book never erases the last reliable baseline.
recent.HandleEvent('TRAINER_SHOW')
local saved = spells; spells = {}
recent.HandleEvent('SPELLS_CHANGED')
spells = saved
recent.HandleEvent('SPELLS_CHANGED')
assert(not recent.Contains('spells', 10))
print('PASS: learning batches, empty visits, late events, reload persistence, talent ranks and group changes')

recent.Record('spells', 777, 'New spell', 1)
assert(recent.IsUnused(777))
assert(recent.MarkUsed(777) and not recent.IsUnused(777))
recent.Record('spells', 777, 'New spell', 1)
assert(not recent.IsUnused(777), 'Duplicate learning events do not forget successful use')
recent.Record('spells', 778, 'New spell rank 2', 2)
assert(recent.IsUnused(778) and recent.Contains('spells',777))
print('PASS: first-use persistence survives repeated learning events without confusing ranks')
