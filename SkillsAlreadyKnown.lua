-- SkillsAlreadyKnown: clearer class trainer rows for WoW Forever.

local serviceTypes = {
  available = true,
  unavailable = true,
  used = true,
  header = true,
}

local hooked
local loadedMessage
local scrollBoxHooked
local cachedServices
local servicesDirty = true
local merchantHooked
local petSyncQueued
local debugFrame

local WHITE = "Interface\\Buttons\\WHITE8X8"
local COLORS = {
  known = { 0.34, 0.34, 0.34 },
  unavailable = { 1, 0.15, 0.15 },
}
local OUTLINE = { 0, 1, 0, 0.85 }
local LEARNABLE_BG = { 0.10, 0.45, 0.12, 0.22 }
local KNOWN_BG = { 0.05, 0.05, 0.05, 0.38 }
local MERCHANT_INACTIVE_KNOWN_BG = { 0.02, 0.28, 0.04, 0.62 }
local MERCHANT_LEARNABLE_TEXT = { 1, 0.82, 0.05 }
local MERCHANT_LEARNABLE_OUTLINE = { 1, 0.82, 0.05, 0.95 }
local MERCHANT_LEARNED_TOOLTIP = { 0.25, 1, 0.25 }
local MERCHANT_LEARNABLE_ICON = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\learnable-plus.tga"
local MERCHANT_LEARNED_LABEL = "[Already Learned!]"
local PET_SUMMON_SPELL_IDS = { 688, 697, 712, 101822, 691, 30146 }
local PET_SUMMON_FALLBACK_LEVELS = {
  [688] = 1,
  [697] = 10,
  [712] = 20,
  [691] = 30,
  [30146] = 50,
}
local petNames
local scanTooltip
local trimText
local normalizeText
local petKey
local cleanupPetName
local grimoireActivePet

local function getServiceInfo(index)
  if not GetTrainerServiceInfo then return end
  local name, second, third, fourth, fifth = GetTrainerServiceInfo(index)
  if serviceTypes[second] then
    local levelReq = fourth or 0
    if levelReq == 0 and GetTrainerServiceLevelReq then levelReq = GetTrainerServiceLevelReq(index) or 0 end
    return name, fifth, second, levelReq
  end

  local levelReq = GetTrainerServiceLevelReq and GetTrainerServiceLevelReq(index) or 0
  return name, second, third, levelReq
end

local function textOf(fontString)
  return fontString and fontString.GetText and fontString:GetText() or nil
end

local function ensureDB()
  SkillsAlreadyKnownDB = SkillsAlreadyKnownDB or {}
  SkillsAlreadyKnownDB.petSpells = SkillsAlreadyKnownDB.petSpells or {}
  return SkillsAlreadyKnownDB
end

local function spellName(spellID)
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
  if info and info.name then return info.name end
  if GetSpellInfo then return GetSpellInfo(spellID) end
end

local function spellTexture(spellID)
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

local function spellLevelLearned(spellID)
  if C_Spell and C_Spell.GetSpellLevelLearned then
    local level = C_Spell.GetSpellLevelLearned(spellID)
    if type(level) == "number" and level > 0 then return level end
  end
  if GetSpellLevelLearned then
    local level = GetSpellLevelLearned(spellID)
    if type(level) == "number" and level > 0 then return level end
  end
  return PET_SUMMON_FALLBACK_LEVELS[spellID]
end

local function tableCount(tbl)
  local count = 0
  for _ in pairs(tbl) do count = count + 1 end
  return count
end

local function learnedSpellCount(petData)
  if type(petData) ~= "table" then return 0 end
  if type(petData.byID) == "table" and tableCount(petData.byID) > 0 then return tableCount(petData.byID) end
  if type(petData.byName) == "table" then return tableCount(petData.byName) end
  return tableCount(petData)
end

local function legacySpellCount(petData)
  if type(petData) ~= "table" then return 0 end
  local count = 0
  for key in pairs(petData) do
    if key ~= "byID" and key ~= "byName" and key ~= "petKey" and key ~= "petName" then
      count = count + 1
    end
  end
  return count
end

