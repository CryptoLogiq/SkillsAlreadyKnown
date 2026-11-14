-- Run: lua scripts/test-display-options.lua
local root=arg[1] or "."
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
NORMAL_FONT_COLOR={r=1,g=0.82,b=0};HIGHLIGHT_FONT_COLOR={r=1,g=1,b=1}
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root.."/Visuals.lua"))()
local sak,v=SkillsAlreadyKnown,SkillsAlreadyKnown.Visuals
local function font(value)
 local f={value=value,rgb={0.8,0.7,0.4,1},writes=0,layer="ARTWORK",level=0}
 function f:GetText() return self.value end
 function f:SetText(text) self.value=text end
 function f:GetTextColor() return table.unpack(self.rgb) end
 function f:SetTextColor(r,g,b,a) self.rgb={r,g,b,a or 1};self.writes=self.writes+1 end
 function f:GetDrawLayer() return self.layer,self.level end
 function f:SetDrawLayer(layer,level) self.layer,self.level=layer,level end
 function f:SetPoint() end
 function f:SetShadowColor() end
 function f:SetShadowOffset() end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 return f
end
local function texture()
 local t={shown=false}
 for _,method in ipairs({"SetPoint","SetAllPoints","SetSize","SetHeight","SetWidth","SetDesaturated"}) do t[method]=function() end end
 function t:SetTexture(path) self.texture=path end
 function t:SetColorTexture(...) self.color={...} end
 function t:SetVertexColor(...) self.tint={...} end
 function t:Show() self.shown=true end
 function t:Hide() self.shown=false end
 function t:SetShown(show) self.shown=not not show end
 return t
end
local function frame()
 local f={icon={GetTexture=function() return 777 end},name=font("Spell"),sub=font("Requires 16")}
 function f:CreateTexture() return texture() end
 function f:CreateFontString() return font("") end
 return f
end
local glowStarts,glowStops=0,0
sak.Glow={SetBadge=function() glowStarts=glowStarts+1 end,Hide=function() glowStops=glowStops+1 end}
local row,merchant=frame(),frame()
merchant.name.value="Book"
local function repaint()
 v.PaintTrainerParts(row.name,row.sub,"known")
 v.PaintOutline(row,true);v.PaintKnownBg(row,true);v.PaintLearnableBg(row,true);v.PaintSoonBg(row,true)
 v.PaintIconKnownOverlay(row,true);v.PaintTrainerBadge(row,"new")
 v.PaintMerchantKnownBookOverlay(merchant,true);v.PaintMerchantPetIcon(merchant,{petIcon=888})
 v.PaintMerchantLearnableBadge(merchant,true);v.PaintMerchantBg(merchant,true)
 v.PaintParts(merchant.name,nil,"unavailable")
 v.PaintMerchantKnownPrefix(merchant.name,true);v.EnsureMerchantTextLayer(merchant.name)
 v.PaintItemDuplicateBadge(merchant,"Bank x2")
end
sak.Refresh=repaint
for _,key in ipairs({"icons","outlines","text","backgrounds"}) do assert(sak.DisplayEnabled(key)) end
repaint()
assert(row.sakTrainerBadge.shown and row.sakOutline[1].shown and row.sakKnownBg.shown)
assert(merchant.sakPetIcon.shown and merchant.sakDuplicateBadge.shown)
assert(merchant.name.value:find("Already Learned",1,true) and merchant.name.layer=="OVERLAY")
sak.SetDisplayOption("icons",false)
assert(not row.sakTrainerBadge.shown and not row.sakIconKnownOverlay.shown and glowStops>0)
assert(not merchant.sakKnownBookOverlay.shown and not merchant.sakPetIcon.shown and not merchant.sakPetIconBg.shown)
assert(not merchant.sakLearnableBadge.shown and row.sakOutline[1].shown and row.sakKnownBg.shown)
sak.SetDisplayOption("outlines",false)
assert(not row.sakOutline[1].shown and row.sakKnownBg.shown)
sak.SetDisplayOption("backgrounds",false)
assert(not row.sakKnownBg.shown and not row.sakLearnableBg.shown and not merchant.sakMerchantBg.shown and not row.sakSoonBg.shown)
sak.SetDisplayOption("text",false)
assert(row.name.rgb[1]==0.8 and row.sub.rgb[1]==0.8 and merchant.name.rgb[1]==0.8)
assert(merchant.name.value=="Book" and merchant.name.layer=="ARTWORK" and not merchant.sakDuplicateBadge.shown)
local writes=row.name.writes;repaint();assert(row.name.writes==writes,"Disabled text must remain untouched")
local fresh=font("New row");v.PaintTrainerParts(fresh,nil,"known");assert(fresh.writes==0)
for _,key in ipairs({"icons","outlines","text","backgrounds"}) do sak.SetDisplayOption(key,true) end
assert(row.sakTrainerBadge.shown and row.sakOutline[1].shown and row.sakKnownBg.shown and row.sakSoonBg.shown)
assert(row.name.rgb[1]==sak.COLORS.known[1] and merchant.sakDuplicateBadge.shown)
local other=font("Other addon");v.PaintParts(other,nil,"known");other:SetTextColor(0.2,0.5,0.8)
sak.SetDisplayOption("text",false);assert(other.rgb[1]==0.2 and other.rgb[3]==0.8,"Do not overwrite later external colors")
sak.SetDisplayOption("icons",false)
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(not sak.DisplayEnabled("icons") and not sak.DisplayEnabled("text"),"Choices persist across module reloads")
assert(not sak.SetDisplayOption("invalid",false))
print("PASS: independent categories, hidden badges/halos/overlays, restored colors/prefixes/layers, external colors, persistence and re-enabling")

