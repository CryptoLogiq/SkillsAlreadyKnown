-- Run: lua scripts/test-startup-footer.lua
local root = arg[1] or "."
local made = {}
CreateFrame = function(_, _, parent, template)
  local frame = {parent=parent, template=template, points={}, scripts={}}
  function frame:SetHeight(value) self.height=value end
  function frame:SetWidth(value) self.width=value end
  function frame:SetText(value) self.text=value end
  function frame:SetParent(value) self.parent=value end
  function frame:SetPoint(...) self.points[#self.points+1]={...} end
  function frame:ClearAllPoints() self.points={} end
  function frame:SetScript(key, callback) self.scripts[key]=callback end
  function frame:SetFrameStrata(value) self.strata=value end
  function frame:SetFrameLevel(value) self.level=value end
  function frame:SetEnabled(value) self.enabled=value end
  function frame:Hide() self.shown=false end
  function frame:Show() self.shown=true end
  function frame:IsShown() return self.shown end
  made[#made+1]=frame
  return frame
end
UIParent = {}
local ownerShown, width, valid, combat = false, 620, true, false
local owner = {
  IsShown=function() return ownerShown end,
  GetFrameStrata=function() return "FULLSCREEN_DIALOG" end,
  GetFrameLevel=function() return 100 end,
  GetWidth=function() return width end,
}
local db = {levelingDraft={}}
local closes, confirms = 0, 0
SkillsAlreadyKnown = {
  EnsureDB=function() return db end,
  Settings={CloseStartup=function() closes=closes+1 end, ConfirmSelection=function() confirms=confirms+1 end},
  PlayerRoles={SelectionSnapshot=function() if valid then return {} end end},
}
local status = {shown=true,Hide=function(self) self.shown=false end,Show=function(self) self.shown=true end}
local dialog = {OpenFrames={SkillsAlreadyKnown={frame=owner,statustext={GetParent=function() return status end}}}}
LibStub = function() return dialog end
InCombatLockdown = function() return combat end
assert(loadfile(root .. "/StartupFooter.lua"))()
local footer, driver = SkillsAlreadyKnown.StartupFooter, made[1]
footer.Refresh()
assert(#made==1 and not footer.IsVisible())
-- The frame becomes visible after the first refresh: the independent driver recovers.
ownerShown=true;driver.scripts.OnUpdate(nil,0.2)
local later, confirm = made[2], made[3]
assert(later.parent==owner and confirm.parent==owner)
assert(later.template=="UIPanelButtonTemplate" and later.height==20 and confirm.height==20)
assert(later.shown and confirm.shown and not status.shown and footer.IsVisible())
assert(later.points[1][1]=="BOTTOMLEFT" and later.points[1][5]==17)
assert(confirm.points[2][4]==-137 and later.level==103 and confirm.level==103)
local oldWidth=later.width
width=900;footer.Refresh();assert(later.width>oldWidth and #made==3)
valid=false;footer.Refresh();assert(not confirm.enabled)
valid=true;combat=true;footer.Refresh();assert(not confirm.enabled)
combat=false;footer.Refresh();assert(confirm.enabled)
later.scripts.OnClick();confirm.scripts.OnClick();assert(closes==1 and confirms==1)
dialog.OpenFrames.SkillsAlreadyKnown=nil
driver.scripts.OnUpdate(nil,0.2)
assert(not later.shown and not confirm.shown and status.shown and not footer.IsVisible())
dialog.OpenFrames.SkillsAlreadyKnown={frame=owner,statustext={GetParent=function() return status end}}
footer.Refresh();assert(later.shown and not status.shown)
db.levelingDraft=nil;footer.Refresh();assert(not later.shown and not confirm.shown)
print("PASS: native Close-style buttons, status-bar removal/restoration, delayed window show, resizing, combat, callbacks and pooled-owner cleanup")
