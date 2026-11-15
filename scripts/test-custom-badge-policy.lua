dofile('scripts/test-class-skills.lua')
local sak=SkillsAlreadyKnown
SkillsAlreadyKnownAccountDB=nil
dofile('BadgeRules.lua')
local rules=sak.BadgeRules
sak.SetDisplayOption('optional',true)
assert(rules.Save('character',1120,{allRanks=true,usage='aoe',advice='optional'}))
assert(sak.SpellUsage.ForSpell('WARLOCK',8288).tag=='aoe')
assert(sak.RankPolicy.PurchaseAdvice('WARLOCK',8288,2)=='optional','Explicit advice overrides supplied CLASS policy')
local spells={{slot=1,id=1120,name='Drain Soul',rank=1,ranked=true},{slot=2,id=8288,name='Drain Soul',rank=2,ranked=true}}
local states=sak.SpellRanks.Classify(spells,'WARLOCK')
assert(states[1].kind=='low' and states[2].optionalReason and states[2].optionalScope=='custom')
assert(rules.Save('character',1120,{allRanks=true,advice='none'}))
assert(not sak.RankPolicy.PurchaseAdvice('WARLOCK',8288,2))
states=sak.SpellRanks.Classify(spells,'WARLOCK')
assert(states[1].kind=='low' and states[2].kind=='best' and not states[2].optionalReason)
assert(rules.Save('character',8288,{allRanks=false,advice='eco'}))
assert(sak.RankPolicy.PurchaseAdvice('WARLOCK',8288,2)=='eco')
states=sak.SpellRanks.Classify(spells,'WARLOCK')
assert(states[1].kind=='low' and states[2].kind=='eco','An exact ID must not affect another rank')
-- Removing an explicit rule restores the inherited class/family rule.
rules.Remove('character',8288)
assert(rules.Resolve('WARLOCK',8288,'advice')=='none')
sak.SetDisplayOption('aoe',false)
assert(rules.Resolve('WARLOCK',8288,'advice')=='none','Display switches do not change custom rules')
print('PASS: custom advice reaches trainer/tooltip policy and spellbook rank states with exact-rank scope and safe inherited restoration')
