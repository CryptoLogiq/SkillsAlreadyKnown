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

local WHITE = "Interface\\Buttons\\WHITE8X8"
local COLORS = {
  known = { 0.34, 0.34, 0.34 },
  unavailable = { 1, 0.15, 0.15 },
}
local OUTLINE = { 0, 1, 0, 0.85 }
local LEARNABLE_BG = { 0.10, 0.45, 0.12, 0.22 }
local KNOWN_BG = { 0.05, 0.05, 0.05, 0.38 }

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

local function paintOutline(frame, show)
  if not frame then return end
  local outline = ensureOutline(frame)
  for _, tex in ipairs(outline) do tex:SetShown(show and true or false) end
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

local function clearRowVisuals(row)
  if not row then return end
  paintParts(row.name or row.Name or row.Text, row.subText or row.SubText, nil)
  paintOutline(row, false)
  paintLearnableBg(row, false)
  paintKnownBg(row, false)
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

local function refresh()
  paintClassicRows()
  paintScrollBoxRows()
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
  if (text or ""):lower() == "debug" then
    markServicesDirty()
    debugScrollBoxRows()
    return
  end

  markServicesDirty()
  refresh()
  print("|cffffcc00SkillsAlreadyKnown:|r grey = known, red = unavailable, green outline = learnable. /sak debug")
end

local events = CreateFrame("Frame")
for _, event in ipairs({
  "ADDON_LOADED",
  "PLAYER_LOGIN",
  "PLAYER_LEVEL_UP",
  "TRAINER_SHOW",
  "TRAINER_UPDATE",
}) do
  pcall(events.RegisterEvent, events, event)
end
events:SetScript("OnEvent", function(_, event, addonName)
  if event == "ADDON_LOADED" and addonName ~= "Blizzard_TrainerUI" then return end
  if event == "PLAYER_LOGIN" and not loadedMessage then
    loadedMessage = true
    print("|cffffcc00SkillsAlreadyKnown:|r loaded. /sak")
  end

  hookTrainer()
  if event == "PLAYER_LEVEL_UP" or event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
    markServicesDirty()
    C_Timer.After(0, refresh)
    C_Timer.After(0.05, refresh)
  end
end)
