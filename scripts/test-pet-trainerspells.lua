local saved = { petSpells = { diablotin = { byID = { ['3110'] = 1 } },
  voidwalker = { byName = { Torment = 3 } } } }
SkillsAlreadyKnown = {
  EnsureDB = function() return saved end,
  PetKey = function(text) return (text or ''):lower() end,
  RankNumber = function(text) return tonumber((text or ''):match('%d+')) end,
}
dofile('PetGrimoires.lua')
local pets = SkillsAlreadyKnown.PetGrimoires
-- The optional provider may be absent or load after us.
pets.SyncTrainerSpellsKnown()
TrainerSpells_PetData = { Imp = { [1] = { [3110] = {rank=1}, [7799] = {rank=2} } },
  Voidwalker = { [1] = { [3716] = {rank=1}, [7809] = {rank=3}, [7810] = {rank=4} } } }
TrainerSpells_Character = { learnedSpellsPet = { Imp = { [7799] = false, [99] = true } } }
GetSpellInfo = function(id) if id ~= 3110 and id ~= 7799 then return 'Torment' end end
local refreshes = 0
TrainerSpells_Refresh = function() refreshes = refreshes + 1; pets.SyncTrainerSpellsKnown() end
pets.SyncTrainerSpellsKnown()
local records = TrainerSpells_Character.learnedSpellsPet
assert(records.Imp[3110] == true and records.Imp[7799] == false and records.Imp[99] == true)
assert(records.Voidwalker[3716] and records.Voidwalker[7809] and not records.Voidwalker[7810])
assert(refreshes == 1, 'Refresh must not recurse')
pets.SyncTrainerSpellsKnown()
assert(refreshes == 1, 'Stable snapshots must not rebuild the foreign list')
-- Empty/transient scans must retain knowledge; a new exact rank updates it.
UnitExists = function() return true end
UnitCreatureFamily = function() return 'Diablotin' end
GetSpellBookItemName = function() end
pets.SyncActivePetSpells()
assert(saved.petSpells.diablotin.byID['3110'])
GetSpellBookItemName = function(i) if i == 1 then return 'Firebolt', 'Rank 2' end end
GetSpellBookItemInfo = function(i) if i == 1 then return 'SPELL', 7799 end end
pets.SyncActivePetSpells()
assert(records.Imp[7799] == true and refreshes == 2)
-- Never infer another rank from an ID match alone or an unrelated pet name.
assert(not records.Voidwalker[7810])
TrainerSpells_Character = {}
pets.SyncTrainerSpellsKnown()
assert(TrainerSpells_Character.learnedSpellsPet.Imp[7799])
print('PASS: optional/late TrainerSpells, localized pets, exact IDs, rank bounds, retained knowledge, refresh deduplication and learning updates')
