-- Run: lua scripts/test-talent-roles.lua
local root=arg[1] or "."
local class="WARLOCK"
UnitClass=function() return class,class end
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root.."/data/ClassRoles.lua"))()
assert(loadfile(root.."/data/TalentSummaries.lua"))()
assert(loadfile(root.."/data/LevelingRecommendations.lua"))()
assert(loadfile(root.."/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root.."/RankPolicy.lua"))()
assert(loadfile(root.."/TalentTooltips.lua"))()
assert(loadfile(root.."/TalentRoles.lua"))()
local sak=SkillsAlreadyKnown
local frames={}
local function frame()
 local f={shown=true,alpha=1,level=5001,scripts={}}
 function f:IsVisible() return self.shown end
 function f:GetEffectiveAlpha() return self.alpha end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:SetShown(value) self.shown=value end
 function f:SetSize(w,h) self.width,self.height=w,h end
 function f:SetBackdrop(value) self.backdrop=value end
 function f:SetBackdropBorderColor(...) self.border={...} end
 function f:SetBackdropColor(...) self.background={...} end
 function f:EnableMouse(value) self.mouse=value end
 function f:SetScript(event,callback) self.scripts[event]=callback end
 function f:HookScript(event,callback) self.scripts[event]=callback end
 function f:SetFrameStrata(value) self.strata=value end
 function f:GetFrameStrata() return 'MEDIUM' end
 function f:SetFrameLevel(value) self.level=value end
 function f:GetFrameLevel() return self.level end
 function f:GetEffectiveScale() return 0.64 end
 function f:SetScale(value) self.scale=value end
 function f:ClearAllPoints() end
 function f:SetPoint(...) self.point={...} end
 function f:CreateFontString()
  local text={}
  function text:SetText(value) self.text=value end
  function text:GetStringWidth() return 100 end
  function text:SetPoint() end
  for _,key in ipairs({'SetAllPoints','SetJustifyH','SetTextColor','SetShadowColor','SetShadowOffset'}) do text[key]=function() end end
  return text
 end
 return f
end
UIParent={GetEffectiveScale=function() return 0.64 end}
CreateFrame=function(_,_,parent) local f=frame();f.parent=parent;if parent==UIParent or parent==nil then frames[#frames+1]=f end;return f end
local titles={}
for i,name in ipairs({'Affliction','Démonologie','Destruction'}) do
 titles[i]={GetText=function() return name end,IsVisible=function() return true end}
end
local native=frame()
function native:GetRegions() return table.unpack(titles) end
function native:GetChildren() return end
PlayerSpellsFrame={TalentsFrame=native}
sak.TalentRoles.Hook()
assert(#frames==4,'One driver and three detached labels')
for i=2,4 do
 local overlay=frames[i]
 assert(overlay.shown and overlay.parent==UIParent and overlay.point[2]==titles[i-1])
 assert(overlay.text.text:find('DPS',1,true) and overlay.text.text:find('|T',1,true))
 assert(overlay.strata=='HIGH' and overlay.level==5021 and overlay.scale==1)
 assert(overlay.width==120 and overlay.height==40 and overlay.border[1]==1 and overlay.border[4]==1)
 assert(overlay.backdrop.edgeFile:find('UI-Tooltip-Border',1,true))
end
local lines={}
GameTooltip={SetOwner=function(_,owner) assert(owner==frames[2],"Tooltip must be anchored to its role label") end,AddLine=function(_,text) lines[#lines+1]=text end,Show=function() end,Hide=function() end}
frames[2].scripts.OnEnter(frames[2])
assert(table.concat(lines,' '):find('Infliger des dégâts',1,true))
assert(table.concat(lines,' '):find('Avantages',1,true) and table.concat(lines,' '):find('Inconvénients',1,true))
assert(table.concat(lines,' '):find('dégâts sur la durée',1,true))
assert(table.concat(lines,' '):find('[LEVELING]',1,true))
assert(not table.concat(lines,' '):find('En groupe :',1,true))
assert(frames[2].leveling.shown and not frames[3].leveling.shown and not frames[4].leveling.shown)
local recommendations=0
for class,data in pairs(sak.ClassRoles.classes) do
 local advice=sak.LevelingRecommendations[class]
 assert(advice and #advice.solo>0 and #advice.group>0)
 for _,kind in ipairs({'solo','group'}) do
  for _,spec in ipairs(advice[kind]) do assert(data.specializations[spec]) end
  assert(type(advice[kind..'Reason'])=='string' and #advice[kind..'Reason']>30)
 end
 assert(#advice.sources>0)
 for _,url in ipairs(advice.sources) do assert(url:find('wowhead.com/forever/',1,true)) end
 recommendations=recommendations+1
end
assert(recommendations==9)

local count=0
for class,info in pairs(sak.ClassRoles.classes) do
 for spec in pairs(info.specializations) do
  local summary=sak.TalentSummaries[class][spec]
  assert(summary and #summary.summary>100 and #summary.advantages>=2 and #summary.drawbacks>=2)
  assert(summary.source:find('wowhead.com/forever/',1,true))
  count=count+1
 end
end
assert(count==28,'All role/spec choices need a documented summary')

native.shown=false;native.scripts.OnHide();for i=2,4 do assert(not frames[i].shown) end
native.shown=true;native.scripts.OnShow();assert(frames[2].shown)
native.alpha=0;sak.TalentRoles.Refresh();assert(not frames[2].shown)
native.alpha=1;sak.TalentRoles.Refresh();assert(frames[2].shown)
sak.EnsureDB().displayOptions.text=false;sak.TalentRoles.Refresh();assert(not frames[2].shown)
sak.EnsureDB().displayOptions.text=true
class='DRUID'
local feral=sak.TalentRoles.RolesForTree(class,2)
assert(feral[1]=='tank' and feral[2]=='dps' and #feral==2)
for _,data in pairs(sak.ClassRoles.classes) do
 assert(#data.talentTrees==3)
 for _,tree in ipairs(data.talentTrees) do for _,spec in ipairs(tree.specs) do assert(data.specializations[spec]) end end
end
-- Native localized API names take precedence without relying on child order.
class='WARLOCK';GetTalentTabInfo=function(index) return index,({'Affliction EN','Demonology EN','Destruction EN'})[index] end
for i,name in ipairs({'Destruction EN','Affliction EN','Demonology EN'}) do
 titles[i].GetText=function() return name end
end
sak.TalentRoles.Refresh();assert(frames[2].shown and frames[2].point[2]==titles[2])
assert(SkillsAlreadyKnownDB.levelingProfile==nil,'Informational labels must not choose or modify player roles')
print('PASS: native header anchors, role icons/tooltips, effective scale/layering, hide/show, text setting, Feral dual role and localized titles')

sak.SetDisplayOption('iconsTalents',false)
sak.TalentRoles.Refresh();assert(not frames[2].shown)
sak.SetDisplayOption('iconsTalents',true)
sak.TalentRoles.Refresh();assert(frames[2].shown)
print('PASS: talent role category hides and restores existing labels')

sak.SetDisplayOption('outlines',false)
sak.TalentRoles.Refresh();assert(frames[2].border[4]==0 and frames[2].shown)
sak.SetDisplayOption('outlines',true)
sak.TalentRoles.Refresh();assert(frames[2].border[4]==1)
print('PASS: fitted gold role frames respect outline preferences without hiding labels')

-- Every class gets exactly one primary solo tree, with no cross-tree summary.
GetTalentTabInfo=nil
GameTooltip.SetOwner=function() end
local checkedClasses=0
for classKey,classData in pairs(sak.ClassRoles.classes) do
 class=classKey
 for index,tree in ipairs(classData.talentTrees) do
  titles[index].GetText=function() return tree.name end
 end
 sak.TalentRoles.Refresh()
 local flagged=0
 local preferred=sak.LevelingRecommendations[class].solo[1]
 local preferredSummary=sak.TalentSummaries[class][preferred].summary
 for index,tree in ipairs(classData.talentTrees) do
  local overlay=frames[index+1]
  local expected=sak.TalentTooltips.IsLevelingTree(class,tree.specs)
  assert(overlay.leveling.shown==expected)
  if expected then flagged=flagged+1 end
  lines={};sak.TalentTooltips.Show(overlay)
  local body=table.concat(lines,' ')
  assert((body:find('[LEVELING]',1,true)~=nil)==expected)
  for _,spec in ipairs(tree.specs) do assert(body:find(sak.TalentSummaries[class][spec].summary,1,true)) end
  if not expected then assert(not body:find(preferredSummary,1,true)) end
  assert(not body:find('En groupe :',1,true))
  lines={};sak.TalentTooltips.AddTreeSummary(GameTooltip,class,tree)
  body=table.concat(lines,' ')
  assert((body:find('[LEVELING]',1,true)~=nil)==expected)
  if not expected then assert(not body:find(preferredSummary,1,true)) end
 end
 assert(flagged==1,classKey..': exactly one preferred leveling tree')
 checkedClasses=checkedClasses+1
end
assert(checkedClasses==9)
sak.SetDisplayOption('icons',false);sak.TalentRoles.Refresh()
for index=2,4 do assert(not frames[index].leveling.shown) end
print('PASS: all 9 classes have one LEVELING tree; talent and spellbook tooltip paths contain only the hovered tree summaries')
