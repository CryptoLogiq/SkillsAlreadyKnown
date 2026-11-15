SkillsAlreadyKnown = nil
SkillsAlreadyKnownDB = nil
SkillsAlreadyKnownAccountDB = nil
GetLocale = function() return 'frFR' end
local class = 'PALADIN'
UnitClass = function() return class, class, 2 end
local aliases = {}
C_Spell = { GetSpellName = function(id) return 'Native-' .. (aliases[id] or id) end }
dofile('Core.lua'); dofile('traductions/fr_FR.lua'); dofile('traductions/en-EN.lua'); dofile('Localization.lua')
dofile('data/ClassRoles.lua'); dofile('data/RoleStances.lua'); dofile('data/UtilitySpells.lua')
dofile('BadgeRules.lua')
SkillsAlreadyKnown.ContentUsage = { classes = {} }
dofile('ContentTags.lua'); dofile('SpellUsage.lua'); dofile('TooltipBadges.lua')
local s = SkillsAlreadyKnown
SkillsAlreadyKnownDB = { language = 'en-EN', levelingProfile = { sentinel = true } }
s.Localization.Initialize()
local count = 0
for cls, entries in pairs(s.RoleStances) do
 for id, entry in pairs(entries) do
  count = count + 1
  assert(entry.spellID == id and entry.role == entry.tag)
  assert(s.ClassRoles.classes[cls].roles[entry.role], 'Orientation uses an actual supported class role')
  assert(entry.source and entry.reviewed)
  local result = s.SpellUsage.ForSpell(cls,id)
  assert(result.role == entry.role)
 end
end
assert(count == 14)
local fury = s.SpellUsage.ForDisplay('PALADIN',25780)
assert(fury.badgeText == 'AGGRO / TANK')
local seal = s.SpellUsage.ForDisplay('PALADIN',20163)
assert(seal.badgeText == 'TAUNT / TANK')
assert(s.UtilitySpells.PALADIN[25780].tags[2] == nil, 'Never mutate the shipped utility classification')
s.SetDisplayOption('tank',false)
assert(s.SpellUsage.ForDisplay('PALADIN',25780).badgeText == 'AGGRO')
s.SetDisplayOption('aggro',false)
assert(not s.SpellUsage.ForDisplay('PALADIN',25780))
s.SetDisplayOption('tank',true)
assert(s.SpellUsage.ForDisplay('PALADIN',25780).badgeText == 'TANK')
assert(s.EnsureDB().levelingProfile.sentinel, 'Appearance preferences do not alter player roles')
assert(not s.SpellUsage.ProtectPurchase('DRUID',{ids={[5487]=true}},1), 'Role hints do not force a purchase recommendation')
assert(s.SpellUsage.ForSpell('PRIEST',27827) == s.RoleStances.PRIEST[20711])
assert(s.SpellUsage.ForDisplay('PRIEST',27827).tag == 'heal')
aliases[999901] = 25780
assert(s.SpellUsage.ForDisplay('PALADIN',999901).tag == 'tank')
assert(not s.SpellUsage.ForSpell('MAGE',5487), 'No cross-class orientation')
assert(not s.SpellUsage.ForSpell('DRUID',783), 'Travel forms have no fabricated combat role')
assert(not s.SpellUsage.ForSpell('PRIEST',588), 'Inner Fire is not a healing-only stance')
s.SetDisplayOption('aggro',true)
local badges=s.TooltipBadges.Collect(25780)
assert(badges[1].badgeText=='AGGRO / TANK')
assert(s.BadgeRules.Save('character',25780,{usage='heal',allRanks=false}))
assert(s.SpellUsage.ForDisplay('PALADIN',25780).tag=='heal', 'Custom explicitly replaces shipped classification')
print('PASS: 14 reviewed role orientations, ClassRoles links, utility/role stacking, independent toggles, aliases, class isolation, no role assignment and Custom overrides')

assert(s.SpellUsage.ForDisplay('PALADIN',465).tag=='tank')
assert(s.SpellUsage.ForDisplay('PALADIN',7294).tag=='dps')
assert(s.SpellUsage.ForDisplay('PALADIN',19746).badgeText=='HEAL / DPS')
s.SetDisplayOption('heal',false)
assert(s.SpellUsage.ForDisplay('PALADIN',19746).badgeText=='DPS')
aliases[10290]=465; aliases[10298]=7294
assert(s.SpellUsage.ForDisplay('PALADIN',10290).tag=='tank')
assert(s.SpellUsage.ForDisplay('PALADIN',10298).tag=='dps')
assert(not s.SpellUsage.ForSpell('PALADIN',19876),'Resistance aura has no exclusive combat role')