local function appendLimitedPairs(lines, label, tbl, limit)
  if type(tbl) ~= "table" then return end
  local shown = 0
  for key, value in pairs(tbl) do
    shown = shown + 1
    if shown > limit then
      lines[#lines + 1] = string.format("SAK pet saved %s: ... +%s more", label, tableCount(tbl) - limit)
      break
    end
    lines[#lines + 1] = string.format("SAK pet saved %s: %s=%s", label, tostring(key), tostring(value))
  end
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
  if tableCount(names) < 2 then return names end
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
    name = cleanupPetName(name)
    local key = petKey(name)
    if name ~= "" and key ~= "" and not seen[key] then
      seen[key] = true
      out[#out + 1] = { name = name, key = key, icon = icon, unlockLevel = unlockLevel }
    end
  end

  for _, spellID in ipairs(PET_SUMMON_SPELL_IDS) do
    local name = spellName(spellID)
    if name and name ~= "" then
      local icon = spellTexture(spellID)
      local unlockLevel = spellLevelLearned(spellID)
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

local function getPetNames()
  if not petNames then petNames = buildPetNames() end
  return petNames
end

local function ensureScanTooltip()
  if not scanTooltip then
    scanTooltip = CreateFrame("GameTooltip", "SkillsAlreadyKnownScanTooltip", nil, "GameTooltipTemplate")
    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  end
  return scanTooltip
end

local function rankNumber(text)
  if type(text) ~= "string" then return nil end
  return tonumber(text:match("%d+"))
end

trimText = function(text)
  if type(text) ~= "string" then return "" end
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

normalizeText = function(text)
  return trimText(text):lower()
end

petKey = function(text)
  return normalizeText(text)
end

cleanupPetName = function(text)
  text = trimText(text)
  text = text:gsub("^[dD][’']un%s+", "")
  text = text:gsub("^[dD][’']une%s+", "")
  text = text:gsub("^[uU]n%s+", "")
  text = text:gsub("^[uU]ne%s+", "")
  text = text:gsub("^[lL][’']", "")
  text = text:gsub("^[lL]e%s+", "")
  text = text:gsub("^[lL]a%s+", "")
  text = text:gsub("^%a%s+", "")
  return trimText(text)
end

local function paintParts(name, sub, state)
  local color = COLORS[state]
  if color then
    if name and name.SetTextColor then name:SetTextColor(color[1], color[2], color[3]) end
    if sub and sub.SetTextColor then
      if state == "unavailable" then
        sub:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
      else
        sub:SetTextColor(color[1], color[2], color[3])
      end
    end
  else
    if name and name.SetTextColor then name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b) end
    if sub and sub.SetTextColor then sub:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end
  end
end

local function ensureOutline(frame)
  if frame.sakOutline then return frame.sakOutline end

  local top = frame:CreateTexture(nil, "OVERLAY")
  local bottom = frame:CreateTexture(nil, "OVERLAY")
  local left = frame:CreateTexture(nil, "OVERLAY")
  local right = frame:CreateTexture(nil, "OVERLAY")

  for _, tex in ipairs({ top, bottom, left, right }) do
    tex:SetTexture(WHITE)
    tex:SetColorTexture(OUTLINE[1], OUTLINE[2], OUTLINE[3], OUTLINE[4])
    tex:Hide()
  end

  top:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  top:SetHeight(2)

  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  bottom:SetHeight(2)

  left:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  left:SetWidth(2)

  right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  right:SetWidth(2)

  frame.sakOutline = { top, bottom, left, right }
  return frame.sakOutline
end

local function paintOutline(frame, show, color)
  if not frame then return end
  local outline = ensureOutline(frame)
  color = color or OUTLINE
  for _, tex in ipairs(outline) do
    tex:SetColorTexture(color[1], color[2], color[3], color[4])
    tex:SetShown(show and true or false)
  end
end

local function ensureLearnableBg(frame)
  if frame.sakLearnableBg then return frame.sakLearnableBg end

  local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
  tex:SetTexture(WHITE)
  tex:SetColorTexture(LEARNABLE_BG[1], LEARNABLE_BG[2], LEARNABLE_BG[3], LEARNABLE_BG[4])
  tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
  tex:Hide()

  frame.sakLearnableBg = tex
  return tex
end

local function paintLearnableBg(frame, show)
  if not frame then return end
  ensureLearnableBg(frame):SetShown(show and true or false)
end

local function ensureKnownBg(frame)
  if frame.sakKnownBg then return frame.sakKnownBg end

  local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 6)
  tex:SetTexture(WHITE)
  tex:SetColorTexture(KNOWN_BG[1], KNOWN_BG[2], KNOWN_BG[3], KNOWN_BG[4])
  tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
  tex:Hide()

  frame.sakKnownBg = tex
  return tex
end

local function paintKnownBg(frame, show)
  if not frame then return end
  ensureKnownBg(frame):SetShown(show and true or false)
end

local function ensureMerchantBg(frame)
  if frame.sakMerchantBg then return frame.sakMerchantBg end

  local tex = frame:CreateTexture(nil, "ARTWORK", nil, 1)
  tex:SetTexture(WHITE)
  tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
  tex:Hide()

  frame.sakMerchantBg = tex
  return tex
end

local function paintMerchantBg(frame, info, state)
  if not frame then return end
  local tex = ensureMerchantBg(frame)
  if state == "known" and not grimoireActivePet(info) then
    tex:SetColorTexture(MERCHANT_INACTIVE_KNOWN_BG[1], MERCHANT_INACTIVE_KNOWN_BG[2], MERCHANT_INACTIVE_KNOWN_BG[3], MERCHANT_INACTIVE_KNOWN_BG[4])
    tex:Show()
  else
    tex:Hide()
  end
end

local function paintMerchantLearnableText(fontString, show)
  if show and fontString and fontString.SetTextColor then
    fontString:SetTextColor(MERCHANT_LEARNABLE_TEXT[1], MERCHANT_LEARNABLE_TEXT[2], MERCHANT_LEARNABLE_TEXT[3])
  end
end

local function merchantItemButton(visible, merchantButton)
  return _G["MerchantItem" .. visible .. "ItemButton"] or (merchantButton and merchantButton.ItemButton) or merchantButton
end

local function merchantItemIconTexture(itemButton)
  if not itemButton then return nil end
  return itemButton.icon or itemButton.Icon or (itemButton.GetName and _G[itemButton:GetName() .. "IconTexture"])
end

local function ensureMerchantKnownBookOverlay(itemButton)
  if not itemButton then return nil end
  if itemButton.sakKnownBookOverlay then return itemButton.sakKnownBookOverlay end

  local source = merchantItemIconTexture(itemButton)
  local overlay = itemButton:CreateTexture(nil, "OVERLAY", nil, 4)
  if source then
    overlay:SetAllPoints(source)
  else
    overlay:SetPoint("TOPLEFT", itemButton, "TOPLEFT", 2, -2)
    overlay:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", -2, 2)
  end
  overlay:SetDesaturated(true)
  overlay:SetVertexColor(0.36, 0.36, 0.36, 0.92)
  overlay:Hide()

  itemButton.sakKnownBookOverlay = overlay
  return overlay
end

local function paintMerchantKnownBookOverlay(itemButton, show)
  if not itemButton then return end
  local overlay = ensureMerchantKnownBookOverlay(itemButton)
  if show then
    local source = merchantItemIconTexture(itemButton)
    local texture = source and source.GetTexture and source:GetTexture()
    if texture then overlay:SetTexture(texture) end
    overlay:Show()
  else
    overlay:Hide()
  end
end

local function ensureMerchantPetIcon(itemButton)
  if not itemButton then return nil end
  if itemButton.sakPetIcon then return itemButton.sakPetIcon end

  local bg = itemButton:CreateTexture(nil, "OVERLAY", nil, 5)
  bg:SetTexture(WHITE)
  bg:SetColorTexture(0, 0, 0, 0.82)
  bg:SetSize(23, 23)
  bg:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 2, -2)
  bg:Hide()

  local icon = itemButton:CreateTexture(nil, "OVERLAY", nil, 6)
  icon:SetSize(21, 21)
  icon:SetPoint("CENTER", bg, "CENTER")
  icon:Hide()

  itemButton.sakPetIconBg = bg
  itemButton.sakPetIcon = icon
  return icon
