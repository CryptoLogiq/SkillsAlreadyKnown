local characterDB={}
local class='MAGE'
local spellNames={[10]='Blizzard',[6141]='Blizzard',[1120]='Drain Soul',[8288]='Drain Soul',[90001]='Custom'}
UnitClass=function() return class,class end
C_Spell={GetSpellName=function(id) return spellNames[id] end}
SkillsAlreadyKnown={EnsureDB=function() return characterDB end,
 DisplayEnabled=function() return true end,
 AreaSpells={MAGE={[10]={spellID=10,tag='aoe'}}},
 ClassSkills={WARLOCK={[1120]={spellID=1120,tag='class',rankOneUtility=true}}},
 Settings={Notify=function() end},
}
SkillsAlreadyKnownAccountDB=nil
dofile('BadgeRules.lua');dofile('BadgeEditor.lua');dofile('SpellUsage.lua')
local sak=SkillsAlreadyKnown
local rules=sak.BadgeRules
assert(rules.Save('class',10,{allRanks=true,usage='survival',advice='optional'}))
assert(rules.Resolve('MAGE',6141,'usage')=='survival')
assert(sak.SpellUsage.ForSpell('MAGE',6141).tag=='survival')
assert(rules.Save('character',6141,{allRanks=false,usage='none'}))
assert(not sak.SpellUsage.ForSpell('MAGE',6141))
assert(sak.SpellUsage.ForSpell('MAGE',10).tag=='survival')
-- The character wins even when a class rule targets a precise rank.
assert(rules.Save('class',6141,{allRanks=false,usage='class'}))
assert(rules.Save('character',10,{allRanks=true,usage='aoe'}))
assert(rules.Resolve('MAGE',6141,'usage')=='none','Exact character ID wins over its broad family rule')
rules.Remove('character',6141)
assert(rules.Resolve('MAGE',6141,'usage')=='aoe','Character family wins over exact class ID')
local otherCharacter={}
local old=characterDB;characterDB=otherCharacter
assert(rules.Resolve('MAGE',10,'usage')=='survival','Shared class settings reach another character')
assert(rules.Resolve('MAGE',6141,'usage')=='class')
characterDB=old
class='WARLOCK';assert(not rules.Resolve('WARLOCK',10,'usage'))
assert(next(sak.BadgeEditor.List())==1120,'Only the current class is listed')
class='MAGE'
local options=sak.BadgeEditor.Options().args
assert(options.ranks.get()==true,'All ranks is the default for new IDs')
assert(options.add.validate(nil,'abc')~=true and options.add.validate(nil,'1.5')~=true)
assert(options.add.validate(nil,'999999')~=true)
assert(options.add.validate(nil,'90001')==true)
options.add.set(nil,'90001')
assert(not rules.Resolve('MAGE',90001,'usage'),'Drafts do not change rendering')
options.usage.set(nil,'class');options.combat.set(nil,'mixed');options.save.func()
assert(rules.Resolve('MAGE',90001,'usage')=='class')
assert(rules.Resolve('MAGE',90001,'combat')=='mixed')
assert(sak.BadgeEditor.List()[90001])
assert(not options.reset.disabled() and options.reset.confirm())
options.reset.func();assert(not rules.Resolve('MAGE',90001,'usage'))
options.scope.set(nil,'class')
options.add.set(nil,'90001');assert(options.ranks.get()==true)
options.ranks.set(nil,false);options.usage.set(nil,'aoe');options.save.func()
assert(SkillsAlreadyKnownAccountDB.badgeRules.MAGE[90001].allRanks==false)
assert(not rules.Save('character',-1,{usage='aoe'}))
assert(not rules.Save('character',90001,{usage='not-a-badge'}))
print('PASS: account/class sharing, character precedence, exact-rank exceptions, class isolation, ID validation, draft/save/restore and all-ranks defaults')
