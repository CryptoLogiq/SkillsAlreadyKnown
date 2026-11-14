-- Run: lua scripts/test-spellbook-tabs.lua
local root=arg[1] or "."
local level,class=9,"MAGE"
UnitLevel=function() return level end
UnitClass=function() return class,class end
for _,file in ipairs({"Core.lua","data/ClassRoles.lua","data/TalentSummaries.lua","data/LevelingRecommendations.lua","TalentTooltips.lua","SpellBookTabs.lua"}) do
  assert(loadfile(root.."/"..file))()
end
local s=SkillsAlreadyKnown
local header,owner,shown,lines=nil,nil,false,{}
local clears={}
GameTooltipTextLeft1={GetText=function() return header end}
GameTooltip={
  GetOwner=function() return owner end,
  IsShown=function() return shown end,
  Show=function() shown=true end,
  AddLine=function(_,line) lines[#lines+1]=line end,
  HookScript=function(_,event,callback) assert(event=="OnTooltipCleared");clears[#clears+1]=callback end,
}
local timers={}
C_Timer={After=function(_,callback) timers[#timers+1]=callback end}
local function flush()
  while #timers>0 do table.remove(timers,1)() end
end
local function tab(name)
  local button={hooks={},name=name}
  button.enter=function(self)
    owner,header,shown,lines=self,self.name,true,{self.name}
    for _,callback in ipairs(clears) do callback(GameTooltip) end
  end
  function button:GetScript(event) if event=="OnEnter" then return self.enter end end
  function button:HookScript(event,callback) assert(event=="OnEnter");self.hooks[#self.hooks+1]=callback end
  function button:Enter()
    self.enter(self)
    for _,callback in ipairs(self.hooks) do callback(self) end
  end
  return button
end
local general,fire,profession,foreign=tab("Général"),tab("Feu"),tab("Couture"),tab("TrainerSpells")
local book={GetChildren=function() return general,fire,profession,foreign end}
PlayerSpellsFrame={SpellBookFrame=book}
s.SpellBookTabs.Hook();s.SpellBookTabs.Hook()
assert(#fire.hooks==1 and #clears==1)
fire:Enter()
assert(lines[1]=="Feu")
assert(table.concat(lines," "):find(s.TalentSummaries.MAGE.fire.summary,1,true))
assert(table.concat(lines," "):find("Avantages",1,true) and table.concat(lines," "):find("Inconvénients",1,true))
local count=#lines;flush();assert(#lines==count,"Deferred hook must not duplicate content")
fire.name="|cffe5e5e5Feu|r";fire:Enter();flush()
assert(table.concat(lines," "):find(s.TalentSummaries.MAGE.fire.summary,1,true))
assert(lines[1]=="|cffe5e5e5Feu|r", "Preserve the native colored tooltip title")
fire.name="Feu"
for _,button in ipairs({general,profession,foreign}) do button:Enter();flush();assert(#lines==1) end
fire:Enter();owner=foreign;lines={"foreign"};flush();assert(#lines==1)
level=10;fire:Enter();flush();assert(#lines==1)
level=9;s.SetDisplayOption("text",false);fire:Enter();flush();assert(#lines==1)
s.SetDisplayOption("text",true)
-- Runtime talent names support another client locale without hardcoded translated data.
GetTalentTabInfo=function(index) return index,({"Arcane EN","Fire EN","Frost EN"})[index] end
fire.name="Fire EN";fire:Enter();flush();assert(#lines>1)
-- A Feral school explains both tank and DPS from the same maintained table.
class="DRUID";GetTalentTabInfo=nil
fire.name="Farouche";fire:Enter();flush()
local text=table.concat(lines," ")
assert(text:find("Farouche DPS",1,true) and text:find("Farouche tank",1,true))
-- The classic Ellesmere book has its own tooltip API; never replace secure scripts.
class="MAGE"
local eui=tab("Feu");eui.tooltip="Feu"
EUI_ClassicSpellbook={GetChildren=function() return eui end}
eui.GetParent=function() return EUI_ClassicSpellbook end
local euiCalls=0
EllesmereUI={ShowWidgetTooltip=function(button,body,options)
 assert(button==eui and options.anchor=="right" and options.justify=="LEFT")
 assert(body:find(s.TalentSummaries.MAGE.fire.summary,1,true))
 euiCalls=euiCalls+1
end}
s.SpellBookTabs.Hook();eui:Enter();assert(euiCalls==1)
level=10;eui:Enter();assert(euiCalls==1)
print("PASS: under-10 native tab summaries, preserved titles, shared advantages/drawbacks, duplicate/owner/level/text guards, localization, Feral dual role and Ellesmere tooltip adapter")
