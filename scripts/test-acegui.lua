-- Run from the development repository: lua scripts/test-acegui.lua
local root=arg[1] or "."
local base=root.."/libs/AceGUI-3.0/"
local file=assert(io.open(base.."AceGUI-3.0.xml"));local xml=file:read("*a");file:close()
local scripts={}
for path in xml:gmatch('<Script%s+file="([^"]+)"%s*/>') do scripts[#scripts+1]=path:gsub("\\","/") end
assert(#scripts>20 and scripts[1]=="AceGUI-3.0.lua")
strmatch=string.match
local frames=0
UIParent={}
CreateFrame=function(kind,name,_,template)
  frames=frames+1
  assert(kind=="GameTooltip" and name=="AceGUITooltip" and template=="GameTooltipTemplate", "Unexpected window during library initialization")
  return {}
end
local function loadGUI()
  for _,path in ipairs(scripts) do assert(loadfile(base..path))() end
end
LibStub=nil
assert(loadfile(root.."/libs/LibStub/LibStub.lua"))()
loadGUI()
local gui,minor=LibStub("AceGUI-3.0")
assert(minor==41 and frames==1)
for _,kind in ipairs({"Frame","Window","Button","CheckBox","TabGroup","TreeGroup","Dropdown","Slider","EditBox","Label"}) do
  assert(type(gui.WidgetRegistry[kind])=="function", "Missing widget: "..kind)
end
local tooltip,create,button,pool=gui.tooltip,gui.Create,gui.WidgetRegistry.Button,gui.objPools
loadGUI()
assert(LibStub("AceGUI-3.0")==gui and gui.tooltip==tooltip and gui.Create==create and frames==1)
assert(gui.WidgetRegistry.Button==button and gui.objPools==pool)
print("PASS: standalone XML loads the core and widgets; equal versions do not reinitialize the core or widget constructors")
-- A newer shared core and widget supplied by another addon must remain intact.
LibStub:NewLibrary("AceGUI-3.0",42)
local futureButton=function() end
gui.WidgetRegistry.Button=futureButton;gui.WidgetVersions.Button=999
loadGUI()
local shared,version=LibStub("AceGUI-3.0")
assert(shared==gui and version==42 and gui.Create==create and gui.WidgetRegistry.Button==futureButton and frames==1)
print("PASS: newer shared core and widget reused without downgrade")
-- An older version upgrades the same shared library and keeps compatible pools.
LibStub.minors["AceGUI-3.0"]=40
gui.WidgetVersions.Button=23
gui.customSentinel="shared addon state"
loadGUI()
shared,version=LibStub("AceGUI-3.0")
assert(shared==gui and version==41 and gui.customSentinel=="shared addon state")
assert(gui.tooltip==tooltip and gui.objPools==pool and frames==1)
assert(gui.WidgetVersions.Button==24 and gui.WidgetRegistry.Button~=futureButton)
print("PASS: older core and widget upgraded in place with shared state preserved")
