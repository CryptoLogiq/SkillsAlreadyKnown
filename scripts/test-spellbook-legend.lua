-- Run: lua scripts/test-spellbook-legend.lua
local root=arg[1] or "."
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/SpellRanks.lua"))()
assert(loadfile(root.."/SpellBook.lua"))()
assert(loadfile(root .. "/SpellTooltips.lua"))()
local sak=SkillsAlreadyKnown
local made={}
local function region()
 local r={}
 function r:SetSize(w,h) self.width,self.height=w,h end
 function r:SetWidth(w) self.width=w end
 function r:SetHeight(h) self.height=h end
 function r:SetPoint(...) self.point={...} end
 function r:ClearAllPoints() end
 function r:SetTexture(value) self.texture=value end
 function r:SetText(value) self.text=value end
 function r:SetShown(value) self.shown=not not value end
 for _,key in ipairs({"SetJustifyH","SetJustifyV","SetWordWrap","SetMaxLines","SetTextColor","SetShadowColor","SetShadowOffset"}) do r[key]=function() end end
 return r
end
UIParent={GetEffectiveScale=function() return 1 end}
CreateFrame=function(_,_,parent)
 local f=region();f.parent=parent
 function f:EnableMouse(value) self.mouse=value end
 function f:CreateTexture() return region() end
 function f:CreateFontString() return region() end
 function f:SetScale(value) self.scale=value end
 function f:SetFrameStrata(value) self.strata=value end
 function f:SetFrameLevel(value) self.level=value end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 made[#made+1]=f;return f
end
local width,shown,hostStrata=574,true,"MEDIUM"
local paged={GetWidth=function() return width end,GetFrameStrata=function() return "MEDIUM" end,GetFrameLevel=function() return 101 end,GetEffectiveScale=function() return 1.25 end}
local book={PagedSpellsFrame=paged,IsVisible=function() return shown end,
 GetEffectiveScale=function() return 1.25 end,GetFrameStrata=function() return hostStrata end,
 GetFrameLevel=function() return 100 end}
paged.GetParent=function() return book end
sak.SpellBook.UpdateLegend(book)
local legend=sak.SpellBook.legend
assert(legend.shown and legend.parent==UIParent and legend.mouse==false)
assert(legend.point[1]=="TOPRIGHT" and legend.point[2]==paged and legend.point[5]==-24)
assert(legend.height==56 and legend.width<=360 and legend.scale==1.25)
assert(legend.strata=="HIGH" and legend.level==121,"Legend clears the real 574-wide Camelot book at levels 100/101")
hostStrata="DIALOG";sak.SpellBook.UpdateLegend(book);assert(legend.strata=="DIALOG")
hostStrata="MEDIUM";sak.SpellBook.UpdateLegend(book);assert(legend.strata=="HIGH")
assert(legend.rows[1].texture.texture==sak.SPELLBOOK_BADGES.eco.texture)
assert(legend.rows[2].texture.texture==sak.SPELLBOOK_BADGES.best.texture)
assert(legend.rows[1].label.text:find("Économie d'or",1,true))
assert(legend.rows[2].label.text:find("même seul",1,true))
assert(legend.rows[2].label.point[5]<legend.rows[1].label.point[5])
local enabled=true
sak.RankPolicy={OptionalEnabled=function() return enabled end}
sak.SpellBook.UpdateLegend(book)
assert(legend.optionalTexture.shown and legend.optionalTexture.texture==sak.SPELLBOOK_BADGES.optional.texture)
assert(legend.rows[2].label.text:find("OPTIONAL",1,true) and legend.rows[2].label.point[4]==112)
assert(legend.height==56,"New marker must not expand into spell rows")
enabled=false;sak.SpellBook.UpdateLegend(book);assert(not legend.optionalTexture.shown)
enabled=true
sak.EnsureDB().displayOptions.icons=false
sak.SpellBook.UpdateLegend(book)
assert(legend.shown and not legend.rows[1].texture.shown and legend.rows[1].label.text:find("ECO :",1,true))
assert(not legend.optionalTexture.shown and legend.rows[2].label.text:find("OPTIONAL",1,true))
sak.EnsureDB().displayOptions.text=false
sak.SpellBook.UpdateLegend(book);assert(not legend.shown)
sak.EnsureDB().displayOptions.text=true
sak.EnsureDB().displayOptions.icons=true
width=900;sak.SpellBook.UpdateLegend(book);assert(legend.shown and legend.width==360 and #made==1)
width=400;sak.SpellBook.UpdateLegend(book);assert(not legend.shown,"Do not crowd narrow books")
width=680;shown=false;sak.SpellBook.UpdateLegend(book);assert(not legend.shown)
shown=true;sak.SpellBook.UpdateLegend(book);assert(legend.shown)
paged.GetAlpha=function() return 0 end
sak.SpellBook.UpdateLegend(book);assert(not legend.shown,"Foreign tab keeps root shown but blanks native content")
paged.GetAlpha=function() return 1 end
sak.SpellBook.UpdateLegend(book);assert(legend.shown,"Native tab restores legend")
paged.GetEffectiveAlpha=function() return 0 end
sak.SpellBook.UpdateLegend(book);assert(not legend.shown,"Inherited transparent content hides legend")
paged.GetEffectiveAlpha=nil
sak.SpellBook.UpdateLegend(nil);assert(not legend.shown)
sak.SpellBook.UpdateLegend({IsVisible=function() return true end});assert(not legend.shown)
print("PASS: detached compact header legend, game scale, resize, icon/text preferences, hidden/narrow books and no duplicate frames")

sak.SetDisplayOption("icons", true)
sak.SetDisplayOption("iconsSpellbook", false)
sak.SpellBook.UpdateLegend(book)
assert(legend.shown and not legend.rows[1].texture.shown)
sak.SetDisplayOption("iconsSpellbook", true)
sak.SpellBook.UpdateLegend(book)
assert(legend.rows[1].texture.shown)
print("PASS: spellbook category hides legend badges while retaining explanations")
