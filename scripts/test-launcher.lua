-- Run: lua scripts/test-launcher.lua
local root = arg[1] or "."
strmatch = string.match
securecallfunction = function(callback, ...) return callback(...) end
assert(loadfile(root .. "/libs/LibStub/LibStub.lua"))()
assert(loadfile(root .. "/libs/CallbackHandler-1.0/CallbackHandler-1.0.lua"))()
assert(loadfile(root .. "/libs/LibDataBroker-1.1/LibDataBroker-1.1.lua"))()
local broker = LibStub("LibDataBroker-1.1")
local frames = 0
CreateFrame = function()
  frames = frames + 1
  return {SetScript=function() end, RegisterEvent=function() end}
end
Minimap = {HookScript=function() end}
assert(loadfile(root .. "/libs/LibDBIcon-1.0/LibDBIcon-1.0.lua"))()
local icons = LibStub("LibDBIcon-1.0")
local count = frames
assert(loadfile(root .. "/libs/LibDBIcon-1.0/LibDBIcon-1.0.lua"))()
assert(frames == count, "Equal shared library must not initialize again")
local newer = LibStub:NewLibrary("LibDBIcon-1.0", 999)
assert(loadfile(root .. "/libs/LibDBIcon-1.0/LibDBIcon-1.0.lua"))()
assert(LibStub("LibDBIcon-1.0") == newer and frames == count)
-- Keep the real broker/callback registry; replace only minimap frame rendering.
local registered, shown, registrations, refreshes = false, false, 0, 0
function icons:IsRegistered() return registered end
function icons:Register(name, object, db)
  registrations = registrations + 1
  registered = true
  self.saved, self.object = db, object
end
function icons:Show() shown = true end
function icons:Hide() shown = false end
function icons:Refresh(_, db) assert(db == self.saved); refreshes = refreshes + 1 end
local db = {}
local options, summaries = 0, 0
SkillsAlreadyKnown = {
  EnsureDB=function() return db end,
  RankPolicy={ShowSettings=function() options=options+1 end},
  ShowSummaryWindow=function() summaries=summaries+1 end,
}
local created = 0
local listener = {}
broker.RegisterCallback(listener, "LibDataBroker_DataObjectCreated", function() created = created + 1 end)
assert(loadfile(root .. "/Launcher.lua"))()
local launcher = SkillsAlreadyKnown.Launcher
launcher.Initialize(); launcher.Initialize()
assert(registrations == 1 and created == 1 and shown)
local object = broker:GetDataObjectByName("SkillsAlreadyKnown")
assert(object.type == "launcher" and object.icon and object.OnTooltipShow)
assert(object.label == "Skills & More" and object.text == "Skills & More")
local tooltipLines = {}
object.OnTooltipShow({ AddLine = function(_, line) tooltipLines[#tooltipLines + 1] = line end })
assert(tooltipLines[1] == "Skills & More" and tooltipLines[2] == "By CryptoLogiq")
object.OnClick(nil, "LeftButton"); object.OnClick(nil, "RightButton")
assert(options == 1 and summaries == 1)
launcher.SetVisible(false)
assert(not shown and not launcher.IsVisible())
assert(broker:GetDataObjectByName("SkillsAlreadyKnown") == object)
local saved = db.minimap
saved.minimapPos = 88
launcher.ResetDefaults()
assert(shown and db.minimap == saved and saved.minimapPos == 220 and refreshes == 1)
launcher.SetVisible(false)
launcher.Initialize()
assert(not shown and registrations == 1)
SkillsAlreadyKnown = {disabledByDev=true}
assert(loadfile(root .. "/Launcher.lua"))()
assert(SkillsAlreadyKnown.Launcher == nil)
print("PASS: upstream library load/reuse, broker discovery callback, single registration, clicks, visibility, reset and inactive official guard")
