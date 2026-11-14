-- Run: lua scripts/test-spellbook.lua
local root = arg[1] or "."
SkillsAlreadyKnown, SkillsAlreadyKnownDB = nil, nil
local class, combat, level = "WARLOCK", false, 15
UnitLevel = function() return level end
UnitClass = function() return class, class end
InCombatLockdown = function() return combat end
assert(loadfile(root .. "/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root .. "/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root .. "/RankPolicy.lua"))()
assert(loadfile(root .. "/SpellRanks.lua"))()
assert(loadfile(root .. "/SpellBook.lua"))()
assert(loadfile(root .. "/SpellTooltips.lua"))()
local sak, policy, book = SkillsAlreadyKnown, SkillsAlreadyKnown.RankPolicy, SkillsAlreadyKnown.SpellBook
local function spell(slot, id, name, rank) return { slot = slot, id = id, name = name, rank = rank } end
local agony = { spell(1, 980, "Plaie d'agonie", 1), spell(2, 1014, "Plaie d'agonie", 2), spell(3, 6217, "Plaie d'agonie", 3) }
local r = book.Classify(agony, class)
assert(r[1].kind == "low" and r[2].kind == "low" and r[3].kind == "best")
assert(book.Classify({agony[1]}, class)[1].kind=="best", "A single learned rank also receives BEST")
policy.SetRole("dps")
r = book.Classify(agony, class)
assert(r[1].kind == "low", "Agony must never become ECO")
local drain = { spell(11, 1120, "Drain d'âme", 1), spell(12, 8288, "Drain d'âme", 2), spell(13, 8289, "Drain d'âme", 3) }
r = book.Classify(drain, class)
assert(r[11].kind == "eco" and r[12].kind == "low" and r[13].kind == "best")
assert(book.Classify({drain[1]}, class)[11].kind == "eco")
local clonedName = { spell(1, 9999, "Drain d'âme", 1), spell(2, 9998, "Drain d'âme", 2) }
assert(book.Classify(clonedName,class)[1].kind == "low", "ECO must require the verified rank-one ID")
local pain = { spell(1,5676,"Douleur brûlante",1),spell(2,17919,"Douleur brûlante",2) }
assert(book.Classify(pain,class)[1].kind == "low", "DPS must not imply Affliction")
assert(policy.SetSpecialization("dps","affliction"))
assert(book.Classify(pain,class)[1].kind == "eco")
assert(policy.SetSpecialization("dps","demonology"))
assert(book.Classify(pain,class)[1].kind == "low")
policy.SetRole("tank")
assert(book.Classify(pain,class)[1].kind == "low")
policy.SetRole("pvp")
assert(book.Classify(drain,class)[11].kind == "low", "PvP suspends ECO, not rank comparison")
policy.SetRole("dps");policy.SetEco(false)
assert(book.Classify(drain,class)[11].kind == "low")
SkillsAlreadyKnownDB.levelingProfile = nil
assert(book.Classify(drain,class)[11].kind == "low", "No selected profile means no ECO")
local ambiguous = {spell(1,1,"Same name",1),spell(2,2,"Same name",1),spell(3,3,"Same name",2)}
assert(not next(book.Classify(ambiguous,class)), "Unrelated IDs with the same name and rank are ambiguous")
local mixed={spell(1,1000,"Mixed",1),spell(2,1001,"Mixed",2)};mixed[1].ranked=false
assert(not next(book.Classify(mixed,class)),"Do not guess order when unranked and ranked IDs share a name")
class="PALADIN";policy.SetRole("dps")
local aura={spell(1,465,"Aura de dévotion",1),spell(2,10290,"Aura de dévotion",2)}
assert(policy.SelectedSpec("dps")=="retribution")
assert(book.Classify(aura,class)[1].kind=="eco", "A unique specialization is visibly selected in the dropdown")
policy.SetRoleEnabled("tank",true)
assert(policy.SelectedSpec("tank")=="protection" and policy.IsRoleEnabled("dps"))
assert(book.Classify(aura,class)[1].kind=="low", "Tank needs must veto DPS-only savings")
policy.SetRoleEnabled("tank",false)
assert(book.Classify(aura,class)[1].kind=="eco")
policy.SetRole("tank")
assert(book.Classify(aura,class)[1].kind=="low")
class="DRUID";policy.SetRole("dps")
local roots={spell(1,339,"Sarments",1),spell(2,1062,"Sarments",2)}
assert(book.Classify(roots,class)[1].kind=="low")
policy.SetSpecialization("dps","feral")
assert(book.Classify(roots,class)[1].kind=="eco")
policy.SetRoleEnabled("heal",true)
assert(book.Classify(roots,class)[1].kind=="low")
policy.SetRoleEnabled("heal",false)
policy.SetRoleEnabled("tank",true)
assert(book.Classify(roots,class)[1].kind=="eco")
policy.SetSpecialization("dps","balance")
assert(book.Classify(roots,class)[1].kind=="low")
policy.SetRole("tank")
assert(book.Classify(roots,class)[1].kind=="eco")
class="PRIEST";policy.SetRole("dps")
assert(book.Classify(drain,class)[11].kind=="low", "Profiles and recommendations are class-scoped")
policy.SetRole("heal")
local soothe={spell(1,453,"Apaisement",1),spell(2,8192,"Apaisement",2)}
assert(book.Classify(soothe,class)[1].kind=="low", "Target-level-capped utilities are not universally rank-one sufficient")
local resurrection={spell(1,2006,"Résurrection",1),spell(2,2010,"Résurrection",2)}
assert(book.Classify(resurrection,class)[1].kind=="eco")
local scream={spell(1,8122,"Cri psychique",1),spell(2,8124,"Cri psychique",2)}
assert(book.Classify(scream,class)[1].kind=="low")
policy.SetSpecialization("heal","discipline")
assert(book.Classify(scream,class)[1].kind=="eco")
policy.SetSpecialization("heal","holy")
assert(book.Classify(scream,class)[1].kind=="low")
for _,case in ipairs({
 {class="WARLOCK",spec="affliction",expected="dps"},
 {class="DRUID",spec="guardian",expected="tank"},
 {class="PRIEST",spec="holy",expected="heal"},
 {class="PALADIN",spec="retribution",tank=true,expected="tank"},
 {class="MAGE",spec="frost",pvp=true,expected="pvp"},
}) do
 class=case.class
 SkillsAlreadyKnownDB.levelingProfile={class=class,spec=case.spec,tank=case.tank,pvp=case.pvp,eco=false}
 local migrated=policy.GetProfile()
 assert(migrated.role==case.expected and migrated.eco==false and migrated.roles[case.expected].enabled)
 assert(migrated.tank==nil and migrated.pvp==nil and migrated.healer==nil)
 assert(not policy.SetRole("invalid"))