end

local function paintMerchantPetIcon(itemButton, info)
  if not itemButton then return end
  local icon = ensureMerchantPetIcon(itemButton)
  local bg = itemButton.sakPetIconBg
  if info and info.petIcon then
    icon:SetTexture(info.petIcon)
    icon:Show()
    if bg then bg:Show() end
  else
    if icon then icon:Hide() end
    if bg then bg:Hide() end
  end
end

local function ensureMerchantLearnableBadge(itemButton)
  if not itemButton then return nil end
  if itemButton.sakLearnableBadge then return itemButton.sakLearnableBadge end

  local icon = itemButton:CreateTexture(nil, "OVERLAY", nil, 7)
  icon:SetTexture(MERCHANT_LEARNABLE_ICON)
  icon:SetSize(24, 24)
  icon:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 10, 8)
  icon:Hide()

  itemButton.sakLearnableBadge = icon
  return icon
end

local function paintMerchantLearnableBadge(itemButton, show)
  if not itemButton then return end
  local icon = ensureMerchantLearnableBadge(itemButton)
  if show then
    icon:Show()
  else
    if icon then icon:Hide() end
  end
end

local function ensureMerchantTextLayer(fontString)
  if not (fontString and fontString.SetDrawLayer) then return end
  pcall(fontString.SetDrawLayer, fontString, "OVERLAY", 7)
