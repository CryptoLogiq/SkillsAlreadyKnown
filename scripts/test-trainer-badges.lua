-- Run from the development repository: lua scripts/test-trainer-badges.lua
local root=arg[1] or "."
SkillsAlreadyKnown=nil
C_AddOns,IsAddOnLoaded,GetAddOnEnableState,UnitName=nil,nil,nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
local sak=SkillsAlreadyKnown
NORMAL_FONT_COLOR={r=1,g=0.82,b=0}; HIGHLIGHT_FONT_COLOR={r=1,g=1,b=1}
assert(loadfile(root.."/Visuals.lua"))()
local visuals=sak.Visuals
for _,key in ipairs({"PaintOutline","PaintLearnableBg","PaintSoonBg","PaintKnownBg","PaintIconKnownOverlay"}) do visuals[key]=function() end end
local timers={}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local function flush() local count=0; while #timers>0 do count=count+1; assert(count<10); table.remove(timers,1)() end end
hooksecurefunc=function(target,key,fn)
  if type(target)=="string" then fn=key;key=target;target=_G end
  local original=target[key]
  target[key]=function(...) original(...); fn(...) end
end
UnitLevel=function() return 14 end
local services={
  {name="Same spell",rank="Rank 1",status="used",level=6,id=101},
  {name="Same spell",rank="Rank 2",status="available",level=14,id=202},
  {name="Next spell",rank="Rank 1",status="unavailable",level=16,id=303},
  {name="Distant spell",rank="Rank 1",status="unavailable",level=30,id=404},
}
GetNumTrainerServices=function() return #services end
GetTrainerServiceInfo=function(i) local s=services[i]; return s.name,s.rank,s.status end
GetTrainerServiceLevelReq=function(i) return services[i].level end
C_TooltipInfo={GetTrainerService=function(i) return {id=services[i].id} end}
local function font()
  return {GetText=function(self) return self.value end,SetText=function(self,value) self.value=value end,
    SetTextColor=function(self,r,g,b) self.rgb={r,g,b} end,
    GetTextColor=function(self) local c=self.rgb or {};return c[1],c[2],c[3] end}
end
local function row(visible)
  local r={name=font(),visible=visible,created=0,icon={GetTexture=function() return 777 end}}
  function r:IsVisible() return self.visible end
  function r:GetElementData() return {GetData=function() return self.data end} end
  function r:CreateTexture(_,layer,_,sublevel)
    self.created=self.created+1
    assert(layer=="OVERLAY" and sublevel==7)
    return {SetPoint=function(self,...) self.point={...} end,
      SetTexture=function(self,value) self.texture=value end,
      SetSize=function(self,w,h) self.width,self.height=w,h end,
      Show=function(self) self.shown=true end,Hide=function(self) self.shown=false end}
  end
  return r
end
local native=row(false)
ClassTrainerFrame={IsShown=function() return true end,HookScript=function() end,
  ScrollBox={IsVisible=function() return true end,Update=function() end,
  ForEachFrame=function(_,fn) fn(native) end}}
local originalCalls=0
ClassTrainerFrame_InitServiceButton=function(r,data)
  originalCalls=originalCalls+1;r.data=data;r.name:SetText(data.name)
