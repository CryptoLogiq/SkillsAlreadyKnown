-- Event routing contracts, independent of the game's UI.
local root = arg[1] or "."
local calls, timers, handler = {}, {}, nil
local function record(name)
  return function() calls[name] = (calls[name] or 0) + 1 end
end
local function count(name) return calls[name] or 0 end
local function reset() calls, timers = {}, {} end
CreateFrame = function()
  return {
    RegisterEvent = function() end,
    SetScript = function(_, name, callback)
      assert(name == "OnEvent")
      handler = callback
    end,
  }
end
C_Timer = { After = function(delay, callback)
  timers[#timers + 1] = {delay = delay, callback = callback}
end }
SkillsAlreadyKnown = {
  EnsureDB = function() record("db")(); return {} end, Refresh = record("refresh"),
  Settings = {Register = record("settings")},
  TalentRoles = {Hook = record("talents")},
  ClassTrainer = {Hook = record("trainerHook"), MarkDirty = record("trainerDirty")},
  PetGrimoires = {Hook = record("petHook"), QueuePetSync = record("petSync"), Paint = record("petPaint")},
  Inventory = {Hook = record("bagHook"), QueueRefresh = record("bags")},
  SpellBook = {Hook = record("bookHook"), MarkDirty = record("bookDirty"), QueueRefresh = record("book")},
  RankPolicy = {MaybePrompt = record("prompt")},
  RankAvailability = {MarkDirty = record("rankDirty"), SetServices = function(services)
    assert(next(services) == nil)
    record("clearServices")()
  end},
}
assert(loadfile(root .. "/Events.lua"))()
handler(nil, "ADDON_LOADED", "UnrelatedAddon")
assert(next(calls) == nil and #timers == 0)
handler(nil, "ADDON_LOADED", "TrainerSpells")
assert(count("rankDirty") == 1 and count("bookDirty") == 1)
reset()
handler(nil, "TRAINER_SHOW")
assert(count("trainerDirty") == 1 and #timers == 2)
assert(timers[1].delay == 0 and timers[2].delay == 0.05)
for _, timer in ipairs(timers) do timer.callback() end
assert(count("refresh") == 2)
reset()
handler(nil, "UNIT_PET", "target")
assert(count("petSync") == 0 and #timers == 0)
handler(nil, "UNIT_PET", "player")
assert(count("petSync") == 1 and timers[1].delay == 0.6)
reset()
handler(nil, "MERCHANT_SHOW")
assert(count("petSync") == 1 and count("bags") == 1)
assert(timers[1].delay == 0 and timers[2].delay == 0.1)
reset()
handler(nil, "TRAINER_CLOSED")
assert(count("clearServices") == 1)
reset()
handler(nil, "PLAYER_LOGIN")
handler(nil, "PLAYER_LOGIN")
assert(count("db") == 3 and count("bookDirty") == 2 and count("bags") == 2)
assert(#timers == 4 and timers[1].callback == SkillsAlreadyKnown.RankPolicy.MaybePrompt)
assert(count("petSync") == 2, "Login must scan the active pet")
print("PASS: watched addons, rank invalidation, trainer timers, pet unit filter, merchant refresh and login initialization")

reset()
handler(nil, "PLAYER_REGEN_ENABLED")
assert(#timers == 0, "Leaving combat must not reopen an unconfirmed startup selection")
SkillsAlreadyKnown.RankPolicy.pending = true
handler(nil, "PLAYER_REGEN_ENABLED")
assert(#timers == 1 and timers[1].callback == SkillsAlreadyKnown.RankPolicy.MaybePrompt)
print("PASS: combat exit opens options only when an opening was explicitly deferred")

reset()
local localized = false
SkillsAlreadyKnown.Localization = { Initialize = function()
  localized = true
  record("locale")()
end }
SkillsAlreadyKnown.Settings.Register = function()
  assert(localized, "Read saved language before registering settings")
end
handler(nil, "ADDON_LOADED", "UnrelatedAddon")
assert(not localized)
handler(nil, "ADDON_LOADED", "SkillsAlreadyKnown")
assert(localized and count("locale") == 1)
localized = false
handler(nil, "PLAYER_LOGIN")
assert(localized and count("locale") == 2)
print("PASS: saved language initializes before GUI registration on own addon load and login fallback")