end

local function paintMerchantKnownPrefix(fontString, show)
  if not (fontString and fontString.GetText and fontString.SetText) then return end
  local text = fontString:GetText()
  if type(text) ~= "string" then return end

  text = text:gsub("^|cffffffff%[Already Learned!%]|r%s*", "")
  text = text:gsub("^%[Already Learned!%]%s*", "")
  text = text:gsub("^|cffffffff%[Learned!%]|r%s*", "")
  text = text:gsub("^%[Learned!%]%s*", "")
  if show then text = "|cffffffff" .. MERCHANT_LEARNED_LABEL .. "|r " .. text end
  fontString:SetText(text)
end

local function clearRowVisuals(row)
  if not row then return end
  paintParts(row.name or row.Name or row.Text, row.subText or row.SubText, nil)
  paintOutline(row, false)
  paintLearnableBg(row, false)
  paintKnownBg(row, false)
end

local function currentPetFamily()
  if not (UnitExists and UnitExists("pet")) then return nil end
  if UnitIsDead and UnitIsDead("pet") then return nil end
  return UnitCreatureFamily and UnitCreatureFamily("pet") or nil
end

local function currentPetKey()
  return petKey(currentPetFamily())
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
        local rankNum = rankNumber(rank) or 1
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

local function syncActivePetSpells()
  local pet = currentPetFamily()
  if not pet then return end

  local learned = scanPetSpellBook()
  local key = petKey(pet)
  learned.petKey = key
  learned.petName = pet
  ensureDB().petSpells[key] = learned
end

local function queuePetSync()
  if petSyncQueued then return end
  petSyncQueued = true

  if C_Timer and C_Timer.After then
    C_Timer.After(0.5, function()
      petSyncQueued = nil
      syncActivePetSpells()
    end)
  else
    petSyncQueued = nil
    syncActivePetSpells()
  end
end

local GetItemInfoCompat = GetItemInfo or (C_Item and C_Item.GetItemInfo)
local GetItemSpellCompat = GetItemSpell or (C_Item and C_Item.GetItemSpell)

local function detectPetFromTooltip(tooltip)
  if not (tooltip and tooltip.GetName and tooltip.NumLines) then return nil end
  local tooltipName = tooltip:GetName()

  for line = 1, tooltip:NumLines() do
    local fs = _G[tooltipName .. "TextLeft" .. line]
    local text = normalizeText(fs and fs:GetText())
    if text ~= "" then
      for _, pet in ipairs(getPetNames()) do
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

  local tooltip = ensureScanTooltip()
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

  local tooltip = ensureScanTooltip()
  tooltip:ClearLines()
  tooltip:SetMerchantItem(index)
  local pet = detectPetFromTooltip(tooltip)
  if not pet then return nil end
  local spellName, spellID = merchantItemSpell(index, itemLink, itemName)

  return {
    itemName = itemName,
    itemLink = itemLink,
    minLevel = tonumber(itemMinLevel) or 0,
    pet = pet.name,
    petKey = pet.key,
    petIcon = pet.icon,
    petUnlockLevel = pet.unlockLevel,
    spell = spellName,
    spellID = spellID,
    rank = rankNumber(itemName),
  }
end

local function petKnowsGrimoire(info)
  if not (info and info.petKey) then return nil end
  local petData = ensureDB().petSpells[info.petKey]
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

grimoireActivePet = function(info)
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

  if petKnowsGrimoire(info) and not tooltipHasLine(tooltip, MERCHANT_LEARNED_LABEL) then
    tooltip:AddLine(MERCHANT_LEARNED_LABEL, MERCHANT_LEARNED_TOOLTIP[1], MERCHANT_LEARNED_TOOLTIP[2], MERCHANT_LEARNED_TOOLTIP[3])
  end

  if grimoireLearnable(info) then
    local line = string.format("You can learn it! Your %s will love it!", info.pet or "pet")
    if not tooltipHasLine(tooltip, line) then
      tooltip:AddLine(line, MERCHANT_LEARNABLE_TEXT[1], MERCHANT_LEARNABLE_TEXT[2], MERCHANT_LEARNABLE_TEXT[3])
    end
  end

  local petData = ensureDB().petSpells[info.petKey]
  local playerLevel = UnitLevel and UnitLevel("player") or 0
  if info.petUnlockLevel and (not petData or playerLevel < info.petUnlockLevel) then
    local line = string.format("Pet unlockable at level: %s", info.petUnlockLevel)
    if not tooltipHasLine(tooltip, line) then
      tooltip:AddLine(line, 1, 0.82, 0.05)
    end
  end

  tooltip:Show()
