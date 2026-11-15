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
  local registered, snapshots = false, {}
  local function capture(texts, seen)
    if type(texts) ~= "table" or seen[texts] then return end
    seen[texts] = true
    for key, value in pairs(texts) do
      if type(value) == "string" then
        snapshots[#snapshots + 1] = { owner = texts, key = key, value = value }
      elseif type(value) == "table" then
        capture(value, seen)
      end
    end
  end
  local toc = assert(io.open(root .. "/SkillsAlreadyKnown.toc")):read("*a")
  for line in toc:gmatch("[^\r\n]+") do
    local file = line:match("^([^#%s][^%s]*%.lua)")
    if file and not file:match("^libs/") then
      assert(loadfile(root .. "/" .. file))("SkillsAlreadyKnown")
      if SkillsAlreadyKnown.Localization and not registered then
        local register = SkillsAlreadyKnown.Localization.RegisterTable
        SkillsAlreadyKnown.Localization.RegisterTable = function(texts)
          capture(texts, {})
          register(texts)
        end
        registered = true
      end
    end
  end
  SkillsAlreadyKnownDB = restored
  SkillsAlreadyKnown.Localization.Initialize()
  assert(#snapshots > 1000, "Audit all registered class/spec/advice text, not only Mage")
  for _, entry in ipairs(snapshots) do
    assert(entry.owner[entry.key] == SkillsAlreadyKnown.L(entry.value),
      "Cached text did not follow the restored language: " .. entry.value)
  end
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
  assert(s.SurvivalAdvice.MAGE[1953].reason == s.L("SURVIVAL_MAGE_1953"),
    "Cached semantic-key advice follows manual language overrides")
  assert(s.L(s.Translations.fr_FR.BADGE_CUSTOM_OPTIONAL) == s.L("BADGE_CUSTOM_OPTIONAL"),
    "French semantic-key values can be retranslated to the selected language")
  assert(s.L(s.Translations["en-EN"].BADGE_CUSTOM_OPTIONAL) == s.L("BADGE_CUSTOM_OPTIONAL"))
  local options = s.Settings.Options().args
  assert(options.display.name == (french and "Affichage" or "Display"))
  assert(options.language.name == (french and "Langue" or "Language"))
  assert(options.recentLearning.name == (french and "Apprentissages récents" or "Recent learning"))
  assert(s.ClassRoles.classes.MAGE.specializations.frost == (french and "Givre" or "Frost"))
  assert(s.TalentSummaries.MAGE.frost.summary:find(french and "Givre contrôle" or "Frost controls", 1, true))
  assert(s.LevelingRecommendations.MAGE.soloReason:find(french and "Givre privilégie" or "Frost favors", 1, true))
  assert(s.SpellBook.Explanations.best:find(french and "Plus haut rang" or "Highest learned rank", 1, true))
  assert(s.RecentLearning.Summary():find(french and "Aucun apprentissage enregistré." or "No learning recorded.", 1, true))
  local history
  for index, entry in ipairs(s.Patchnotes) do
    if entry.version == "0.4.0" then
      history = options.patchnotes.args["version" .. index].args.additions.args.notes.name
    end
  end
  assert(history, "Keep the translated 0.4.0 history available across releases")
  assert(history:find(french and "Skills Already Known devient" or "Skills Already Known becomes", 1, true))
  local tooltipLines = {}
  s.SpellBook.StateForSpell = function()
    return { id = 123, kind = "best", optionalReason = "Reviewed advice", optionalScope = "spell" }
  end
  s.SpellBook.AddSpellTooltip({ AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end }, 123)
  assert(table.concat(tooltipLines, "\n"):find(french and "achat facultatif" or "purchase that can wait", 1, true))
  -- Exercise the actual external spell-tooltip hook on a French game client,
  -- including tooltips that already contain native text in the client language.
  local previousProcessor, previousEnum = TooltipDataProcessor, Enum
  local paintBadges = s.TooltipBadges.Paint
  s.TooltipBadges.Paint = function() end -- Geometry is covered by test-tooltip-badges.lua.
  local callback
  Enum = { TooltipDataType = { Spell = 1 } }
  TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) callback = fn end }
  s.SpellBook.spellTooltipHooked = nil
  s.SpellTooltips.Hook()
  assert(callback, "External spell tooltip processor is hooked")
  for _, scope in ipairs({ "spell", "rank-one", "higher-ranks", "custom" }) do
    local lines = { "Description native du jeu" }
    local hooks = {}
    local tip = {
      AddLine = function(_, text) lines[#lines + 1] = text end,
      HookScript = function(_, event, fn) hooks[event] = fn end,
    }
    s.SpellBook.StateForSpell = function()
      return { id = 123, kind = "best", optionalReason = "Reviewed advice", optionalScope = scope }
    end
    callback(tip, { id = 123 })
    local title = ({
      spell = "OPTIONAL — achat facultatif pendant le leveling selon tes rôles et spécialisations.",
      ["rank-one"] = "OPTIONAL — seuls les rangs supplémentaires sont facultatifs.",
      ["higher-ranks"] = "OPTIONAL — l'achat de ce rang supplémentaire peut attendre pendant le leveling.",
      custom = "BADGE_CUSTOM_OPTIONAL",
    })[scope]
    assert(lines[1] == "Description native du jeu", "Do not translate native or third-party tooltip content")
    assert(table.concat(lines, "\n"):find(s.L(title), 1, true), "External OPTIONAL scope uses the selected addon language: " .. case[1] .. "/" .. tostring(case[2]) .. "/" .. scope .. "\n" .. table.concat(lines, "\n"))
    hooks.OnTooltipCleared(tip)
    callback(tip, { id = 123 })
    assert(s.Localization.GetActiveLanguage() == case[3], "External hover cannot reset addon language")
  end
  TooltipDataProcessor, Enum = previousProcessor, previousEnum
  s.TooltipBadges.Paint = paintBadges
  -- The beginner hint also appears without purchase advice or an existing badge.
  local previousClass = UnitClass
  UnitClass = function() return "Paladin", "PALADIN", 2 end
  local oldState = s.SpellBook.StateForSpell
  s.SpellBook.StateForSpell = function() return nil end
  local hintLines, hintHooks = {}, {}
  local hintTip = {
    AddLine = function(_, text) hintLines[#hintLines + 1] = text end,
    HookScript = function(_, event, fn) hintHooks[event] = fn end,
  }
  local oldPaint = s.TooltipBadges.Paint
  s.TooltipBadges.Paint = function() end
  s.SpellBook.AddSpellTooltip(hintTip, 20271)
  assert(hintLines[1] == s.L("SPELL_HINT_JUDGEMENT_SEAL"))
  s.SpellBook.AddSpellTooltip(hintTip, 20271)
  assert(#hintLines == 1, "Do not duplicate the seal reminder on repeated hooks")
  hintHooks.OnTooltipCleared(hintTip)
  s.SpellBook.AddSpellTooltip(hintTip, 20271)
  assert(#hintLines == 2)
  s.EnsureDB().displayOptions.text = false
  hintHooks.OnTooltipCleared(hintTip)
  s.SpellBook.AddSpellTooltip(hintTip, 20271)
  assert(#hintLines == 2, "Respect disabled tooltip explanations")
  s.EnsureDB().displayOptions.text = nil
  s.TooltipBadges.Paint, s.SpellBook.StateForSpell = oldPaint, oldState
  UnitClass = previousClass
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