end
-- OPTIONAL is independent of ECO, matches all roles, and never replaces BEST.
class="PALADIN";SkillsAlreadyKnownDB.levelingProfile=nil;policy.SetRole("dps")
local optionalAura={spell(1,465,"Aura de dévotion",1),spell(2,10290,"Aura de dévotion",2)}
local optionalSeal={spell(1,20164,"Sceau de justice",1)}
r=book.Classify(optionalAura,class)
assert(r[1].kind=="eco" and not r[1].optionalReason and r[2].kind=="best" and r[2].optionalReason)
assert(book.Classify(optionalSeal,class)[1].optionalReason)
policy.SetEco(false)
assert(book.Classify(optionalAura,class)[2].optionalReason,"OPTIONAL must not depend on ECO checkbox")
policy.SetRoleEnabled("tank",true)
assert(not book.Classify(optionalAura,class)[2].optionalReason,"Tank vetoes DPS-only optional ranks")
assert(book.Classify(optionalSeal,class)[1].optionalReason,"Reviewed all-role utility remains optional")
policy.SetRoleEnabled("pvp",true)
assert(not book.Classify(optionalSeal,class)[1].optionalReason)
policy.SetRole("dps");policy.SetOptional(false)
assert(not book.Classify(optionalSeal,class)[1].optionalReason)
policy.SetOptional(true);level=60
assert(not book.Classify(optionalSeal,class)[1].optionalReason)
level=15
assert(not book.Classify({spell(1,99999,"Sceau de justice",1)},class)[1].optionalReason,"No localized-name guessing")
SkillsAlreadyKnownDB.levelingProfile=nil
assert(not book.Classify(optionalSeal,class)[1].optionalReason,"No optional advice without a profile")
print("PASS: OPTIONAL identity, extra ranks, separate checkbox, multi-role veto, PvP, level cap and absent profile")
print("PASS: role/spec ECO, multi-role vetoes, explicit choices, PvP suspension and profile migration")

