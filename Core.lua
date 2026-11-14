-- SkillsAlreadyKnown: shared state, constants, and helpers.

local SAK = _G.SkillsAlreadyKnown or {}
_G.SkillsAlreadyKnown = SAK

-- Check enable state before any module registers frames, hooks or slash commands.
-- Using the actual folder name also keeps staged _dev copies from disabling themselves.
local addonName = ...
addonName = type(addonName) == "string" and addonName or "SkillsAlreadyKnown"
local function devCopyEnabled()
  if addonName:sub(-4) == "_dev" then return false end
  local devName = addonName .. "_dev"
  local character = UnitName and UnitName("player")
  local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
  if loaded then
    local ok, active = pcall(loaded, devName)
    if ok and active then return true end
  end
  if not character then return false end
  local ok, state
  if C_AddOns and C_AddOns.GetAddOnEnableState then
    ok, state = pcall(C_AddOns.GetAddOnEnableState, devName, character)
  elseif GetAddOnEnableState then
    ok, state = pcall(GetAddOnEnableState, character, devName)
  end
  return ok and type(state) == "number" and state > 0
end

SAK.disabledByDev = devCopyEnabled() or false
if SAK.disabledByDev then
  print("|cffffcc00Skills & More:|r inactive while " .. addonName .. "_dev is enabled.")
  return
end

SAK.WHITE = "Interface\\Buttons\\WHITE8X8"
SAK.COLORS = {
  known = { 0.34, 0.34, 0.34 },
  unavailable = { 1, 0.15, 0.15 },
}
SAK.OUTLINE = { 0, 1, 0, 0.85 }
SAK.TRAINER_OUTLINES = {
  known = { 0.50, 0.50, 0.50, 0.95 },
  available = { 0, 1, 0, 0.95 },
  soon = { 1, 0.82, 0.05, 0.95 },
  unavailable = { 1, 0.15, 0.15, 0.95 },
}
SAK.LEARNABLE_BG = { 0.10, 0.45, 0.12, 0.22 }
SAK.SOON_BG = { 0.55, 0.42, 0.05, 0.22 }
SAK.KNOWN_BG = { 0.05, 0.05, 0.05, 0.38 }
SAK.MERCHANT_INACTIVE_KNOWN_BG = { 0.02, 0.28, 0.04, 0.62 }
SAK.MERCHANT_LEARNABLE_TEXT = { 1, 0.82, 0.05 }
SAK.MERCHANT_LEARNABLE_OUTLINE = { 1, 0.82, 0.05, 0.95 }
SAK.MERCHANT_LEARNED_TOOLTIP = { 0.25, 1, 0.25 }
SAK.MERCHANT_LEARNABLE_ICON = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\learnable-plus.tga"
SAK.TRAINER_BADGES = {
  eco = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\trainer-eco.tga", width = 64, height = 16 },
  notnow = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\trainer-not-now.tga", width = 52, height = 16 },
  new = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\trainer-new.tga", width = 40, height = 14 },
  known = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\trainer-known.tga", width = 20, height = 20 },
  next = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\trainer-next.tga", width = 36, height = 14 },
}

