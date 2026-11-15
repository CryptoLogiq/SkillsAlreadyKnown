local db, calls, notifications = {}, {}, 0
local function called(key) calls[key]=(calls[key] or 0)+1 end
SkillsAlreadyKnown={isDev=true,EnsureDB=function() return db end,
 Settings={Notify=function() notifications=notifications+1 end,
 RestartFirstUse=function() called('startup');return true end, OfferReload=function() called('reload') end},
 SpellBook={ShowDebugWindow=function() called('book') end},
 ClassTrainer={ShowDebugWindow=function() called('trainer') end},
 Diagnostics={ShowWindow=function() called('conflicts') end},
 PetGrimoires={ShowSummaryWindow=function() called('pet') end,ShowDebugWindow=function() called('petdebug') end},
 debugFrames={Summary={Hide=function() called('summaryHide') end},Trainer={Hide=function() called('debugHide') end}},
 exportFrame={Hide=function() called('exportHide') end},
}
dofile('DevTools.lua')
local dev=SkillsAlreadyKnown.DevTools
local function command(_,_,_,_,callback) return {func=callback} end
local tab=dev.Options(command)
local startup=dev.StartupOption()
assert(not dev.IsEnabled() and tab.hidden() and startup.hidden())
assert(dev.ToggleOption().get()==false and #dev.CommandSummary()==0)
assert(dev.RunCommand('debug') and not calls.trainer)
assert(not dev.RunCommand('settings'),'Player commands stay outside the module')
startup.func();assert(not calls.startup)
dev.ToggleOption().set(nil,true)
assert(db.devToolsEnabled and not tab.hidden() and not startup.hidden())
assert(#dev.CommandSummary()==5)
dev.RunCommand('debug');assert(calls.trainer==1)
tab.args.reports.args.spellbook.func();assert(calls.book==1)
startup.func();assert(calls.startup==1 and calls.reload==1)
dofile('DevTools.lua');assert(SkillsAlreadyKnown.DevTools.IsEnabled(),'Retain preference after module reload')
dev.SetEnabled(false)
assert(tab.hidden() and startup.hidden() and calls.debugHide==1 and calls.exportHide==1 and not calls.summaryHide)
assert(SkillsAlreadyKnown.isDev,'Visibility of debug controls must not alter DEV runtime identity')
tab.args.reports.args.spellbook.func();assert(calls.book==1,'Previously built callbacks must also be gated')
assert(notifications>=2)
SkillsAlreadyKnown={disabledByDev=true}
dofile('DevTools.lua');assert(not SkillsAlreadyKnown.DevTools)
print('PASS: default-off module, live GUI visibility, saved preference, guarded commands/replay, report cleanup and independent DEV identity')