-- Modern book: all learned ranks, not merely the currently visible page.
class="WARLOCK";policy.SetRole("dps")
Enum={SpellBookSpellBank={Player=0,Pet=1},SpellBookItemType={Spell=1,FutureSpell=2,Flyout=3}}
local data={
 [1]={spellID=980,name="Plaie d'agonie",subName="Rang 1",itemType=1},
 [2]={spellID=1014,name="Plaie d'agonie",subName="Rang 2",itemType=1},
 [3]={spellID=6217,name="Plaie d'agonie",subName="Rang 3",itemType=1},
 [4]={spellID=11711,name="Plaie d'agonie",subName="Rang 4",itemType=2,isUnlearned=true},
 [5]={spellID=100,name="Passive",subName="Rang 1",itemType=1,isPassive=true},
 [6]={spellID=20271,name="Jugement",itemType=1},
 [7]={spellID=1120,name="Drain d'âme",subName="Rang 1",itemType=1},
 [8]={spellID=8288,name="Drain d'âme",subName="Rang 2",itemType=1},
 [9]={spellID=99999,name="Unclear rank",subName="Rang inconnu",itemType=1},
}
C_SpellBook={GetNumSpellBookSkillLines=function() return 1 end,
 GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=9} end,
 GetSpellBookItemInfo=function(slot,b) assert(b==0);return data[slot] end}
r=book.Scan()
assert(r[1].kind=="low" and r[3].kind=="best" and r[3].highest==3)
assert(not r[4] and not r[5] and r[6].kind=="best" and not r[9] and r[7].kind=="eco")
-- Custom clients may expose future ranks as ordinary SPELL items with no flags.
local saved = data[3]
data[3]={spellID=6217,name="Plaie d'agonie",subName="Rang 3",itemType=1}
C_SpellBook.IsSpellKnown=function(id) return id~=1014 and id~=6217 end
r=book.Scan()
assert(r[1].kind=="best" and not r[2] and not r[3],"Unlearned higher IDs must never demote rank one to LOW")
C_SpellBook.IsSpellKnown=nil
IsPlayerSpell=function(id) return id~=1014 and id~=6217 end
r=book.Scan();assert(r[1].kind=="best" and not r[2] and not r[3])
IsPlayerSpell=nil
IsSpellKnown=function(id) return id~=1014 and id~=6217 end
r=book.Scan();assert(r[1].kind=="best" and not r[2] and not r[3])
IsSpellKnown=nil
C_SpellBook.GetSpellBookItemLevelLearned=function(slot) return (slot==2 or slot==3) and 20 or 1 end
r=book.Scan();assert(r[1].kind=="best" and not r[2] and not r[3],"Future level requirement vetoes misleading item metadata")
C_SpellBook.GetSpellBookItemLevelLearned=nil
data[3]=saved
r=book.Scan();assert(r[1].kind=="low" and r[3].kind=="best","Actually learned higher ranks still compare normally")
print("PASS: future ordinary-SPELL entries excluded by exact learned ID or future level, including legacy APIs")
-- Kilrogg and other summons expose a spell category, not rank text.
local previousInfo=data[6]
policy.SetSpecialization("dps","demonology")
data[6]={spellID=126,name="Œil de Kilrogg",subName="Invocation",itemType=1}
r=book.Scan();assert(r[6].kind=="best" and r[6].optionalReason,"Kilrogg must receive BEST + OPTIONAL despite Invocation subtext")
policy.SetOptional(false);r=book.Scan();assert(r[6].kind=="best" and not r[6].optionalReason)
policy.SetOptional(true)
data[6]={spellID=688,name="Invocation d'un diablotin",subName="Invocation",itemType=1}
r=book.Scan();assert(r[6].kind=="best" and not r[6].optionalReason)
data[6]={spellID=7744,name="Volonté des Réprouvés",subName="Raciale",itemType=1}
r=book.Scan();assert(r[6].kind=="best")
RANK="Rango"
data[6]={spellID=9999,name="Uncertain",subName="Rango desconocido",itemType=1}
r=book.Scan();assert(not r[6],"Localized unreadable rank must remain uncertain")
RANK=nil;data[6]=previousInfo;r=book.Scan()
print("PASS: Invocation/Summon category preserves Kilrogg OPTIONAL, active racials and unreadable-rank exclusion")
-- Some clients expose names in item info but ranks only in the slot-name API.
local subs={}
for slot,info in pairs(data) do subs[slot]=info.subName;info.subName=nil end
C_SpellBook.GetSpellBookItemName=function(slot) return data[slot].name,subs[slot] end
r=book.Scan();assert(r[1].kind=="low" and r[3].kind=="best" and r[6].kind=="best" and not r[9])
for slot,info in pairs(data) do info.subName=subs[slot] end
C_SpellBook.GetSpellBookItemName=nil
local timers={}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local function flush() while #timers>0 do table.remove(timers,1)() end end
local function frame()
 local f={shown=true,scripts={},created=0}
 function f:IsVisible() return self.shown end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:SetShown(value) self.shown=not not value end
 function f:HookScript(k,fn) self.scripts[k]=fn end
 function f:SetScript(k,fn) self.scripts[k]=fn end
 function f:EnableMouse() end
 function f:ClearAllPoints() end
 function f:SetPoint(...) self.point={...} end
 function f:SetSize(w,h) self.w,self.h=w,h end
 function f:GetFrameStrata() return self.strata or "MEDIUM" end
 function f:GetFrameLevel() return self.level or 4 end
 function f:GetParent() return self.parent end
 function f:GetAlpha() return self.alpha or 1 end
 function f:SetAlpha(value) self.alpha=value end
 function f:GetEffectiveScale() return self.effectiveScale or (self.scale or 1)*0.64 end
 function f:SetScale(v) self.scale=v end
 function f:SetFrameStrata(v) self.strata=v end
 function f:SetFrameLevel(v) self.level=v end
 function f:CreateTexture()
  self.created=self.created+1
  return {SetAllPoints=function() end,SetTexture=function(t,path) t.path=path end,
   SetSize=function(t,w,h) t.w,t.h=w,h end,SetPoint=function(t,...) t.point={...} end,
   SetShown=function(t,v) t.shown=v end}
 end
 return f