end
assert(loadfile(root.."/ClassTrainer.lua"))()
local trainer=sak.ClassTrainer
trainer.Hook();trainer.Hook()
local learnable,known,soon=row(true),row(true),row(true)
-- A generic id deliberately matches the lower rank: only validated skillIndex wins.
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=2,name="Same spell",id=101})
ClassTrainerFrame_InitServiceButton(known,{skillIndex=1,name="Same spell",spellID=101})
ClassTrainerFrame_InitServiceButton(soon,{skillIndex=3,name="Next spell",spellID=303})
ClassTrainerFrame_InitServiceButton(native,{skillIndex=4,name="Distant spell",spellID=404})
flush()
assert(originalCalls==4 and trainer.GetDiagnostics().initializerHooked)
assert(native.created==0,"Must not paint the hidden Blizzard list")
assert(learnable.sakTrainerBadge.texture==sak.TRAINER_BADGES.new.texture)
assert(known.sakTrainerBadge.texture==sak.TRAINER_BADGES.known.texture)
assert(soon.sakTrainerBadge.texture==sak.TRAINER_BADGES.next.texture)
assert(learnable.created==1 and learnable.sakTrainerBadge.point[2]==learnable.icon)
assert(learnable.sakTrainerBadge.point[4]==7 and learnable.sakTrainerBadge.point[5]==12)
assert(learnable.sakLearnableBadge==nil,"Old book plus must not be added on trainers")
print("PASS: TrainerSpells replacement rows, hidden native list, skillIndex rank validation, three badges and icon-corner anchors")
-- Recycled rows must change or hide their badge without accumulating textures.
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=3,name="Next spell",spellID=303});flush()
assert(learnable.sakTrainerBadge.texture==sak.TRAINER_BADGES.next.texture and learnable.created==1)
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=4,name="Distant spell",spellID=404});flush()
assert(learnable.sakTrainerBadge.shown and learnable.sakTrainerBadge.texture==sak.TRAINER_BADGES.notnow.texture)
ClassTrainerFrame_InitServiceButton(learnable,{name="Unmatched row",skillIndex=999,spellID=999});flush()
assert(not learnable.sakTrainerBadge.shown)
local report
sak.ShowDebugTextWindow=function(_,_,text) report=text end
trainer.ShowDebugWindow()
assert(report:find("SAK trainer badge: expected=known",1,true))
assert(report:find("SAK trainer badge: expected=next",1,true))
assert(not report:find("row='Distant spell'",1,true))
print("PASS: recycled/unmatched rows, mutually exclusive badges, replacement-list support exports")
-- Native rows still use the same renderer, without a replacement addon.
native.visible=true
native.data={skillIndex=2,name="Same spell",spellID=202};native.name:SetText("Same spell")
trainer.MarkDirty();trainer.Refresh()
assert(native.sakTrainerBadge.texture==sak.TRAINER_BADGES.new.texture)
local count=trainer.GetDiagnostics().rows
assert(count==4,"Deduplicate native rows captured through the initializer")
print("PASS: Blizzard rows and deduplicated initialized/native rendering")

-- The reported mage case: a learnable, unlearned optional purchase gets both badges.
UnitClass=function() return "Mage","MAGE" end
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root .. "/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root.."/RankPolicy.lua"))()
sak.RankPolicy.SetRole("dps");sak.RankPolicy.SetSpecialization("dps","fire")
services[2]={name="Amplification de la magie",rank="Rang 1",status="available",level=18,id=1008}
trainer.MarkDirty()
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=2,name=services[2].name,spellID=1008});flush()
assert(learnable.sakTrainerBadge.texture==sak.TRAINER_BADGES.new.texture)
assert(learnable.sakTrainerAdvice.shown and learnable.sakTrainerAdvice.texture==sak.SPELLBOOK_BADGES.optional.texture)
assert(learnable.sakTrainerAdvice.point[2]==learnable.sakTrainerBadge and learnable.sakTrainerAdvice.point[3]=="RIGHT")
sak.RankPolicy.SetOptional(false);flush();assert(not learnable.sakTrainerAdvice.shown)
sak.RankPolicy.SetOptional(true);flush();assert(learnable.sakTrainerAdvice.shown)
sak.SetDisplayOption("icons",false);trainer.Refresh();assert(not learnable.sakTrainerAdvice.shown)
sak.SetDisplayOption("icons",true);trainer.Refresh();assert(learnable.sakTrainerAdvice.shown)
sak.RankPolicy.SetRoleEnabled("pvp",true);flush();assert(not learnable.sakTrainerAdvice.shown)
sak.RankPolicy.SetRoleEnabled("pvp",false);flush();assert(learnable.sakTrainerAdvice.shown)
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=3,name="Next spell",spellID=303});flush()
assert(not learnable.sakTrainerAdvice.shown,"A recycled row must lose its optional marker")
print("PASS: unlearned Amplify Magic shows NEW + OPTIONAL, with role/preference changes and recycled-row cleanup")

local tagServices={}
sak.ContentTags={
 PaintTrainer=function(row,service) tagServices[row]=service end,
 HideTrainer=function(row) tagServices[row]=nil end,
}
services[2]={name="Métamorphose",rank="Rang 1",status="available",level=8,id=118}
trainer.MarkDirty()
ClassTrainerFrame_InitServiceButton(learnable,{skillIndex=2,name=services[2].name,spellID=118});flush()
assert(tagServices[learnable].spellID==118 and tagServices[learnable].serviceType=="available")
services[2].status="used";trainer.MarkDirty();trainer.Refresh()
assert(tagServices[learnable].serviceType=="used", "Tag renderer must receive the changed availability")
print("PASS: resolved TrainerSpells service IDs and availability feed the shared content-tag renderer")
