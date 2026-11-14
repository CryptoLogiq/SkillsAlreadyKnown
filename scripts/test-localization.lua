-- Load the real addon order, including localized advice, without a game UI.
local root = arg[1] or "."
local function loadAddon(client, preference, saved)
  SkillsAlreadyKnown = nil
  local restored = saved or { language = preference }
  SkillsAlreadyKnownDB = nil
  GetLocale = function() return client end
  UnitClass = function() return "Mage", "MAGE", 8 end
  UnitLevel = function() return 17 end
  GetTalentTabInfo = nil
  SlashCmdList = {}
  LibStub = nil
  CreateFrame = function()
    return { RegisterEvent = function() end, SetScript = function() end }
  end
  C_Timer = { After = function() end }
  local toc = assert(io.open(root .. "/SkillsAlreadyKnown.toc")):read("*a")
  for line in toc:gmatch("[^\r\n]+") do
    local file = line:match("^([^#%s][^%s]*%.lua)")
    if file and not file:match("^libs/") then
      assert(loadfile(root .. "/" .. file))("SkillsAlreadyKnown")
    end
  end
  SkillsAlreadyKnownDB = restored
  SkillsAlreadyKnown.Localization.Initialize()
  return SkillsAlreadyKnown
end

for _, case in ipairs({
  { "frFR", nil, "fr_FR" }, { "frCA", nil, "fr_FR" },
  { "enUS", nil, "en-EN" }, { "enGB", nil, "en-EN" },
  { "deDE", nil, "en-EN" }, { "esES", "auto", "en-EN" },
  { "frFR", "en-EN", "en-EN" }, { "enUS", "fr_FR", "fr_FR" },
  { "enUS", "invalid", "en-EN" },
}) do
  local s = loadAddon(case[1], case[2])
  local french = case[3] == "fr_FR"
  assert(s.Localization.GetActiveLanguage() == case[3])
  assert(s.L("Affichage") == (french and "Affichage" or "Display"))
  assert(s.L("Unknown key") == "Unknown key")
  local options = s.Settings.Options().args
  assert(options.display.name == (french and "Affichage" or "Display"))
  assert(options.language.name == (french and "Langue" or "Language"))
  assert(options.recentLearning.name == (french and "Apprentissages récents" or "Recent learning"))
  assert(s.ClassRoles.classes.MAGE.specializations.frost == (french and "Givre" or "Frost"))
  assert(s.TalentSummaries.MAGE.frost.summary:find(french and "Givre contrôle" or "Frost controls", 1, true))
  assert(s.LevelingRecommendations.MAGE.soloReason:find(french and "Givre privilégie" or "Frost favors", 1, true))
  assert(s.SpellBook.Explanations.best:find(french and "Plus haut rang" or "Highest learned rank", 1, true))
  assert(s.RecentLearning.Summary():find(french and "Aucun apprentissage enregistré." or "No learning recorded.", 1, true))
  local history = options.patchnotes.args.version2.args.additions.args.notes.name
  assert(history:find(french and "Skills Already Known devient" or "Skills Already Known becomes", 1, true))
  local tooltipLines = {}
  s.SpellBook.StateForSpell = function()
    return { id = 123, kind = "best", optionalReason = "Reviewed advice", optionalScope = "spell" }
  end
  s.SpellBook.AddSpellTooltip({ AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end }, 123)
  assert(table.concat(tooltipLines, "\n"):find(french and "achat facultatif" or "purchase that can wait", 1, true))
  -- A manual language override must not break native game title matching.
  local aliases = s.TalentTooltips.TreeNames("MAGE")
  assert(aliases.givre and aliases.frost and aliases.givre.index == aliases.frost.index)
  local shown
  s.Settings.OfferReload = function(message) shown = message end
  options.language.args.choice.set(nil, french and "en-EN" or "fr_FR")
  assert(shown and shown:find(french and "Recharger" or "Reload", 1, true))
  assert(s.Localization.GetActiveLanguage() == case[3], "Keep one language until reload")
  s.Localization.Initialize()
  assert(s.Localization.GetActiveLanguage() == case[3], "Repeated events must not apply a pending preference early")
  assert(not s.Localization.SetLanguage("unsupported"))
  local saved = SkillsAlreadyKnownDB
  saved.petSpells.keep = { count = 2 }
  local after = loadAddon(case[1], nil, saved)
  assert(after.Localization.GetActiveLanguage() == (french and "en-EN" or "fr_FR"))
  assert(SkillsAlreadyKnownDB.petSpells.keep.count == 2, "Preserve other saved data")
end

local s = loadAddon("enUS")
for key in pairs(s.Translations.fr_FR) do
  assert(type(s.Translations["en-EN"][key]) == "string", "Missing English key: " .. key)
end
for key in pairs(s.Translations["en-EN"]) do
  assert(type(s.Translations.fr_FR[key]) == "string", "Missing French key: " .. key)
end
s = loadAddon("enUS", "fr_FR")
s.disabledByDev = true
s.Translations, s.Localization, s.L = nil, nil, nil
for _, file in ipairs({ "traductions/fr_FR.lua", "traductions/en-EN.lua", "Localization.lua" }) do
  assert(loadfile(root .. "/" .. file))()
end
assert(s.Translations == nil and s.Localization == nil and s.L == nil)
print("PASS: full-addon FR/EN/client fallback, saved overrides, reload consistency, translated advice/history, native title aliases and inactive guard")