end

local function cleanText(text)
  if type(text) ~= "string" then return "" end
  return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function serviceDisplayName(name, subText)
  if type(name) ~= "string" then return "" end
  if type(subText) == "string" and subText ~= "" then
    return name .. " (" .. subText .. ")"
  end
  return name
end

local function getServiceSpellID(index)
  if not (C_TooltipInfo and C_TooltipInfo.GetTrainerService) then return nil end
  local ok, data = pcall(C_TooltipInfo.GetTrainerService, index)
  if ok and type(data) == "table" and type(data.id) == "number" and data.id > 0 then
    return data.id
  end
  return nil
end

local function buildVisibleServices()
  local out = {}
  if not GetNumTrainerServices then return out end

  for index = 1, GetNumTrainerServices() do
    local name, subText, serviceType, levelReq = getServiceInfo(index)
    if name and serviceType ~= "header" then
      out[#out + 1] = {
        index = index,
        name = name,
        subText = subText,
        serviceType = serviceType,
        levelReq = tonumber(levelReq) or 0,
        spellID = getServiceSpellID(index),
        display = cleanText(serviceDisplayName(name, subText)),
      }
    end
  end

  return out
end

local function markServicesDirty()
  servicesDirty = true
end

local function getVisibleServices()
  if servicesDirty or not cachedServices then
    cachedServices = buildVisibleServices()
    servicesDirty = nil
  end

  return cachedServices
end

local function serviceState(service)
  if not service then return nil end
  if service.serviceType == "used" then return "known" end
  if (service.levelReq or 0) > (UnitLevel("player") or 0) then return "unavailable" end
  return nil
end

local function serviceLearnable(service)
  return service and service.serviceType == "available"
end

local function serviceMatchesRow(service, rowText)
  if not service or rowText == "" then return false end
  return service.display == rowText or service.name == rowText
end

local function elementData(row)
  if not (row and row.GetElementData) then return nil end
  local ok, data = pcall(row.GetElementData, row)
  if ok and type(data) == "table" then return data end
  return nil
end

local function elementDataIndex(row)
  local data = elementData(row)
  if not data then return nil end
  return data.index or data.serviceIndex or data.trainerServiceIndex
end

local function findSpellID(data, depth)
  if type(data) ~= "table" or (depth or 0) > 3 then return nil end

  for _, key in ipairs({ "spellID", "spellId", "spellIDLearned", "learnedSpellID", "learnedSpellId", "id" }) do
    local value = data[key]
    if type(value) == "number" and value > 0 then return value end
  end

  for _, value in pairs(data) do
    local found = findSpellID(value, (depth or 0) + 1)
    if found then return found end
  end

  return nil
end

local function elementDataSpellID(row)
  return findSpellID(elementData(row), 0)
end

local function resolveRowService(row, services, state)
  local rowText = cleanText(textOf(row.name or row.Name or row.Text))
  local service
  local matchedPosition
  local rowSpellID = elementDataSpellID(row)
  if rowSpellID then
    for i, candidate in ipairs(services) do
      if candidate.spellID == rowSpellID then service = candidate; matchedPosition = i; break end
    end
  end

  local directIndex = elementDataIndex(row)
  if not service and directIndex then
    for i, candidate in ipairs(services) do
      if candidate.index == directIndex and serviceMatchesRow(candidate, rowText) then service = candidate; matchedPosition = i; break end
    end
  end

  if not service then
    for i, candidate in ipairs(services) do
      if i > (state.lastPosition or 0) and serviceMatchesRow(candidate, rowText) then
        service = candidate
        matchedPosition = i
        break
      end
    end
  end

  if not service then
    for i, candidate in ipairs(services) do
      if not state.used[i] and serviceMatchesRow(candidate, rowText) then
        service = candidate
        matchedPosition = i
        break
      end
    end
  end

  if matchedPosition then
    state.used[matchedPosition] = true
    state.lastPosition = matchedPosition
  end

  return service, rowText, rowSpellID
end

local function paintScrollBoxRow(row, services, state)
  if not row or (row.IsForbidden and row:IsForbidden()) then return end

  local name = row.name or row.Name or row.Text
  local sub = row.subText or row.SubText

  if not name then
    clearRowVisuals(row)
    return
  end

  local service = resolveRowService(row, services, state)
  paintParts(name, sub, serviceState(service))
  paintOutline(row, serviceLearnable(service))
  paintLearnableBg(row, serviceLearnable(service))
  paintKnownBg(row, serviceState(service) == "known")
end

