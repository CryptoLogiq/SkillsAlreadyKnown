-- Run from the development repository: lua scripts/test-compatibility.lua
local root=arg[1] or "."
local function setup(loaded)
  SkillsAlreadyKnown=nil
  C_AddOns, GetAddOnEnableState, UnitName, IsAddOnLoaded=nil,nil,nil,nil
  assert(loadfile(root .. "/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
  local sak=SkillsAlreadyKnown
  local timers={}
  C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
  local function flush()
    local n=0
    while #timers>0 do n=n+1; assert(n<25,"compatibility recursion"); table.remove(timers,1)() end
  end
  local hooks=0
  hooksecurefunc=function(object,method,fn)
    hooks=hooks+1
    local original=object[method]
    object[method]=function(...) original(...); fn(...) end
  end
  C_AddOns={IsAddOnLoaded=function(name) return name=="DarkMode" and loaded end}
  assert(loadfile(root .. "/Compatibility.lua"))()
  assert(loadfile(root .. "/Visuals.lua"))()
  NORMAL_FONT_COLOR={r=1,g=0.82,b=0}; HIGHLIGHT_FONT_COLOR={r=1,g=1,b=1}
  return sak,flush,function() return hooks end
end
local function font(text)
  return {value=text,rgb={1,0.82,0},GetText=function(self) return self.value end,
    SetText=function(self,value) self.value=value end,
    SetTextColor=function(self,r,g,b,a) self.rgb={r,g,b,a} end}
end
local function darkText(text)
  text.dm_setup_text=true
  hooksecurefunc(text,"SetTextColor",function(self)
    if self.dm_settextcolor then return end
    self.dm_settextcolor=true
    self:SetTextColor(0.9,0.9,0.9,1)
    self:SetText("|cffe5e5e5" .. self:GetText():gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""))
    self.dm_settextcolor=false
  end)
end
local function texture()
  return {SetVertexColor=function(self,r,g,b,a) self.tint={r,g,b,a} end,
    SetColorTexture=function(self,r,g,b,a) self.solid={r,g,b,a} end}
end
local function darkTexture(tex)
  tex.dm_setup_texture=true
  hooksecurefunc(tex,"SetVertexColor",function(self)
    if self.dm_setvertexcolor then return end
    self.dm_setvertexcolor=true
    self:SetVertexColor(0.2,0.2,0.2,1)
    self.dm_setvertexcolor=false
  end)
end
local sak,flush,count=setup(false)
local name,sub=font("Spell"),font("Requires |cffff000018|r")
sak.Visuals.PaintTrainerParts(name,sub,"unavailable")
assert(count()==0 and name.rgb[2]==0.15 and sub.value=="Requires |cffff000018|r")
local tex=texture(); sak.Compatibility.ProtectTexture(tex)
assert(count()==0 and tex.tint==nil)
assert(not sak.Compatibility.GetDiagnostics().darkModeLoaded)
print("PASS: without DarkMode no compatibility hooks or texture changes; requirement text unchanged")

for _, late in ipairs({false,true}) do
  sak,flush,count=setup(true)
  name,sub=font("|cffe5e5e5Spell"),font("Requires |cffff000018|r")
  tex=texture()
  if not late then darkText(name); darkTexture(tex) end
  sak.Visuals.PaintTrainerParts(name,sub,"unavailable")
  sak.Compatibility.ProtectTexture(tex,nil,{0,1,0,0.85})
  if late then darkText(name); darkTexture(tex) end
  name:SetTextColor(1,1,0); tex:SetVertexColor(0.2,0.2,0.2,1); flush()
  assert(name.rgb[1]==1 and name.rgb[2]==0.15 and name.value=="Spell")
  assert(name.dm_settextcolor==false and tex.dm_setvertexcolor==false)
  assert(tex.tint[1]==1 and tex.solid[2]==1)
  local before=count()
  sak.Visuals.PaintTrainerParts(name,sub,"known"); flush()
  assert(count()==before and name.rgb[1]==0.34)
  sak.Visuals.PaintTrainerParts(name,sub,nil); flush()
  assert(name.rgb[1]==1 and name.rgb[2]==0.82)
  assert(sub.value=="Requires |cffff000018|r")
  local other=font("Unmanaged"); darkText(other); other:SetTextColor(1,0,0); flush()
  assert(other.rgb[1]==0.9 and other.value:find("|cffe5e5e5",1,true))
  print("PASS: DarkMode "..(late and "hooks late" or "hooks first")..", state changes, no duplicate hooks, marker colors, other text untouched")
end
-- Errors must not leave DarkMode's re-entry guard active.
sak,flush=setup(true)
name=font("Spell"); darkText(name)
local errors=0; sak.Diagnostics={Record=function() errors=errors+1 end}
name.SetText=function() error("simulated font failure") end
sak.Compatibility.SetTrainerNameColor(name,1,0,0)
assert(errors==1 and name.dm_settextcolor==nil)
print("PASS: failed paints restore DarkMode guards and report diagnostics")
-- Detection also works when only the actual hook markers are available.
sak,flush=setup(false); C_AddOns=nil
name=font("Spell"); darkText(name)
sak.Visuals.PaintTrainerParts(name,nil,"known"); flush()
assert(name.rgb[1]==0.34)
print("PASS: capability detection works without addon-enumeration APIs")
-- The Ellesmere bridge and DarkMode adapter must work independently and together.
for _, loaded in ipairs({false,true}) do
  sak,flush=setup(loaded)
  local hosts={}
  local function newTexture()
    local t=texture()
    function t:SetTexture(value) self.file=value end
    function t:GetTexture() return self.file end
    function t:SetShown(value) self.shown=value end
    function t:Show() self.shown=true end
    function t:Hide() self.shown=false end
    for _,method in ipairs({"SetAllPoints","SetPoint","SetSize","SetHeight","SetWidth","SetDesaturated"}) do t[method]=function() end end
    if loaded then darkTexture(t) end
    return t
  end
  CreateFrame=function(_,_,parent)
    local host={parent=parent,SetAllPoints=function() end,CreateTexture=newTexture}
    hosts[#hosts+1]=host
    return host
  end
  local callback
  EUI_Bags={itemOverlayIcons={},RegisterItemOverlayIcon=function(key,fn)
    EUI_Bags.itemOverlayIcons[key]=fn; callback=fn
  end}
  sak.Visuals.PaintItemDuplicateBadge=function() end
  local known=true
  sak.PetGrimoires={ItemInfoFromLink=function() return {itemID=1,petIcon=777} end,
    ItemState=function() return known and "known" or nil end,ItemLearnable=function() return not known end}
  sak.ItemStorageSummary=function() end
  assert(loadfile(root .. "/Inventory.lua"))()
  sak.Inventory.Hook()
  assert(callback)
  local icon={GetTexture=function() return 123 end}
  local button={icon=icon,_textOverlay={}}
  callback(button,{bag=0,slot=1,itemLink="item:1"}); flush()
  local host=hosts[1]
  assert(host.parent==button._textOverlay and host.sakKnownBookOverlay.shown)
  assert(host.sakKnownBookOverlay.tint[1]==0.36)
  assert(not host.sakLearnableBadge.shown and host.sakPetIcon.shown)
  known=false; callback(button,{bag=0,slot=1,itemLink="item:1"}); flush()
  assert(not host.sakKnownBookOverlay.shown and host.sakLearnableBadge.shown)
  assert(host.sakOutline[1].solid[2]==0.82)
  assert(button.sakKnownBookOverlay==nil and icon.tint==nil)
  assert(sak.Inventory.GetDiagnostics().callbackIntact)
  print("PASS: Ellesmere "..(loaded and "with" or "without").." DarkMode; learned/learnable markers, own frames, native icons untouched")
end

-- TrainerSpells owns text; all existing name/requirement content stays intact.
for _, dark in ipairs({false,true}) do
  sak,flush,count=setup(dark)
  C_AddOns.IsAddOnLoaded=function(addon) return addon=="TrainerSpells" or (addon=="DarkMode" and dark) end
  name,sub=font("|cff123456TrainerSpells name|r"),font("Requires |cffff000018|r")
  local before=count()
  sak.Visuals.PaintTrainerParts(name,sub,"known");flush()
  assert(name.value=="|cff123456TrainerSpells name|r" and name.rgb[1]==1)
  assert(sub.value=="Requires |cffff000018|r" and sub.rgb[2]==0.82)
  assert(count()==before,"No text hooks should be registered with TrainerSpells")
  assert(not sak.Compatibility.ShouldStyleTrainerText())
  assert(sak.Compatibility.GetDiagnostics().trainerTextMode=="icons-only (TrainerSpells)")
end
-- Previously registered protection must stop repainting when TrainerSpells loads.
sak,flush=setup(true)
name=font("Spell");darkText(name)
sak.Visuals.PaintTrainerParts(name,nil,"known");flush()
assert(name.rgb[1]==0.34)
C_AddOns.IsAddOnLoaded=function() return true end
name:SetTextColor(1,0,0);flush()
assert(name.rgb[1]==0.9 and name.value:find("|cffe5e5e5",1,true))
assert(name.dm_settextcolor==false)
-- Legacy clients must make the same choice.
C_AddOns=nil;IsAddOnLoaded=function(addon) return addon=="TrainerSpells" end
assert(not sak.Compatibility.ShouldStyleTrainerText())
print("PASS: TrainerSpells text preserved with/without DarkMode, late loading disables existing protection, legacy detection")
