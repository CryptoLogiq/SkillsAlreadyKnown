-- Run: lua scripts/test-content-tags.lua
local root = arg[1] or "."
local class = "MAGE"
UnitClass = function() return class,class end
SkillsAlreadyKnown, SkillsAlreadyKnownDB = nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root.."/data/ContentUsage.lua"))()
local s = SkillsAlreadyKnown
local classes,talents,spells = 0,0,0
for _,data in pairs(s.ContentUsage.classes) do
  classes=classes+1
  assert(#data.sources>0 and #data.talents>=5 and #data.spells>=3)
  local ids,nodes={},{}
  for _,list in ipairs({data.talents,data.spells}) do
    for _,entry in ipairs(list) do
      assert(type(entry.spellID)=="number" and not ids[entry.spellID])
      ids[entry.spellID]=true
      assert(entry.tag=="pvp" or entry.tag=="mixed")
      assert(#entry.name>0 and #entry.reason>0)
      if entry.nodeID then
        talents=talents+1
        assert(not nodes[entry.nodeID] and entry.tree>=1 and entry.tree<=3)
        nodes[entry.nodeID]=true
      else spells=spells+1 end
    end
  end
end
assert(classes==9 and talents==79 and spells==39)
local made={}
local function frame()
  local f={shown=true,alpha=1,level=100,points={},scripts={}}
  function f:IsVisible() return self.shown end
  function f:IsShown() return self.shown end
  function f:GetEffectiveAlpha() return self.alpha end
  function f:GetEffectiveScale() return 0.64 end
  function f:GetFrameLevel() return self.level end
  function f:GetFrameStrata() return "MEDIUM" end
  function f:GetParent() return self.parent end
  function f:Hide()
    if self.shown then
      self.hides=(self.hides or 0)+1
      self.shown=false
      if self.scripts.OnHide then self.scripts.OnHide(self) end
    end
  end
  function f:Show() self.shown=true end
  function f:EnableMouse() end
  function f:SetScript(event,callback) self.scripts[event]=callback end
  function f:SetSize(w,h) self.width,self.height=w,h end
  function f:GetWidth() return self.width or 40 end
  function f:SetScale(value) self.scale=value end
  function f:SetFrameStrata(value) self.strata=value end
  function f:SetFrameLevel(value) self.level=value end
  function f:ClearAllPoints() self.points={} end
  function f:SetPoint(...) self.points[#self.points+1]={...} end
  function f:SetBackdrop() end
  function f:SetBackdropColor() end
  function f:SetBackdropBorderColor() end
  function f:CreateFontString()
    return {
      size=12,
      SetAllPoints=function() end,
      SetText=function(self,text) self.text=text end,
      SetTextColor=function() end,
      GetFont=function(self) return "font",self.size,"" end,
      SetFont=function(self,_,size) self.size=size end,
      GetStringWidth=function(self) return #self.text*self.size*0.6 end,
      SetWordWrap=function() end,
      SetNonSpaceWrap=function() end,
    }
  end
  return f
end
UIParent={GetEffectiveScale=function() return 0.64 end}
CreateFrame=function(_,_,parent) local f=frame();f.parent=parent;made[#made+1]=f;return f end
local names={[11071]="Morsure de givre",[900001]="Morsure de givre",[900002]="Jamais classé"}
C_Spell={GetSpellInfo=function(id) if names[id] then return {name=names[id]} end end}
assert(loadfile(root.."/ContentTags.lua"))()
local tags=s.ContentTags
assert(tags.ForSpell("MAGE",11071).tag=="pvp")
assert(tags.ForSpell("MAGE",900001).spellID==11071)
assert(not tags.ForSpell("MAGE",900002) and not tags.ForSpell("WARLOCK",11071))
local nodeCalls,definition = 0,11071
C_ClassTalents={GetActiveConfigID=function() return 7 end}
C_Traits={
  GetNodeInfo=function() nodeCalls=nodeCalls+1;return {entryIDs={11}} end,
  GetEntryInfo=function() return {definitionID=22} end,
  GetDefinitionInfo=function() return {spellID=definition} end,
}
local native,button,unknown,duplicate=frame(),frame(),frame(),frame()
button.GetNodeID=function() return 105774 end
button.Icon=frame()
unknown.GetID=function() return 11071 end -- A generic frame ID is not a spell ID.
duplicate.spellID=11071
function native:GetChildren() return button,unknown end
PlayerSpellsFrame={TalentsFrame=native}
tags.RefreshTalents()
local badge=made[1]
assert(#made==1 and badge.entry.spellID==11071 and badge.text.text=="PVP")
assert(badge.points[1][1]=="TOP" and badge.points[1][2]==button.Icon)
assert(badge.points[1][3]=="BOTTOM" and badge.points[1][5]==0)
assert(badge.width==button.Icon:GetWidth())
assert(badge.strata=="HIGH" and badge.level==130 and badge.scale==1)
function native:GetChildren() return button,unknown,duplicate end
button.Icon.width=32
local hides=badge.hides or 0
tags.RefreshTalents()
assert(nodeCalls==1 and #made==1 and (badge.hides or 0)==hides,"Refresh must not flash/hide active badges")
assert(badge.width==32)
function native:GetChildren() return button,unknown end
button.GetNodeID=function() return 105769 end
C_Traits=nil
tags.RefreshTalents()
assert(badge.text.text=="PVE PVP" and badge.width==32 and badge.text:GetStringWidth()<=26.01)
button.Icon.width=64;tags.RefreshTalents()
assert(badge.width==64 and badge.text.size==12)
button.GetNodeID=function() return 105774 end
C_Traits={GetNodeInfo=function() nodeCalls=nodeCalls+1;return {entryIDs={11}} end,
 GetEntryInfo=function() return {definitionID=22} end, GetDefinitionInfo=function() return {spellID=definition} end}
function native:GetChildren() return button,unknown end
-- A live definition takes precedence over the stored node hint after a talent update.
definition=900002;tags.MarkDirty();tags.RefreshTalents();assert(not badge.shown)
C_Traits=nil;tags.RefreshTalents();assert(badge.shown,"Reviewed class/node identity supports clients without traits APIs")
native.alpha=0;tags.RefreshTalents();assert(not badge.shown)
native.alpha=1;tags.RefreshTalents();assert(badge.shown)
local row=frame()
row.sakTrainerBadge=frame();row.sakTrainerAdvice=frame()
tags.PaintTrainer(row,{serviceType="available",spellID=118})
local trainer=made[2]
assert(trainer.entry.spellID==118 and trainer.text.text=="PVE PVP")
assert(trainer.points[1][2]==row.sakTrainerAdvice and trainer.width==60)
tags.PaintTrainer(row,{serviceType="used",spellID=118});assert(not trainer.shown and not trainer.entry)
tags.PaintTrainer(row,{serviceType="unavailable",spellID=118});assert(not trainer.shown)
tags.PaintTrainer(row,{serviceType="available",spellID=999});assert(not trainer.shown)
tags.PaintTrainer(row,{serviceType="available",spellID=118});assert(trainer.shown and #made==2)
s.SetDisplayOption("iconsTrainer",false);tags.Refresh();assert(not trainer.shown and badge.shown)
s.SetDisplayOption("iconsTrainer",true)
s.SetDisplayOption("iconsTalents",false);tags.Refresh();assert(not badge.shown)
s.SetDisplayOption("iconsTalents",true)
s.SetDisplayOption("contentTags",false);tags.PaintTrainer(row,{serviceType="available",spellID=118});tags.Refresh()
assert(not trainer.shown and not badge.shown)
s.SetDisplayOption("contentTags",true);tags.RefreshTalents();assert(badge.shown)
local lines={}
GameTooltip={SetOwner=function() end,AddLine=function(_,line) lines[#lines+1]=line end,Show=function() end,Hide=function() end}
badge.scripts.OnEnter(badge)
assert(table.concat(lines," "):find("Principalement",1,true))
assert(table.concat(lines," "):find("pas une obligation",1,true))
local count=#made;tags.Initialize();tags.Initialize();assert(#made==count+1)
print("PASS: 9-class data, 79 talents/39 spells, exact/localized rank identities, modern node APIs/cache, native node hints, unknown IDs, alpha/visibility, learned-service exclusion, recycled rows, tooltip and category switches")

-- The same icon can carry PvP advice and an independent area-use marker.
dofile(root..'/data/SurvivalAdvice.lua')
dofile(root..'/data/AreaSpells.lua')
dofile(root..'/data/AreaTalents.lua')
dofile(root..'/SpellUsage.lua')
C_Traits=nil
button.GetNodeID=function() return 105771 end
function native:GetChildren() return button end
s.SetDisplayOption('aoe',true);s.SetDisplayOption('iconsTalents',true)
tags.RefreshTalents()
local area
for _,display in ipairs(made) do
 if display.entry and display.entry.tag=='aoe' then area=display end
end
assert(area and area.shown and area.entry.spellID==11185)
assert(area.width==button.Icon:GetWidth())
assert(area.points[1][1]=='TOP' and area.points[1][2]==badge and area.points[1][3]=='BOTTOM')
local frameCount=#made
tags.RefreshTalents();assert(#made==frameCount)
s.SetDisplayOption('contentTags',false);tags.RefreshTalents()
assert(not badge.shown and area.shown,'AoE is independent of PvP markers')
assert(area.points[1][2]==button.Icon)
s.SetDisplayOption('aoe',false);tags.RefreshTalents();assert(not area.shown)
s.SetDisplayOption('aoe',true);tags.RefreshTalents();assert(area.shown)
button.GetNodeID=function() return 999999 end
tags.RefreshTalents();assert(not area.shown,'Clear a recycled unknown talent')
button.GetNodeID=function() return 105771 end
s.SetDisplayOption('iconsTalents',false);tags.RefreshTalents();assert(not area.shown)
local classes,talents=0,0
for class,entries in pairs(s.AreaTalents) do
 classes=classes+1
 for id,entry in pairs(entries) do
  talents=talents+1
  assert(s.SpellUsage.ForTalent(class,id,nil)==entry)
  assert(s.SpellUsage.ForTalent(class,nil,entry.nodeID)==entry)
 end
end
assert(classes==9 and talents==21)
assert(s.AreaSpells.SHAMAN[408341] and not s.AreaSpells.SHAMAN[1535],'Use the Forever Fire Nova, not removed Classic totem')
print('PASS: nine-class talent review, passive/active AoE, exact/node IDs, stacked PvP markers, independent switches and recycling')
