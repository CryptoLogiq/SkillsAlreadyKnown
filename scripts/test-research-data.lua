-- Run: lua scripts/test-research-data.lua
local root=arg[1] or "."
local research=assert(loadfile(root.."/scripts/research/eco-spells-forever.lua"))()
local records,classes=0,0
for class,specs in pairs(research) do
 assert(type(class)=="string" and type(specs)=="table")
 classes=classes+1
 for spec,entries in pairs(specs) do
  assert(type(spec)=="string")
  for _,entry in ipairs(entries) do
   records=records+1
   for _,key in ipairs({"category","ranks","condition","status","source"}) do
    assert(type(entry[key])=="string" and entry[key]~="",class..":"..spec..":"..key)
   end
   assert(#entry.spells>0 and type(entry.spellIDs)=="table")
   assert(entry.status=="source" or entry.status=="a_verifier")
  end
 end
end
assert(classes==9 and records==81,"Preserve the full original research inventory")
SkillsAlreadyKnown=nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root.."/data/LevelingAdvice.lua"))()
local active=SkillsAlreadyKnown.LevelingAdvice
local count=0
for class,profiles in pairs(active) do
 for spec,profile in pairs(profiles) do
  assert(profile.role=="dps" or profile.role=="heal" or profile.role=="tank")
  assert(profile.source:match("^https://www%.wowhead%.com/forever/"))
  local ids={}
  for _,spell in ipairs(profile.spells) do
   count=count+1
   assert(type(spell.baseID)=="number" and spell.baseID>0)
   assert(not ids[spell.baseID],"Duplicate spell anchor in "..class..":"..spec)
   ids[spell.baseID]=true
   assert(type(spell.name)=="string" and spell.name~="")
   assert(type(spell.reason)=="string" and spell.reason~="")
   assert(type(spell.category)=="string" and spell.category~="")
   assert(type(spell.minRank)=="number" and spell.minRank>=1)
   assert(not spell.maxRank or spell.maxRank>=spell.minRank)
  end
 end
end
assert(count==157)
local toc=assert(io.open(root.."/SkillsAlreadyKnown.toc")):read("*a")
local dataAt=toc:find("data/LevelingAdvice.lua",1,true)
local policyAt=toc:find("RankPolicy.lua",1,true)
assert(dataAt and policyAt and dataAt<policyAt,"Active data must load before policy")
assert(not toc:find("scripts/research",1,true),"Research candidates must never be packaged as runtime recommendations")
print("PASS: 81 research records, nine classes, readable active schema, unique spell anchors, rank bounds and TOC load order")
