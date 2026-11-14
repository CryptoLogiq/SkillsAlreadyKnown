-- Run from the development repository: lua scripts/test-bundled-libs.lua
local root=arg[1] or "."
local stub=root.."/libs/LibStub/LibStub.lua"
local glow=root.."/libs/LibButtonGlow-1.0/LibButtonGlow-1.0.lua"
strmatch=string.match -- WoW's string alias used by upstream LibStub.
CreateFrame=function() error("Library loading must not create UI frames") end
local function fresh()
  LibStub=nil
  assert(loadfile(stub))()
end
fresh()
local sharedStub, newLibrary=LibStub,LibStub.NewLibrary
assert(loadfile(stub))()
assert(LibStub==sharedStub and LibStub.NewLibrary==newLibrary)
assert(loadfile(glow))()
local lib,minor=LibStub("LibButtonGlow-1.0")
assert(minor==7 and type(lib.ShowOverlayGlow)=="function" and type(lib.HideOverlayGlow)=="function")
local show,overlays=lib.ShowOverlayGlow,lib.unusedOverlays
assert(loadfile(glow))()
assert(LibStub("LibButtonGlow-1.0")==lib and lib.ShowOverlayGlow==show and lib.unusedOverlays==overlays)
print("PASS: standalone initialization and equal-version skip without duplicate state")
fresh()
local newer=LibStub:NewLibrary("LibButtonGlow-1.0",8)
local marker=function() end
newer.ShowOverlayGlow=marker;newer.marker="existing newer copy"
assert(loadfile(glow))()
local active,version=LibStub("LibButtonGlow-1.0")
assert(active==newer and version==8 and active.ShowOverlayGlow==marker and active.marker=="existing newer copy")
assert(active.HideOverlayGlow==nil,"Older bundled code must not initialize a newer copy")
print("PASS: newer library provided by another addon is reused untouched")
fresh()
local older=LibStub:NewLibrary("LibButtonGlow-1.0",6)
older.marker="shared state";older.unusedOverlays={};older.numOverlays=4
local pool=older.unusedOverlays
assert(loadfile(glow))()
active,version=LibStub("LibButtonGlow-1.0")
assert(active==older and version==7 and active.marker=="shared state")
assert(active.unusedOverlays==pool and active.numOverlays==4 and type(active.ShowOverlayGlow)=="function")
print("PASS: older shared library upgraded in place, preserving its table and pool")
-- The addon should use the library even when native functions also exist.
SkillsAlreadyKnown={}
assert(loadfile(root.."/Glow.lua"))()
local selected
LibStub=function() return {ShowOverlayGlow=function() selected="library" end,HideOverlayGlow=function() end} end
ActionButton_ShowOverlayGlow=function() error("Should prefer shared library") end
ActionButton_HideOverlayGlow=function() end
CreateFrame=function() return {EnableMouse=function() end,SetFrameLevel=function() end,
 SetPoint=function() end,HookScript=function() end,SetSize=function() end,Show=function() end} end
local row={GetFrameLevel=function() return 1 end}
SkillsAlreadyKnown.Glow.SetBadge(row,{},"new",40,14)
assert(selected=="library" and row.sakTrainerGlow.mode=="LibButtonGlow")
print("PASS: shared library selected before native glow")
