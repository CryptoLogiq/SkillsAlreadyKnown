-- Addon text follows the client by default; explicit changes apply after reload.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Localization = {}
SAK.Localization = Localization
local catalogs = SAK.Translations
local client = GetLocale and GetLocale() or "enUS"
local automatic = client:sub(1, 2):lower() == "fr" and "fr_FR" or "en-EN"
local active = automatic
local initialized = false
local tables, initializers = {}, {}
local sourceByEnglish = {}
for source, english in pairs(catalogs["en-EN"]) do
  sourceByEnglish[english] = source
end

function Localization.GetPreference()
  local value = SAK.EnsureDB().language
  return (value == "fr_FR" or value == "en-EN") and value or "auto"
end

function Localization.GetActiveLanguage()
  return active
end

function Localization.SetLanguage(value)
  if value ~= "auto" and not catalogs[value] then return false end
  SAK.EnsureDB().language = value
  return true
end

function SAK.L(text)
  local source = catalogs[active][text] and text or sourceByEnglish[text] or text
  return catalogs[active][source] or text
end

-- SavedVariables are restored after Lua files execute. Re-localize owned text
-- tables in place on ADDON_LOADED, before settings and overlays are initialized.
function Localization.RegisterTable(texts)
  tables[#tables + 1] = texts
end

function Localization.RegisterInitializer(callback)
  initializers[#initializers + 1] = callback
end

function Localization.Initialize()
  if initialized then return end
  local preference = Localization.GetPreference()
  active = catalogs[preference] and preference or automatic
  local seen = {}
  local function translate(texts)
    if type(texts) ~= "table" or seen[texts] then return end
    seen[texts] = true
    for key, value in pairs(texts) do
      if type(value) == "string" then
        texts[key] = SAK.L(value)
      elseif type(value) == "table" then
        translate(value)
      end
    end
  end
  for _, texts in ipairs(tables) do translate(texts) end
  for _, callback in ipairs(initializers) do callback() end
  initialized = true
end

-- UI language can differ from the game's spellbook/talent-title language.
local variants = {}
for source, english in pairs(catalogs["en-EN"]) do
  local names = { source, english }
  variants[source], variants[english] = names, names
end
function Localization.NameVariants(text)
  return variants[text] or { text }
end
