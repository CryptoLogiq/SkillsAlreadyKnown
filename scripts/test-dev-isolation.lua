-- Official startup must depend on loaded DEV code, not enable-state guesses.
local root = arg[1] or "."
local function load(loaded, name, legacy, failed)
  SkillsAlreadyKnown, SkillsAlreadyKnownDB = nil, nil
  UnitName = function() return "Character" end
  local probe = function(addon)
    assert(addon == "SkillsAlreadyKnown_dev")
    if failed then error("API unavailable") end
    return loaded
  end
  GetAddOnEnableState = function() error("Enable state must not disable the official addon") end
  if legacy then
    C_AddOns = nil
    IsAddOnLoaded = probe
  else
    C_AddOns = { IsAddOnLoaded = probe, GetAddOnEnableState = GetAddOnEnableState }
    IsAddOnLoaded = nil
  end
  assert(loadfile(root .. "/Core.lua"))(name or "SkillsAlreadyKnown")
  return SkillsAlreadyKnown
end
for _, legacy in ipairs({ false, true }) do
  local s = load(false, nil, legacy)
  assert(not s.disabledByDev and type(s.EnsureDB) == "function" and s.isDev == false)
  s = load(true, nil, legacy)
  assert(s.disabledByDev and s.EnsureDB == nil)
  s = load(false, nil, legacy, true)
  assert(not s.disabledByDev, "Uncertain DEV state must not stop official startup")
end
local s = load(true, "SkillsAlreadyKnown_dev")
assert(not s.disabledByDev and type(s.EnsureDB) == "function" and s.isDev == true, "DEV must identify itself from its actual loaded addon name")
local toc = assert(io.open(root .. "/SkillsAlreadyKnown.toc")):read("*a")
assert(toc:find("## OptionalDeps: TrainerSpells, SkillsAlreadyKnown_dev", 1, true))
print("PASS: loaded DEV priority, disabled/failed/unknown DEV fallback, legacy API and self-copy guard")
