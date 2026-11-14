-- Run: lua scripts/test-profession-trainer.lua
local root=arg[1] or "."
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root.."/ProfessionTrainer.lua"))()
local s=SkillsAlreadyKnown
local step,profession=1,true
GetTrainerServiceStepIndex=function() return step end
IsTradeskillTrainer=function() return profession end
UnitLevel=function() return 17 end
local entries={
 {name="Minage de compagnon",id=2576,status="unavailable",skill=50},
 {name="Minage d’expert",id=3564,status="unavailable",skill=125},
 {name="Minage d’artisan",id=10248,status="unavailable",skill=200},
 {name="Magnétite",id=7777,status="unavailable",skill=20},
}
GetNumTrainerServices=function() return #entries end
GetTrainerServiceInfo=function(index) local e=entries[index];return e.name,"",e.status end
GetTrainerServiceLevelReq=function() return 0 end
C_TooltipInfo={GetTrainerService=function(index) return {id=entries[index].id} end}
local rows={}
for index=1,#entries do
 local i=index
 rows[i]={name={GetText=function() return entries[i].name end},subText={},
  GetElementData=function() return {skillIndex=i,spellID=entries[i].id} end,
  IsVisible=function() return true end,IsShown=function() return true end,GetID=function() return i end}
end
s.Visuals={
 PaintTrainerParts=function() end,
 PaintOutline=function(row,show,color) row.outline=show;row.color=color end,
 PaintLearnableBg=function(row,value) row.available=value end,
 PaintSoonBg=function(row,value) row.soon=value end,
 PaintKnownBg=function(row,value) row.known=value end,
 PaintIconKnownOverlay=function() end,
 PaintTrainerBadge=function(row,kind) row.badge=kind;row.paints=(row.paints or 0)+1 end,
 PaintTrainerAdvice=function() end,
 ClearRow=function(row) row.badge=nil end,
}
ClassTrainerFrame={IsShown=function() return true end,skillStepButton=rows[1],ScrollBox={
 IsVisible=function() return true end,
 ForEachFrame=function(_,callback) for i=2,#rows do callback(rows[i]) end end,
}}
assert(loadfile(root.."/ClassTrainer.lua"))()
local function refresh() s.ClassTrainer.MarkDirty();s.ClassTrainer.Refresh() end
refresh()
assert(rows[1].badge=="next" and rows[1].soon and rows[1].color==s.TRAINER_OUTLINES.soon)
assert(rows[2].badge=="notnow" and rows[3].badge=="notnow" and rows[4].badge=="notnow")
assert(rows[1].paints==1,"Separate milestone row must be painted")
entries[1].status="available";refresh();assert(rows[1].badge=="new" and rows[1].available and not rows[1].soon)
entries[1].status="used";step=2;ClassTrainerFrame.skillStepButton=rows[2]
local before=rows[2].paints
refresh()
assert(rows[1].badge==nil or rows[1].badge=="new") -- It is no longer a visible row in this fixture.
assert(rows[2].badge=="next" and rows[2].paints==before+1,"Do not double-paint a step already in ScrollBox")
step=nil;refresh();assert(rows[2].badge=="notnow")
step=99;assert(s.ProfessionTrainer.NextStepIndex()==nil)
step=1;profession=false;assert(s.ProfessionTrainer.NextStepIndex()==nil)
profession=true;GetTrainerServiceStepIndex=function() error("API unavailable") end
assert(s.ProfessionTrainer.NextStepIndex()==nil)
GetTrainerServiceStepIndex=nil;assert(s.ProfessionTrainer.NextStepIndex()==nil)
GetTrainerServiceStepIndex=function() return step end
-- The classic row path uses the same milestone and status precedence.
entries[1].status="unavailable";ClassTrainerFrame.skillStepButton=nil
ClassTrainerFrame.ScrollBox.IsVisible=function() return false end
CLASS_TRAINER_SKILLS_DISPLAYED=#rows
for i,row in ipairs(rows) do
 _G["ClassTrainerSkill"..i]=row
 _G["ClassTrainerSkill"..i.."Text"]=row.name
 _G["ClassTrainerSkill"..i.."SubText"]=row.subText
end
refresh();assert(rows[1].badge=="next" and rows[4].badge=="notnow")
entries[1].status="used";refresh();assert(rows[1].badge=="known" and rows[1].known and not rows[1].soon)
print("PASS: next profession milestone at skill 5/75, recipes excluded, separate step row, deduplication, available/known precedence, later rank, missing/invalid API and classic rows")
