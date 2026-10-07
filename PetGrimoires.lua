-- SkillsAlreadyKnown: warlock pet grimoire support.

local SAK = SkillsAlreadyKnown
local Visuals = SAK.Visuals
local PetGrimoires = {}
SAK.PetGrimoires = PetGrimoires

local merchantHooked
local petSyncQueued
local GetItemInfoCompat = GetItemInfo or (C_Item and C_Item.GetItemInfo)
local GetItemSpellCompat = GetItemSpell or (C_Item and C_Item.GetItemSpell)

local function containerNumSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) or 0 end
  if GetContainerNumSlots then return GetContainerNumSlots(bag) or 0 end
  return 0
end

local function containerItemLink(bag, slot)
  if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bag, slot) end
  if GetContainerItemLink then return GetContainerItemLink(bag, slot) end
end

local function scanInventoryItemIDs()
  local owned = {}
  local maxBag = NUM_BAG_SLOTS or 4

  for bag = 0, maxBag do
    for slot = 1, containerNumSlots(bag) do
      local itemID = SAK.ItemIDFromLink(containerItemLink(bag, slot))
      if itemID then owned[itemID] = (owned[itemID] or 0) + 1 end
    end
  end

  return owned
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
  local spellID

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
      local id = info.actionID or info.spellID
      if type(id) == "number" and id > 0 then spellID = id end
    end
  end

  if GetSpellBookItemName then
    local ok, name, rank = pcall(GetSpellBookItemName, index, bank)
    if ok and name then return name, rank, spellID end
  end

  if C_SpellBook and C_SpellBook.GetSpellBookItemName then
    local ok, name, rank = pcall(C_SpellBook.GetSpellBookItemName, index, bank)
    if ok and name then return name, rank, spellID end
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

function PetGrimoires.SyncActivePetSpells()
  local pet = currentPetFamily()
  if not pet then return end

  local learned = scanPetSpellBook()
  local key = SAK.PetKey(pet)
  learned.petKey = key
  learned.petName = pet
  SAK.EnsureDB().petSpells[key] = learned
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

  return {
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
  }
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

local function grimoireState(info)
  if not info then return nil end
  local known = petKnowsGrimoire(info)
  if known then return "known" end

  local activePet = currentPetKey() == info.petKey
  local playerLevel = UnitLevel and UnitLevel("player") or 0
  local petLevel = UnitLevel and UnitLevel("pet") or playerLevel
  local level = activePet and petLevel or playerLevel
  if (info.minLevel or 0) > level then return "unavailable" end
  return nil
end

local function grimoireLearnable(info)
  if not info or petKnowsGrimoire(info) then return false end
  if currentPetKey() ~= info.petKey then return false end
  local petLevel = UnitLevel and UnitLevel("pet") or UnitLevel("player") or 0
  return (info.minLevel or 0) <= petLevel
end

local function grimoireBookOwned(info, ownedItems)
  return info and info.itemID and ownedItems and (ownedItems[info.itemID] or 0) > 0
end

local function grimoireActivePet(info)
  return info and currentPetKey() == info.petKey
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
  if not (tooltip and tooltip.AddLine and index) then return end
  local info = merchantPetGrimoire(index)
  if not info then return end

  if petKnowsGrimoire(info) and not tooltipHasLine(tooltip, SAK.MERCHANT_LEARNED_LABEL) then
    tooltip:AddLine(SAK.MERCHANT_LEARNED_LABEL, SAK.MERCHANT_LEARNED_TOOLTIP[1], SAK.MERCHANT_LEARNED_TOOLTIP[2], SAK.MERCHANT_LEARNED_TOOLTIP[3])
  end

  if grimoireLearnable(info) then
    local ownedItems = scanInventoryItemIDs()
    if grimoireBookOwned(info, ownedItems) then
      local line = string.format("You already own this book. Read it with your %s out.", info.pet or "pet")
      if not tooltipHasLine(tooltip, line) then
        tooltip:AddLine(line, SAK.MERCHANT_READ_BOOK_COLOR[1], SAK.MERCHANT_READ_BOOK_COLOR[2], SAK.MERCHANT_READ_BOOK_COLOR[3])
      end
      tooltip:Show()
      return
    end

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
      local readBook = learnable and grimoireBookOwned(info, ownedItems)
      Visuals.PaintOutline(merchantButton, false)
      Visuals.PaintLearnableBg(merchantButton, false)
      Visuals.PaintKnownBg(merchantButton, false)
      Visuals.PaintMerchantBg(merchantButton)
      Visuals.PaintMerchantKnownPrefix(name, false)
      Visuals.PaintMerchantReadBookPrefix(name, false)
      Visuals.PaintMerchantBg(merchantButton, state == "known" and not grimoireActivePet(info))
      Visuals.PaintParts(name, nil, state == "known" and nil or state)
      Visuals.PaintMerchantLearnableText(name, learnable and not readBook)
      Visuals.PaintMerchantKnownPrefix(name, state == "known")
      Visuals.PaintMerchantReadBookPrefix(name, readBook)
      Visuals.EnsureMerchantTextLayer(name)
      Visuals.PaintOutline(merchantButton, learnable, readBook and SAK.MERCHANT_READ_BOOK_OUTLINE or SAK.MERCHANT_LEARNABLE_OUTLINE)
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
  SAK.ShowDebugTextWindow("Pet", "Skills Already Known Pet Debug", buildMerchantDebugText(), function()
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
  SAK.ShowDebugTextWindow("PetSummary", "Skills Already Known Pet Summary", PetGrimoires.SummaryText(), PetGrimoires.SummaryText)
end

function PetGrimoires.PrintSummary()
  SAK.ShowDebugTextWindow("PetSummary", "Skills Already Known Pet Summary", PetGrimoires.SummaryText(), PetGrimoires.SummaryText)
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
