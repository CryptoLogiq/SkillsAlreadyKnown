-- Run: lua scripts/test-spellbook-roles.lua
local root=arg[1] or "."
local class="PALADIN"
UnitClass=function() return class,class end
for _,file in ipairs({"Core.lua","data/ClassRoles.lua","data/LevelingRecommendations.lua",
 "data/TalentSummaries.lua","PlayerRoles.lua","SpellRanks.lua","SpellBook.lua",
 "TalentTooltips.lua","TalentRoles.lua","SpellBookRoles.lua"}) do
 assert(loadfile(root.."/"..file))()
end
local s=SkillsAlreadyKnown
local made={}
local function font(text,size)
 local f={text=text,size=size or 12,shown=true}
 function f:GetText() return self.text end
 function f:GetFont() return "font",self.size end
 function f:GetWidth() return 200 end
 function f:GetStringWidth() return 100 end
 function f:GetJustifyH() return "LEFT" end
 function f:GetParent() return self.parent end
 function f:IsVisible() return self.shown end
 function f:SetText(value) self.text=value end
 for _,key in ipairs({"SetPoint","SetAllPoints","SetJustifyH","SetFontObject","SetTextColor","SetShadowColor","SetShadowOffset"}) do f[key]=function() end end
 return f
end
local function frame()
 local f={shown=true,alpha=1,level=100,scripts={},points={}}
 function f:IsVisible() return self.shown end
 function f:GetAlpha() return self.alpha end
 function f:GetEffectiveAlpha() return self.alpha end
 function f:GetEffectiveScale() return 0.64 end
 function f:GetFrameStrata() return self.strata or "MEDIUM" end
 function f:GetFrameLevel() return self.level end
 function f:GetParent() return self.parent end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:SetShown(value) self.shown=value end
 function f:SetSize(w,h) self.width,self.height=w,h end
 function f:SetScale(value) self.scale=value end
 function f:SetFrameStrata(value) self.strata=value end
 function f:SetFrameLevel(value) self.level=value end
 function f:SetBackdrop(value) self.backdrop=value end
 function f:SetBackdropColor(...) self.background={...} end
 function f:SetBackdropBorderColor(...) self.border={...} end
 function f:EnableMouse(value) self.mouse=value end
 function f:SetScript(event,callback) self.scripts[event]=callback end
 function f:SetPoint(...) self.points[#self.points+1]={...} end
 function f:ClearAllPoints() self.points={} end
 function f:CreateFontString() return font() end
 return f
end
UIParent={GetEffectiveScale=function() return 0.64 end}
CreateFrame=function(_,_,parent)
 local f=frame();f.parent=parent;made[#made+1]=f;return f
end
local book,paged=frame(),frame()
paged.parent=book;book.PagedSpellsFrame=paged
local small,title=font("Protection",10),font("Vindicte",24)
small.parent=paged;title.parent=paged
function paged:GetRegions() return small,title end
PlayerSpellsFrame={SpellBookFrame=book}
s.SpellBookRoles.Refresh()
local label=made[1]
assert(label.shown and label.parent==UIParent and label.width==64 and label.height==36)
assert(label.text.text:find("DPS",1,true) and label.text.text:find(":20:20:",1,true))
assert(label.points[1][1]=="RIGHT" and label.points[1][2]==title and label.points[1][3]=="LEFT")
assert(label.points[1][4]==-8 and label.border[4]==1 and label.scale==1)
assert(label.strata=="HIGH" and label.level==120 and not label.leveling.shown)
title.text="|cffe5e5e5Vindicte|r"
s.SpellBookRoles.Refresh()
assert(label.shown and label.text.text:find("DPS",1,true))
assert(title.text=="|cffe5e5e5Vindicte|r", "Do not rewrite DarkMode's title")
small.shown=false
title.text="Protection";s.SpellBookRoles.Refresh();assert(label.text.text:find("Tank",1,true))
title.text="Sacré";s.SpellBookRoles.Refresh();assert(label.text.text:find("Heal",1,true))
local lines={}
GameTooltip={SetOwner=function(_,owner) assert(owner==label) end,AddLine=function(_,line) lines[#lines+1]=line end,Show=function() end,Hide=function() end}
label.scripts.OnEnter(label)
assert(table.concat(lines," "):find(s.TalentSummaries.PALADIN.holy.summary,1,true))
assert(not table.concat(lines," "):find(s.TalentSummaries.PALADIN.retribution.summary,1,true))
for _,name in ipairs({"Général","TrainerSpells","Alchimie"}) do
 title.text=name;s.SpellBookRoles.Refresh();assert(not label.shown)
end
title.text="Vindicte";paged.alpha=0;s.SpellBookRoles.Refresh();assert(not label.shown)
paged.alpha=1;s.SpellBookRoles.Refresh();assert(label.shown)
s.SetDisplayOption("iconsSpellbook",false);s.SpellBookRoles.Refresh();assert(not label.shown)
s.SetDisplayOption("iconsSpellbook",true)
s.SetDisplayOption("icons",false);s.SpellBookRoles.Refresh()
assert(label.shown and not label.text.text:find("|T",1,true))
s.SetDisplayOption("icons",true)
s.SetDisplayOption("text",false);s.SpellBookRoles.Refresh();assert(not label.shown)
s.SetDisplayOption("text",true)
class="DRUID";title.text="Farouche";s.SpellBookRoles.Refresh()
assert(label.shown and label.height==44 and label.text.text:find("Tank",1,true) and label.text.text:find("DPS",1,true))
assert(#made==2,"Reuse the role display and its existing LEVELING child")
assert(s.EnsureDB().levelingProfile==nil,"Informational roles must not select a player role")
print("PASS: native title identification, compact left-side shared role widget, active tree changes, own tooltip, Feral dual role, foreign/transparent views, preferences and no role mutation")
