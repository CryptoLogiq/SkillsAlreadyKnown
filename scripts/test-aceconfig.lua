-- Run from the development repository: lua scripts/test-aceconfig.lua
local root = arg[1] or "."
unpack = unpack or table.unpack
strmatch = string.match
wipe = function(t) for k in pairs(t) do t[k] = nil end; return t end
GetLocale = function() return "enUS" end
UIParent = {}
local frames = 0
CreateFrame = function()
  frames = frames + 1
  local f = { scripts = {} }
  function f:GetScript(k) return self.scripts[k] end
  function f:SetScript(k,v) self.scripts[k]=v end
  function f:Hide() end
  function f:SetPoint() end
  function f:SetFrameStrata() end
  for _,method in ipairs({"SetSize","EnableMouse","SetFrameLevel","SetBackdrop","SetBackdropColor","SetBackdropBorderColor","SetText","SetWidth","SetHeight","SetNormalFontObject","SetHighlightFontObject","SetDisabledFontObject","SetNormalTexture","SetPushedTexture","SetHighlightTexture","SetAllPoints","SetVertexColor","SetTexture","SetFontObject","SetJustifyH","SetJustifyV"}) do f[method]=function() end end
  function f:CreateTexture() return CreateFrame() end
  function f:CreateFontString() return CreateFrame() end
  function f:SetFixedFrameStrata() end
  function f:SetFixedFrameLevel() end
  function f:SetTexCoord() end
  function f:GetNormalTexture() return self end
  function f:GetPushedTexture() return self end
  function f:GetHighlightTexture() return self end
  return f
end
LibStub = nil
assert(loadfile(root .. "/libs/LibStub/LibStub.lua"))()
local function xml(path)
  local f=assert(io.open(path));local contents=f:read("*a");f:close()
  contents=contents:gsub("<!%-%-.-%-%->", "")
  local dir=path:match("^(.*)/")
  for tag,file in contents:gmatch('<(%w+)%s+file="([^"]+)"%s*/>') do
    local target=dir.."/"..file:gsub("\\","/")
    if tag=="Include" then xml(target) elseif tag=="Script" then assert(loadfile(target))() end
  end
end
local function loadLibraries()
  xml(root.."/libs/AceGUI-3.0/AceGUI-3.0.xml")
  xml(root.."/libs/CallbackHandler-1.0/CallbackHandler-1.0.xml")
  xml(root.."/libs/AceConfig-3.0/AceConfig-3.0.xml")
end
loadLibraries()
local config,minor=LibStub("AceConfig-3.0")
local registry=LibStub("AceConfigRegistry-3.0")
local dialog=LibStub("AceConfigDialog-3.0")
assert(minor==3 and LibStub.minors["AceConfigRegistry-3.0"]==22)
assert(LibStub.minors["AceConfigDialog-3.0"]==93 and LibStub.minors["CallbackHandler-1.0"]==8)
local previousFrames=frames
config:RegisterOptionsTable("SAK test",{type="group",name="SAK",args={}})
loadLibraries()
assert(LibStub("AceConfig-3.0")==config and LibStub("AceConfigDialog-3.0")==dialog)
assert(registry:GetOptionsTable("SAK test"))
local future=function() end
LibStub:NewLibrary("AceConfigDialog-3.0",94)
dialog.Open=future
loadLibraries()
assert(LibStub("AceConfigDialog-3.0").Open==future and frames==previousFrames)
LibStub.minors["AceConfigDialog-3.0"]=92
loadLibraries()
assert(LibStub("AceConfigDialog-3.0")==dialog and dialog.Open~=future)
assert(registry:GetOptionsTable("SAK test"))
print("PASS: complete upstream XML load, shared equal/newer reuse, older upgrade and preserved registry")

-- Let the real registry validate our options schema; panel rendering is in-game.
SkillsAlreadyKnown={disabledByDev=false,EnsureDB=function() return {} end,
 RankPolicy={RoleLabels=function() return {tank="Tank",heal="Heal",dps="DPS",pvp="PvP"} end,SpecsForRole=function(role) return role=="dps" and {affliction="Affliction"} or {} end,GetProfile=function() end}}
UnitClass=function() return "Warlock","WARLOCK" end
assert(loadfile(root.."/Settings.lua"))("SkillsAlreadyKnown")
assert(loadfile(root .. "/data/Patchnotes.lua"))()
dofile(root.."/BadgeRules.lua")
dofile(root.."/BadgeEditor.lua")
dofile(root.."/DevTools.lua")
local options=SkillsAlreadyKnown.Settings.Options()
registry:ValidateOptionsTable(options,"SAK options schema")
assert(options.args.custom.childGroups == "tab")
assert(options.args.custom.args.spellBadges.type == "group")
assert(not options.args.spellBadges, "Badge editor lives inside Custom")
assert(options.args.spellbook.args.roles.args.dps.args.specialization.values().affliction=="Affliction")
print("PASS: actual AceConfigRegistry accepts the settings table and class-scoped choices")
