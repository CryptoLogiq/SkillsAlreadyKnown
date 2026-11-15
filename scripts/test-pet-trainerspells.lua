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

-- Real Forever failure: localized family + pet spell IDs != grimoire training IDs.
SkillsAlreadyKnown.GetPetNames = function() return {
 {key='marcheur du vide',summonID=697}, {key='diablotin',summonID=688},
} end
saved.petSpells['marcheur du vide']={byID={['7809']=2,['19438']=2},
 byName={Tourment=2,Sacrifice=2,['Consumer les ombres']=1}}
local localizedNames={[20376]='Tourment',[20317]='Tourment',[20377]='Tourment',
 [20381]='Sacrifice',[20382]='Sacrifice',[20387]='Consumer les ombres',[20388]='Consumer les ombres'}
GetSpellInfo=function(id) return localizedNames[id] end
TrainerSpells_PetData={Voidwalker={
 [10]={[20376]={rank=1}},[20]={[20317]={rank=2}},[30]={[20377]={rank=3}},
 [16]={[20381]={rank=1}},[24]={[20382]={rank=2}},
 [18]={[20387]={rank=1}},[26]={[20388]={rank=2}},
}}
TrainerSpells_Character={learnedSpellsPet={}}
pets.SyncTrainerSpellsKnown()
local known=TrainerSpells_Character.learnedSpellsPet.Voidwalker
assert(known[20317] and known[20382] and known[20387])
assert(not known[20377] and not known[20388],'Never infer a future unlearned rank')
local info,isKnown=pets.TrainerSpellInfo(20382)
assert(info.family=='Voidwalker' and isKnown)
assert(select(2,pets.TrainerSpellInfo(20377))==false)
TrainerSpells_Character.learnedSpellsPet.Voidwalker={}
pets.SyncTrainerSpellsKnown()
assert(TrainerSpells_Character.learnedSpellsPet.Voidwalker[20382],'Recover a replaced provider cache')
assert(not pets.TrainerSpellInfo(999999))
print('PASS: French demon families, distinct grimoire/ability IDs, exact known ranks and native cache replacement')
