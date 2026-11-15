SkillsAlreadyKnown = nil
SkillsAlreadyKnownDB = nil
SkillsAlreadyKnownAccountDB = nil
GetLocale = function() return 'frFR' end
local class = 'MAGE'
UnitClass = function() return class, class, 8 end
local aliases = {}
C_Spell = { GetSpellName = function(id) return 'Native-' .. (aliases[id] or id) end }
dofile('Core.lua')
dofile('traductions/fr_FR.lua'); dofile('traductions/en-EN.lua'); dofile('Localization.lua')
dofile('data/UtilitySpells.lua'); dofile('data/SpellHints.lua')
SkillsAlreadyKnown.ContentUsage = { classes = {} }
dofile('BadgeRules.lua'); dofile('ContentTags.lua'); dofile('SpellUsage.lua')
SkillsAlreadyKnown.SpellBook = { StateForSpell = function() end }
dofile('SpellTooltips.lua')
dofile('TooltipBadges.lua')
local s = SkillsAlreadyKnown
SkillsAlreadyKnownDB = { language = 'en-EN' }
s.Localization.Initialize()
local entries, classes = 0, 0
for cls, catalogue in pairs(s.UtilitySpells) do
 classes = classes + 1
 for id, entry in pairs(catalogue) do
  entries = entries + 1
  assert(entry.spellID == id and entry.source and entry.reviewed)
  assert(s.SpellUsage.ForSpell(cls, id) == entry)
  for _, tag in ipairs(entry.tags) do assert(tag=='kick' or tag=='taunt' or tag=='aggro') end
 end
end
assert(classes==9 and entries==24)
local combined = s.SpellUsage.ForDisplay('MAGE', 2139)
assert(combined.badgeText=='KICK / AGGRO' and combined.width>70)
assert(not s.SpellUsage.ProtectPurchase('MAGE', {ids={[2139]=true}}, 1), 'Utility display must not change purchase policy')
assert(s.SetDisplayOption('kick',false))
assert(s.SpellUsage.ForDisplay('MAGE',2139).badgeText=='AGGRO')
assert(s.SpellUsage.ForSpell('MAGE',2139).tags[1]=='kick','Preferences do not alter classification data')
assert(s.SetDisplayOption('aggro',false));assert(not s.SpellUsage.ForDisplay('MAGE',2139))
s.SetDisplayOption('kick',true);s.SetDisplayOption('aggro',true)
local collected=s.TooltipBadges.Collect(2139)
assert(collected[1].badgeText=='KICK / AGGRO')
class='WARLOCK'
assert(s.SpellUsage.ForSpell(class,3716).tag=='aggro', 'Torment is threat, not forced taunt')
assert(not s.SpellUsage.ForSpell('PRIEST',15487),'Do not classify every silence as an interrupt')
assert(not s.SpellUsage.ForSpell('WARRIOR',1160),'Do not infer additional threat from old Demo Shout recommendations')
assert(not s.SpellUsage.ForSpell('DRUID',6807),'No AGGRO without explicit reviewed threat wording')
class='MAGE'
assert(s.BadgeRules.Save('character',2139,{usage='taunt',allRanks=false}))
assert(s.SpellUsage.ForSpell(class,2139).tag=='taunt')
assert(s.BadgeRules.Save('character',2139,{usage='none',allRanks=false}))
assert(not s.SpellUsage.ForSpell(class,2139))
s.EnsureDB().badgeRules = {}
local function tooltip()
 local tip={lines={},hooks={}}
 function tip:AddLine(text) self.lines[#self.lines+1]=text end
 function tip:HookScript(event,fn) self.hooks[event]=self.hooks[event] or {};table.insert(self.hooks[event],fn) end
 function tip:clear() self.lines={};for _,fn in ipairs(self.hooks.OnTooltipCleared or {}) do fn(self) end end
 return tip
end
s.TooltipBadges.Paint=function() end
local tips=0
for cls, catalogue in pairs(s.SpellHints) do
 class=cls
 for id,hint in pairs(catalogue) do
  tips=tips+1
  local t=tooltip()
  s.SpellBook.AddSpellTooltip(t,id)
  assert(table.concat(t.lines,'\n'):find(s.L(hint.textKey),1,true), 'Primary tooltip uses localized hint')
  local count=#t.lines
  s.SpellBook.AddSpellTooltip(t,id); assert(#t.lines==count)
  t:clear(); aliases[id+10000000]=id
  s.SpellBook.AddSpellTooltip(t,id+10000000)
  assert(table.concat(t.lines,'\n'):find(s.L(hint.textKey),1,true),'Other ranks match native names within the class')
 end
end
assert(tips==12)
class='MAGE';s.SetDisplayOption('combinations',false)
local hidden=tooltip();s.SpellBook.AddSpellTooltip(hidden,1240047)
assert(#hidden.lines==0)
print('PASS: 24 reviewed utilities, cumulative/independent tags, custom overrides, unchanged purchase policy, 12 selective hints, rank matching, language and tooltip recycling')
