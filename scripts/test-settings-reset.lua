-- Run: lua scripts/test-settings-reset.lua
local root = arg[1] or "."
local combat = false
UnitClass = function() return "Mage", "MAGE" end
UnitLevel = function() return 5 end
InCombatLockdown = function() return combat end
for _, file in ipairs({"Core.lua", "data/ClassRoles.lua", "data/LevelingRecommendations.lua",
  "data/RankOneAdvice.lua", "PlayerRoles.lua", "RankPolicy.lua", "Settings.lua"}) do
  assert(loadfile(root .. "/" .. file))()
end
local s = SkillsAlreadyKnown
local refreshes, notifications, launches, opens = 0, 0, 0, 0
s.Refresh = function() refreshes = refreshes + 1 end
s.Settings.Notify = function() notifications = notifications + 1 end
s.Settings.LaunchReport = function(callback) launches = launches + 1; callback() end
s.Settings.Open = function(firstUse)
  assert(firstUse)
  opens = opens + 1
end
local db = s.EnsureDB()
local pets, books, storage = db.petSpells, db.petGrimoires, db.itemStorage
pets.example, books.example, storage.example = true, true, true
s.PlayerRoles.SetRole("dps")
s.PlayerRoles.SetSpecialization("dps", "fire")
s.PlayerRoles.SetEco(false)
db.displayOptions = {icons=false, text=false, outlines=false, backgrounds=false}
assert(s.Settings.ResetDefaults())
assert(s.PlayerRoles.SelectionSpec("dps") == "frost")
assert(s.PlayerRoles.EcoEnabled() and s.PlayerRoles.OptionalEnabled() and s.PlayerRoles.BuyRankEnabled())
for _, key in ipairs({"icons", "text", "outlines", "backgrounds"}) do assert(s.DisplayEnabled(key)) end
assert(not db.profilePromptSeen and not s.PlayerRoles.GetProfile() and opens == 0)
db.displayOptions.icons = false
s.PlayerRoles.SetSpecialization("dps", "fire")
assert(s.Settings.RestartFirstUse())
assert(launches == 1 and opens == 1 and not db.profilePromptSeen)
assert(db.replayStartupOnLogin == true)
assert(s.PlayerRoles.SelectionSpec("dps") == "frost" and not s.DisplayEnabled("icons"))
assert(db.petSpells == pets and db.petGrimoires == books and db.itemStorage == storage)
assert(pets.example and books.example and storage.example)
local savedRole, savedDisplay = db.levelingProfile, db.displayOptions
combat = true
assert(s.Settings.ResetDefaults() == false and s.Settings.RestartFirstUse() == false)
assert(db.levelingProfile == savedRole and db.displayOptions == savedDisplay and opens == 1)
local actions = s.Settings.Options().args.maintenance.args
assert(actions.defaults.confirm and actions.startup.confirm)
assert(actions.defaults.disabled() and actions.startup.disabled())
assert(refreshes == 2 and notifications >= 2)
print("PASS: default preferences, startup reselection, appearance preservation, retained pet/storage records, confirmation and combat guards")

-- Simulate a new event coordinator after reload, with the same saved variables.
local onEvent, queued = nil, {}
CreateFrame = function() return {
  RegisterEvent = function() end,
  SetScript = function(_, _, callback) onEvent = callback end,
} end
C_Timer = {After = function(_, callback) queued[#queued + 1] = callback end}
s.ClassTrainer = {Hook=function() end, MarkDirty=function() end}
s.PetGrimoires = {Hook=function() end}
s.Inventory = {Hook=function() end, QueueRefresh=function() end}
s.Settings.Register = function() end
combat = false
assert(loadfile(root .. "/Events.lua"))()
onEvent(nil, "PLAYER_LOGIN")
assert(s.RankPolicy.pending and s.RankPolicy.pendingFirstUse)
-- The real Open consumes the saved flag only when the window can be opened.
s.Settings.Open = function(firstUse)
  assert(firstUse)
  opens = opens + 1
  db.replayStartupOnLogin = nil
end
for _, callback in ipairs(queued) do callback() end
assert(opens == 2 and not db.replayStartupOnLogin)
s.RankPolicy.MaybePrompt()
assert(opens == 2 and not s.PlayerRoles.GetProfile())
print("PASS: saved restart request survives reload and reopens once despite existing role and seen flag")

-- AceConfig confirms before calling func; the second dialog only offers reload.
local popup, reloads = nil, 0
StaticPopupDialogs = {}
StaticPopup_Show = function(name) popup = assert(StaticPopupDialogs[name]) end
ReloadUI = function() reloads = reloads + 1 end
combat = false
local defaultsBefore = db.levelingProfile
for _, action in ipairs({actions.defaults, actions.startup}) do
  assert(action.confirm == true, "AceConfig treats a string confirm as a handler method name")
  assert(type(action.confirmText) == "string" and #action.confirmText > 0)
end
assert(db.levelingProfile == defaultsBefore)
actions.defaults.func()
assert(popup and popup.button1 == "Recharger l'interface" and popup.button2 == "Plus tard")
assert(reloads == 0)
assert(not popup.OnCancel and popup.hideOnEscape and popup.timeout == 0)
popup.OnAccept()
assert(reloads == 1)
combat = true
popup.OnAccept()
assert(reloads == 1)
combat = false
popup = nil
actions.startup.func()
assert(popup and db.replayStartupOnLogin and reloads == 1)
print("PASS: both confirmed reset buttons offer reload, Later never reloads, accept reloads once and combat blocks it")
