-- SkillsAlreadyKnown: class trainer row coloring.

local SAK = SkillsAlreadyKnown
local Visuals = SAK.Visuals
local ClassTrainer = {}
SAK.ClassTrainer = ClassTrainer

local serviceTypes = {
  available = true,
  unavailable = true,
  used = true,
  header = true,
}

local hooked
local scrollBoxHooked
local cachedServices
local servicesDirty = true
local refreshQueued

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
        display = SAK.CleanText(serviceDisplayName(name, subText)),
      }
    end
  end

  return out
end

function ClassTrainer.MarkDirty()
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

local function playerSpellBookBanks()
  local banks = {}
  if BOOKTYPE_SPELL then banks[#banks + 1] = BOOKTYPE_SPELL end
  banks[#banks + 1] = "spell"
  if Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player then
    banks[#banks + 1] = Enum.SpellBookSpellBank.Player
  end
  return banks
end

local function readPlayerSpellBookEntry(index, bank)
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

local function scanPlayerSpellBook()
  local learned = { byID = {}, byName = {} }
  local count = 0

  for _, bank in ipairs(playerSpellBookBanks()) do
    local current = { byID = {}, byName = {} }
    local currentCount = 0
    local misses = 0

    for index = 1, 400 do
      local name, rank, spellID = readPlayerSpellBookEntry(index, bank)
      if name then
        misses = 0
        currentCount = currentCount + 1
        local rankNum = SAK.RankNumber(rank) or 1
        current.byName[name] = math.max(current.byName[name] or 0, rankNum)
        current[name] = math.max(current[name] or 0, rankNum)
        if spellID then
          current.byID[tostring(spellID)] = math.max(current.byID[tostring(spellID)] or 0, rankNum)
        end
      else
        misses = misses + 1
        if misses >= 30 then break end
      end
    end

    if currentCount > count then
      learned = current
      count = currentCount
    end
  end

  return learned, count
end

local function playerKnowsTrainerService(service, learned)
  if not service or type(learned) ~= "table" then return false end
  if service.spellID and learned.byID and learned.byID[tostring(service.spellID)] then return true end
  if service.name and learned.byName and learned.byName[service.name] then
    local serviceRank = SAK.RankNumber(service.subText) or 1
    return (learned.byName[service.name] or 0) >= serviceRank
  end
  return false
end

local function appendPairs(lines, label, tbl, limit)
  if type(tbl) ~= "table" then return end
  local shown = 0
  for key, value in pairs(tbl) do
    shown = shown + 1
    if shown > limit then
      lines[#lines + 1] = string.format("%s: ... +%s more", label, SAK.TableCount(tbl) - limit)
      break
    end
    lines[#lines + 1] = string.format("%s: %s=%s", label, tostring(key), tostring(value))
  end
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
  local rowText = SAK.CleanText(SAK.TextOf(row.name or row.Name or row.Text))
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
    Visuals.ClearRow(row)
    return
  end

  local service = resolveRowService(row, services, state)
  local stateName = serviceState(service)
  local learnable = serviceLearnable(service)
  Visuals.PaintParts(name, sub, stateName)
  Visuals.PaintOutline(row, learnable)
  Visuals.PaintLearnableBg(row, learnable)
  Visuals.PaintKnownBg(row, stateName == "known")
  Visuals.PaintIconKnownOverlay(row, stateName == "known")
  Visuals.PaintLearnableBadge(row, learnable)
end

local function paintScrollBoxRows()
  local frame = ClassTrainerFrame
  local scrollBox = frame and frame.ScrollBox
  if not (scrollBox and scrollBox.ForEachFrame and scrollBox:IsVisible()) then return end
  local services = getVisibleServices()
  local state = { used = {}, lastPosition = 0 }
  pcall(scrollBox.ForEachFrame, scrollBox, function(row) paintScrollBoxRow(row, services, state) end)
end

local function buildDebugText()
  local lines = {}
  local learned, learnedTotal = scanPlayerSpellBook()
  local className, classFilename, classID
  if UnitClass then
    className, classFilename, classID = UnitClass("player")
  end

  lines[#lines + 1] = string.format(
    "SAK player: class=%s className=%s classID=%s level=%s legacyBook=%s modernBook=%s",
    tostring(classFilename),
    tostring(className),
    tostring(classID),
    tostring(UnitLevel and UnitLevel("player")),
    tostring(GetSpellBookItemName and true or false),
    tostring(C_SpellBook and true or false)
  )
  lines[#lines + 1] = string.format(
    "SAK player spellbook: total=%s byID=%s byName=%s legacy=%s",
    tostring(learnedTotal),
    tostring(SAK.TableCount(learned.byID)),
    tostring(SAK.TableCount(learned.byName)),
    tostring(SAK.LegacySpellCount(learned))
  )
  appendPairs(lines, "SAK player saved byID", learned.byID, 30)
  appendPairs(lines, "SAK player saved byName", learned.byName, 30)
  lines[#lines + 1] = ""

  local services = getVisibleServices()
  lines[#lines + 1] = string.format("SAK trainer services: visible=%s", tostring(#services))
  for _, service in ipairs(services) do
    lines[#lines + 1] = string.format(
      "SAK trainer service: idx=%s spell=%s savedID=%s knownByScan=%s type=%s level=%s name='%s' display='%s'",
      tostring(service.index),
      tostring(service.spellID),
      tostring(service.spellID and learned.byID and learned.byID[tostring(service.spellID)]),
      tostring(playerKnowsTrainerService(service, learned)),
      tostring(service.serviceType),
      tostring(service.levelReq),
      tostring(service.name),
      tostring(service.display)
    )
  end
  lines[#lines + 1] = ""

  local frame = ClassTrainerFrame
  local scrollBox = frame and frame.ScrollBox
  if not (scrollBox and scrollBox.ForEachFrame and scrollBox:IsVisible()) then
    lines[#lines + 1] = "SkillsAlreadyKnown: no visible trainer ScrollBox."
    return table.concat(lines, "\n")
  end

  local state = { used = {}, lastPosition = 0 }
  pcall(scrollBox.ForEachFrame, scrollBox, function(row)
    local service, rowText, rowSpellID = resolveRowService(row, services, state)
    lines[#lines + 1] = string.format(
      "SAK trainer row: row='%s' rowSpell=%s -> idx=%s spell=%s savedID=%s knownByScan=%s type=%s level=%s display='%s'",
      tostring(rowText),
      tostring(rowSpellID),
      tostring(service and service.index),
      tostring(service and service.spellID),
      tostring(service and service.spellID and learned.byID and learned.byID[tostring(service.spellID)]),
      tostring(playerKnowsTrainerService(service, learned)),
      tostring(service and service.serviceType),
      tostring(service and service.levelReq),
      tostring(service and service.display)
    )
  end)

  if #lines == 0 then
    lines[#lines + 1] = "SkillsAlreadyKnown: trainer ScrollBox is visible, but no rows were found."
  end

  return table.concat(lines, "\n")
end

function ClassTrainer.ShowDebugWindow()
  ClassTrainer.MarkDirty()
  SAK.ShowDebugTextWindow("Trainer", "Skills Already Known Trainer Debug", buildDebugText(), buildDebugText)
end

function ClassTrainer.Debug()
  ClassTrainer.ShowDebugWindow()
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
      local name, _, serviceType, levelReq = getServiceInfo(index)
      if name and serviceType ~= "header" then
        local state
        if serviceType == "used" then state = "known"
        elseif (tonumber(levelReq) or 0) > (UnitLevel("player") or 0) then state = "unavailable" end
        Visuals.PaintParts(text, subTextFrame, state)
        Visuals.PaintOutline(button, serviceType == "available")
        Visuals.PaintLearnableBg(button, serviceType == "available")
        Visuals.PaintKnownBg(button, state == "known")
        Visuals.PaintIconKnownOverlay(button, state == "known")
        Visuals.PaintLearnableBadge(button, serviceType == "available")
      end
    elseif button then
      Visuals.ClearRow(button)
    end
  end
end

function ClassTrainer.Refresh()
  paintClassicRows()
  paintScrollBoxRows()
end

local function queueRefresh()
  if refreshQueued then return end
  refreshQueued = true

  if C_Timer and C_Timer.After then
    C_Timer.After(0, function()
      refreshQueued = nil
      ClassTrainer.Refresh()
    end)
  else
    refreshQueued = nil
    ClassTrainer.Refresh()
  end
end

local function hookScrollBoxRows(scrollBox)
  if not scrollBox or scrollBox.sakRowsHooked then return end
  scrollBox.sakRowsHooked = true

  if ScrollUtil and ScrollUtil.AddInitializedFrameCallback then
    local ok = pcall(ScrollUtil.AddInitializedFrameCallback, scrollBox, function(_, row)
      Visuals.ClearRow(row)
      queueRefresh()
    end, nil, false)
    scrollBox.sakHasRowCallbacks = ok or nil
  end

  if scrollBox.RegisterCallback and BaseScrollBoxEvents and BaseScrollBoxEvents.OnDataRangeChanged then
    local ok = pcall(scrollBox.RegisterCallback, scrollBox, BaseScrollBoxEvents.OnDataRangeChanged, function()
      queueRefresh()
    end)
    scrollBox.sakHasRowCallbacks = scrollBox.sakHasRowCallbacks or ok or nil
  end
end

function ClassTrainer.Hook()
  if not hooked and type(ClassTrainerFrame_Update) == "function" then
    hooksecurefunc("ClassTrainerFrame_Update", ClassTrainer.Refresh)
    hooked = true
  end

  if ClassTrainerFrame and ClassTrainerFrame.HookScript and hooked ~= "show" then
    ClassTrainerFrame:HookScript("OnShow", function()
      C_Timer.After(0, ClassTrainer.Refresh)
      C_Timer.After(0.05, ClassTrainer.Refresh)
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
