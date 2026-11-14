-- Data-only local extractor. Invoked by extract-trainerspells-all.py.
local source,output=arg[1],arg[2]
assert(source and output and arg[3],"Expected source, output and source filenames")
local function sortedKeys(t)
 local keys={};for k in pairs(t) do keys[#keys+1]=k end
 table.sort(keys,function(a,b) if type(a)==type(b) then return a<b end;return type(a)=="number" end)
 return keys
end
local function serialize(value,depth)
 local kind=type(value)
 if kind=="string" then return string.format("%q",value) end
 if kind=="number" or kind=="boolean" then return tostring(value) end
 assert(kind=="table","Non-data value: "..kind)
 if not next(value) then return "{}" end
 local result={"{"}
 for _,key in ipairs(sortedKeys(value)) do
  local label
  if type(key)=="string" and key:match("^[%a_][%w_]*$") then label=key
  elseif type(key)=="string" then label="["..string.format("%q",key).."]"
  else label="["..key.."]" end
  result[#result+1]=string.rep("  ",depth+1)..label.." = "..serialize(value[key],depth+1)..","
 end
 result[#result+1]=string.rep("  ",depth).."}"
 return table.concat(result,"\n")
end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)~="table" then return a==b end
 for key,value in pairs(a) do if not same(value,b[key]) then return false end end
 for key in pairs(b) do if a[key]==nil then return false end end
 return true
end
local function write(file,data)
 local f=assert(io.open(output.."/"..file,"w"))
 f:write("-- Donnees TrainerSpells Forever : recherche locale uniquement, ne pas redistribuer.\nreturn ",serialize(data,0),"\n");f:close()
 assert(same(data,assert(loadfile(output.."/"..file))()),"Round-trip mismatch: "..file)
end
local toc=assert(io.open(source.."/TrainerSpells_Camelot.toc")):read("*a")
local interface=assert(tonumber(toc:match("## Interface:%s*(%d+)")))
local version=toc:match("## Version:%s*([^\r\n]+)") or "unknown"
local classes,manifest={},{addon="TrainerSpells",version=version,edition="forever",sourceFiles={},classSummary={},notes={
 "Personal local extraction, not a redistribution license.",
 "No spell names or talent specialization inferred from numeric rank alone.",
 "Rank missing in source remains unknown, never silently replaced by rank one.",
 "Required player level is not proof of affordability or prerequisite completion.",
 "A future visual indicator must distinguish highest learned rank, highest currently accessible rank and eventual maximum rank.",
}}
local totals={files=0,classes=0,classEntries=0,questSpells=0,recipeCalls=0}
for index=3,#arg do
 local file=arg[index]
 assert(file:match("^[%w_%-]+%.lua$"),"Unexpected filename")
 local namespace,recipes={},{}
 local env={GetBuildInfo=function() return nil,nil,nil,interface end, tonumber=tonumber, TrainerSpellsBuiltin_AddProfessionRecipes=function(...)
  local call={};for i=1,select('#',...) do call[i]=select(i,...) end
  recipes[#recipes+1]=call
 end}
 local chunk=assert(loadfile(source.."/data/forever/"..file,"t",env))
 chunk("TrainerSpells",namespace)
 env.TrainerSpellsBuiltin_AddProfessionRecipes=nil
 env.GetBuildInfo,env.tonumber=nil,nil
 local data={sourceFile="data/forever/"..file,version=version,globals=env}
 if next(namespace) then data.namespace=namespace end
 if #recipes>0 then data.recipeCalls=recipes;totals.recipeCalls=totals.recipeCalls+#recipes end
 write("raw/"..file,data)
 totals.files=totals.files+1
 manifest.sourceFiles[#manifest.sourceFiles+1]={file=file,output="raw/"..file,verified=true}
 for class,levels in pairs(env.TrainerSpellsBuiltin or {}) do
  local result={class=class,sourceFile=file,scope="class training shared across specializations; preserve prerequisites where supplied",levels={},bySpellID={},unresolvedPrerequisites={}}
  local count=0
  for _,level in ipairs(sortedKeys(levels)) do
   result.levels[level]={}
   for _,spellID in ipairs(sortedKeys(levels[level])) do
    local fields=levels[level][spellID]
    local entry={spellID=spellID,requiredPlayerLevel=level}
    for key,value in pairs(fields) do
     if key=="cost" then entry.costCopper=value else entry[key]=value end
    end
    result.levels[level][#result.levels[level]+1]=entry
    result.bySpellID[spellID]=result.bySpellID[spellID] or {}
    result.bySpellID[spellID][#result.bySpellID[spellID]+1]=entry
    count=count+1
   end
  end
  -- Keep raw prerequisites and report suspicious links, instead of fabricating rank chains.
  for spellID,offerings in pairs(result.bySpellID) do
   for _,entry in ipairs(offerings) do
    for _,required in ipairs(entry.requires or {}) do
     local problem
     if required==spellID then problem="self-reference in source"
     elseif not result.bySpellID[required] then problem="not in trainer list; may be starting, talent or quest spell" end
     if problem then result.unresolvedPrerequisites[#result.unresolvedPrerequisites+1]={spellID=spellID,requiredSpellID=required,reason=problem} end
    end
   end
  end
  write("classes/"..class..".lua",result)
  classes[class]=result
  totals.classes=totals.classes+1;totals.classEntries=totals.classEntries+count
  manifest.classSummary[class]={entries=count,unresolvedPrerequisites=#result.unresolvedPrerequisites,file="classes/"..class..".lua"}
 end
 if namespace.QuestSpells then
  write("QuestSpells.lua",{sourceFile=file,definitions=namespace})
  for _,spells in pairs(namespace.QuestSpells) do for _ in pairs(spells) do totals.questSpells=totals.questSpells+1 end end
 end
end
assert(totals.classes==9,"Expected every Forever class")
manifest.totals=totals
write("Manifest.lua",manifest)
print(string.format("Verified %d Forever files; %d classes / %d trainer entries; %d quest spell entries; %d recipe registration tables. Every raw and normalized table round-trip checked.",totals.files,totals.classes,totals.classEntries,totals.questSpells,totals.recipeCalls))