local function paintScrollBoxRows()
  local frame = ClassTrainerFrame
  local scrollBox = frame and frame.ScrollBox
  if not (scrollBox and scrollBox.ForEachFrame and scrollBox:IsVisible()) then return end
  local services = getVisibleServices()
  local state = { used = {}, lastPosition = 0 }
  pcall(scrollBox.ForEachFrame, scrollBox, function(row) paintScrollBoxRow(row, services, state) end)
end

local function debugScrollBoxRows()
  local frame = ClassTrainerFrame
  local scrollBox = frame and frame.ScrollBox
  if not (scrollBox and scrollBox.ForEachFrame and scrollBox:IsVisible()) then
    print("|cffffcc00SkillsAlreadyKnown:|r no visible trainer ScrollBox.")
    return
  end

  local services = getVisibleServices()
  local state = { used = {}, lastPosition = 0 }
  pcall(scrollBox.ForEachFrame, scrollBox, function(row)
    local service, rowText, rowSpellID = resolveRowService(row, services, state)
    print(string.format(
      "|cffffcc00SAK:|r row='%s' rowSpell=%s -> idx=%s spell=%s type=%s level=%s display='%s'",
      tostring(rowText),
      tostring(rowSpellID),
      tostring(service and service.index),
      tostring(service and service.spellID),
      tostring(service and service.serviceType),
      tostring(service and service.levelReq),
      tostring(service and service.display)
    ))
  end)
end

local function paintClassicRows()
  if not GetNumTrainerServices or not ClassTrainerFrame then return end

  local maxRows = CLASS_TRAINER_SKILLS_DISPLAYED or 0
  for visible = 1, maxRows do
    local button = _G["ClassTrainerSkill" .. visible]
    local text = _G["ClassTrainerSkill" .. visible .. "Text"]
    local subTextFrame = _G["ClassTrainerSkill" .. visible .. "SubText"]
    if button and button:IsShown() then
      local index = button:GetID()
      local name, subText, serviceType, levelReq = getServiceInfo(index)
      if name and serviceType ~= "header" then
        local state
        if serviceType == "used" then state = "known"
        elseif (tonumber(levelReq) or 0) > (UnitLevel("player") or 0) then state = "unavailable" end
        paintParts(text, subTextFrame, state)
        paintOutline(button, serviceType == "available")
        paintLearnableBg(button, serviceType == "available")
        paintKnownBg(button, state == "known")
      end
    end
  end
end

local function merchantVisibleIndex(visible)
  local page = MerchantFrame and MerchantFrame.page or 1
  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  return ((page - 1) * perPage) + visible
end

