local db, registrations, native, opened = {}, {}, {}, nil
UnitClass=function() return 'Mage','MAGE' end
SkillsAlreadyKnown={EnsureDB=function() return db end,
 RankPolicy={GetProfile=function() return {class='MAGE'} end,
 RoleLabels=function() return {tank='Tank',heal='Heal',dps='DPS',pvp='PvP'} end,
 SpecsForRole=function() return {} end},
}
local options, libraryCalls = nil,0
local dialog={}
function dialog:SetDefaultSize() end
function dialog:AddToBlizOptions(app,name,parent,path)
 assert(app=='SkillsAlreadyKnown' and path)
 local id=#registrations+100
 local frame={name=name,path=path,parent=parent}
 registrations[#registrations+1]=frame
 native[path]={frame=frame,id=id}
 if path=='home' then assert(parent==nil) else
  assert(parent=='Skills & More — By CryptoLogiq')
  assert(options.args[path].type=='group')
 end
 return frame,id
end
function dialog:Close() end
function dialog:Open(_,path) opened=path end
local libs={
 ['AceConfig-3.0']={RegisterOptionsTable=function(_,_,value) options=value;libraryCalls=libraryCalls+1 end},
 ['AceConfigDialog-3.0']=dialog,
 ['AceConfigRegistry-3.0']={NotifyChange=function() end},
}
LibStub=function(name) return libs[name] end
Settings={RegisterCanvasLayoutCategory=function() end,RegisterCanvasLayoutSubcategory=function() end,
 RegisterAddOnCategory=function() end,OpenToCategory=function(id) opened=id end}
dofile('DevTools.lua')
dofile('Settings.lua')
local config=SkillsAlreadyKnown.Settings
assert(config.Register() and #registrations==7 and libraryCalls==1)
assert(native.home and native.display and native.spellbook and native.language)
assert(not native.diagnostics,'Hidden developer tools must not leave an empty sidebar category')
assert(options.childGroups=='tree' and options.args.display.childGroups~='tab')
assert(options.args.display.args.development.hidden())
config.Register();assert(#registrations==7,'Register each native category only once')
config.Open();assert(opened==native.display.id)
config.Open(true);assert(opened=='spellbook','First use still opens only role selection')
SkillsAlreadyKnown.DevTools.SetEnabled(true)
assert(not options.args.display.args.development.hidden() and #registrations==7)
SkillsAlreadyKnown.DevTools.SetEnabled(false)
assert(options.args.display.args.development.hidden())
print('PASS: native parent/subcategory paths, no internal tabs, one-time registration, direct Display opening, first-use view and hidden development controls')
