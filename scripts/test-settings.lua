-- Run: lua scripts/test-settings.lua
local root=arg[1] or "."
SkillsAlreadyKnown,SkillsAlreadyKnownDB=nil,nil
UnitClass=function() return "Warlock","WARLOCK" end
local combat=false
InCombatLockdown=function() return combat end
assert(loadfile(root.."/Core.lua"))()
assert(loadfile(root .. "/DebugWindows.lua"))()
assert(loadfile(root .. "/data/ClassRoles.lua"))()
assert(loadfile(root .. "/data/LevelingAdvice.lua"))()
assert(loadfile(root .. "/data/RankOneAdvice.lua"))()
assert(loadfile(root .. "/PlayerRoles.lua"))()
assert(loadfile(root.."/RankPolicy.lua"))()
local sak=SkillsAlreadyKnown
local registered,panels,opens,closes,notifies,refreshes=0,0,0,0,0,0
local savedOptions,openedCategory,group
local dialog={}
function dialog:AddToBlizOptions(app,name)
 panels=panels+1;assert(app=="SkillsAlreadyKnown" and name=="Skills & More — By CryptoLogiq")
 return {name=name},321
end
function dialog:SetDefaultSize(app,w,h) assert(app=="SkillsAlreadyKnown" and w>=600 and h>=600) end
function dialog:Open(app,container) assert(app=="SkillsAlreadyKnown");opens=opens+1;self.lastContainer=container end
function dialog:Close(app) assert(app=="SkillsAlreadyKnown");closes=closes+1 end
local libraries={
 ["AceConfig-3.0"]={RegisterOptionsTable=function(_,app,options,slash)
  registered=registered+1;assert(app=="SkillsAlreadyKnown" and slash==nil);savedOptions=options
 end},
 ["AceConfigDialog-3.0"]=dialog,
 ["AceConfigRegistry-3.0"]={NotifyChange=function(_,app) assert(app=="SkillsAlreadyKnown");notifies=notifies+1 end},
 ["AceGUI-3.0"]={Create=function(_,kind)
  assert(kind=="BlizOptionsGroup")
  group={frame={},callbacks={}}
  function group:SetName(name) self.frame.name=name end
  function group:SetTitle() end
  function group:SetCallback(key,fn) self.callbacks[key]=fn end
  function group:ReleaseChildren() self.released=true end
  return group
 end},
}
LibStub=function(name) return libraries[name] end
sak.SpellBook={MarkDirty=function() end,Refresh=function() refreshes=refreshes+1 end}
Settings={RegisterCanvasLayoutCategory=function() end,RegisterAddOnCategory=function() end,
 OpenToCategory=function(id) openedCategory=id end}
assert(loadfile(root.."/Settings.lua"))("SkillsAlreadyKnown")
local settings=sak.Settings
assert(settings.Register() and settings.Register() and registered==1 and panels==1)
local args=savedOptions.args.spellbook.args
local roles={tank=args.roles.args.tank,heal=args.roles.args.heal,dps=args.roles.args.dps,pvp=args.activities.args.pvp}
local roleCount=0
for _,role in ipairs({"tank","heal","dps","pvp"}) do
 roleCount=roleCount+1
 local block=roles[role]
 assert(block.order==(role=="pvp" and 1 or roleCount) and block.inline)
 assert(block.args.enabled.type=="toggle" and block.args.enabled.name:find("|T",1,true))
 assert(block.args.specialization.type=="select" and block.args.specialization.order>block.args.enabled.order)
 assert(block.args.specialization.disabled())
