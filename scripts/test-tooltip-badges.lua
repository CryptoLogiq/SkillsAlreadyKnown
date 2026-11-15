local options={}
local frames={}
local function frame()
 local f={shown=false,hooks={}}
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:SetPoint(...) self.point={...} end
 function f:ClearAllPoints() end
 function f:SetSize(w,h) self.width,self.height=w,h end
 function f:SetFrameStrata(value) self.strata=value end
 function f:SetFrameLevel(value) self.level=value end
 function f:EnableMouse() end
 function f:SetClampedToScreen(value) self.clamped=value end
 function f:SetScale() end
 function f:SetParent() end
 function f:SetTexture(value) self.texture=value end
 function f:CreateTexture() return frame() end
 function f:HookScript(key,fn) self.hooks[key]=fn end
 function f:SetScript(key,fn) self.hooks[key]=fn end
 frames[#frames+1]=f
 return f
end
CreateFrame=function(_,_,parent) local f=frame();f.parent=parent;return f end
UnitClass=function() return 'Warlock','WARLOCK' end
UIParent={GetTop=function() return 1000 end,GetEffectiveScale=function() return 1 end}
SkillsAlreadyKnown={
 DisplayEnabled=function(key) return options[key]~=false end,
 SPELLBOOK_BADGES={best={texture='best',width=40,height=16},optional={texture='optional',width=64,height=16}},
 SpellUsage={ForSpell=function(_,id) if id==1120 then return {tag='class',spellID=id} end end},
 RecentLearning={Contains=function(kind,id) return kind=='pets' and id==1120 end},
 ContentTags={CreateBadge=frame,PrepareBadge=function(display,_,entry) display.entry=entry end,
 BadgeWidth=function(tag) return tag=='class' and 44 or 58 end},
}
dofile('TooltipBadges.lua')
local badges=SkillsAlreadyKnown.TooltipBadges
local state={kind='best',optionalReason='optional'}
local specs=badges.Collect(1120,state)
assert(#specs==4 and specs[1].texture=='best' and specs[2].texture=='optional' and specs[3].tag=='class' and specs[4].tag=='recent')
options.class=false;assert(#badges.Collect(1120,state)==3);options.class=true
options.iconsTooltips=false;assert(#badges.Collect(1120,state)==0);options.iconsTooltips=true
local tip=frame()
local top=500
function tip:GetTop() return top end
function tip:GetWidth() return 120 end
function tip:GetFrameLevel() return 10 end
function tip:GetEffectiveScale() return 1 end
local before=#frames
badges.Paint(tip,1120,state)
local strip=frames[before+1]
assert(strip.shown and strip.parent==tip and strip.strata=='TOOLTIP' and strip.level==30)
assert(strip.point[1]=='BOTTOMLEFT' and strip.point[3]=='TOPLEFT' and strip.point[5]==-3)
assert(strip.height>20,'Wrap badges to the tooltip width')
local count=#frames
badges.Paint(tip,1120,state);assert(#frames==count,'Reuse all badge frames')
top=995;strip.hooks.OnUpdate(nil,0.1)
assert(strip.point[1]=='TOPLEFT' and strip.point[3]=='BOTTOMLEFT','Avoid clipping at the top of the screen')
tip.hooks.OnTooltipCleared();assert(not strip.shown and not strip.id)
badges.Paint(tip,1120,state);tip.hooks.OnHide();assert(not strip.shown)
badges.Paint(tip,1120,state);options.icons=false;strip.hooks.OnUpdate(nil,0.1);assert(not strip.shown)
options.icons=true
badges.Paint(tip,9999,nil);assert(not strip.shown,'Unrelated spells must not inherit badges')
print('PASS: tooltip badge order, usage/recent preferences, wrapped layout, scaling/layering, edge placement, frame reuse and hide/clear cleanup')

SkillsAlreadyKnown.isDev=true
options.icons=false;options.iconsTooltips=false
local dev=badges.Collect(9999,nil)
assert(#dev==1 and dev[1].tag=='dev','DEV identity remains visible with appearance disabled')
badges.Paint(tip,9999,nil)
assert(strip.shown)
SkillsAlreadyKnown.isDev=false
badges.Paint(tip,9999,nil);assert(not strip.shown,'The official copy must never show DEV')
options.icons=true;options.iconsTooltips=true
SkillsAlreadyKnown.isDev=true
assert(badges.Collect(1120,state)[1].tag=='dev')
print('PASS: runtime DEV identity, first badge placement, appearance independence and official-copy exclusion')
