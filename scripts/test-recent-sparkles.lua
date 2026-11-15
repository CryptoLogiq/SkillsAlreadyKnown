local options, recent, actions, macros = {},{[10]=true,[11]=true},{},{}
local made, queued, reads = {},0,0
local function frame(_,_,parent,template)
 local f={parent=parent,template=template,shown=true,scripts={},width=40,height=40}
 function f:IsVisible()return self.shown and (not self.parent or self.parent:IsVisible())end
 function f:GetEffectiveAlpha()return self.alpha or 1 end
 function f:Show()self.shown=true end
 function f:Hide()self.shown=false;if self.scripts.OnHide then self.scripts.OnHide(self)end end
 function f:GetWidth()return self.width end
 function f:GetHeight()return self.height end
 function f:GetFrameLevel()return 20 end
 function f:RegisterEvent(event)self.events=self.events or{};self.events[event]=true end
 function f:SetScript(key,fn)self.scripts[key]=fn end
 function f:HookScript(key,fn)
  local prev=self.scripts[key];self.scripts[key]=function(...)if prev then prev(...)end;fn(...)end
 end
 for _,key in ipairs({'EnableMouse','ClearAllPoints','SetPoint','SetFrameLevel','SetTexture','SetBlendMode','SetVertexColor','SetSize','SetAlpha'})do f[key]=function()end end
 function f:ClearAllPoints()self.points={}end
 function f:SetPoint(...)self.points=self.points or{};self.points[#self.points+1]={...}end
 function f:CreateTexture()return frame()end
 made[#made+1]=f;return f
end
CreateFrame=frame
UIParent=frame()
GetActionInfo=function(slot)reads=reads+1;local a=actions[slot];if a then return a[1],a[2]end end
GetMacroSpell=function(id)return macros[id]end
SkillsAlreadyKnown={DisplayEnabled=function(key)return options[key]~=false end,
 RecentLearning={Contains=function(kind,id)return kind=='spells' and recent[id]end},
 SpellBook={QueueRefresh=function()queued=queued+1 end}}
dofile('RecentSparkles.lua')
local s=SkillsAlreadyKnown.RecentSparkles
local parent,owner,icon=frame(),frame(),frame()
actions[160]={'spell',10}
s.Paint(parent,owner,icon,{id=10})
local driver=made[#made]
assert(driver.events.ACTIONBAR_SLOT_CHANGED,'Subscribe even if the first spell is already on a bar')
assert(s.IsAssigned(10))
local n=reads;s.IsAssigned(11);assert(reads==n,'Do not rescan every visible spell on every frame')
actions[160]=nil;driver.scripts.OnEvent();assert(queued==1)
s.Paint(parent,owner,icon,{id=10})
local host
for _,f in ipairs(made)do if f.parent==parent then host=f end end
assert(host and host.shown and host.stars and #host.stars==4)
host.scripts.OnUpdate(host,0.2)
actions[160]={'spell',10};driver.scripts.OnEvent();host.scripts.OnUpdate(host,0.2)
assert(not host.shown,'Adding to an inactive bar page stops particles')
actions[160]=nil;s.Invalidate();s.Paint(parent,owner,icon,{id=10});assert(host.shown)
owner.alpha=0;host.scripts.OnUpdate(host,0.2);assert(not host.shown,'Foreign transparent tabs stop the effect')
owner.alpha=1
for _,key in ipairs({'icons','iconsSpellbook','recent','recentSparkles'})do
 options[key]=false;s.Paint(parent,owner,icon,{id=10});assert(not host.shown);options[key]=true
end
s.Paint(parent,owner,icon,{id=999});assert(not host.shown)
s.Paint(parent,owner,icon,{id=10,pet=true});assert(not host.shown)
actions[8]={'macro',1};macros[1]=10;s.Invalidate();assert(s.IsAssigned(10),'Recognized macro counts as a bar placement')
macros[1]=11;s.Invalidate();assert(not s.IsAssigned(10),'Do not confuse different learned rank IDs')
GetActionInfo=nil;s.Invalidate();assert(s.IsAssigned(10)==nil,'Unknown action APIs must fail closed')
C_ActionBar={FindSpellActionButtons=function(id)if id==10 then return{2}else return{}end end}
assert(s.IsAssigned(10)and s.IsAssigned(11)==false)
-- Exercise the guarded native effect rather than replacing its animation script.
local starts,stops=0,0
AutoCastShine_AutoCastStart=function()starts=starts+1 end
AutoCastShine_AutoCastStop=function()stops=stops+1 end
local second=frame();s.Paint(second,owner,icon,{id=11})
local native=made[#made];assert(native.native and starts==1)
s.Paint(second,owner,icon,{id=11});assert(starts==1,'Reuse running native particles')
options.recentSparkles=false;s.Paint(second,owner,icon,{id=11});assert(not native.shown and stops>0)
print('PASS: RECENT-only particles, inactive bar pages, exact ranks, recognized macros, cache invalidation, no unknown/passive pet effects, preferences, visibility and native/fallback engines')

-- The shared learning effect must surround the icon, never the entire row/tooltip.
SkillsAlreadyKnown.SpellBook.PrepareOverlay=function(host,owner)host.preparedFor=owner end
local row, itemIcon=frame(),frame();row.width=400
s.PaintIcon(row,itemIcon,true,'iconsMerchant')
local itemHost=made[#made]
assert(itemHost.preparedFor==row and itemHost.parent==UIParent)
assert(itemHost.points[1][2]==itemIcon and itemHost.points[2][2]==itemIcon)
assert(itemHost.points[1][1]=='TOPLEFT' and itemHost.points[2][1]=='BOTTOMRIGHT')
local total=#made;s.PaintIcon(row,itemIcon,true,'iconsMerchant');assert(#made==total)
options.iconsMerchant=false;itemHost.scripts.OnUpdate(itemHost,0.2);assert(not itemHost.shown)
options.iconsMerchant=true;s.PaintIcon(row,itemIcon,true,'iconsTrainer');assert(itemHost.shown)
s.PaintIcon(row,itemIcon,false,'iconsTrainer');assert(not itemHost.shown)
s.PaintIcon(row,itemIcon,true,'iconsLoot');options.learningSparkles=false
itemHost.scripts.OnUpdate(itemHost,0.2);assert(not itemHost.shown)
print('PASS: shared trainer/merchant/loot sparkle uses icon bounds, no tooltip/row-sized effects, recycling and independent controls')
