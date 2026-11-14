-- Run: lua scripts/test-rank-availability.lua
local root=arg[1] or "."
local class,level="MAGE",15
UnitClass=function() return class,class end
UnitLevel=function() return level end
UnitRace=function() return "Humain","Human" end
UnitFactionGroup=function() return "Alliance" end
local learned={[133]=true}
IsPlayerSpell=function(id) return learned[id]==true end
local names={[133]="Boule de feu",[143]="Boule de feu",[145]="Boule de feu",[1008]="Amplification",[8455]="Amplification",[1120]="Drain d'âme",[8288]="Drain d'âme"}
C_Spell={GetSpellName=function(id) return names[id] end}
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root.."/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root.."/RankPolicy.lua"))()
assert(loadfile(root.."/RankAvailability.lua"))()
assert(loadfile(root .. "/SpellRanks.lua"))()
assert(loadfile(root.."/SpellBook.lua"))()
assert(loadfile(root .. "/SpellTooltips.lua"))()
local sak=SkillsAlreadyKnown
local policy,availability,book=sak.RankPolicy,sak.RankAvailability,sak.SpellBook
policy.SetRole("dps");policy.SetSpecialization("dps","fire")
TrainerSpellsBuiltin={MAGE={[6]={[143]={rank=2,requires={133}}},[18]={[145]={rank=3,requires={143}}}}}
local one={{slot=1,id=133,name=names[133],rank=1}}
local function state() return book.Classify(one,class)[1] end
assert(state().kind=="buy" and state().upgrade.id==143)
level=4;assert(state().kind=="best","No alert for a future level")
level=30;assert(state().upgrade.id==143,"Cannot skip an unlearned required intermediate rank")
learned[143]=true
local two={one[1],{slot=2,id=143,name=names[143],rank=2}}
local states=book.Classify(two,class)
assert(states[1].kind=="low" and states[2].kind=="buy" and states[2].upgrade.id==145)
learned[145]=true;assert(book.Classify(two,class)[2].kind=="best")
learned[143],learned[145]=nil,nil
TrainerSpellsBuiltin.MAGE[6][143].race="Orc";availability.MarkDirty();assert(state().kind=="best")
TrainerSpellsBuiltin.MAGE[6][143].race="Human";availability.MarkDirty();assert(state().kind=="buy")
TrainerSpellsBuiltin.MAGE[6][143].faction="Horde";availability.MarkDirty();assert(state().kind=="best")
TrainerSpellsBuiltin.MAGE[6][143].faction=nil;TrainerSpellsBuiltin.MAGE[6][143].requires={143};availability.MarkDirty();assert(state().kind=="best","Self prerequisites cannot establish access")
TrainerSpellsBuiltin.MAGE[6][143].requires={133};availability.MarkDirty()
local knownAPI=IsPlayerSpell;IsPlayerSpell=nil;assert(state().kind=="best","Unknown learned state must fail closed")
IsPlayerSpell=knownAPI
policy.SetBuyRank(false);assert(state().kind=="best");policy.SetBuyRank(true)
-- Buying an optional ability never becomes mandatory just because its badge is hidden.
TrainerSpellsBuiltin.MAGE={[30]={[8455]={rank=2}}};availability.MarkDirty();learned[1008]=true
local amp={{slot=1,id=1008,name=names[1008],rank=1}}
assert(book.Classify(amp,class)[1].optionalReason)
policy.SetOptional(false);assert(book.Classify(amp,class)[1].kind=="best")
policy.SetOptional(true)
class="WARLOCK";level=30;policy.SetRole("dps");policy.SetSpecialization("dps","affliction")
TrainerSpellsBuiltin.WARLOCK={[24]={[8288]={rank=2}}};learned[1120]=true
local drain={{slot=1,id=1120,name=names[1120],rank=1}}
assert(book.Classify(drain,class)[1].kind=="eco")
policy.SetEco(false);assert(book.Classify(drain,class)[1].kind=="best","Hidden ECO must not create BUY for optional extra ranks")
-- A live available trainer is the fallback, not a remembered level alone.
class="MAGE";policy.SetRole("dps");policy.SetSpecialization("dps","fire");TrainerSpellsBuiltin=nil;availability.MarkDirty()
assert(state().kind=="best")
availability.SetServices({{spellID=143,subText="Rang 2",levelReq=6,serviceType="available"}})
assert(state().kind=="buy")
availability.SetServices({{spellID=143,subText="Rang 2",levelReq=6,serviceType="unavailable"}})
assert(state().kind=="best")
print("PASS: BUY vs learned-only LOW, future levels, prerequisite chains, race/faction, uncertain knowledge, ECO/OPTIONAL semantics and live trainer fallback")