end
assert(args.role==nil and roles.tank.args.enabled.disabled() and roles.heal.args.enabled.disabled())
assert(roles.tank.hidden() and roles.heal.hidden() and not roles.dps.hidden())
assert(args.roles.args.pvp==nil and args.activities.args.pvp==roles.pvp)
assert(roles.dps.args.specialization.values().affliction=="Affliction")
assert(args.context.args.eco.disabled() and args.context.args.eco.get())
settings.Open(true)
assert(opens==1 and not SkillsAlreadyKnownDB.profilePromptSeen and args.later.hidden())
args.later.func();assert(closes==1)
roles.dps.args.enabled.set(nil,true)
assert(sak.RankPolicy.GetProfile().role=="dps" and refreshes==1 and not roles.dps.args.specialization.disabled())
roles.dps.args.specialization.set(nil,"affliction")
roles.pvp.args.enabled.set(nil,true)
assert(roles.dps.args.enabled.get() and roles.pvp.args.enabled.get(),"Checkboxes are independent")
roles.pvp.args.specialization.set(nil,"destruction")
args.context.args.eco.set(nil,false)
roles.dps.args.specialization.set(nil,"demonology")
assert(sak.RankPolicy.SelectedSpec("pvp")=="destruction" and sak.RankPolicy.SelectedSpec("dps")=="demonology")
roles.pvp.args.enabled.set(nil,false)
roles.dps.args.enabled.set(nil,false)
assert(sak.RankPolicy.GetProfile()==nil and args.context.args.eco.disabled() and not args.context.args.eco.get())
roles.dps.args.enabled.set(nil,true)
assert(sak.RankPolicy.GetProfile().role=="dps" and sak.RankPolicy.SelectedSpec("dps")=="demonology")
assert(not sak.RankPolicy.GetProfile().eco and args.later.hidden() and notifies>=4)
settings.Open();assert(openedCategory==321 and not settings.promptOpen)
local count=opens;sak.RankPolicy.MaybePrompt();assert(opens==count)
combat=true;sak.RankPolicy.ShowSettings();assert(sak.RankPolicy.pending and opens==count)
combat=false;sak.RankPolicy.MaybePrompt();assert(not sak.RankPolicy.pending and openedCategory==321)
print("PASS: single native category, shared startup model, live saved settings, role preservation, refresh and combat deferral")

