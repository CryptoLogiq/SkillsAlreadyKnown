SkillsAlreadyKnown = nil
SkillsAlreadyKnownDB = nil
GetLocale = function() return 'frFR' end
local class = 'PALADIN'
UnitClass = function() return class, class, 2 end
C_Spell = { GetSpellName = function(id) return 'Spell-' .. id end }
dofile('Core.lua'); dofile('traductions/fr_FR.lua'); dofile('traductions/en-EN.lua'); dofile('Localization.lua')
dofile('data/SurvivalAdvice.lua'); dofile('data/UtilitySpells.lua')
SkillsAlreadyKnown.ContentUsage = {classes={}}
dofile('ContentTags.lua'); dofile('SpellUsage.lua'); dofile('TooltipBadges.lua')
local s=SkillsAlreadyKnown
SkillsAlreadyKnownDB={language='en-EN'}
s.Localization.Initialize()
local classes,count=0,0
for cls,spells in pairs(s.SurvivalAdvice) do
 classes=classes+1
 for id,entry in pairs(spells) do
  count=count+1
  assert(entry.spellID==id and entry.source and entry.reviewed and entry.reason)
  assert(s.SpellUsage.ProtectPurchase(cls,{ids={[id]=true}},1))
  assert(not s.SpellUsage.ProtectPurchase(cls,{ids={[id]=true}},2),'Do not infer that rank 1 suffices')
 end
end
assert(classes==9 and count==56)
for cls,id in pairs({DRUID=22812,HUNTER=5384,MAGE=11958,PALADIN=5573,PRIEST=17,ROGUE=5277,SHAMAN=2484,WARLOCK=6789,WARRIOR=871}) do
 assert(s.SpellUsage.ForSpell(cls,id).tag=='survival', 'Cover an essential defensive for every class')
end
assert(s.SpellUsage.ForSpell('PALADIN',5573)==s.SurvivalAdvice.PALADIN[498])
assert(s.SpellUsage.ForSpell('PALADIN',1020)==s.SurvivalAdvice.PALADIN[642])
assert(s.SpellUsage.ForTalent('MAGE',nil,105769).spellID==11958)
assert(s.SpellUsage.ForTalent('WARRIOR',nil,105970).spellID==12975)
assert(not s.SpellUsage.ForSpell('MAGE',45438),'Do not import a different expansion’s Ice Block ID')
assert(not s.SpellUsage.ForSpell('WARRIOR',1719),'Recklessness is not a defensive')
assert(not s.SpellUsage.ForSpell('WARLOCK',1454),'Life Tap is not directly survival')
assert(not s.SpellUsage.ForSpell('PALADIN',19752),'Sacrificing the caster is not a personal defensive')
class='SHAMAN'
local entry=s.SpellUsage.ForDisplay(class,5730)
assert(entry.badgeText=='SURVIVAL / AGGRO')
assert(#s.UtilitySpells.SHAMAN[5730].tags==1,'Do not mutate utility tags')
s.SetDisplayOption('survival',false)
assert(s.SpellUsage.ForDisplay(class,5730).badgeText=='AGGRO')
s.SetDisplayOption('aggro',false); assert(not s.SpellUsage.ForDisplay(class,5730))
s.SetDisplayOption('survival',true)
assert(s.SpellUsage.ForDisplay(class,5730).badgeText=='SURVIVAL')
local lines={}
s.SpellUsage.AddTooltip({AddLine=function(_,line)lines[#lines+1]=line end},5730)
assert(lines[1]:find('The totem can distract',1,true),'New reasons follow the saved language')
print('PASS: 56 survival families across nine classes, Divine Protection/Shield aliases, talent node anchors, explicit exclusions, rank policy and cumulative threat rendering')
