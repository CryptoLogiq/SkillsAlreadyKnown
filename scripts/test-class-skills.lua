dofile('scripts/test-survival.lua')
local sak=SkillsAlreadyKnown
dofile('data/ClassSkills.lua')
dofile('SpellRanks.lua')
UnitClass=function() return 'Warlock','WARLOCK' end
C_Spell={GetSpellName=function(id) if id==1120 or id==8288 then return 'Drain Soul' end end}
SkillsAlreadyKnownDB.levelingProfile=nil
sak.RankPolicy.SetRole('dps');sak.RankPolicy.SetSpecialization('dps','affliction')
assert(sak.SpellUsage.ForSpell('WARLOCK',1120).tag=='class')
assert(sak.SpellUsage.ForSpell('WARLOCK',8288).tag=='class','Resolve the learned rank through its native spell name')
assert(not sak.SpellUsage.ForSpell('MAGE',1120))
assert(not sak.RankPolicy.PurchaseAdvice('WARLOCK',8288,2))
assert(sak.RankPolicy.PurchaseAdvice('WARLOCK',1120,1)=='eco')
sak.RankAvailability={FindUpgrade=function() error('Rank-one class utility must not request extra-rank purchases') end}
local states=sak.SpellRanks.Classify({
 {slot=1,id=1120,name='Drain Soul',rank=1,ranked=true},
 {slot=2,id=8288,name='Drain Soul',rank=2,ranked=true},
},'WARLOCK')
assert(states[1].kind=='eco' and not states[1].optionalReason)
assert(states[2].kind=='best' and not states[2].optionalReason)
sak.SetDisplayOption('class',false)
assert(not sak.RankPolicy.PurchaseAdvice('WARLOCK',8288,2),'Hiding CLASS must not restore OPTIONAL')
print('PASS: CLASS exact/later ranks, no optional rank 2, ECO rank 1, BEST rank 2 and display-independent purchase policy')
