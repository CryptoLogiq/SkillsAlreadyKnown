-- Local research only. Run: lua scripts/research/extract-trainerspells-pets.lua ADDON_PATH OUTPUT_DIRECTORY
-- TrainerSpells data is not licensed for redistribution: output must stay ignored,
-- outside the runtime TOC and release packages. No TrainerSpells implementation is copied.
local source, destination = arg[1], arg[2]
assert(source and destination, "Usage: lua scripts/research/extract-trainerspells-pets.lua ADDON_PATH OUTPUT_DIRECTORY")
local function readTable(file, global)
  local environment = {}
  assert(loadfile(source .. "/data/forever/" .. file, "t", environment))()
  assert(type(environment[global]) == "table", "Missing source table: " .. global)
  return environment[global]
end
local function keys(value)
  local result = {}
  for key in pairs(value) do result[#result + 1] = key end
  table.sort(result, function(a,b)
    if type(a) == type(b) then return a < b end
    return type(a) == "number"
  end)
  return result
end
local function quote(value) return string.format("%q",value) end
local function serialize(value, depth)
  if type(value) == "string" then return quote(value) end
  if type(value) == "number" or type(value) == "boolean" then return tostring(value) end
  assert(type(value) == "table", "Unsupported data type")
  if not next(value) then return "{}" end
  local lines={"{"}
  for _,key in ipairs(keys(value)) do
    local label
    if type(key)=="string" and key:match("^[%a_][%w_]*$") then label=key
    elseif type(key)=="string" then label="["..quote(key).."]"
    else label="["..key.."]" end
    lines[#lines+1]=string.rep("  ",depth+1)..label.." = "..serialize(value[key],depth+1)..","
  end
  lines[#lines+1]=string.rep("  ",depth).."}"
  return table.concat(lines,"\n")
end
local function write(file, value)
  local handle=assert(io.open(destination.."/"..file,"w"))
  handle:write("-- Extraction locale de donnees TrainerSpells Forever. Ne pas redistribuer.\n")
  handle:write("-- Niveaux, rangs et identifiants conserves depuis les tables source.\nreturn ",serialize(value,0),"\n")
  handle:close()
end
local version="unknown"
local toc=assert(io.open(source.."/TrainerSpells_Camelot.toc")):read("*a")
version=toc:match("## Version:%s*([^\r\n]+)") or version
local function metadata(file)
 return {addon="TrainerSpells",version=version,sourceFile="data/forever/"..file,
   usage="local research only; source license prohibits redistribution",
   levelMeaning="source table requirement; not a verified owner/pet level distinction"}
end
local warlock=readTable("WarlockPet.lua","TrainerSpellsBuiltin_WarlockPet")
local hunterTrainer=readTable("HunterPet.lua","TrainerSpellsBuiltin_HunterPet")
local beasts=readTable("HunterBeasts.lua","TrainerSpellsHunterBeasts")
local function convertLevels(levels)
 local output={}
 for _,level in ipairs(keys(levels)) do
  local spells={}
  for _,id in ipairs(keys(levels[level])) do
   local entry={sourceSpellID=id,sourceLevel=level}
   for key,value in pairs(levels[level][id]) do
    if key=="cost" then entry.costCopper=value else entry[key]=value end
   end
   spells[#spells+1]=entry
  end
  output[level]=spells
 end
 return output
end
local demons,warlockCount={},0
for _,demon in ipairs(keys(warlock)) do
 demons[demon]={levels=convertLevels(warlock[demon])}
 for _,spells in pairs(demons[demon].levels) do warlockCount=warlockCount+#spells end
end
write("WarlockPet.lua",{metadata=metadata("WarlockPet.lua"),demons=demons})
local trainerLevels=convertLevels(hunterTrainer)
local trainerCount=0
for _,spells in pairs(trainerLevels) do trainerCount=trainerCount+#spells end
write("HunterPetTrainer.lua",{metadata=metadata("HunterPet.lua"),levels=trainerLevels})
local teachersBySpell,byNPC={},{}
local teacherCount,teacherLinks=0,0
for _,beast in ipairs(beasts.beasts or {}) do
 -- Keep all source fields (including unknown locations, zero levels and empty spells).
 assert(not byNPC[beast.id],"Duplicate source creature ID: "..beast.id)
 byNPC[beast.id]=beast
 teacherCount=teacherCount+1
 for _,id in ipairs(beast.spells or {}) do
  teachersBySpell[id]=teachersBySpell[id] or {}
  teachersBySpell[id][#teachersBySpell[id]+1]=beast.id
  teacherLinks=teacherLinks+1
 end
end
for _,list in pairs(teachersBySpell) do table.sort(list) end
local abilities,abilityCount={},0
local ranksTotal=0
for name,ability in pairs(beasts.abilities or {}) do
 local entry={generic=ability.generic,families=ability.families,ranks={}}
 for _,rank in ipairs(ability.ranks or {}) do
  local data={spellID=rank.spell,rank=rank.rank,requiredPetLevel=rank.level,
    trainingPoints=rank.tp,teacherNPCs=teachersBySpell[rank.spell] or {}}
  -- Preserve source fields that may be added in future versions.
  for key,value in pairs(rank) do
   if key~="spell" and key~="rank" and key~="level" and key~="tp" then data[key]=value end
  end
  entry.ranks[#entry.ranks+1]=data
  ranksTotal=ranksTotal+1
 end
 for key,value in pairs(ability) do if key~="ranks" and key~="generic" and key~="families" then entry[key]=value end end
 abilities[name]=entry;abilityCount=abilityCount+1
end
local meta=metadata("HunterBeasts.lua");meta.levelMeaning="ability ranks: required pet level; creature min/max levels are separate"
meta.teacherSource=beasts.teacherSource
write("HunterPetAbilities.lua",{metadata=meta,families=beasts.families,abilities=abilities})
write("HunterPetTeachers.lua",{metadata=metadata("HunterBeasts.lua"),creatures=byNPC,teachersBySpell=teachersBySpell})
-- Verify every source trainer entry after serializing and reading it back.
local loadedWarlock=assert(loadfile(destination.."/WarlockPet.lua"))()
local loadedHunter=assert(loadfile(destination.."/HunterPetTrainer.lua"))()
for demon,levels in pairs(warlock) do
 for level,spells in pairs(levels) do
  local found={}
  for _,entry in ipairs(loadedWarlock.demons[demon].levels[level]) do found[entry.sourceSpellID]=entry end
  for id,entry in pairs(spells) do
   assert(found[id] and found[id].sourceLevel==level and found[id].rank==entry.rank and found[id].costCopper==entry.cost)
  end
 end
end
for level,spells in pairs(hunterTrainer) do
 local found={}
 for _,entry in ipairs(loadedHunter.levels[level]) do found[entry.sourceSpellID]=entry end
 for id,entry in pairs(spells) do assert(found[id] and found[id].rank==entry.rank and found[id].costCopper==entry.cost) end
end
local loadedAbilities=assert(loadfile(destination.."/HunterPetAbilities.lua"))()
local loadedTeachers=assert(loadfile(destination.."/HunterPetTeachers.lua"))()
for name,ability in pairs(beasts.abilities) do
 for index,rank in ipairs(ability.ranks) do
  local result=loadedAbilities.abilities[name].ranks[index]
  assert(result.spellID==rank.spell and result.rank==rank.rank and result.requiredPetLevel==rank.level and result.trainingPoints==rank.tp)
  for _,npc in ipairs(result.teacherNPCs) do assert(loadedTeachers.creatures[npc]) end
 end
end
local familyCount=0;for _ in pairs(beasts.families) do familyCount=familyCount+1 end
print(string.format("Verified extraction from TrainerSpells %s: %d warlock entries, %d hunter trainer entries, %d abilities / %d ranks, %d families, %d creatures / %d teacher links.",version,warlockCount,trainerCount,abilityCount,ranksTotal,familyCount,teacherCount,teacherLinks))