end
local made={}
UIParent={GetFrameStrata=function() return "MEDIUM" end,GetFrameLevel=function() return 0 end,GetEffectiveScale=function() return 0.64 end}
CreateFrame=function(_,_,parent) local f=frame();f.parent=parent;made[#made+1]=f;return f end
local row=frame();row.slotIndex=1;row.spellBank=0;row.Button={Icon={}}
PlayerSpellsFrame={SpellBookFrame=frame()}
PlayerSpellsFrame.SpellBookFrame.level=100
local pager=frame();pager.level=101;pager.parent=PlayerSpellsFrame.SpellBookFrame
PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame=pager
row.level=103;row.parent=pager

function PlayerSpellsFrame.SpellBookFrame:ForEachDisplayedSpell(fn) fn(row) end
book.Hook();book.Refresh()
local overlay=made[2]
assert(overlay.shown and overlay.texture.path==sak.SPELLBOOK_BADGES.low.texture)
assert(overlay.strata=="HIGH" and overlay.level==123,"Detached badge must clear the complete MEDIUM book tree")
assert(overlay.scale==1 and overlay:GetEffectiveScale()==row:GetEffectiveScale())
assert(overlay.parent==UIParent and overlay.point[2]==row.Button.Icon and overlay.point[4]==7)
assert(not row.sakSpellBookBadge and row.created==0, "Never store overlay state on protected spell rows")
-- Render and explain the accessible-upgrade status through the existing detached path.
sak.RankAvailability={FindUpgrade=function() return {id=11711,rank=4,level=28} end}
row.slotIndex=3;book.MarkDirty();book.Refresh()
assert(overlay.texture.path==sak.SPELLBOOK_BADGES.buy.texture and overlay.w==88)
local buyTip={AddLine=function(self,text) self[#self+1]=text end}
book.AddSpellTooltip(buyTip,6217)
assert(table.concat(buyTip," "):find("BUY NEW RANK",1,true) and table.concat(buyTip," "):find("28",1,true))
sak.RankAvailability=nil;row.slotIndex=1;book.MarkDirty();book.Refresh()

sak.SetDisplayOption("icons",false);book.Refresh();assert(not overlay.shown)
sak.SetDisplayOption("icons",true);book.Refresh();assert(overlay.shown)
row.slotIndex=3;book.Refresh()
assert(overlay.texture.path==sak.SPELLBOOK_BADGES.best.texture and #made==2)
row.slotIndex=8;book.Refresh()
assert(overlay.optionalTexture.shown and overlay.optionalTexture.path==sak.SPELLBOOK_BADGES.optional.texture)
assert(overlay.optionalTexture.point[1]=="LEFT" and overlay.optionalTexture.point[2]==overlay.texture and overlay.optionalTexture.point[3]=="RIGHT")
local tooltipLines={};book.AddTooltip({AddLine=function(_,text) tooltipLines[#tooltipLines+1]=text end},8,0)
assert(table.concat(tooltipLines," "):find("OPTIONAL",1,true))
policy.SetOptional(false);book.Refresh();assert(not overlay.optionalTexture.shown and overlay.shown)
policy.SetOptional(true);book.Refresh();assert(overlay.optionalTexture.shown)
sak.SetDisplayOption("icons",false);book.Refresh();assert(not overlay.shown)
sak.SetDisplayOption("icons",true);book.Refresh();assert(overlay.shown)
row.slotIndex=3;book.Refresh();assert(not overlay.optionalTexture.shown,"Recycled row clears secondary badge")
-- TrainerSpells leaves the native rows visible while making the paged content transparent.
assert(row:IsVisible())
pager:SetAlpha(0);book.Refresh();assert(not overlay.shown,"Transparent native content must hide detached badges")
pager:SetAlpha(1);book.Refresh();assert(overlay.shown,"Returning to native tab restores badges")
pager.shown=false;book.Refresh();assert(not overlay.shown,"Hidden native content also hides badges")
pager.shown=true;book.Refresh();assert(overlay.shown)
row.Button.Icon.GetEffectiveAlpha=function() return 0 end
book.Refresh();assert(not overlay.shown,"Hidden spell icon must not leave a floating badge")
row.Button.Icon.GetEffectiveAlpha=nil;book.Refresh();assert(overlay.shown)
row.slotIndex=4;book.Refresh();assert(not overlay.shown)
row.slotIndex=1;row.spellBank=1;book.Refresh();assert(not overlay.shown,"Pet slots cannot inherit player badges")
row.spellBank=0;book.Refresh();assert(overlay.shown)
PlayerSpellsFrame.SpellBookFrame.shown=false;book.Refresh();assert(not overlay.shown)
local runtime=book.DebugText()
assert(runtime:find("nativeRows=1",1,true) and runtime:find("API slot=1",1,true))
assert(runtime:find("scans=",1,true) and runtime:find("legend:",1,true))
print("PASS: modern scan, future/passive exclusion and single/unranked BEST, cross-page ranks, player bank, recycling and detached overlays")

-- Ellesmere classic book's protected children are read-only as well.
local euiButton=frame();euiButton.slot=7;euiButton.icon={}
EUI_ClassicSpellbook=frame()
function EUI_ClassicSpellbook:GetChildren() return euiButton end
book.Hook();book.Refresh()
local euiOverlay=made[3]
assert(euiOverlay.shown and euiOverlay.texture.path==sak.SPELLBOOK_BADGES.eco.texture)
euiButton.slot=nil;book.Refresh();assert(not euiOverlay.shown)
assert(euiButton.created==0)
local tips={AddLine=function(self,text) self[#self+1]=text end}
sak.SetDisplayOption("text",false);book.AddTooltip(tips,7,0);assert(#tips==0)
sak.SetDisplayOption("text",true)
book.AddTooltip(tips,7,0);assert(tips[2]:find("ECO",1,true))
assert(tips[2]:find("pièces d'or",1,true) and tips[2]:find("pas d'économie de mana garantie",1,true))
local lowTips={AddLine=tips.AddLine};book.AddTooltip(lowTips,1,0)
assert(not table.concat(lowTips," "):find("pour économiser de la mana",1,true))
tips={AddLine=tips.AddLine};book.AddTooltip(tips,7,1);assert(#tips==0)
print("PASS: Ellesmere classic adapter, cleared slots and bank-scoped explanatory tooltip")

-- Advice on action bars / other spell tooltips, including recycled tooltips.
local function tip()
 local t={lines={},scripts={}}
 function t:AddLine(text) self.lines[#self.lines+1]=text end
 function t:HookScript(event,fn) self.scripts[event]=fn end
 function t:Clear() self.lines={};if self.scripts.OnTooltipCleared then self.scripts.OnTooltipCleared(self) end end
 return t
end
local external=tip()
book.AddSpellTooltip(external,1120)
assert(table.concat(external.lines," "):find("ECO",1,true))
local count=#external.lines
book.AddSpellTooltip(external,1120);book.AddTooltip(external,7,0)
assert(#external.lines==count,"Multiple tooltip paths must not duplicate advice")
external:Clear();book.AddSpellTooltip(external,8288)
assert(table.concat(external.lines," "):find("OPTIONAL",1,true))
assert(table.concat(external.lines," "):find("Le rang 1 suffit",1,true))
assert(table.concat(external.lines," "):find("seuls les rangs supplémentaires",1,true))
assert(not table.concat(external.lines," "):find("BEST",1,true),"External tooltips only add requested advice")
external:Clear();book.AddSpellTooltip(external,980);assert(#external.lines==0)
book.AddSpellTooltip(external,999999);assert(#external.lines==0,"Do not guess unknown IDs")
sak.SetDisplayOption("text",false);book.AddSpellTooltip(external,1120);assert(#external.lines==0)
sak.SetDisplayOption("text",true)
policy.SetOptional(false);external:Clear();book.AddSpellTooltip(external,8288);assert(#external.lines==0)
policy.SetOptional(true)
local processor
TooltipDataProcessor={AddTooltipPostCall=function(kind,fn) assert(kind==42);processor=fn end}
Enum.TooltipDataType={Spell=42}
book.Hook();assert(processor)
external:Clear();processor(external,{id=1120});assert(#external.lines>0)
TooltipDataProcessor=nil;book.spellTooltipHooked=nil
GameTooltip=tip();function GameTooltip:GetSpell() return "Drain d'âme",1120 end
function GameTooltip:HasScript(event) return event=="OnTooltipSetSpell" end
book.Hook();assert(GameTooltip.scripts.OnTooltipSetSpell)
GameTooltip.scripts.OnTooltipSetSpell(GameTooltip);assert(#GameTooltip.lines>0)
GameTooltip=nil
print("PASS: external exact-ID ECO/OPTIONAL tooltips, no duplicates, clear/reuse, settings, modern and legacy hooks")

class="MAGE";policy.SetRole("dps");policy.SetSpecialization("dps","fire")
external:Clear();book.AddSpellTooltip(external,1008)
assert(table.concat(external.lines," "):find("OPTIONAL",1,true),"Unlearned Amplify Magic needs purchase advice too")
policy.SetRoleEnabled("pvp",true);external:Clear();book.AddSpellTooltip(external,1008);assert(#external.lines==0)
class="WARLOCK";policy.SetRole("dps")
-- Legacy API scan and page slot resolution.
C_SpellBook=nil;PlayerSpellsFrame=nil;EUI_ClassicSpellbook=nil;Enum=nil
BOOKTYPE_SPELL="spell"
GetNumSpellTabs=function() return 1 end
GetSpellTabInfo=function() return "Affliction",nil,0,3 end
GetSpellBookItemInfo=function(slot,b) assert(b=="spell");return "SPELL",agony[slot].id end
GetSpellBookItemName=function(slot) return agony[slot].name,"Rang "..agony[slot].rank end
book.MarkDirty();r=book.Scan();assert(r[1].kind=="low" and r[3].kind=="best")
SpellBookFrame=frame();SpellBookFrame.bookType="spell"
SpellButton1=frame();SpellButton1.icon={}
SpellBook_GetSpellBookSlot=function() return 3 end
book.Refresh();local legacy=made[4];assert(legacy.texture.path==sak.SPELLBOOK_BADGES.best.texture)
SpellBookFrame.bookType="pet";book.Refresh();assert(not legacy.shown)
print("PASS: legacy scan, spellbook slot mapping and pet-tab cleanup")

-- Profile routing is separate from the UI library and remains combat-safe.
local opened={}
sak.Settings={Open=function(firstUse)
 opened[#opened+1]={firstUse=firstUse}
 SkillsAlreadyKnownDB.profilePromptSeen=true
end,Notify=function() end}
SkillsAlreadyKnownDB.levelingProfile=nil;SkillsAlreadyKnownDB.profilePromptSeen=nil
combat=true;policy.MaybePrompt();assert(policy.pending and #opened==0)
combat=false;policy.MaybePrompt();assert(opened[1].firstUse==true)
policy.SetRole("dps")
policy.MaybePrompt();assert(#opened==1)
policy.ShowSettings();assert(#opened==2 and not opened[2].firstUse)
print("PASS: deferred first-use profile, no repeat prompt and settings routing")
