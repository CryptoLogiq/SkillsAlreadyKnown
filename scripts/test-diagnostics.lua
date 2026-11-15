-- Run from the development repository: lua scripts/test-diagnostics.lua
local root = arg[1] or "."
local diagnosticsFile = root .. "/Diagnostics.lua"
local function contains(text, needle)
  assert(text:find(needle, 1, true), "Missing: " .. needle)
end
local function absent(text, needle)
  assert(not text:find(needle, 1, true), "Unexpected: " .. needle)
end
local frames
local function setup(legacy, transform)
  SkillsAlreadyKnown, SkillsAlreadyKnown_dev = nil, nil
  BugGrabber, EUI_Bags, ClassTrainerFrame, MerchantFrame, ContainerFrameCombinedBags = nil, nil, nil, nil, nil
  SLASH_OTHER1, SLASH_SKILLSALREADYKNOWN1, SLASH_SKILLSALREADYKNOWN2 = nil, nil, nil
  C_AddOns, GetNumAddOns, GetAddOnInfo, IsAddOnLoaded, GetAddOnMetadata = nil, nil, nil, nil, nil
  UnitName, UnitClass, UnitLevel, GetBuildInfo, GetLocale = nil, nil, nil, nil, nil
  local names = { "AlreadyKnown", "Bagnon", "DisabledAddon" }
  local api = {
    GetNumAddOns = function() return #names end,
    GetAddOnInfo = function(i) return legacy and names[i] or {name=names[i]} end,
    IsAddOnLoaded = function(name) return name == "AlreadyKnown" or name == "Bagnon" end,
    GetAddOnMetadata = function(name, field) assert(field=="Version"); return "1.2.3" end,
  }
  if legacy then for key, fn in pairs(api) do _G[key]=fn end else C_AddOns=api end
  frames = {}
  CreateFrame = function()
    local frame = { events={} }
    function frame:RegisterEvent(event) self.events[event]=true end
    function frame:SetScript(_, fn) self.handler=fn end
    frames[#frames+1]=frame
    return frame
  end
  GetTime = function() return 42 end
  seterrorhandler = function() error("Must not replace the global error handler") end
  SetCVar = function() error("Must not change client settings") end
  SlashCmdList = {}
  local sak = { CleanText=function(text) return text end, Refresh=function() end }
  local name = transform and "SkillsAlreadyKnown_dev" or "SkillsAlreadyKnown"
  _G[name]=sak
  if transform then
    local file=assert(io.open(diagnosticsFile)); local text=file:read("*a"); file:close()
    assert((loadstring or load)(text:gsub("SkillsAlreadyKnown", "SkillsAlreadyKnown_dev"), "Diagnostics.lua"))(name)
  else assert(loadfile(diagnosticsFile))(name) end
  return sak, sak.Diagnostics
end

for _, legacy in ipairs({false,true}) do
  local sak, diag=setup(legacy)
  local text=diag.BuildText()
  contains(text,"addon=AlreadyKnown version=1.2.3")
  contains(text,"shared UI: known-item markers; not proof of a conflict")
  absent(text,"addon=DisabledAddon")
  absent(text,"[DETECTED]")
  assert(frames[1].events.ADDON_ACTION_BLOCKED and frames[1].events.ADDON_ACTION_FORBIDDEN)
  frames[1].handler(nil,"ADDON_ACTION_BLOCKED","AnotherAddon","UseAction()")
  frames[1].handler(nil,"ADDON_ACTION_BLOCKED","AnotherAddon","UseAction()")
  contains(diag.BuildText(),"count=2 kind=ADDON_ACTION_BLOCKED detail=addon=AnotherAddon action=UseAction()")
  local fn=function() end; sak.slashHandler=fn; SlashCmdList.SKILLSALREADYKNOWN=fn
  absent(diag.BuildText(),"handler was replaced")
  SlashCmdList.SKILLSALREADYKNOWN=function() end
  contains(diag.BuildText(),"handler was replaced")
  SLASH_OTHER1="/sam"; contains(diag.BuildText(),"SLASH_OTHER1=/sam")
  SkillsAlreadyKnown_dev={Refresh=function() end}
  contains(diag.BuildText(),"[DETECTED] Both copies initialized")
  SkillsAlreadyKnown_dev.disabledByDev=true
  absent(diag.BuildText(),"[DETECTED] Both copies initialized")
  sak.Inventory={GetDiagnostics=function() return {available=true,registered=true,callbackIntact=false,trackedButtons=3} end}
  contains(diag.BuildText(),"overlay callback is missing or replaced")
  print("PASS: " .. (legacy and "legacy" or "modern") .. " APIs, observations, command replacement, double initialization, callback loss")
end

local sak, diag=setup()
C_AddOns=nil
contains(diag.BuildText(),"Addon enumeration unavailable")
for i=1,40 do diag.Record("test", "entry=" .. i) end
local text=diag.BuildText()
absent(text,"detail=entry=1\n"); contains(text,"detail=entry=40")
local _, entries=text:gsub("kind=test",""); assert(entries==25)
BugGrabber={
  GetSessionId=function() return 5 end,
  GetDB=function() return {
    {session=4,message="SkillsAlreadyKnown old error"},
    {session=5,message="Unrelated error",stack="UnrelatedAddon/file.lua"},
    {session=5,message="current failure",stack="SkillsAlreadyKnown/Inventory.lua"},
  } end,
}
text=diag.BuildText()
contains(text,"Lua error: current failure")
absent(text,"old error"); absent(text,"Lua error: Unrelated error")
BugGrabber.GetDB=function() error("optional integration unavailable") end
contains(diag.BuildText(),"BugGrabber session unavailable")
print("PASS: missing APIs, bounded log, session filtering, optional integration failures")

sak,diag=setup(false,true)
SkillsAlreadyKnown={Refresh=function() end}
contains(diag.BuildText(),"officialActive=true devActive=true")
contains(diag.BuildText(),"[DETECTED] Both copies initialized")
print("PASS: staged DEV namespace detects the actual official copy")

sak,diag=setup()
-- Exercise the real export function and slash-command routing.
assert(loadfile(root .. "/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
local report=sak.DebugTextToReport("Trainer", "trainer detail")
contains(report,"trainer detail"); contains(report,"SAM compatibility report")
report=sak.DebugTextToReport("Conflicts", diag.BuildText())
local _, occurrences=report:gsub("SAM compatibility report", "")
assert(occurrences==1)
local opened
sak.ShowDebugTextWindow=function(key, _, text) opened=key; contains(text,"SAM compatibility report") end
assert(loadfile(root .. "/DevTools.lua"))()
sak.DevTools.SetEnabled(true)
assert(loadfile(root .. "/Main.lua"))()
assert(loadfile(root .. "/Events.lua"))()
SlashCmdList.SKILLSALREADYKNOWN("conflicts")
assert(opened=="Conflicts" and sak.slashHandler==SlashCmdList.SKILLSALREADYKNOWN)
opened=nil
SlashCmdList.SKILLSALREADYKNOWN=function() error("replaced by another addon") end
SlashCmdList.SKILLSALREADYKNOWNCONFLICTS()
assert(opened=="Conflicts")
print("PASS: debug exports include diagnostics once; /sam conflicts opens the report")

-- Errors previously hidden by protected scans are now observable.
ClassTrainerFrame={ScrollBox={IsVisible=function() return true end,
  ForEachFrame=function() error("test trainer paint failure") end}}
sak.Visuals={}
assert(loadfile(root .. "/ClassTrainer.lua"))()
sak.ClassTrainer.Refresh()
contains(diag.BuildText(), "kind=Trainer row paint error")
sak.EnsureScanTooltip=function() return {
  ClearLines=function() end, SetHyperlink=function() error("test item scan failure") end,
} end
GetItemInfo=function() return "Test item" end
assert(loadfile(root .. "/PetGrimoires.lua"))()
sak.PetGrimoires.ItemInfoFromLink("item:123")
contains(diag.BuildText(), "kind=Item tooltip scan error")
SkillsAlreadyKnown={disabledByDev=true}
local before=#frames
assert(loadfile(diagnosticsFile))("SkillsAlreadyKnown")
assert(SkillsAlreadyKnown.Diagnostics==nil and #frames==before)
print("PASS: protected scan errors recorded; inactive official copy registers no diagnostics")

assert(SLASH_SKILLSALREADYKNOWN2 == "/sam", "Primary short command must be /sam")
assert(SLASH_SKILLSALREADYKNOWNCONFLICTS1 == "/samconflicts", "Dedicated support alias follows /sam")

assert(SLASH_SKILLSALREADYKNOWN1 == "/skillsandmore")
assert(SLASH_SKILLSALREADYKNOWN3 == "/skillsalreadyknown", "Preserve legacy alias")
