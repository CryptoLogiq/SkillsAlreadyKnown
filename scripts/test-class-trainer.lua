-- Run from the development repository: lua scripts/test-class-trainer.lua
local root=arg[1] or "."
SkillsAlreadyKnown=nil
C_AddOns, IsAddOnLoaded, GetAddOnEnableState, UnitName = nil,nil,nil,nil
assert(loadfile(root .. "/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
local sak=SkillsAlreadyKnown
NORMAL_FONT_COLOR={r=1,g=0.82,b=0}
HIGHLIGHT_FONT_COLOR={r=1,g=1,b=1}
assert(loadfile(root .. "/Visuals.lua"))()
local visuals=sak.Visuals
for _, name in ipairs({"PaintOutline","PaintLearnableBg","PaintSoonBg","PaintKnownBg","PaintIconKnownOverlay","PaintLearnableBadge"}) do
  visuals[name]=function(row,value) row[name]=value end
end
visuals.PaintTrainerBadge=function(row,kind) row.badge=kind end
visuals.ClearRow=function(row) visuals.PaintParts(row.name,row.subText,nil) end
UnitLevel=function() return 14 end
GetTime=function() return 100 end
local services={
  {name="Aura de vindicte",rank="Rang 1",state="unavailable",level=16,id=7294},
  {name="Protection divine",rank="Rang 2",state="unavailable",level=18,id=5573},
  {name="Learnable spell",rank="Rang 1",state="available",level=14,id=123},
  {name="Protection divine",rank="Rang 1",state="used",level=6,id=498},
}
GetNumTrainerServices=function() return #services end
GetTrainerServiceInfo=function(index)
  local s=services[index]
  return s.name,s.state,nil,s.level,s.rank
end
C_TooltipInfo={GetTrainerService=function(index) return {id=services[index].id} end}
local function font(text)
  return {text=text, rgb={1,0.82,0},GetText=function(self) return self.text end,
    SetTextColor=function(self,r,g,b) self.rgb={r,g,b} end,
    GetTextColor=function(self) return self.rgb[1],self.rgb[2],self.rgb[3] end}
end
local rows={}
for index, service in ipairs(services) do
  local data={index=index,spellID=service.id}
  rows[index]={name=font(service.name),subText=font("Requires level "..service.level),GetElementData=function() return data end}
end
local timers={}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local function flush()
  local iterations=0
  while #timers>0 do iterations=iterations+1; assert(iterations<10,"refresh loop"); table.remove(timers,1)() end
end
local hookCounts={}
hooksecurefunc=function(target,key,fn)
  if type(target)=="string" then fn=key; key=target; target=_G end
  local original=target[key]
  target[key]=function(...) original(...); fn(...) end
  hookCounts[key]=(hookCounts[key] or 0)+1
end
local shows={}
ClassTrainerFrame={HookScript=function(_,event,fn) assert(event=="OnShow"); shows[#shows+1]=fn end}
ClassTrainerFrame_Update=nil
local initialized
ScrollUtil={AddInitializedFrameCallback=function(_,fn) initialized=fn end}
BaseScrollBoxEvents=nil
assert(loadfile(root .. "/ClassTrainer.lua"))()
local trainer=sak.ClassTrainer
trainer.Hook(); trainer.Hook()
assert(#shows==1)
local function resetNames() for _, row in ipairs(rows) do row.name:SetTextColor(1,0.82,0) end end
ClassTrainerFrame_Update=resetNames
local scroll={IsVisible=function() return true end,ForEachFrame=function(_,fn) for _,row in ipairs(rows) do fn(row) end end,Update=resetNames}
ClassTrainerFrame.ScrollBox=scroll
trainer.Hook(); trainer.Hook()
assert(hookCounts.ClassTrainerFrame_Update==1,"late update function not hooked")
assert(hookCounts.Update==1,"row callbacks must not suppress repaint hooks")
assert(trainer.GetDiagnostics().rowCallbacks)
-- A later skin hook changes text after our synchronous update hook.
hooksecurefunc("ClassTrainerFrame_Update",resetNames)
ClassTrainerFrame_Update(); flush()
assert(rows[1].name.rgb[1]==1 and rows[1].name.rgb[2]==0.15)
assert(rows[1].subText.rgb[1]==1 and rows[1].subText.rgb[2]==1)
assert(rows[2].name.rgb[2]==0.15 and not rows[2].PaintIconKnownOverlay)
assert(rows[3].PaintOutline and rows[3].badge=="new")
assert(rows[4].PaintKnownBg and rows[4].PaintIconKnownOverlay and rows[4].name.rgb[1]==0.34)
local info=trainer.GetDiagnostics()
assert(info.updateHooked and info.showHooked and info.scrollHooked and info.rows==4 and info.matched==4)
print("PASS: late loading, idempotent hooks, deferred paint after skin hooks, level-locked/learnable/known states and rank IDs")
scroll:Update(); scroll:Update(); assert(#timers==1); flush()
assert(rows[1].name.rgb[2]==0.15)
initialized(nil,rows[1]); flush(); assert(rows[1].name.rgb[2]==0.15)
-- Replacing the ScrollBox must not leave the replacement unhooked.
local replacement={IsVisible=scroll.IsVisible,ForEachFrame=scroll.ForEachFrame,Update=resetNames}
ClassTrainerFrame.ScrollBox=replacement
trainer.Hook(); assert(hookCounts.Update==2)
replacement:Update(); flush(); assert(rows[1].name.rgb[2]==0.15)
print("PASS: existing-row repaints, coalesced refresh, initialized callbacks, replaced ScrollBox")
-- Debug output must reveal changes occurring after our last paint.
rows[1].name:SetTextColor(1,0.82,0)
local report
sak.ShowDebugTextWindow=function(_,_,text) report=text end
trainer.ShowDebugWindow()
assert(report:find("lastRows=4 lastMatched=4",1,true))
assert(report:find("expectedState=unavailable actualNameRGB=1.00,0.82,0.00",1,true))
assert(report:find("lastPaintState=unavailable",1,true))
rows={}; trainer.ShowDebugWindow()
assert(report:find("visible, but no rows were found",1,true))
print("PASS: debug reports refresh status, actual colors, last-painted states and empty-row scans")