-- Late and queued compatibility hooks must honor the disabled text category.
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
sak=SkillsAlreadyKnown
local loaded={DarkMode=true};local timers={}
C_AddOns={IsAddOnLoaded=function(name) return loaded[name] end}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
hooksecurefunc=function(object,method,callback)
 local old=object[method];object[method]=function(...) old(...);callback(...) end
end
assert(loadfile(root.."/Compatibility.lua"))()
assert(loadfile(root.."/Visuals.lua"))();v=sak.Visuals
local name,sub=font("|cffe5e5e5Spell"),font("Requires")
name.dm_setup_text=true
hooksecurefunc(name,"SetTextColor",function(self)
 if self.dm_settextcolor then return end
 self.dm_settextcolor=true;self:SetTextColor(0.9,0.9,0.9,1)
 self:SetText("|cffe5e5e5"..self:GetText():gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""))
 self.dm_settextcolor=false
end)
name:SetTextColor(0.9,0.9,0.9,1)
v.PaintTrainerParts(name,sub,"known")
assert(name.rgb[1]==0.34)
sak.SetDisplayOption("text",false)
while #timers>0 do table.remove(timers,1)() end
assert(name.rgb[1]==0.9 and not sak.Compatibility.ShouldStyleTrainerText())
assert(sak.Compatibility.GetDiagnostics().trainerTextMode=="disabled (display settings)")
sak.SetDisplayOption("text",true);v.PaintTrainerParts(name,sub,"known")
loaded.TrainerSpells=true
local nameWrites,subWrites=name.writes,sub.writes
sak.SetDisplayOption("text",false);v.PaintTrainerParts(name,sub,"known")
assert(name.writes==nameWrites and sub.writes==subWrites,"Never restore trainer text underneath TrainerSpells")
print("PASS: DarkMode regains control, queued hooks remain inert, TrainerSpells also protects cleanup of requirement text")

sak.SetDisplayOption("icons", true)
local bag = frame()
local function paintCategories()
  v.PaintTrainerBadge(row, "new")
  v.PaintMerchantPetIcon(merchant, {petIcon=888})
  v.PaintItemPetIcon(bag, {petIcon=888})
  v.PaintItemLearnableBadge(bag, true)
end
paintCategories()
sak.SetDisplayOption("iconsMerchant", false)
paintCategories()
assert(not merchant.sakPetIcon.shown and bag.sakPetIcon.shown and row.sakTrainerBadge.shown)
sak.SetDisplayOption("iconsMerchant", true)
sak.SetDisplayOption("iconsInventory", false)
paintCategories()
assert(merchant.sakPetIcon.shown and not bag.sakPetIcon.shown and not bag.sakLearnableBadge.shown)
sak.SetDisplayOption("iconsTrainer", false)
paintCategories()
assert(not row.sakTrainerBadge.shown and merchant.sakPetIcon.shown)
sak.SetDisplayOption("iconsInventory", true)
sak.SetDisplayOption("iconsTrainer", true)
sak.SetDisplayOption("icons", false)
paintCategories()
assert(not row.sakTrainerBadge.shown and not merchant.sakPetIcon.shown and not bag.sakPetIcon.shown)
assert(sak.DisplayEnabled("iconsInventory") and sak.DisplayEnabled("iconsMerchant"))
print("PASS: merchant/inventory/trainer icon choices are independent and retained beneath the global switch")