local function paintMerchantGrimoires()
  if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems) then return end
  syncActivePetSpells()

  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  local numItems = GetMerchantNumItems()
  for visible = 1, perPage do
    local merchantButton = _G["MerchantItem" .. visible]
    local name = _G["MerchantItem" .. visible .. "Name"]
    if merchantButton and merchantButton:IsShown() and name then
      local itemButton = merchantItemButton(visible, merchantButton)
      local index = merchantVisibleIndex(visible)
      local info = index <= numItems and merchantPetGrimoire(index) or nil
      local state = grimoireState(info)
      local learnable = state ~= "known" and grimoireLearnable(info)
      paintOutline(merchantButton, false)
      paintLearnableBg(merchantButton, false)
      paintKnownBg(merchantButton, false)
      paintMerchantBg(merchantButton)
      paintMerchantKnownPrefix(name, false)
      paintMerchantBg(merchantButton, info, state)
      paintParts(name, nil, state == "known" and nil or state)
      paintMerchantLearnableText(name, learnable)
      paintMerchantKnownPrefix(name, state == "known")
      ensureMerchantTextLayer(name)
      paintOutline(merchantButton, learnable, MERCHANT_LEARNABLE_OUTLINE)
      paintMerchantKnownBookOverlay(itemButton, state == "known")
      paintMerchantPetIcon(itemButton, info)
      paintMerchantLearnableBadge(itemButton, learnable)
    elseif merchantButton then
      paintOutline(merchantButton, false)
      paintLearnableBg(merchantButton, false)
      paintKnownBg(merchantButton, false)
      paintMerchantBg(merchantButton)
      paintMerchantKnownPrefix(name, false)
      local itemButton = merchantItemButton(visible, merchantButton)
      paintMerchantKnownBookOverlay(itemButton, false)
      paintMerchantPetIcon(itemButton, nil)
      paintMerchantLearnableBadge(itemButton, false)
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
    tostring(SkillsAlreadyKnownDB and SkillsAlreadyKnownDB.petSpells and tableCount(SkillsAlreadyKnownDB.petSpells) or 0),
    tostring(type(GetSpellBookItemName) == "function"),
    tostring(C_SpellBook and type(C_SpellBook.GetSpellBookItemName) == "function")
  )
  local petData = ensureDB().petSpells[currentPetKey()]
  lines[#lines + 1] = string.format(
    "SAK pet saved: name=%s total=%s byID=%s byName=%s legacy=%s",
    tostring(type(petData) == "table" and petData.petName or nil),
    tostring(learnedSpellCount(petData)),
    tostring(type(petData) == "table" and type(petData.byID) == "table" and tableCount(petData.byID) or 0),
    tostring(type(petData) == "table" and type(petData.byName) == "table" and tableCount(petData.byName) or 0),
    tostring(legacySpellCount(petData))
  )
  if type(petData) == "table" then
    appendLimitedPairs(lines, "byID", petData.byID, 12)
    appendLimitedPairs(lines, "byName", petData.byName, 12)
  end

  if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems) then
    lines[#lines + 1] = "SAK pet: no visible merchant."
    return table.concat(lines, "\n")
  end

  for index = 1, GetMerchantNumItems() do
    local info = merchantPetGrimoire(index)
    if info then
      local known = petKnowsGrimoire(info)
      local saved = info.spellID and ensureDB().petSpells[info.petKey]
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
    end
  end

  return table.concat(lines, "\n")
end

local function createDebugFrame()
  if debugFrame then return debugFrame end

  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local frame = CreateFrame("Frame", "SkillsAlreadyKnownDebugFrame", UIParent, template)
  frame:SetSize(760, 520)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
  else
    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.03, 0.03, 0.03, 0.95)
  end

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -18)
  title:SetText("Skills Already Known Debug")

  local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeButton:SetPoint("TOPRIGHT", -5, -5)

  local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 24, -52)
  scrollFrame:SetPoint("BOTTOMRIGHT", -46, 52)

  local editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetMultiLine(true)
  editBox:SetAutoFocus(false)
  editBox:SetFontObject(ChatFontNormal)
  editBox:SetTextInsets(4, 4, 4, 4)
  editBox:SetWidth(682)
  editBox:SetHeight(416)
  editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    frame:Hide()
  end)
  editBox:SetScript("OnTextChanged", function(self)
    local text = self:GetText() or ""
    local _, newlineCount = string.gsub(text, "\n", "\n")
    local contentHeight = (newlineCount + 1) * 14 + 16
    self:SetHeight(math.max(contentHeight, scrollFrame:GetHeight()))
  end)
  scrollFrame:SetScrollChild(editBox)

  local selectButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  selectButton:SetSize(110, 24)
  selectButton:SetPoint("BOTTOMLEFT", 24, 18)
  selectButton:SetText("Select All")
  selectButton:SetScript("OnClick", function()
    editBox:SetFocus()
    editBox:HighlightText()
  end)

  local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  refreshButton:SetSize(110, 24)
  refreshButton:SetPoint("LEFT", selectButton, "RIGHT", 8, 0)
  refreshButton:SetText("Refresh")
  refreshButton:SetScript("OnClick", function()
    syncActivePetSpells()
    editBox:SetText(buildMerchantDebugText())
    editBox:SetCursorPosition(0)
  end)

  frame.editBox = editBox
  frame:Hide()
  debugFrame = frame

  if UISpecialFrames then table.insert(UISpecialFrames, frame:GetName()) end
  return frame
end

local function showMerchantDebugWindow()
  syncActivePetSpells()
  local frame = createDebugFrame()
  frame.editBox:SetText(buildMerchantDebugText())
  frame.editBox:SetCursorPosition(0)
  frame:Show()
  frame:Raise()
  frame.editBox:SetFocus()
  frame.editBox:HighlightText()
end

local function printPetSummary()
  syncActivePetSpells()
  local pet = currentPetFamily()
  local key = currentPetKey()
  local petData = key ~= "" and ensureDB().petSpells[key]
  print(string.format(
    "|cffffcc00SkillsAlreadyKnown:|r active pet=%s, key=%s, saved spells=%s.",
    tostring(pet),
    tostring(key),
    tostring(learnedSpellCount(petData))
  ))
end

local function hookMerchant()
  if merchantHooked then return end
  merchantHooked = true

  if type(MerchantFrame_UpdateMerchantInfo) == "function" then
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", paintMerchantGrimoires)
  end
  if GameTooltip and GameTooltip.SetMerchantItem then
    hooksecurefunc(GameTooltip, "SetMerchantItem", enhanceMerchantPetTooltip)
  end
