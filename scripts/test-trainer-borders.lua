-- Run from the development repository: lua scripts/test-trainer-borders.lua
local root=arg[1] or "."
SkillsAlreadyKnown=nil
C_AddOns, IsAddOnLoaded, GetAddOnEnableState, UnitName=nil,nil,nil,nil
assert(loadfile(root .. "/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
local sak=SkillsAlreadyKnown
local playerLevel=14
UnitLevel=function() return playerLevel end
local entries={
  {"Available",1,"available",14},
  {"Next odd level",2,"unavailable",15},
  {"Next even level",3,"unavailable",16},
  {"Farther away",4,"unavailable",18},
  {"Other requirement",5,"unavailable",14},
  {"No level data",6,"unavailable",nil},
  {"Known",7,"used",6},
  {"Unknown state",8,"other",40},
}
GetNumTrainerServices=function() return #entries end
GetTrainerServiceInfo=function(i) local e=entries[i]; return e[1],"Rank 1",e[3] end
GetTrainerServiceLevelReq=function(i) return entries[i][4] end
C_TooltipInfo={GetTrainerService=function(i) return {id=entries[i][2]} end}
local rows={}
for i,e in ipairs(entries) do
  local index=i
  rows[i]={name={GetText=function() return entries[index][1] end},subText={},
    GetElementData=function() return {spellID=entries[index][2],index=index} end,
    IsShown=function() return true end,GetID=function() return index end}
end
local visuals={}
sak.Visuals=visuals
visuals.PaintTrainerParts=function(name,sub,state) name.state=state end
visuals.PaintOutline=function(row,show,color) row.outline=show; row.color=color end
for _,method in ipairs({"PaintLearnableBg","PaintSoonBg","PaintKnownBg","PaintIconKnownOverlay","PaintLearnableBadge","PaintTrainerAdvice"}) do
  visuals[method]=function(row,value) row[method]=value end
end
visuals.PaintTrainerBadge=function(row,kind) row.badge=kind end
visuals.ClearRow=function(row) row.outline=false; row.color=nil end
ClassTrainerFrame={ScrollBox={IsVisible=function() return true end,
  ForEachFrame=function(_,fn) for _,row in ipairs(rows) do fn(row) end end}}
assert(loadfile(root .. "/ClassTrainer.lua"))()
local trainer=sak.ClassTrainer
local colors=sak.TRAINER_OUTLINES
local function check(level,expected)
  playerLevel=level; trainer.MarkDirty(); trainer.Refresh()
  for i,key in ipairs(expected) do
    local row=rows[i]
    if key=="none" then assert(not row.outline,"Unexpected border on row "..i)
    else assert(row.outline and row.color==colors[key],"Wrong border at level "..level.." row "..i) end
    local badge = key=="available" and "new" or key=="soon" and "next" or key=="unavailable" and "notnow"
      or entries[i][3]=="used" and "known" or nil
    assert(row.badge==badge,"Wrong badge at level "..level.." row "..i)
    assert(row.PaintSoonBg==(key=="soon"),"Wrong yellow background at level "..level.." row "..i)
    assert(not (row.PaintSoonBg and (row.PaintLearnableBg or row.PaintKnownBg)),"Status backgrounds must be exclusive")
    assert((row.badge=="new")==(entries[i][3]=="available"),"Plus badge on unavailable spell")
  end
end
check(14,{"available","soon","soon","unavailable","unavailable","unavailable","known","none"})
check(15,{"available","unavailable","soon","unavailable","unavailable","unavailable","known","none"})
check(16,{"available","unavailable","unavailable","soon","unavailable","unavailable","known","none"})
-- API availability takes precedence; known state keeps its grey outline regardless of level requirements.
entries[1][4]=60; entries[7][4]=60
check(14,{"available","soon","soon","unavailable","unavailable","unavailable","known","none"})
assert(rows[7].PaintKnownBg and rows[7].name.state=="known")
print("PASS: modern rows, even/odd milestones, boundary levels, non-level locks, known and unknown states, API precedence")
-- Check the same classification on the legacy trainer path.
ClassTrainerFrame.ScrollBox.IsVisible=function() return false end
CLASS_TRAINER_SKILLS_DISPLAYED=#rows
for i,row in ipairs(rows) do
  _G["ClassTrainerSkill"..i]=row
  _G["ClassTrainerSkill"..i.."Text"]=row.name
  _G["ClassTrainerSkill"..i.."SubText"]=row.subText
end
check(14,{"available","soon","soon","unavailable","unavailable","unavailable","known","none"})
check(15,{"available","unavailable","soon","unavailable","unavailable","unavailable","known","none"})
entries[1][3]="used"
check(15,{"known","unavailable","soon","unavailable","unavailable","unavailable","known","none"})
assert(rows[1].badge=="known" and rows[1].PaintKnownBg)
print("PASS: legacy rows and recycled row replaces its availability border with a grey known border")
