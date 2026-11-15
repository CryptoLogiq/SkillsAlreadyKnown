-- SkillsAlreadyKnown: warlock pet grimoire support.

local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Visuals = SAK.Visuals
local PetGrimoires = {}
SAK.PetGrimoires = PetGrimoires

local merchantHooked
local petSyncQueued
local petRevision = 0
local trainerSync = {}
local GetItemInfoCompat = GetItemInfo or (C_Item and C_Item.GetItemInfo)
local GetItemSpellCompat = GetItemSpell or (C_Item and C_Item.GetItemSpell)

local function scanInventoryItemIDs()
  return SAK.ScanBagItemIDs()
end

local function currentPetFamily()
  if not (UnitExists and UnitExists("pet")) then return nil end
  if UnitIsDead and UnitIsDead("pet") then return nil end
  return UnitCreatureFamily and UnitCreatureFamily("pet") or nil
end

local function currentPetKey()
  return SAK.PetKey(currentPetFamily())
end

local function petSpellBookBanks()
  local banks = {}
  if BOOKTYPE_PET then banks[#banks + 1] = BOOKTYPE_PET end
  banks[#banks + 1] = "pet"
  if Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet then
    banks[#banks + 1] = Enum.SpellBookSpellBank.Pet
  end
  return banks
end

local function readPetSpellBookEntry(index, bank)
  local spellID, modernName, modernRank

  if GetSpellBookItemInfo then
    local ok, kind, id = pcall(GetSpellBookItemInfo, index, bank)
    if ok and kind == "SPELL" and type(id) == "number" and id > 0 then
      spellID = id
    end
  end

  if C_SpellBook and C_SpellBook.GetSpellBookItemType then
    local ok, kind, _, id = pcall(C_SpellBook.GetSpellBookItemType, index, bank)
    if ok and kind then
      local spellType = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.Spell
      if spellType and kind == spellType and type(id) == "number" and id > 0 then spellID = id end
    end
  end

  if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
    local ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, index, bank)
    if ok and type(info) == "table" then
      local spellType = Enum and Enum.SpellBookItemType and Enum.SpellBookItemType.Spell
      if info.isUnlearned or (spellType and info.itemType and info.itemType ~= spellType) then return end
      local id = info.spellID or info.actionID
      if type(id) == "number" and id > 0 then spellID = id end
      modernName, modernRank = info.name, info.subName
      if modernName and modernRank and modernRank ~= "" then return modernName, modernRank, spellID end
    end
  end

  if GetSpellBookItemName then
    local ok, name, rank = pcall(GetSpellBookItemName, index, bank)
    if ok and name and (not modernName or name == modernName) then return name, rank, spellID end
  end

  if C_SpellBook and C_SpellBook.GetSpellBookItemName then
    local ok, name, rank = pcall(C_SpellBook.GetSpellBookItemName, index, bank)
    if ok and name and (not modernName or name == modernName) then return name, rank, spellID end
  end
  if modernName then
    local subtext = C_Spell and C_Spell.GetSpellSubtext or GetSpellSubtext
    if subtext and spellID then
      local ok, rank = pcall(subtext, spellID)
      if ok then modernRank = rank end
    end
    return modernName, modernRank, spellID
  end
end

local function scanPetSpellBook()
  local learned = { byID = {}, byName = {} }
  local count = 0

  for _, bank in ipairs(petSpellBookBanks()) do
    local current = { byID = {}, byName = {} }
    local currentCount = 0
    local misses = 0

    for index = 1, 200 do
      local name, rank, spellID = readPetSpellBookEntry(index, bank)
      if name then
        misses = 0
        currentCount = currentCount + 1
        local rankNum = SAK.RankNumber(rank) or 1
        current.byName[name] = math.max(current.byName[name] or 0, rankNum)
        current[name] = math.max(current[name] or 0, rankNum)
        if spellID then
          local key = tostring(spellID)
          current.byID[key] = math.max(current.byID[key] or 0, rankNum)
        end
      else
        misses = misses + 1
        if misses >= 20 then break end
      end
    end

    if currentCount > count then
      learned = current
      count = currentCount
    end
  end

  return learned, count
end

local familySummons = { Imp = 688, Voidwalker = 697, Succubus = 712,
  Incubus = 101822, Felhunter = 691, Felguard = 30146 }
local catalogueIndex, catalogueSource, catalogueTime = {}, nil, nil

local function providerIndex()
  local source = TrainerSpells_PetData
  local now = GetTime and GetTime()
  if source ~= catalogueSource or (now and (not catalogueTime or now - catalogueTime >= 1)) then
    catalogueIndex, catalogueSource, catalogueTime = {}, source, now
    for family, levels in pairs(type(source) == "table" and source or {}) do
      for _, spells in pairs(type(levels) == "table" and levels or {}) do
        for id, entry in pairs(type(spells) == "table" and spells or {}) do
          if tonumber(id) and type(entry) == "table" then
            catalogueIndex[tonumber(id)] = { family = family, rank = tonumber(entry.rank) or 1 }
          end
        end
      end
    end
  end
  return catalogueIndex
end

local function matchesFamily(key, family)
  if SAK.PetKey(key) == SAK.PetKey(family) then return true end
  local summonID = familySummons[family]
  if summonID and SAK.GetPetNames then
    for _, pet in ipairs(SAK.GetPetNames()) do
      if pet.summonID == summonID and pet.key == key then return true end
    end
  end
  return false
end

local function providerKnowledge(id, entry)
  local saved = SAK.EnsureDB().petSpells
  local api = C_Spell and C_Spell.GetSpellName or GetSpellInfo
  local name = api and api(id)
  for key, pet in pairs(saved) do
    if type(pet) == "table" then
      if pet.byID and (pet.byID[tostring(id)] or pet.byID[id]) then return true end
      local linked = matchesFamily(key, entry.family)
      -- A real spell-ID match can identify a localized family too.
      if not linked and pet.byID then
        for otherID, other in pairs(providerIndex()) do
          if other.family == entry.family and (pet.byID[tostring(otherID)] or pet.byID[otherID]) then linked = true; break end
        end
      end
      if linked and name then
        local rank = (pet.byName and pet.byName[name]) or pet[name]
        if tonumber(rank) and tonumber(rank) >= entry.rank then return true end
      end
    end
  end
  local learned = TrainerSpells_Character and TrainerSpells_Character.learnedSpellsPet
  return learned and learned[entry.family] and learned[entry.family][id] == true or false
end

function PetGrimoires.TrainerSpellInfo(id)
  local entry = providerIndex()[id]
  if entry then return entry, providerKnowledge(id, entry) end
end

-- Grimoire training IDs and pet ability IDs differ: localized names + exact ranks
-- are only compared within the identified demon family.
function PetGrimoires.SyncTrainerSpellsKnown()
  local index = providerIndex()
  local character = TrainerSpells_Character
  if type(TrainerSpells_PetData) ~= "table" or type(character) ~= "table" then return end
  local saved, learned = SAK.EnsureDB().petSpells, character.learnedSpellsPet
  local now = GetTime and GetTime()
  local intact = true
  for _, applied in ipairs(trainerSync.applied or {}) do
    if applied.records[applied.id] ~= true or not learned or learned[applied.family] ~= applied.records then intact = false; break end
  end
  if intact and trainerSync.index == index and trainerSync.character == character
    and trainerSync.saved == saved and trainerSync.learned == learned
    and trainerSync.revision == petRevision and (not now or now - (trainerSync.time or 0) < 1) then return end

  -- Set the snapshot before refreshing the foreign UI to prevent re-entry.
  trainerSync = { index = index, character = character, saved = saved,
    revision = petRevision, time = now, applied = {} }
  local changed = false
  for id, entry in pairs(index) do
    if providerKnowledge(id, entry) then
      character.learnedSpellsPet = character.learnedSpellsPet or {}
      local records = character.learnedSpellsPet
      records[entry.family] = records[entry.family] or {}
      local family = records[entry.family]
      if family[id] ~= true then family[id] = true; changed = true end
      trainerSync.applied[#trainerSync.applied + 1] = { records = family, id = id, family = entry.family }
    end
  end
  trainerSync.learned = character.learnedSpellsPet
  if changed and type(TrainerSpells_Refresh) == "function" then TrainerSpells_Refresh() end
end

function PetGrimoires.SyncActivePetSpells()
  local pet = currentPetFamily()
  if not pet then return end

  local learned, count = scanPetSpellBook()
  -- The pet book can be empty briefly while summoning or loading.
  if count == 0 then return end
  local key = SAK.PetKey(pet)
  learned.petKey = key
  learned.petName = pet
  local previous = SAK.EnsureDB().petSpells[key]
  local changed = not previous
  for id, rank in pairs(learned.byID) do
    if not previous or not previous.byID or previous.byID[id] ~= rank then
      changed = true
      if previous and SAK.RecentLearning then
        SAK.RecentLearning.Record("pets", tonumber(id), nil, rank)
      end
    end
  end
  SAK.EnsureDB().petSpells[key] = learned
  if changed and SAK.SpellBook then SAK.SpellBook.MarkDirty() end
  petRevision = petRevision + 1
  PetGrimoires.SyncTrainerSpellsKnown()
  if SAK.Inventory then SAK.Inventory.QueueRefresh() end
end

function PetGrimoires.QueuePetSync()
  if petSyncQueued then return end
  petSyncQueued = true

  if C_Timer and C_Timer.After then
    C_Timer.After(0.5, function()
      petSyncQueued = nil
      PetGrimoires.SyncActivePetSpells()
    end)
  else
    petSyncQueued = nil
    PetGrimoires.SyncActivePetSpells()
  end
end

local function detectPetFromTooltip(tooltip)
  if not (tooltip and tooltip.GetName and tooltip.NumLines) then return nil end
  local tooltipName = tooltip:GetName()

  for line = 1, tooltip:NumLines() do
    local fs = _G[tooltipName .. "TextLeft" .. line]
    local text = SAK.NormalizeText(fs and fs:GetText())
    if text ~= "" then
      for _, pet in ipairs(SAK.GetPetNames()) do
        if text:find(pet.key, 1, true) then
          return pet
        end
      end
    end
  end
end

local function merchantItemSpell(index, itemLink, itemName)
  if itemLink and GetItemSpellCompat then
    local spell, spellID = GetItemSpellCompat(itemLink)
    if spell and spell ~= "" then return spell, spellID end
  end

  local tooltip = SAK.EnsureScanTooltip()
  tooltip:ClearLines()
  tooltip:SetMerchantItem(index)
  local firstLine = _G[tooltip:GetName() .. "TextLeft1"]
  return firstLine and firstLine:GetText() or itemName, nil
end

local function storeGrimoireInfo(info)
  if not (info and info.itemID) then return info end
  SAK.RegisterKnownItem("petGrimoire", info.itemID, {
    itemName = info.itemName,
    itemID = info.itemID,
    minLevel = info.minLevel,
    pet = info.pet,
    petKey = info.petKey,
    petIcon = info.petIcon,
    petUnlockLevel = info.petUnlockLevel,
    spell = info.spell,
    spellID = info.spellID,
    rank = info.rank,
  })
  return info
end

local function grimoireFromRegistry(itemLink)
  local itemID = SAK.ItemIDFromLink(itemLink)
  if not itemID then return nil end
  local saved = SAK.EnsureDB().petGrimoires[itemID]
  if type(saved) ~= "table" then return nil end
  local info = {}
  for key, value in pairs(saved) do info[key] = value end
  info.itemLink = itemLink
  info.itemID = info.itemID or itemID
  return info
end

function PetGrimoires.ItemInfoFromLink(itemLink)
  if not itemLink then return nil end
  local cached = grimoireFromRegistry(itemLink)
  local itemID = SAK.ItemIDFromLink(itemLink)
  local itemName, itemMinLevel
  if GetItemInfoCompat then
    local name, _, _, _, minLevel = GetItemInfoCompat(itemLink)
    itemName, itemMinLevel = name, minLevel
  end

  local tooltip = SAK.EnsureScanTooltip()
  tooltip:ClearLines()
  if tooltip.SetHyperlink then
    local ok, err = pcall(tooltip.SetHyperlink, tooltip, itemLink)
    if not ok and SAK.Diagnostics then SAK.Diagnostics.Record("Item tooltip scan error", err) end
    if not ok and cached then return cached end
  elseif cached then
    return cached
  else
    return nil
  end

  local pet = detectPetFromTooltip(tooltip)
  if not pet then return cached end
  local spellName, spellID
  if itemLink and GetItemSpellCompat then
    spellName, spellID = GetItemSpellCompat(itemLink)
  end

  return storeGrimoireInfo({
    itemName = itemName or (cached and cached.itemName),
    itemLink = itemLink,
    itemID = itemID,
    minLevel = tonumber(itemMinLevel) or (cached and cached.minLevel) or 0,
    pet = pet.name,
    petKey = pet.key,
    petIcon = pet.icon,
    petUnlockLevel = pet.unlockLevel,
    spell = spellName or (cached and cached.spell) or itemName,
    spellID = spellID or (cached and cached.spellID),
    rank = SAK.RankNumber(itemName) or (cached and cached.rank),
  })
end

local function merchantPetGrimoire(index)
  if not (GetMerchantItemLink and GetItemInfoCompat) then return nil end
  local itemLink = GetMerchantItemLink(index)
  if not itemLink then return nil end

  local itemName, _, _, _, itemMinLevel = GetItemInfoCompat(itemLink)
  if not itemName then return nil end

  local tooltip = SAK.EnsureScanTooltip()
  tooltip:ClearLines()
  tooltip:SetMerchantItem(index)
  local pet = detectPetFromTooltip(tooltip)
  if not pet then return nil end
  local spellName, spellID = merchantItemSpell(index, itemLink, itemName)

  return storeGrimoireInfo({
    itemName = itemName,
    itemLink = itemLink,
    itemID = SAK.ItemIDFromLink(itemLink),
    minLevel = tonumber(itemMinLevel) or 0,
    pet = pet.name,
    petKey = pet.key,
    petIcon = pet.icon,
    petUnlockLevel = pet.unlockLevel,
    spell = spellName,
    spellID = spellID,
    rank = SAK.RankNumber(itemName),
  })
end

local function petKnowsGrimoire(info)
  if not (info and info.petKey) then return nil end
  local petData = SAK.EnsureDB().petSpells[info.petKey]
  if not petData then return nil end
  petData.petKey = petData.petKey or info.petKey
  petData.petName = petData.petName or info.pet
  if info.spellID and petData.byID and petData.byID[tostring(info.spellID)] then return true end

  local knownRank
  if info.spell and petData.byName then knownRank = petData.byName[info.spell] end
  if not knownRank and info.spell then knownRank = petData[info.spell] end
  if not knownRank then return false end
  if info.rank and not (tonumber(knownRank) and tonumber(knownRank) >= info.rank) then return false end

  if info.spellID then
    petData.byID = petData.byID or {}
    petData.byID[tostring(info.spellID)] = tonumber(knownRank) or info.rank or 1
  end
  return true
end

function PetGrimoires.FindUpgrade(family, spell)
  if spell.ranked == false then return end
  if SAK.RankPolicy and not SAK.RankPolicy.BuyRankEnabled() then return end
  local level = UnitLevel and UnitLevel("pet") or 0
  if not level or level < 1 then level = UnitLevel and UnitLevel("player") or 0 end
  local getName = C_Spell and C_Spell.GetSpellName or GetSpellInfo
  local best
  local function consider(id, rank, required, name)
    id, rank, required = tonumber(id), tonumber(rank), tonumber(required)
    if not id or not rank or not required or rank <= family.max or required > level then return end
    name = name or (getName and getName(id))
    if name and SAK.NormalizeText(name) == SAK.NormalizeText(spell.name)
      and (not best or rank > best.rank) then
      best = { id = id, rank = rank, level = required }
    end
  end
  for _, levels in pairs(type(TrainerSpells_PetData) == "table" and TrainerSpells_PetData or {}) do
    local matched = false
    for _, spells in pairs(levels) do
      for id in pairs(spells) do if family.ids[tonumber(id)] then matched = true end end
    end
    if matched then
      for required, spells in pairs(levels) do
        for id, data in pairs(spells) do consider(id, data.rank, required) end
      end
    end
  end
  for _, info in pairs(SAK.EnsureDB().petGrimoires or {}) do
    if info.petKey == currentPetKey() then
      consider(info.spellID, info.rank, info.minLevel, info.spell)
    end
  end
  return best
end

function PetGrimoires.KnowsItemInfo(info)
  return petKnowsGrimoire(info)
end

local function grimoireState(info)
  if not info then return nil end
  local known = petKnowsGrimoire(info)
  if known then return "known" end

  local level = UnitLevel and UnitLevel("player") or 0
  if (info.minLevel or 0) > level then return "unavailable" end
  return nil
end

function PetGrimoires.ItemState(info)
  return grimoireState(info)
end

local function grimoireLearnable(info)
  if not info or petKnowsGrimoire(info) then return false end
  local level = UnitLevel and UnitLevel("player") or 0
  return (info.minLevel or 0) <= level
end

function PetGrimoires.ItemLearnable(info)
  return grimoireLearnable(info)
end

local function grimoireBookOwned(info, ownedItems)
  return info and info.itemID and ownedItems and (ownedItems[info.itemID] or 0) > 0
end

local function grimoireActivePet(info)
  return info and currentPetKey() == info.petKey
end

function PetGrimoires.ActivePetForInfo(info)
  return grimoireActivePet(info)
end

local function tooltipHasLine(tooltip, expected)
  if not (tooltip and tooltip.GetName and tooltip.NumLines) then return false end
  local tooltipName = tooltip:GetName()
  for line = 1, tooltip:NumLines() do
    local fs = _G[tooltipName .. "TextLeft" .. line]
    if fs and fs.GetText and fs:GetText() == expected then return true end
  end
  return false
end

local function enhanceMerchantPetTooltip(tooltip, index)
  if SAK.DisplayEnabled and not SAK.DisplayEnabled("text") then return end
  if not (tooltip and tooltip.AddLine and index) then return end
  local info = merchantPetGrimoire(index)
  if not info then return end

  if petKnowsGrimoire(info) and not tooltipHasLine(tooltip, SAK.MERCHANT_LEARNED_LABEL) then
    tooltip:AddLine(SAK.MERCHANT_LEARNED_LABEL, SAK.MERCHANT_LEARNED_TOOLTIP[1], SAK.MERCHANT_LEARNED_TOOLTIP[2], SAK.MERCHANT_LEARNED_TOOLTIP[3])
  end

  local ownedItems = scanInventoryItemIDs()
  if not petKnowsGrimoire(info) and grimoireBookOwned(info, ownedItems) then
    local line = "You already have this book in your bags."
    if not tooltipHasLine(tooltip, line) then
      tooltip:AddLine(line, SAK.MERCHANT_READ_BOOK_COLOR[1], SAK.MERCHANT_READ_BOOK_COLOR[2], SAK.MERCHANT_READ_BOOK_COLOR[3])
    end
  end

  if grimoireLearnable(info) and not grimoireBookOwned(info, ownedItems) then
    local line = string.format("You can learn it! Your %s will love it!", info.pet or "pet")
    if not tooltipHasLine(tooltip, line) then
      tooltip:AddLine(line, SAK.MERCHANT_LEARNABLE_TEXT[1], SAK.MERCHANT_LEARNABLE_TEXT[2], SAK.MERCHANT_LEARNABLE_TEXT[3])
    end
  end

  local petData = SAK.EnsureDB().petSpells[info.petKey]
  local playerLevel = UnitLevel and UnitLevel("player") or 0
  if info.petUnlockLevel and (not petData or playerLevel < info.petUnlockLevel) then
    local line = string.format("Pet unlockable at level: %s", info.petUnlockLevel)
    if not tooltipHasLine(tooltip, line) then
      tooltip:AddLine(line, 1, 0.82, 0.05)
    end
  end

  tooltip:Show()
end

local function merchantVisibleIndex(visible)
  local page = MerchantFrame and MerchantFrame.page or 1
  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  return ((page - 1) * perPage) + visible
end

function PetGrimoires.Paint()
  if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems) then return end
  PetGrimoires.SyncActivePetSpells()
  local ownedItems = scanInventoryItemIDs()

  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  local numItems = GetMerchantNumItems()
  for visible = 1, perPage do
    local merchantButton = _G["MerchantItem" .. visible]
    local name = _G["MerchantItem" .. visible .. "Name"]
    if merchantButton and merchantButton:IsShown() and name then
      local itemButton = Visuals.MerchantItemButton(visible, merchantButton)
      local index = merchantVisibleIndex(visible)
      local info = index <= numItems and merchantPetGrimoire(index) or nil
      local state = grimoireState(info)
      local learnable = state ~= "known" and grimoireLearnable(info)
      local readBook = state ~= "known" and grimoireBookOwned(info, ownedItems)
      Visuals.PaintOutline(merchantButton, false)
      Visuals.PaintLearnableBg(merchantButton, false)
      Visuals.PaintKnownBg(merchantButton, false)
      Visuals.PaintMerchantBg(merchantButton)
      Visuals.PaintMerchantKnownPrefix(name, false)
      Visuals.PaintMerchantReadBookPrefix(name, false)
      Visuals.PaintMerchantBg(merchantButton, state == "known")
      Visuals.PaintParts(name, nil, state == "known" and nil or state)
      Visuals.PaintMerchantLearnableText(name, learnable and not readBook)
      Visuals.PaintMerchantKnownPrefix(name, state == "known")
      Visuals.PaintMerchantReadBookPrefix(name, readBook)
      Visuals.EnsureMerchantTextLayer(name)
      Visuals.PaintOutline(merchantButton, learnable or readBook, readBook and SAK.MERCHANT_READ_BOOK_OUTLINE or SAK.MERCHANT_LEARNABLE_OUTLINE)
      if SAK.RecentVisuals then
        SAK.RecentVisuals.Paint(itemButton, itemButton, info and info.spellID, "pets", "iconsMerchant")
      end
      Visuals.PaintMerchantKnownBookOverlay(itemButton, state == "known")
      Visuals.PaintMerchantPetIcon(itemButton, info)
      Visuals.PaintMerchantLearnableBadge(itemButton, learnable and not readBook)
    elseif merchantButton then
      Visuals.PaintOutline(merchantButton, false)
      Visuals.PaintLearnableBg(merchantButton, false)
      Visuals.PaintKnownBg(merchantButton, false)
      Visuals.PaintMerchantBg(merchantButton)
      Visuals.PaintMerchantKnownPrefix(name, false)
      Visuals.PaintMerchantReadBookPrefix(name, false)
      local itemButton = Visuals.MerchantItemButton(visible, merchantButton)
      if SAK.RecentVisuals then SAK.RecentVisuals.Paint(itemButton, itemButton, nil, "pets", "iconsMerchant") end
      Visuals.PaintMerchantKnownBookOverlay(itemButton, false)
      Visuals.PaintMerchantPetIcon(itemButton, nil)
      Visuals.PaintMerchantLearnableBadge(itemButton, false)
    end
  end
end

local function buildMerchantDebugText()
  local lines = {}
  lines[#lines + 1] = string.format(
    "SAK pet: active=%s activeKey=%s petLevel=%s savedPets=%s legacyBook=%s modernBook=%s",
    tostring(currentPetFamily()),
    tostring(currentPetKey()),
    tostring(UnitLevel and UnitLevel("pet")),
    tostring(SkillsAlreadyKnownDB and SkillsAlreadyKnownDB.petSpells and SAK.TableCount(SkillsAlreadyKnownDB.petSpells) or 0),
    tostring(type(GetSpellBookItemName) == "function"),
    tostring(C_SpellBook and type(C_SpellBook.GetSpellBookItemName) == "function")
  )
  local petData = SAK.EnsureDB().petSpells[currentPetKey()]
  lines[#lines + 1] = string.format(
    "SAK pet saved: name=%s total=%s byID=%s byName=%s legacy=%s",
    tostring(type(petData) == "table" and petData.petName or nil),
    tostring(SAK.LearnedSpellCount(petData)),
    tostring(type(petData) == "table" and type(petData.byID) == "table" and SAK.TableCount(petData.byID) or 0),
    tostring(type(petData) == "table" and type(petData.byName) == "table" and SAK.TableCount(petData.byName) or 0),
    tostring(SAK.LegacySpellCount(petData))
  )
  if type(petData) == "table" then
    SAK.AppendLimitedPairs(lines, "byID", petData.byID, 12)
    SAK.AppendLimitedPairs(lines, "byName", petData.byName, 12)
  end

  if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems) then
    lines[#lines + 1] = "SAK pet: no visible merchant."
    return table.concat(lines, "\n")
  end

  local ownedItems = scanInventoryItemIDs()
  for index = 1, GetMerchantNumItems() do
    local info = merchantPetGrimoire(index)
    if info then
      local known = petKnowsGrimoire(info)
      local saved = info.spellID and SAK.EnsureDB().petSpells[info.petKey]
      local savedID = saved and saved.byID and saved.byID[tostring(info.spellID)] or nil
      lines[#lines + 1] = string.format(
        "SAK pet: idx=%s pet=%s key=%s unlock=%s spell=%s spellID=%s savedID=%s rank=%s minLevel=%s known=%s state=%s learnable=%s item=%s",
        tostring(index),
        tostring(info.pet),
        tostring(info.petKey),
        tostring(info.petUnlockLevel),
        tostring(info.spell),
        tostring(info.spellID),
        tostring(savedID),
        tostring(info.rank),
        tostring(info.minLevel),
        tostring(known),
        tostring(grimoireState(info)),
        tostring(grimoireLearnable(info)),
        tostring(info.itemName)
      )
      lines[#lines] = lines[#lines] .. string.format(" itemID=%s ownedBook=%s", tostring(info.itemID), tostring(grimoireBookOwned(info, ownedItems)))
    end
  end

  return table.concat(lines, "\n")
end

function PetGrimoires.ShowDebugWindow()
  PetGrimoires.SyncActivePetSpells()
  SAK.ShowDebugTextWindow("Pet", "Skills & More Pet Debug", buildMerchantDebugText(), function()
    PetGrimoires.SyncActivePetSpells()
    return buildMerchantDebugText()
  end)
end

function PetGrimoires.SummaryText()
  PetGrimoires.SyncActivePetSpells()
  local pet = currentPetFamily()
  local key = currentPetKey()
  local petData = key ~= "" and SAK.EnsureDB().petSpells[key]
  return string.format(
    "SkillsAlreadyKnown pet summary\n\nactive pet=%s\nkey=%s\nsaved spells=%s\nsaved byID=%s\nsaved byName=%s\nlegacy=%s",
    tostring(pet),
    tostring(key),
    tostring(SAK.LearnedSpellCount(petData)),
    tostring(petData and SAK.TableCount(petData.byID)),
    tostring(petData and SAK.TableCount(petData.byName)),
    tostring(SAK.LegacySpellCount(petData))
  )
end

function PetGrimoires.ShowSummaryWindow()
  PetGrimoires.Paint()
  SAK.ShowDebugTextWindow("PetSummary", "Skills & More Pet Summary", PetGrimoires.SummaryText(), PetGrimoires.SummaryText)
end

function PetGrimoires.PrintSummary()
  SAK.ShowDebugTextWindow("PetSummary", "Skills & More Pet Summary", PetGrimoires.SummaryText(), PetGrimoires.SummaryText)
end

function PetGrimoires.Hook()
  if merchantHooked then return end
  merchantHooked = true

  if type(MerchantFrame_UpdateMerchantInfo) == "function" then
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", PetGrimoires.Paint)
  end
  if GameTooltip and GameTooltip.SetMerchantItem then
    hooksecurefunc(GameTooltip, "SetMerchantItem", enhanceMerchantPetTooltip)
  end
end
