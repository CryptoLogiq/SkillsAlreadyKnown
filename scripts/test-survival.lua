dofile('scripts/test-trainer-advice.lua')
local sak = SkillsAlreadyKnown
dofile('data/SurvivalAdvice.lua')
dofile('data/AreaSpells.lua')
dofile('data/AreaTalents.lua')
dofile('SpellUsage.lua')
local survival = sak.SpellUsage
local count = 0
for class, spells in pairs(sak.SurvivalAdvice) do
  for id, entry in pairs(spells) do
    count = count + 1
    assert(entry.spellID == id and entry.tag == 'survival')
    assert(survival.ForSpell(class,id) == entry)
  end
end
assert(count == 56)
C_Spell = { GetSpellName = function(id)
  if id == 1463 or id == 999001 then return 'Mana Shield' end
end }
assert(survival.ForSpell('MAGE',999001) == sak.SurvivalAdvice.MAGE[1463])
assert(not survival.ForSpell('MAGE',999002))
assert(not survival.ForSpell('WARLOCK',1463))
UnitClass=function() return 'Mage','MAGE' end
SkillsAlreadyKnownDB.levelingProfile=nil
sak.RankPolicy.SetRole('dps');sak.RankPolicy.SetSpecialization('dps','arcane')
assert(not sak.RankPolicy.PurchaseAdvice('MAGE',1463,1),'Protect first defensive purchase')
assert(sak.RankPolicy.PurchaseAdvice('MAGE',1463,2)=='optional','Keep extra-rank advice independent')
local frames={}
local function frame()
 local f={shown=true}
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:IsVisible() return self.shown end
 function f:SetPoint(...) self.point={...} end
 function f:ClearAllPoints() end
 function f:SetScript(_,callback) self.tick=callback end
 frames[#frames+1]=f
 return f
end
CreateFrame=frame
sak.ContentTags={CreateBadge=frame,PrepareBadge=function(display,owner,entry) display.entry=entry end}
local owner,anchor=frame(),frame()
survival.Paint(owner,anchor,1463,'iconsSpellbook',2)
local display=frames[3]
assert(display.shown and display.entry == sak.SurvivalAdvice.MAGE[1463])
assert(display.point[1]=='BOTTOMLEFT' and display.point[2]==anchor and display.point[3]=='TOPLEFT' and display.point[4]==0 and display.point[5]==-6,'Book categories sit above rank badges, not beside the spell name')
survival.Paint(owner,anchor,1463,'iconsTrainer',4)
assert(display.point[1]=='LEFT' and display.point[3]=='RIGHT' and display.point[4]==4,'Trainer positioning stays independent')

survival.Paint(owner,anchor,1463,'iconsSpellbook',2)
assert(#frames==4,'Reuse the badge and cleanup driver')
sak.EnsureDB().displayOptions.survival=false
frames[4].tick();assert(not display.shown)
sak.EnsureDB().displayOptions.survival=true
survival.Paint(owner,anchor,1463,'iconsSpellbook',2);assert(display.shown)
anchor:Hide();frames[4].tick();assert(not display.shown)
anchor:Show();survival.Paint(owner,anchor,999002,'iconsSpellbook');assert(not display.shown)
local lines,hooks={},{}
local tip={AddLine=function(_,text) lines[#lines+1]=text end,HookScript=function(_,key,fn) hooks[key]=fn end}
survival.AddTooltip(tip,1463);survival.AddTooltip(tip,1463)
assert(#lines==1)
hooks.OnTooltipCleared(tip);survival.AddTooltip(tip,1463);assert(#lines==2)
print('PASS: survival data, exact/rank/class matching, first-purchase protection, independent extra ranks, category hiding, recycling and tooltip reuse')

local areaCount=0
for class,spells in pairs(sak.AreaSpells) do
  for id,entry in pairs(spells) do
    areaCount=areaCount+1
    assert(entry.tag=='aoe' and survival.ForSpell(class,id)==entry)
    for _,rank in ipairs({1,2,8}) do
      assert(survival.ProtectPurchase(class,{ids={[id]=true}},rank))
      assert(not sak.RankPolicy.OptionalAdvice(class,{ids={[id]=true}},rank))
    end
  end
end
assert(areaCount==21)
assert(survival.ForSpell('MAGE',10).tag=='aoe')
assert(survival.ForSpell('WARLOCK',5740).tag=='aoe')
assert(survival.ForSpell('PALADIN',26573).tag=='aoe')
for _,rule in ipairs(sak.RankPolicy.PurchaseCatalogue) do
  assert(not (sak.AreaSpells[rule.class] and sak.AreaSpells[rule.class][rule.baseID]),'No optional AoE rules')
end
sak.EnsureDB().displayOptions.aoe=true
survival.Paint(owner,anchor,10,'iconsSpellbook');assert(display.shown and display.entry.tag=='aoe')
sak.EnsureDB().displayOptions.aoe=false
frames[4].tick();assert(not display.shown)
survival.Paint(owner,anchor,1463,'iconsSpellbook');assert(display.shown,'AOE toggle must not hide SURVIVAL')
print('PASS: 21 AoE/cleave families, three requested examples, no optional area ranks and independent category switches')

-- Usage is inherited by every rank even when names have not loaded yet.
C_Spell = { GetBaseSpell = function(id)
  if id == 999003 or id == 1463 then return 1463 end
  return id
end }
assert(survival.ForDisplay('MAGE',999003) == sak.SurvivalAdvice.MAGE[1463])
C_Spell.GetSpellName = function() return nil end
GetSpellInfo = function(id)
  if id == 999004 or id == 1463 then return 'Bouclier de mana' end
end
assert(survival.ForSpell('MAGE',999004) == sak.SurvivalAdvice.MAGE[1463])
sak.UtilitySpells = { DRUID = { [16979] = {spellID=16979,tag='kick',exactOnly=true} } }
C_Spell.GetBaseSpell = function(id) return id == 999005 and 16979 or id end
assert(not survival.ForSpell('DRUID',999005),'Distinct form variants must retain their own mechanics')
print('PASS: usage categories inherit native rank families and legacy localized names, preserving form exceptions')
