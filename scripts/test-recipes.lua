-- Run: lua scripts/test-recipes.lua
local root=arg[1] or "."
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
local s=SkillsAlreadyKnown
ITEM_SPELL_KNOWN="Déjà connu"
local metadata={ [101]={9,5},[102]={9,7},[103]={4,1},[104]={9,0} }
local tips={ [101]={{leftText="Recette"},{leftText="|cff00ff00Déjà connu|r"}},[102]={{leftText="Recette"}},[103]={{leftText=ITEM_SPELL_KNOWN}},[104]={{leftText=ITEM_SPELL_KNOWN}} }
local calls,requests=0,{}
C_Item={GetItemInfoInstant=function(link)
 local id=tonumber(link:match("item:(%d+)"));local data=metadata[id]
 if data then return id,"Recipe","Cooking","",77,data[1],data[2] end
end,RequestLoadItemDataByID=function(id) requests[id]=(requests[id] or 0)+1 end}
C_TooltipInfo={GetHyperlink=function(link)
 calls=calls+1;local lines=tips[tonumber(link:match("item:(%d+)"))]
 if lines then return {lines=lines} end
end}
local made,legacyScans={},0
local legacyText=ITEM_SPELL_KNOWN
local function frame()
 local f={shown=true,level=100,points={},scripts={}}
 function f:IsVisible() return self.shown end
 function f:GetWidth() return 40 end
 function f:GetEffectiveScale() return 0.64 end
 function f:GetFrameStrata() return "MEDIUM" end
 function f:GetFrameLevel() return self.level end
 function f:GetParent() return self.parent end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:EnableMouse(value) self.mouse=value end
 function f:SetSize(w,h) self.width,self.height=w,h end
 function f:SetAllPoints() end
 function f:SetFrameStrata(value) self.strata=value end
 function f:SetFrameLevel(value) self.level=value end
 function f:SetScale(value) self.scale=value end
 function f:ClearAllPoints() self.points={} end
 function f:SetPoint(...) self.points[#self.points+1]={...} end
 function f:SetScript(event,callback) self.scripts[event]=callback end
 function f:CreateTexture()
  return {SetAllPoints=function() end,SetTexture=function(self,path) self.path=path end}
 end
 return f
end
UIParent={}
GameTooltip={SetOwner=function() error("Do not use the visible player tooltip") end}
CreateFrame=function(kind,name,parent)
 local f=frame();f.parent=parent
 if kind=="GameTooltip" then
  legacyScans=legacyScans+1
  f.SetOwner=function() end;f.ClearLines=function() end;f.SetHyperlink=function() end
  f.NumLines=function() return 1 end;f.GetName=function() return name end
  _G[name.."TextLeft1"]={GetText=function() return legacyText end}
 end
 made[#made+1]=f;return f
end
s.SpellBook={PrepareOverlay=function(display,owner) display:SetFrameLevel(owner:GetFrameLevel()+20) end}
assert(loadfile(root.."/RecipeKnowledge.lua"))()
local recipes=s.RecipeKnowledge
assert(recipes.IsKnown("item:101"))
local before=calls;assert(recipes.IsKnown("item:101") and calls==before)
assert(recipes.IsKnown("item:102")==nil and recipes.IsKnown("item:103")==nil and recipes.IsKnown("item:104")==nil)
assert(legacyScans==0)
assert(recipes.IsKnown("item:105")==nil)
assert(recipes.IsKnown("item:105")==nil and requests[105]==1)
metadata[105]={9,5};tips[105]={{leftText=ITEM_SPELL_KNOWN}}
assert(recipes.IsKnown("item:105"), "Data received after a request must be re-read without negative cache")
local bag=frame();bag.icon=frame();bag.itemLink="item:101"
recipes.Paint(bag,bag.itemLink,"iconsInventory",false)
local bagBadge=made[1]
assert(bagBadge.shown and bagBadge.texture.path==s.RECIPE_KNOWN_BADGE and bagBadge.width==40 and not bagBadge.mouse)
recipes.Paint(bag,"item:102","iconsInventory",false);assert(not bagBadge.shown)
-- No negative cache: tooltip data may arrive after the item is visible.
tips[102]={{rightText=ITEM_SPELL_KNOWN}}
recipes.Paint(bag,"item:102","iconsInventory",false);assert(bagBadge.shown)
recipes.Invalidate();tips[102]=nil;assert(recipes.IsKnown("item:102")==nil)
-- Group/raid roll frames, including the native container pool.
local roll=frame();roll.IconFrame=frame();roll.IconFrame.Icon=frame();roll.rollID=55
GroupLootFrame1=roll
GroupLootContainer={rollFrames={roll}}
GetLootRollItemLink=function(id) assert(id==55);return "item:101" end
RollOnLoot=function() error("Never choose a roll for the player") end
recipes.RefreshRolls()
local rollBadge=made[2]
assert(rollBadge.shown and rollBadge.width==88 and rollBadge.points[1][2]==roll.IconFrame.Icon)
assert(#made==2,"Do not duplicate a frame present in both native collections")
s.SetDisplayOption("iconsInventory",false);recipes.RefreshRolls()
assert(not bagBadge.shown and rollBadge.shown)
s.SetDisplayOption("iconsLoot",false);recipes.RefreshRolls();assert(not rollBadge.shown)
s.SetDisplayOption("iconsLoot",true);recipes.RefreshRolls();assert(rollBadge.shown)
GetLootRollItemLink=function() return "item:103" end
recipes.RefreshRolls();assert(not rollBadge.shown and not rollBadge.link)
GetLootRollItemLink=function() return "item:101" end
recipes.RefreshRolls();assert(rollBadge.shown)
roll.shown=false;recipes.RefreshRolls();assert(not rollBadge.shown)
-- Legacy clients use a separate hidden scan tooltip and the localized constant.
recipes.Invalidate();C_TooltipInfo=nil
assert(recipes.IsKnown("item:101") and legacyScans==1)
legacyText="Not a known recipe";recipes.Invalidate()
assert(recipes.IsKnown("item:101")==nil and legacyScans==1)
legacyText=ITEM_SPELL_KNOWN
-- Native bags feed the same renderer without requiring a mouse event.
s.SetDisplayOption("iconsInventory",true)
s.Visuals={ClearItemButton=function(owner) recipes.Clear(owner) end}
s.ScanContainerStorage=function() return {} end
ContainerFrame1={IsShown=function() return true end,EnumerateValidItems=function() return ipairs({bag}) end}
assert(loadfile(root.."/Inventory.lua"))()
s.Inventory.Refresh();assert(bagBadge.shown)
bag.itemLink="item:103";s.Inventory.Refresh();assert(not bagBadge.shown)
-- Ellesmere supplies its own overlay host and follows the same recipe path.
local callback
EUI_Bags={RegisterItemOverlayIcon=function(_,fn) callback=fn end}
s.Inventory.Refresh();assert(callback)
callback(bag,{bag=0,slot=1,itemLink="item:101"})
assert(made[#made].texture.path==s.RECIPE_KNOWN_BADGE and made[#made].shown)
s.SetDisplayOption("recipes",false);recipes.RefreshRolls();assert(not made[#made].shown)
local count=#made;recipes.Initialize();recipes.Initialize();assert(#made==count+1)
print("PASS: localized positive tooltip detection, no false unknown/learnable result, async retry, hidden legacy scanner, native/Ellesmere bags, group/raid roll pooling, recycling, category settings and no roll automation")
