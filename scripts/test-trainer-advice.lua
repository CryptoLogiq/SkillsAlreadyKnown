-- Run: lua scripts/test-trainer-advice.lua
local root=arg[1] or "."
local class="MAGE"
UnitClass=function() return class,class end
UnitLevel=function() return 30 end
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root .. "/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root.."/RankPolicy.lua"))()
SkillsAlreadyKnown.EnsureDB()
local policy=SkillsAlreadyKnown.RankPolicy
local names={}
for _,rule in ipairs(policy.PurchaseCatalogue) do
 names[rule.baseID]=rule.class..":"..rule.baseID
 names[rule.baseID+50000000]=names[rule.baseID]
end
C_Spell={GetSpellName=function(id) return names[id] end}
local classes,count={},0
for _,rule in ipairs(policy.PurchaseCatalogue) do
 class=rule.class;SkillsAlreadyKnownDB.levelingProfile=nil
 assert(policy.SetRole(rule.role));assert(policy.SetSpecialization(rule.role,rule.spec))
 local kind,reason=policy.PurchaseAdvice(class,rule.baseID,rule.minRank)
 assert(kind=="optional" and type(reason)=="string",class..":"..rule.baseID..":"..rule.spec)
 -- A later rank is resolved from client API names of verified numeric anchors.
 local rank=math.max(2,rule.minRank)
 if not rule.maxRank or rank<=rule.maxRank then
  assert(policy.PurchaseAdvice(class,rule.baseID+50000000,rank)=="optional")
 end
 classes[class]=true;count=count+1
end
local classCount=0;for _ in pairs(classes) do classCount=classCount+1 end
assert(classCount==9 and count==157)
class="MAGE";SkillsAlreadyKnownDB.levelingProfile=nil
policy.SetRole("dps");policy.SetSpecialization("dps","fire")
assert(policy.PurchaseAdvice(class,6143,1)=="optional","Frost Ward in Fire's situational purchase list")
assert(policy.PurchaseAdvice(class,2948,1)=="optional","Scorch advice preserves the build caveat in its reason")
policy.SetSpecialization("dps","frost")
assert(policy.PurchaseAdvice(class,1008+50000000,3)=="optional","Amplify higher rank in Frost")
assert(not policy.PurchaseAdvice(class,6143,1),"Do not extrapolate Fire/Arcane's ward list to Frost")
policy.SetRoleEnabled("pvp",true);assert(not policy.PurchaseAdvice(class,1008,1))
policy.SetRoleEnabled("pvp",false);policy.SetOptional(false);assert(not policy.PurchaseAdvice(class,1008,1))
policy.SetOptional(true)
class="WARRIOR";SkillsAlreadyKnownDB.levelingProfile=nil
policy.SetRole("dps");policy.SetSpecialization("dps","fury")
assert(not policy.PurchaseAdvice(class,694,1))
assert(policy.PurchaseAdvice(class,694,2)=="optional")
local _,_,rangeScope=policy.PurchaseAdvice(class,694,2)
assert(rangeScope=="higher-ranks","A rank range must not claim rank 1 suffices")
assert(not policy.PurchaseAdvice(class,694,6),"Respect explicit rank 2-5 range")
class="DRUID";SkillsAlreadyKnownDB.levelingProfile=nil
policy.SetRole("dps");policy.SetSpecialization("dps","feral")
assert(policy.PurchaseAdvice(class,2912,1)=="optional")
policy.SetRoleEnabled("heal",true)
assert(not policy.PurchaseAdvice(class,2912,1),"Healer list only permits later ranks; no optional first purchase with both roles")
print("PASS: "..count.." catalogue rules across nine classes, higher-rank ID resolution, exact spec/rank bounds, role intersection and preferences")

class="WARLOCK";SkillsAlreadyKnownDB.levelingProfile=nil
policy.SetRole("dps");policy.SetSpecialization("dps","affliction")
local _,_,scope=policy.PurchaseAdvice(class,1120+50000000,2)
assert(scope=="rank-one","Exact higher-rank ID keeps the rank-one sufficient meaning")
local _,_,utilityScope=policy.PurchaseAdvice(class,126,1)
assert(utilityScope=="spell","An optional utility is distinct from an optional extra rank")
print("PASS: OPTIONAL scope preserved for rank-one usage, deferrable rank ranges and whole-spell utilities")
