-- Run: lua scripts/test-role-confirmation.lua
local root = arg[1] or "."
UnitClass = function() return "Mage", "MAGE" end
UnitLevel = function() return 8 end
local combat = false
InCombatLockdown = function() return combat end
for _, file in ipairs({"Core.lua", "data/ClassRoles.lua", "data/LevelingRecommendations.lua",
  "data/LevelingAdvice.lua", "data/RankOneAdvice.lua", "PlayerRoles.lua", "RankPolicy.lua", "Settings.lua"}) do
  assert(loadfile(root .. "/" .. file))()
end
local s = SkillsAlreadyKnown
local opened, closed = 0, 0
local dialog = {
  Open = function() opened = opened + 1 end,
  Close = function() closed = closed + 1 end,
}
LibStub = function(name) if name == "AceConfigDialog-3.0" then return dialog end end
s.Settings.Register = function() return true end
local popup, centered
local popupFrame = {strata="DIALOG", level=5}
function popupFrame:GetFrameStrata() return self.strata end
function popupFrame:GetFrameLevel() return self.level end
function popupFrame:SetFrameStrata(value) self.strata=value end
function popupFrame:SetFrameLevel(value) self.level=value end
function popupFrame:ClearAllPoints() end
function popupFrame:SetPoint(point) centered=point end
dialog.OpenFrames = {SkillsAlreadyKnown={frame={GetFrameLevel=function() return 200 end}}}
StaticPopupDialogs = {}
StaticPopup_Show = function(name)
  popup = StaticPopupDialogs[name]
  return popupFrame
end
s.RankPolicy.MaybePrompt()
local db = s.EnsureDB()
assert(opened == 1 and not db.profilePromptSeen)
assert(s.PlayerRoles.SelectionSpec("dps") == "frost")
assert(not s.RankPolicy.GetProfile() and not s.RankPolicy.IsRoleEnabled("dps"))
local args = s.Settings.Options().args.spellbook.args
args.roles.args.dps.args.specialization.set(nil, "fire")
args.context.args.eco.set(nil, false)
assert(s.PlayerRoles.SelectionSpec("dps") == "fire" and not s.PlayerRoles.SelectionPreference("eco"))
assert(not s.RankPolicy.GetProfile())
assert(not args.confirmSelection.disabled())
args.confirmSelection.func()
assert(popup.button1 == "OK" and popup.button2 == "Annuler" and centered == "CENTER")
assert(popup.text:find("DPS : Feu", 1, true) and popup.text:find("ECO : désactivé", 1, true))
-- Cancel / Escape has no commit callback and the draft remains editable.
assert(not popup.OnCancel and popup.hideOnEscape and not db.levelingProfile)
assert(popupFrame.strata == "FULLSCREEN_DIALOG" and popupFrame.level == 230)
popup.OnHide(popupFrame)
assert(popupFrame.strata == "DIALOG" and popupFrame.level == 5)
args.later.func()
assert(closed == 1 and db.levelingDraft and not db.profilePromptSeen)
s.RankPolicy.MaybePrompt()
assert(opened == 1, "Closing startup must suppress repeated automatic opens this session")
-- Reload module state with saved variables retained, as the game does on reload.
for _, file in ipairs({"PlayerRoles.lua", "RankPolicy.lua"}) do assert(loadfile(root .. "/" .. file))() end
s.RankPolicy.MaybePrompt()
assert(opened == 2 and s.PlayerRoles.SelectionSpec("dps") == "fire")
assert(not s.RankPolicy.GetProfile())
s.Settings.ConfirmSelection()
combat = true
popup.OnAccept()
assert(not db.levelingProfile and db.levelingDraft)
combat = false
popup.OnAccept()
assert(db.levelingProfile.confirmed and not db.levelingDraft and db.profilePromptSeen)
assert(s.RankPolicy.SelectedSpec("dps") == "fire" and not s.RankPolicy.EcoEnabled())
s.RankPolicy.MaybePrompt()
assert(opened == 2)
-- An automatic choice from the previous build requires explicit consent too.
db.levelingProfile.initialSuggestion = "leveling"
db.levelingProfile.confirmed = nil
assert(not s.RankPolicy.GetProfile())
assert(db.levelingDraft.roles.dps.spec == "fire" and not db.levelingProfile)
assert(not db.profilePromptSeen)
-- An incomplete selection cannot be confirmed.
s.PlayerRoles.SetSelectionRole("dps", false)
assert(not s.PlayerRoles.SelectionSnapshot() and not s.Settings.ConfirmSelection())
print("PASS: inactive draft, editable recommendations, recap/cancel/OK, reload persistence, combat guard, legacy automatic migration and incomplete selection")