-- The three tabs expose the actual command actions without slash re-routing.
assert(savedOptions.childGroups=="tab")
assert(savedOptions.args.display.name=="Affichage" and savedOptions.args.display.order==1)
assert(savedOptions.args.spellbook.name=="Talent Spec and Role" and savedOptions.args.spellbook.order==2)
assert(savedOptions.args.diagnostics.name=="Diagnostics" and savedOptions.args.diagnostics.order==3)
assert(savedOptions.args.spellbook.args.legend.args.eco.image==sak.SPELLBOOK_BADGES.eco.texture)
local actions={}
local function record(key) actions[#actions+1]=key end
sak.ShowSummaryWindow=function() record("summary") end
sak.ClassTrainer={ShowDebugWindow=function() record("trainer") end,MarkDirty=function() record("trainer dirty") end}
sak.PetGrimoires={ShowSummaryWindow=function() record("pet") end,ShowDebugWindow=function() record("grimoires") end}
sak.Diagnostics={ShowWindow=function() record("conflicts") end}
sak.SpellBook.ShowDebugWindow=function() record("spellbook") end
sak.SpellBook.MarkDirty=function() record("spellbook dirty") end
sak.Refresh=function() record("refresh") end
local hidden=0
SettingsPanel={IsShown=function() return true end}
HideUIPanel=function(p) assert(p==SettingsPanel);hidden=hidden+1 end
savedOptions.args.display.args.summary.func()
local reports=savedOptions.args.diagnostics.args.reports.args
for _,key in ipairs({"trainer","pet","grimoires","conflicts"}) do
 assert(reports[key].desc:find("/sam",1,true))
 reports[key].func()
end
assert(table.concat(actions,",")=="summary,trainer,pet,grimoires,conflicts" and hidden==5)
reports.spellbook.func();assert(actions[6]=="spellbook" and hidden==6)
settings.Open(true);assert(dialog.lastContainer=="spellbook","Startup must select the profile tab")
settings.Open()
savedOptions.args.display.args.refresh.func()
assert(actions[7]=="trainer dirty" and actions[8]=="spellbook dirty" and actions[9]=="refresh")
SettingsPanel=nil;HideUIPanel=nil
count=opens
print("PASS: ordered tabs, marker previews, every report command, visible report routing, refresh and startup profile selection")

-- Appearance controls are profile-independent, persistent and update previews.
local controls=savedOptions.args.display.args.controls.args
local selectedRole=sak.RankPolicy.GetProfile().role
for _,key in ipairs({"icons","outlines","text","backgrounds"}) do
 local control=controls[key]
 assert(control.type=="toggle" and control.get() and control.disabled==nil)
 control.set(nil,false);assert(not control.get() and SkillsAlreadyKnownDB.displayOptions[key]==false)
end
assert(controls.iconsPreview.image()==nil)
assert(not controls.textPreview.name():find("|cff",1,true))
assert(not controls.outlinesPreview.name():find("|cff",1,true))
assert(sak.RankPolicy.GetProfile().role==selectedRole)
for _,key in ipairs({"icons","outlines","text","backgrounds"}) do controls[key].set(nil,true) end
assert(controls.iconsPreview.image()==sak.TRAINER_BADGES.new.texture)
assert(controls.textPreview.name():find("|cff",1,true))
print("PASS: profile-independent appearance toggles, persistent choices, immediate refresh and live previews")

-- Settings may become available after the options table was registered.
Settings=nil;openedCategory=nil
assert(loadfile(root.."/Settings.lua"))("SkillsAlreadyKnown")
settings=sak.Settings;settings.Register();local regCount=registered;local panelCount=panels
settings.Open();assert(opens==count+1)
Settings={RegisterCanvasLayoutCategory=function() end,RegisterAddOnCategory=function() end,
 OpenToCategory=function(id) openedCategory=id end}
settings.Open();assert(registered==regCount and panels==panelCount+1 and openedCategory==321)
print("PASS: late Settings API registration and standalone fallback")

Settings=nil
local legacyPanel,legacyOpened
InterfaceOptions_AddCategory=function(p) legacyPanel=p end
InterfaceOptionsFrame_OpenToCategory=function(p) legacyOpened=p end
assert(loadfile(root.."/Settings.lua"))("SkillsAlreadyKnown")
settings=sak.Settings;settings.Register();settings.Open()
assert(legacyOpened==legacyPanel and legacyPanel.name=="Skills & More — By CryptoLogiq")
group.callbacks.OnShow();assert(dialog.lastContainer==group)
group.callbacks.OnHide();assert(group.released)
print("PASS: legacy AddOns category feeds the same model without patching Ace3")

local optional=savedOptions.args.spellbook.args.context.args.optional
assert(optional.type=="toggle")
sak.RankPolicy.SetRole("dps")
assert(optional.get() and not optional.disabled())
optional.set(nil,false);assert(not sak.RankPolicy.OptionalEnabled())
sak.RankPolicy.SetRole("pvp");assert(not optional.get(),"Role changes preserve optional preference")
optional.set(nil,true);assert(sak.RankPolicy.OptionalEnabled())
print("PASS: OPTIONAL toggle is independent and persists across role changes")

local buyRank=savedOptions.args.spellbook.args.context.args.buyRank
assert(buyRank.type=="toggle" and buyRank.get())
buyRank.set(nil,false);assert(not sak.RankPolicy.BuyRankEnabled())
sak.RankPolicy.SetRole("dps");assert(not buyRank.get())
buyRank.set(nil,true);assert(sak.RankPolicy.BuyRankEnabled())
print("PASS: accessible-rank alert has its own saved preference")

-- The same table-driven UI adapts to hybrid classes, without impossible choices.
UnitClass=function() return "Paladin","PALADIN" end
local pal=sak.Settings.Options().args.spellbook.args.roles.args
assert(not pal.tank.hidden() and not pal.heal.hidden() and not pal.dps.hidden())
assert(pal.tank.args.specialization.hidden() and pal.heal.args.specialization.hidden() and pal.dps.args.specialization.hidden())
sak.RankPolicy.SetRoleEnabled("tank",true)
assert(sak.RankPolicy.SelectedSpec("tank")=="protection")
assert(not pal.tank.args.singleSpec.hidden() and pal.tank.args.singleSpec.name():find("Protection",1,true))
UnitClass=function() return "Druide","DRUID" end
local dru=sak.Settings.Options().args.spellbook.args.roles.args
assert(dru.tank.args.specialization.hidden() and not dru.dps.args.specialization.hidden())
assert(dru.dps.args.specialization.values().balance and dru.dps.args.specialization.values().feral)
print("PASS: only supported roles visible, PvP activity separated, unique specs automatic and hybrids retain choices")

-- Inactive official copy must not create or register settings.
sak.disabledByDev=true;local old=sak.Settings
assert(loadfile(root.."/Settings.lua"))("SkillsAlreadyKnown")
assert(sak.Settings==old)
print("PASS: inactive official copy does not initialize settings")


local categories = settings.Options().args.display.args.categories
sak.SetDisplayOption("iconsMerchant", false)
sak.SetDisplayOption("icons", false)
assert(categories.disabled(), "Category options must be greyed out under the global icon switch")
assert(not sak.DisplayEnabled("iconsMerchant"))
sak.SetDisplayOption("icons", true)
assert(not categories.disabled(), "Category options must become editable again")
assert(not sak.DisplayEnabled("iconsMerchant"), "Category choices must survive disabling the global switch")
print("PASS: icon category controls disabled by global switch without losing saved choices")