end

local function refresh()
  paintClassicRows()
  paintScrollBoxRows()
  paintMerchantGrimoires()
end

local refreshQueued
local function queueRefresh()
  if refreshQueued then return end
  refreshQueued = true

  if C_Timer and C_Timer.After then
    C_Timer.After(0, function()
      refreshQueued = nil
      refresh()
    end)
  else
    refreshQueued = nil
    refresh()
  end
end

local function hookScrollBoxRows(scrollBox)
  if not scrollBox or scrollBox.sakRowsHooked then return end
  scrollBox.sakRowsHooked = true

  if ScrollUtil and ScrollUtil.AddInitializedFrameCallback then
    local ok = pcall(ScrollUtil.AddInitializedFrameCallback, scrollBox, function(_, row)
      clearRowVisuals(row)
      queueRefresh()
    end, nil, false)
    scrollBox.sakHasRowCallbacks = ok or nil
  end

  if scrollBox.RegisterCallback and BaseScrollBoxEvents then
    if BaseScrollBoxEvents.OnDataRangeChanged then
      local ok = pcall(scrollBox.RegisterCallback, scrollBox, BaseScrollBoxEvents.OnDataRangeChanged, function()
        queueRefresh()
      end)
      scrollBox.sakHasRowCallbacks = scrollBox.sakHasRowCallbacks or ok or nil
    end
  end
end

local function hookTrainer()
  if not hooked and type(ClassTrainerFrame_Update) == "function" then
    hooksecurefunc("ClassTrainerFrame_Update", refresh)
    hooked = true
  end

  if ClassTrainerFrame and ClassTrainerFrame.HookScript and hooked ~= "show" then
    ClassTrainerFrame:HookScript("OnShow", function()
      C_Timer.After(0, refresh)
      C_Timer.After(0.05, refresh)
    end)
    hooked = "show"
  end

  local scrollBox = ClassTrainerFrame and ClassTrainerFrame.ScrollBox
  if scrollBox and not scrollBoxHooked then
    scrollBoxHooked = true
    hookScrollBoxRows(scrollBox)
    if scrollBox.Update and not scrollBox.sakHasRowCallbacks then
      hooksecurefunc(scrollBox, "Update", function()
        queueRefresh()
      end)
    end
  end
end

SLASH_SKILLSALREADYKNOWN1 = "/skillsalreadyknown"
SLASH_SKILLSALREADYKNOWN2 = "/sak"
SlashCmdList.SKILLSALREADYKNOWN = function(text)
  text = (text or ""):lower()
  if text == "debug" then
    markServicesDirty()
    debugScrollBoxRows()
    return
  elseif text == "pet" then
    printPetSummary()
    paintMerchantGrimoires()
    return
  elseif text == "petdebug" then
    showMerchantDebugWindow()
    return
  end

  markServicesDirty()
  refresh()
  print("|cffffcc00SkillsAlreadyKnown:|r grey = known, red = unavailable, green outline = learnable. /sak debug, /sak petdebug")
end

local events = CreateFrame("Frame")
for _, event in ipairs({
  "ADDON_LOADED",
  "MERCHANT_SHOW",
  "MERCHANT_UPDATE",
  "PLAYER_LOGIN",
  "PLAYER_LEVEL_UP",
  "SPELLS_CHANGED",
  "TRAINER_SHOW",
  "TRAINER_UPDATE",
  "UNIT_PET",
}) do
  pcall(events.RegisterEvent, events, event)
end
events:SetScript("OnEvent", function(_, event, addonName)
  if event == "ADDON_LOADED" then
    if addonName ~= "SkillsAlreadyKnown" and addonName ~= "Blizzard_TrainerUI" and addonName ~= "Blizzard_Merchant" then return end
    ensureDB()
  end

  if event == "PLAYER_LOGIN" and not loadedMessage then
    loadedMessage = true
    ensureDB()
    print("|cffffcc00SkillsAlreadyKnown:|r loaded. /sak")
  end

  hookTrainer()
  hookMerchant()
  if event == "PLAYER_LEVEL_UP" or event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
    markServicesDirty()
    C_Timer.After(0, refresh)
    C_Timer.After(0.05, refresh)
  end

  if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
    queuePetSync()
    C_Timer.After(0, paintMerchantGrimoires)
    C_Timer.After(0.1, paintMerchantGrimoires)
  elseif event == "SPELLS_CHANGED" or (event == "UNIT_PET" and addonName == "player") then
    queuePetSync()
    C_Timer.After(0.6, paintMerchantGrimoires)
  end
end)
