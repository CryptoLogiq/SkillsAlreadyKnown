SkillsAlreadyKnown=nil
SkillsAlreadyKnownDB=nil
dofile('Core.lua')
local s=SkillsAlreadyKnown
ITEM_SPELL_KNOWN='Déjà connu'
ITEM_SPELL_TRIGGER_ONUSE='Utiliser : '
local cached=true
local tips={
 [201]={{leftText='Plan bleu'},{leftText='Utiliser : Vous apprend à créer un objet.'}},
 [202]={{leftText='Plan vert'}},
 [203]={{leftText='Plan violet'},{leftText='Utiliser : Vous apprend à créer un objet.'},{leftText=ITEM_SPELL_KNOWN}},
}
local names={[201]='Plan bleu',[202]='Plan vert',[203]='Plan violet'}
C_Item={GetItemInfoInstant=function(link)
 local id=tonumber(link:match('item:(%d+)'));if names[id]then return id,'Recipe','Blacksmithing','',77,9,4 end
end,GetItemInfo=function(link)if cached then return names[tonumber(link:match('item:(%d+)'))]end end}
C_TooltipInfo={GetHyperlink=function(link)return{lines=tips[tonumber(link:match('item:(%d+)'))]}end}
local function frame()
 local f={shown=true}
 function f:IsVisible()return self.shown end
 function f:GetWidth()return 40 end
 function f:Show()self.shown=true end
 function f:Hide()self.shown=false end
 function f:GetTexture()return 'icon'end
 for _,key in ipairs({'SetPoint','SetSize','EnableMouse','SetAllPoints','SetTexture','SetShown'})do f[key]=function()end end
 function f:ClearAllPoints()end
 function f:CreateTexture()return frame()end
 return f
end
CreateFrame=frame
UIParent=frame()
local glitter={}
s.RecentSparkles={PaintIcon=function(owner,icon,show,zone)glitter[owner]={icon=icon,show=not not show,zone=zone}end}
s.SpellBook={PrepareOverlay=function()end}
GameTooltip={SetOwner=function()error('Never use the player tooltip')end}
dofile('RecipeKnowledge.lua')
local r=s.RecipeKnowledge
assert(r.IsUnlearned('item:201'))
assert(not r.IsUnlearned('item:202'),'A title without complete Use text does not prove an unknown recipe')
assert(not r.IsUnlearned('item:203'))
assert(not r.IsUnlearned('item:999'))
r.Invalidate();cached=false;assert(not r.IsUnlearned('item:201'),'Uncached data never sparkles')
cached=true;assert(r.IsUnlearned('item:201'),'Retry after item data arrives')
local merchant,item=frame(),frame();item.icon=frame();merchant.ItemButton=item
MerchantFrame=frame();MerchantFrame.page=1
MerchantItem1=merchant
local link,stock='item:201',-1
GetMerchantItemLink=function()return link end
GetMerchantItemInfo=function()return 'Plan',1,1,1,stock end
r.RefreshMerchant()
assert(glitter[item].show and glitter[item].icon==item.icon and glitter[item].zone=='iconsMerchant')
stock=0;r.RefreshMerchant();assert(not glitter[item].show)
stock=-1;MerchantFrame.selectedTab=2;r.RefreshMerchant();assert(not glitter[item].show)
MerchantFrame.selectedTab=1;link='item:203';r.RefreshMerchant();assert(not glitter[item].show)
link='item:202';r.RefreshMerchant();assert(not glitter[item].show)
link='item:201';s.SetDisplayOption('iconsMerchant',false);r.RefreshMerchant();assert(not glitter[item].show)
s.SetDisplayOption('iconsMerchant',true)
local roll=frame();roll.IconFrame=frame();roll.IconFrame.Icon=frame();roll.rollID=1
GroupLootFrame1=roll
GetLootRollItemLink=function()return link end
LootFrame=frame();LootButton1=frame();LootButton1.icon=frame();LootButton1.slot=1
GetLootSlotLink=function()return link end
r.RefreshRolls()
assert(glitter[roll].show and glitter[roll].icon==roll.IconFrame.Icon)
assert(glitter[LootButton1].show and glitter[LootButton1].icon==LootButton1.icon)
tips[201][3]={leftText=ITEM_SPELL_KNOWN};r.Invalidate();r.RefreshRolls()
assert(not glitter[item].show and not glitter[roll].show and not glitter[LootButton1].show,'Learning the recipe stops all effects')
s.SetDisplayOption('recipes',false);r.RefreshRolls();assert(not glitter[roll].show)
-- NEW + is shared by class and profession trainer rows.
dofile('Visuals.lua')
local row=frame();row.icon=frame()
s.Visuals.PaintTrainerBadge(row,'new')
assert(glitter[row].show and glitter[row].icon==row.icon and glitter[row].zone=='iconsTrainer')
s.Visuals.PaintTrainerBadge(row,'soon');assert(not glitter[row].show)
s.Visuals.PaintTrainerBadge(row,nil);assert(not glitter[row].show)
s.SetDisplayOption('iconsTrainer',false);s.Visuals.PaintTrainerBadge(row,'new');assert(not glitter[row].show)
print('PASS: cached complete recipes only, icon-only merchant/roll/loot effects, stock/buyback, learned state, async retry, preferences and trainer NEW + integration')
