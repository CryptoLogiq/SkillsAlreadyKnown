SkillsAlreadyKnown=nil
SkillsAlreadyKnownDB=nil
GetLocale=function()return 'frFR'end
local class='PALADIN'
UnitClass=function()return class,class,2 end
local aliases={}
C_Spell={GetSpellName=function(id)return 'Native-'..(aliases[id]or id)end}
dofile('Core.lua');dofile('traductions/fr_FR.lua');dofile('traductions/en-EN.lua');dofile('Localization.lua')
dofile('data/ClassRoles.lua');dofile('data/TalentRecommendations.lua');dofile('TalentAdvice.lua')
local s=SkillsAlreadyKnown
SkillsAlreadyKnownDB={language='en-EN',levelingProfile={sentinel=true}}
s.Localization.Initialize()
s.PlayerRoles={RoleLabels=function()return {tank='|Trole-tank:18:18|t Tank',heal='|Trole-heal:18:18|t Heal',dps='|Trole-dps:18:18|t DPS'}end}
local count,classes,specs=0,0,{}
for cls,entries in pairs(s.TalentRecommendations.classes)do
 classes=classes+1
 for id,e in pairs(entries)do
  count=count+1
  assert(e.spellID==id and e.nodeID and e.basis=='theorycraft-build')
  assert(s.TalentAdvice.Find(cls,nil,e.nodeID)==e)
  local labels=s.TalentAdvice.Labels(cls,e)
  assert(#labels==#e.choices)
  for i,choice in ipairs(e.choices)do
   specs[cls..':'..choice.spec]=true
   local data=s.ClassRoles.classes[cls]
   assert(labels[i]:find(data.specializations[choice.spec],1,true),'Always show specialization')
   assert(labels[i]:find('|TInterface\\Icons\\',1,true),'Use a game specialization icon')
   local roles=0;for _ in pairs(data.roles)do roles=roles+1 end
   if roles==1 then assert(not labels[i]:find('role-dps',1,true),'Single-role classes show the spec, not a redundant role')end
  end
 end
end
local n=0;for _ in pairs(specs)do n=n+1 end
assert(count==7 and classes==1 and n==3)
local function tip()
 local t={lines={},hooks={}}
 function t:AddLine(line)self.lines[#self.lines+1]=line end
 function t:HookScript(event,cb)self.hooks[event]=cb end
 return t
end
local t=tip()
s.TalentAdvice.AddTooltip(t,1310905)
assert(t.lines[1]:find('Recommended for:',1,true))
assert(t.lines[1]:find('Protection',1,true)and t.lines[1]:find('Shockprot',1,true))
assert(not t.lines[1]:find('Retribution',1,true),'Do not generalize a situational build into another spec')
assert(not t.lines[1]:find('Holy',1,true),'Holy-tree damage improvement does not imply healer advice')
assert(t.lines[2]:find('Situational',1,true))
s.TalentAdvice.AddTooltip(t,1310905);assert(#t.lines==2,'Deduplicate tooltip callbacks')
t.hooks.OnTooltipCleared(t);t.lines={}
s.TalentAdvice.AddTooltip(t,1237268);assert(#t.lines==2)
aliases[999001]=1310905
assert(s.TalentAdvice.Find(class,999001).spellID==1310905,'All ranks keep the same recommendations')
assert(not s.TalentAdvice.Find('MAGE',1310905))
assert(not s.TalentAdvice.Find(class,999002))
s.SetDisplayOption('icons',false)
local text=s.TalentAdvice.Labels(class,s.TalentRecommendations.classes[class][1310905])[1]
assert(not text:find('|T',1,true)and text:find('Protection',1,true))
s.SetDisplayOption('text',false);local hidden=tip();s.TalentAdvice.AddTooltip(hidden,1310905);assert(#hidden.lines==0)
s.SetDisplayOption('text',true);s.SetDisplayOption('iconsTalents',false);s.TalentAdvice.AddTooltip(hidden,1310905);assert(#hidden.lines==0)
s.SetDisplayOption('iconsTalents',true);s.SetDisplayOption('icons',true)
SkillsAlreadyKnownDB.language='fr_FR'
dofile('Localization.lua');dofile('data/ClassRoles.lua');dofile('TalentAdvice.lua');s.Localization.Initialize()
local fr=tip();s.TalentAdvice.AddTooltip(fr,1310905)
assert(fr.lines[1]:find('Conseillé pour',1,true)and fr.lines[1]:find('Protection',1,true))
assert(s.EnsureDB().levelingProfile.sentinel,'Suggestions never select roles')
-- Exercise the actual external/native spell tooltip integration.
s.SpellBook={StateForSpell=function()end,Explanations={}}
s.TooltipBadges=nil
local post
Enum={TooltipDataType={Spell=1}}
TooltipDataProcessor={AddTooltipPostCall=function(_,callback)post=callback end}
dofile('SpellTooltips.lua');s.SpellTooltips.Hook()
local live=tip();post(live,{id=1310905})
assert(live.lines[1]:find('Conseillé pour',1,true))
post(live,{id=1310905});assert(#live.lines==2)
-- A plausible effect or popular pick must never become a recommendation.
s.TalentRecommendations.classes.MAGE={ [12043]={spellID=12043,basis='editorial-mechanics',choices={{role='dps',spec='arcane'}}} }
assert(not s.TalentAdvice.Find('MAGE',12043),'Reject the previous mechanics-only suggestions')
s.TalentRecommendations.classes.MAGE[12043].basis='theorycraft-build'
assert(not s.TalentAdvice.Find('MAGE',12043),'Require named author, build section and source evidence')
for _,entries in pairs(s.TalentRecommendations.classes)do
 for _,entry in pairs(entries)do
  if entry.spellID~=12043 then
   for _,choice in ipairs(entry.choices)do assert(choice.author and choice.source and choice.section and choice.reviewed and choice.build)end
  end
 end
end
print('PASS: seven sourced paladin talent suggestions, precise build context, no popularity or mechanics-only promotion, specialization icons, language overrides and real tooltip hook')