SAK.SPELLBOOK_BADGES = {
  buy = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\spellbook-buy-rank.tga", width = 88, height = 16 },
  optional = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\spellbook-optional.tga", width = 64, height = 16 },
  eco = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\spellbook-eco.tga", width = 40, height = 16 },
  best = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\spellbook-best.tga", width = 40, height = 16 },
  low = { texture = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\spellbook-low.tga", width = 40, height = 16 },
}

SAK.RECIPE_KNOWN_BADGE = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\recipe-already-known.tga"

SAK.MERCHANT_LEARNED_LABEL = "[Already Learned!]"
SAK.MERCHANT_READ_BOOK_LABEL = "[Already in your Bag]"
SAK.MERCHANT_READ_BOOK_COLOR = { 0.25, 1, 0.25 }
SAK.MERCHANT_READ_BOOK_OUTLINE = { 0.25, 1, 0.25, 0.95 }

SAK.PET_SUMMON_SPELL_IDS = { 688, 697, 712, 101822, 691, 30146 }
SAK.PET_SUMMON_FALLBACK_LEVELS = {
  [688] = 1,
  [697] = 10,
  [712] = 20,
  [691] = 30,
  [30146] = 50,
}

function SAK.EnsureDB()
  SkillsAlreadyKnownDB = SkillsAlreadyKnownDB or {}
  SkillsAlreadyKnownDB.petSpells = SkillsAlreadyKnownDB.petSpells or {}
  SkillsAlreadyKnownDB.petGrimoires = SkillsAlreadyKnownDB.petGrimoires or {}
  SkillsAlreadyKnownDB.itemStorage = SkillsAlreadyKnownDB.itemStorage or {}
  if type(SkillsAlreadyKnownDB.displayOptions) ~= "table" then SkillsAlreadyKnownDB.displayOptions = {} end
  return SkillsAlreadyKnownDB
end

function SAK.DisplayEnabled(key)
  local options = SkillsAlreadyKnownDB and SkillsAlreadyKnownDB.displayOptions
  return type(options) ~= "table" or options[key] ~= false
end

local displayKeys = {
  icons = true,
  outlines = true,
  text = true,
  backgrounds = true,
  iconsSpellbook = true,
  iconsTrainer = true,
  iconsMerchant = true,
  iconsInventory = true,
  iconsTalents = true,
  contentTags = true,
  recipes = true,
  iconsLoot = true,
  iconsTrainerSpells = true,
  recent = true,
  iconsProfessions = true,
}

function SAK.SetDisplayOption(key, value)
  if not displayKeys[key] then return false end
  local enabled = value == true
  SAK.EnsureDB().displayOptions[key] = enabled
  if key == "text" and not enabled and SAK.Visuals then SAK.Visuals.ResetTextStyles() end
  if SAK.Settings then SAK.Settings.Notify() end
  if SAK.Refresh then SAK.Refresh() end
  return true
end

function SAK.TableCount(tbl)
  local count = 0
  if type(tbl) ~= "table" then return count end
  for _ in pairs(tbl) do count = count + 1 end
  return count
end

function SAK.LearnedSpellCount(petData)
  if type(petData) ~= "table" then return 0 end
  if type(petData.byID) == "table" and SAK.TableCount(petData.byID) > 0 then return SAK.TableCount(petData.byID) end
  if type(petData.byName) == "table" then return SAK.TableCount(petData.byName) end
  return SAK.TableCount(petData)
end

function SAK.LegacySpellCount(petData)
  if type(petData) ~= "table" then return 0 end
  local count = 0
  for key in pairs(petData) do
    if key ~= "byID" and key ~= "byName" and key ~= "petKey" and key ~= "petName" then
      count = count + 1
    end
  end
  return count
end

function SAK.AppendLimitedPairs(lines, label, tbl, limit)
  if type(tbl) ~= "table" then return end
  local shown = 0
  for key, value in pairs(tbl) do
    shown = shown + 1
    if shown > limit then
      lines[#lines + 1] = string.format("SAK pet saved %s: ... +%s more", label, SAK.TableCount(tbl) - limit)
      break
    end
    lines[#lines + 1] = string.format("SAK pet saved %s: %s=%s", label, tostring(key), tostring(value))
  end
end

function SAK.TextOf(fontString)
  return fontString and fontString.GetText and fontString:GetText() or nil
end

function SAK.TrimText(text)
  if type(text) ~= "string" then return "" end
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

function SAK.NormalizeText(text)
  return SAK.TrimText(text):lower()
end

function SAK.PetKey(text)
  return SAK.NormalizeText(text)
end

function SAK.CleanupPetName(text)
  text = SAK.TrimText(text)
  text = text:gsub("^[dD][’']un%s+", "")
  text = text:gsub("^[dD][’']une%s+", "")
  text = text:gsub("^[uU]n%s+", "")
  text = text:gsub("^[uU]ne%s+", "")
  text = text:gsub("^[lL][’']", "")
  text = text:gsub("^[lL]e%s+", "")
  text = text:gsub("^[lL]a%s+", "")
  text = text:gsub("^%a%s+", "")
  return SAK.TrimText(text)
end

function SAK.CleanText(text)
  if type(text) ~= "string" then return "" end
  return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function SAK.RankNumber(text)
  if type(text) ~= "string" then return nil end
  return tonumber(text:match("%d+"))
end

function SAK.ItemIDFromLink(itemLink)
  if type(itemLink) ~= "string" then return nil end
  return tonumber(itemLink:match("item:(%d+)"))
end

function SAK.ContainerNumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
  if GetContainerNumSlots then return GetContainerNumSlots(bag) or 0 end
  return 0
end

function SAK.ContainerItemLink(bag, slot)
  if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bag, slot) end
  if GetContainerItemLink then return GetContainerItemLink(bag, slot) end
end

function SAK.ScanBagItemIDs()
  local owned = {}
  local maxBag = NUM_BAG_SLOTS or 4

  for bag = 0, maxBag do
    for slot = 1, SAK.ContainerNumSlots(bag) do
      local itemID = SAK.ItemIDFromLink(SAK.ContainerItemLink(bag, slot))
      if itemID then owned[itemID] = (owned[itemID] or 0) + 1 end
    end
  end

  return owned
end

function SAK.SaveItemStorage(itemID, location, count)
  itemID = tonumber(itemID)
  if not (itemID and location and location ~= "") then return end
  local storage = SAK.EnsureDB().itemStorage
  storage[itemID] = storage[itemID] or {}
  storage[itemID][location] = math.max(tonumber(count) or 0, 0)
end

function SAK.ClearItemStorageLocation(location)
  if not location or location == "" then return end
  local storage = SAK.EnsureDB().itemStorage
  for _, locations in pairs(storage) do
    if type(locations) == "table" then locations[location] = 0 end
  end
end

function SAK.RegisterKnownItem(kind, itemID, data)
  itemID = tonumber(itemID)
  if not (kind and itemID and type(data) == "table") then return end
  local db = SAK.EnsureDB()
  if kind == "petGrimoire" then
    db.petGrimoires[itemID] = db.petGrimoires[itemID] or {}
    for key, value in pairs(data) do
      if value ~= nil then db.petGrimoires[itemID][key] = value end
    end
  end
end

function SAK.ItemStorageSummary(itemID, currentLocation)
  itemID = tonumber(itemID)
  local storage = itemID and SAK.EnsureDB().itemStorage[itemID]
  if type(storage) ~= "table" then return nil end

  local out = {}
  for location, count in pairs(storage) do
    count = tonumber(count) or 0
    if count > 0 and location ~= currentLocation then
      out[#out + 1] = string.format("%s=%s", location, count)
    end
  end
  table.sort(out)
  if #out == 0 then return nil end
  return table.concat(out, ", ")
end

function SAK.SpellName(spellID)
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
  if info and info.name then return info.name end
  if GetSpellInfo then return GetSpellInfo(spellID) end
end

function SAK.SpellTexture(spellID)
  if C_Spell and C_Spell.GetSpellTexture then
    local texture = C_Spell.GetSpellTexture(spellID)
    if texture then return texture end
  end
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
  if info and (info.iconID or info.iconFileID) then return info.iconID or info.iconFileID end
  if GetSpellInfo then
    local _, _, texture = GetSpellInfo(spellID)
    return texture
  end
end

function SAK.SpellLevelLearned(spellID)
  if C_Spell and C_Spell.GetSpellLevelLearned then
    local level = C_Spell.GetSpellLevelLearned(spellID)
    if type(level) == "number" and level > 0 then return level end
  end
  if GetSpellLevelLearned then
    local level = GetSpellLevelLearned(spellID)
    if type(level) == "number" and level > 0 then return level end
  end
  return SAK.PET_SUMMON_FALLBACK_LEVELS[spellID]
end

local function commonAffixLength(a, b, fromEnd)
  local maxLen = math.min(#a, #b)
  local len = 0
  while len < maxLen do
    local posA = fromEnd and (#a - len) or (len + 1)
    local posB = fromEnd and (#b - len) or (len + 1)
    if a:sub(posA, posA) ~= b:sub(posB, posB) then break end
    len = len + 1
  end
  return len
end

local function stripCommonAffixes(names)
  if SAK.TableCount(names) < 2 then return names end
  local first
  local prefixLen
  local suffixLen

  for _, name in pairs(names) do
    if not first then
      first = name
      prefixLen = #name
      suffixLen = #name
    else
      prefixLen = math.min(prefixLen, commonAffixLength(first, name, false))
      suffixLen = math.min(suffixLen, commonAffixLength(first, name, true))
    end
  end

  local out = {}
  for _, name in pairs(names) do
    local suffixStart = math.max(prefixLen, #name - suffixLen)
    out[#out + 1] = name:sub(prefixLen + 1, suffixStart)
  end
  return out
end

local function buildPetNames()
  local raw = {}
  local seen = {}
  local out = {}
  local function add(name, icon, unlockLevel)
    name = SAK.CleanupPetName(name)
    local key = SAK.PetKey(name)
    if name ~= "" and key ~= "" and not seen[key] then
      seen[key] = true
      out[#out + 1] = { name = name, key = key, icon = icon, unlockLevel = unlockLevel }
    end
  end

  for _, spellID in ipairs(SAK.PET_SUMMON_SPELL_IDS) do
    local name = SAK.SpellName(spellID)
    if name and name ~= "" then
      local icon = SAK.SpellTexture(spellID)
      local unlockLevel = SAK.SpellLevelLearned(spellID)
      raw[#raw + 1] = name
      add(name, icon, unlockLevel)
      add(name:match("[dD][’']un%s+(.+)"), icon, unlockLevel)
      add(name:match("[dD][’']une%s+(.+)"), icon, unlockLevel)
    end
  end

  for _, name in ipairs(stripCommonAffixes(raw)) do
    add(name)
  end

  table.sort(out, function(a, b) return #a.name > #b.name end)
  return out
end

function SAK.GetPetNames()
  if not SAK.petNames then SAK.petNames = buildPetNames() end
  return SAK.petNames
end

function SAK.EnsureScanTooltip()
  if not SAK.scanTooltip then
    SAK.scanTooltip = CreateFrame("GameTooltip", "SkillsAlreadyKnownScanTooltip", nil, "GameTooltipTemplate")
    SAK.scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  end
  return SAK.scanTooltip
end


-- nil signifie que le client ne permet pas de confirmer ce rang.
function SAK.IsPlayerSpellKnown(spellID)
  local checks = {
    C_SpellBook and C_SpellBook.IsSpellKnown or false,
    IsPlayerSpell or false,
    IsSpellKnown or false,
  }

  for _, check in ipairs(checks) do
    if type(check) == "function" then
      local ok, learned = pcall(check, spellID)
      if ok and type(learned) == "boolean" then
        return learned
      end
    end
  end

  return nil
end
