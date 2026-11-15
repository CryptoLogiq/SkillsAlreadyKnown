SkillsAlreadyKnown=nil;SkillsAlreadyKnownDB=nil
GetLocale=function()return 'frFR'end
UnitClass=function()return 'Mage','MAGE',8 end
local slots={[1]={'spell',10},[13]={'spell',11},[20]={'macro',1}}
GetActionInfo=function(slot)local v=slots[slot];if v then return v[1],v[2]end end
GetMacroSpell=function()return 11 end
local made={}
local function frame(_,_,parent)
 local f={parent=parent,shown=true,scripts={},events={},width=40,height=40}
 function f:IsVisible()return self.shown end
 function f:GetWidth()return self.width end
 function f:GetHeight()return self.height end
 function f:GetEffectiveAlpha()return self.alpha or 1 end
 function f:GetFrameLevel()return 10 end
 function f:Show()self.shown=true end
 function f:Hide()self.shown=false;if self.scripts.OnHide then self.scripts.OnHide(self)end end
 function f:RegisterEvent(e)self.events[e]=true end
 function f:SetScript(k,fn)self.scripts[k]=fn end
 function f:HookScript(k,fn)local prev=self.scripts[k];self.scripts[k]=function(...)if prev then prev(...)end;fn(...)end end
 function f:CreateTexture()local t=frame();self.textures=self.textures or{};self.textures[#self.textures+1]=t;return t end
 function f:SetVertexColor(r,g,b,a)self.color={r,g,b,a}end
 function f:SetPoint(...)self.point={...}end
 for _,k in ipairs({'EnableMouse','SetTexture','SetBlendMode','SetSize','ClearAllPoints','SetFrameLevel','SetAlpha'})do f[k]=function()end end
 made[#made+1]=f;return f
end
CreateFrame=frame;UIParent=frame()
dofile('Core.lua');dofile('traductions/fr_FR.lua');dofile('traductions/en-EN.lua');dofile('Localization.lua')
local s=SkillsAlreadyKnown
SkillsAlreadyKnownDB={language='en-EN',recentLearning={spells={[10]={rank=1},[11]={rank=2}},recipes={},talents={},pets={}}}
s.Localization.Initialize()
dofile('RecentLearning.lua')
local queued=0
s.SpellBook={PrepareOverlay=function()end,QueueRefresh=function()queued=queued+1 end,StateForSpell=function()end}
dofile('RecentSparkles.lua');dofile('UnusedSpells.lua')
local u,r=s.UnusedSpells,s.RecentLearning
ActionButton1=frame();ActionButton1.action=1;ActionButton1.icon=frame()
EABButton1=frame();EABButton1.GetAttribute=function()return 13 end;EABButton1.Icon=frame()
MultiBarRightButton1=frame();MultiBarRightButton1.action=20;MultiBarRightButton1.icon=frame()
u.Initialize();local events=made[#made]
assert(events.events.UNIT_SPELLCAST_SUCCEEDED and not events.events.UNIT_SPELLCAST_FAILED)
local captured={};local real=s.RecentSparkles.PaintIcon
s.RecentSparkles.PaintIcon=function(owner,icon,show,zone,style)captured[owner]={show=not not show,icon=icon,zone=zone,style=style};return real(owner,icon,show,zone,style)end
u.Refresh()
assert(captured[ActionButton1].show and captured[EABButton1].show and captured[MultiBarRightButton1].show)
assert(captured[EABButton1].icon==EABButton1.Icon)
assert(captured[ActionButton1].style.color[3]==1 and captured[ActionButton1].style.color[1]<0.5)
assert(u.ShouldExplain(10))
local parent,owner,icon=frame(),frame(),frame()
s.RecentSparkles.Paint(parent,owner,icon,{id=10})
local host;for _,f in ipairs(made)do if f.parent==parent then host=f end end
assert(host.shown and host.textures[1].color[3]==1,'Assigned unused spells are blue in the book too')
events.scripts.OnEvent(events,'UNIT_SPELLCAST_SUCCEEDED','pet','cast',10)
assert(r.IsUnused(10),'Pet casts do not consume player hints')
events.scripts.OnEvent(events,'UNIT_SPELLCAST_SUCCEEDED','player','cast',999)
assert(r.IsUnused(10),'Unrelated casts do not mark another spell used')
events.scripts.OnEvent(events,'UNIT_SPELLCAST_SUCCEEDED','player','cast',10)
assert(not r.IsUnused(10) and r.IsUnused(11),'Ranks remain independent')
assert(not captured[ActionButton1].show and captured[EABButton1].show)
host.scripts.OnUpdate(host,0.2);assert(not host.shown)
assert(r.Contains('spells',10) and SkillsAlreadyKnownDB.recentLearning.spells[10].used)
dofile('RecentLearning.lua');assert(not s.RecentLearning.IsUnused(10),'Used status persists across reload')
s.SetDisplayOption('iconsActionBars',false);u.Refresh();assert(not captured[EABButton1].show)
s.SetDisplayOption('iconsActionBars',true);s.SetDisplayOption('recent',false);u.Refresh();assert(not captured[EABButton1].show)
s.SetDisplayOption('recent',true)
-- Exercise the real SetAction tooltip path, including a recognized macro.
local hooks={}
GameTooltip={SetAction=function()end,HookScript=function()end}
hooksecurefunc=function(_,name,callback)hooks[name]=callback end
local function tip()local t={lines={},scripts={}};function t:AddLine(line)self.lines[#self.lines+1]=line end;function t:HookScript(k,fn)self.scripts[k]=fn end;return t end
dofile('SpellTooltips.lua');s.SpellTooltips.Hook()
local t=tip();hooks.SetAction(t,20)
assert(table.concat(t.lines,' '):find('no successful use recorded',1,true))
local count=#t.lines;hooks.SetAction(t,20);assert(#t.lines==count)
t.scripts.OnTooltipCleared(t);t.lines={}
u.HandleCast('player','success',11);hooks.SetAction(t,20)
assert(not table.concat(t.lines,' '):find('no successful use recorded',1,true))
assert(s.RecentLearning.Contains('spells',11),'Using a spell retains RECENT')
print('PASS: persisted first successful player use, independent ranks, Blizzard/Ellesmere/macro buttons, blue book color, category controls and actual action-tooltip explanation')

-- Forms/stances/auras live outside ordinary action slots, including Ellesmere's
-- reused StanceButtons. Their own native IDs take precedence over action fields.
SkillsAlreadyKnownDB.recentLearning.spells[31]={rank=2}
SkillsAlreadyKnownDB.recentLearning.spells[40]={rank=1}
s.SpellBook.StateForSpell=function(id)if id==30 then return {highestID=31}end end
local forms=true
GetNumShapeshiftForms=function()return forms and 2 or 0 end
GetShapeshiftFormInfo=function(index)
 if index==1 then return 100,false,true,30 end
 if index==2 then return 200,'Legacy form',false,true,40 end
end
StanceButton1=frame();StanceButton1.Icon=frame();StanceButton1.action=9999
StanceButton2=frame();StanceButton2.icon=frame()
s.RecentSparkles.Invalidate()
assert(s.RecentSparkles.IsAssigned(31) and s.RecentSparkles.IsAssigned(40))
assert(u.StanceSpell(1)==31 and u.StanceSpell(2)==40)
u.Refresh()
assert(captured[StanceButton1].show and captured[StanceButton1].icon==StanceButton1.Icon)
assert(captured[StanceButton2].show)
GameTooltip.SetShapeshift=function()end
s.SpellTooltips.Hook()
local formTip=tip();hooks.SetShapeshift(formTip,1)
assert(table.concat(formTip.lines,' '):find('no successful use recorded',1,true))
u.HandleCast('player','success',31)
assert(not captured[StanceButton1].show and captured[StanceButton2].show)
forms=false;s.RecentSparkles.Invalidate();u.Refresh()
assert(not captured[StanceButton2].show and not s.RecentSparkles.IsAssigned(40),'Removed form buttons must not retain effects or bar membership')
GetShapeshiftFormInfo=nil
assert(u.StanceCount()==0 and u.StanceSpell(1)==nil)
print('PASS: native/Ellesmere stance bars, modern/legacy form APIs, automatic learned aura ranks, stance tooltips and removed-form cleanup')
