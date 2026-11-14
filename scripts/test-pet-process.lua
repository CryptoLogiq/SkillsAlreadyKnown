local db = { petSpells = {}, petGrimoires = {} }
local active, petRank = false, 1
local timers = {}
C_Timer = { After = function(_, f) timers[#timers + 1] = f end }
UnitClass = function() return 'Warlock', 'WARLOCK' end
UnitLevel = function(unit) return unit == 'pet' and 20 or 25 end
UnitExists = function() return active end
UnitCreatureFamily = function() return active and 'Imp' end
local names = { [10] = 'Player spell', [100] = 'Firebolt', [101] = 'Firebolt', [102] = 'Firebolt' }
C_Spell = { GetSpellName = function(id) return names[id] end }
Enum = { SpellBookSpellBank = { Player=0, Pet=1 }, SpellBookItemType = {Spell=1} }
C_SpellBook = {
 GetNumSpellBookSkillLines = function() return 1 end,
 GetSpellBookSkillLineInfo = function() return {itemIndexOffset=0, numSpellBookItems=1} end,
 GetSpellBookItemInfo = function(slot, bank)
   if bank == 0 and slot == 1 then return {spellID=10,name=names[10],subName='Rank 1',itemType=1} end
   if bank == 1 and active and slot <= petRank then
     local id = 99 + slot
     return {spellID=id,name=names[id],subName='Rank '..slot,itemType=1}
   end
 end,
}
SkillsAlreadyKnown = {
 EnsureDB = function() return db end,
 NormalizeText = function(s) return (s or ''):lower() end,
 PetKey = function(s) return (s or ''):lower() end,
 CleanText = function(s) return s end,
 RankNumber = function(s) return tonumber((s or ''):match('%d+')) end,
 IsPlayerSpellKnown = function(id) return id == 10 end,
 RankPolicy = { BuyRankEnabled=function() return true end, RankOneAdvice=function() end, OptionalAdvice=function() end },
}
dofile('RecentLearning.lua')
dofile('PetGrimoires.lua')
dofile('SpellRanks.lua')
dofile('SpellBook.lua')
local sak=SkillsAlreadyKnown
sak.RecentLearning.HandleEvent('PLAYER_LOGIN')
-- Neither a dismissed pet nor another active family hides books/known marks.
local info={petKey='imp',spellID=100,spell='Firebolt',rank=1,minLevel=10}
assert(sak.PetGrimoires.ItemLearnable(info))
db.petSpells.imp={byID={['100']=1},byName={Firebolt=1}}
assert(sak.PetGrimoires.ItemState(info)=='known' and not sak.PetGrimoires.ItemLearnable(info))
active=true
TrainerSpells_PetData={Imp={[1]={[100]={rank=1}},[10]={[101]={rank=2}},[30]={[102]={rank=3}}}}
sak.PetGrimoires.SyncActivePetSpells()
assert(not sak.RecentLearning.Contains('pets',100),'Summoning is not learning')
sak.SpellBook.Scan()
assert(sak.SpellBook.StateForSlot(1,0).id==10)
assert(sak.SpellBook.StateForSlot(1,1).kind=='buy')
assert(sak.SpellBook.StateForSlot(1,1).upgrade.id==101,'Future rank 3 must not trigger')
sak.RecentLearning.HandleEvent('MERCHANT_SHOW')
petRank=2
sak.PetGrimoires.SyncActivePetSpells()
assert(sak.RecentLearning.Contains('pets',101))
sak.SpellBook.Scan()
assert(sak.SpellBook.StateForSlot(1,1).kind=='low')
assert(sak.SpellBook.StateForSlot(2,1).kind=='best')
sak.RecentLearning.HandleEvent('MERCHANT_CLOSED')
for _,callback in ipairs(timers) do callback() end
timers={}
sak.RecentLearning.HandleEvent('MERCHANT_SHOW')
sak.RecentLearning.HandleEvent('MERCHANT_CLOSED')
assert(sak.RecentLearning.Contains('pets',101),'An empty visit must preserve RECENT')
active=false
sak.SpellBook.MarkDirty()
assert(not sak.SpellBook.StateForSlot(1,1),'Dismissed pet must clear its book overlays')
assert(sak.PetGrimoires.ItemState(info)=='known','Knowledge must survive dismissal')
print('PASS: inactive-pet books, persistent learned state, player/pet bank separation, accessible BUY, BEST/LOW, merchant RECENT and empty visits')
