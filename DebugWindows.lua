-- Fenetres de diagnostic, mise en forme et export des rapports.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local DEBUG_COLORS = {
  key = "ffffd36b",
  text = "ffffffff",
  number = "ff7dd3fc",
  trueValue = "ff66ff66",
  falseValue = "ffff6666",
  nilValue = "ff9ca3af",
  heading = "ffffcc00",
}

local function colorText(color, text)
  return "|c" .. color .. tostring(text) .. "|r"
end

local function debugValueColor(value)
  if value == "true" then return DEBUG_COLORS.trueValue end
  if value == "false" then return DEBUG_COLORS.falseValue end
  if value == "nil" then return DEBUG_COLORS.nilValue end
  if tonumber(value) then return DEBUG_COLORS.number end
  return DEBUG_COLORS.text
end

function SAK.ColorizeDebugText(text)
  if type(text) ~= "string" or text == "" then return text or "" end
  local out = {}

  for line in (text .. "\n"):gmatch("(.-)\n") do
    if line == "" then
      out[#out + 1] = ""
    elseif not line:find("=") then
      out[#out + 1] = colorText(DEBUG_COLORS.heading, line)
    else
      local _, equalsCount = line:gsub("=", "")
      local prefix, fullKey, fullValue = line:match("^(.-:%s*)(.-)=([^=]+)$")
      if equalsCount == 1 and prefix and fullKey and fullValue then
        out[#out + 1] = colorText(DEBUG_COLORS.heading, prefix) .. colorText(DEBUG_COLORS.key, fullKey) .. "=" .. colorText(debugValueColor(fullValue), fullValue)
      else
        local colored = line:gsub("([%w_]+)=([^%s,]+)", function(key, value)
          return colorText(DEBUG_COLORS.key, key) .. "=" .. colorText(debugValueColor(value), value)
        end)
        out[#out + 1] = colored
      end
    end
  end

  return table.concat(out, "\n")
end

local function isContinuationByte(byte)
  return byte and byte >= 128 and byte <= 191
end

local function stripInvalidUtf8(text)
  text = tostring(text or "")
  local out = {}
  local i = 1
  local len = #text

  while i <= len do
    local b1 = text:byte(i)

    if b1 == 9 or b1 == 10 or (b1 >= 32 and b1 <= 126) then
      out[#out + 1] = text:sub(i, i)
      i = i + 1
    elseif b1 and b1 >= 194 and b1 <= 223 and isContinuationByte(text:byte(i + 1)) then
      out[#out + 1] = text:sub(i, i + 1)
      i = i + 2
    elseif b1 and b1 >= 224 and b1 <= 239 and isContinuationByte(text:byte(i + 1)) and isContinuationByte(text:byte(i + 2)) then
      local chunk = text:sub(i, i + 2)
      if chunk ~= "\239\191\189" then out[#out + 1] = chunk end
      i = i + 3
    elseif b1 and b1 >= 240 and b1 <= 244 and isContinuationByte(text:byte(i + 1)) and isContinuationByte(text:byte(i + 2)) and isContinuationByte(text:byte(i + 3)) then
      out[#out + 1] = text:sub(i, i + 3)
      i = i + 4
    else
      i = i + 1
    end
  end

  return table.concat(out)
end

function SAK.SanitizeDebugText(text)
  text = stripInvalidUtf8(text)
  text = text:gsub("```", "` ` `")
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local cleanLine = line:gsub("\239\191\189", "")
    cleanLine = cleanLine:gsub("[\194-\244][\128-\191]*$", "")
    lines[#lines + 1] = cleanLine:gsub("[%z\1-\8\11-\31\127]+$", "")
  end
  return table.concat(lines, "\n"):gsub("%s+$", "")
end

function SAK.AsciiDebugText(text)
  text = SAK.SanitizeDebugText(text)
  local replacements = {
    ["\195\160"] = "a", ["\195\162"] = "a", ["\195\164"] = "a",
    ["\195\167"] = "c",
    ["\195\168"] = "e", ["\195\169"] = "e", ["\195\170"] = "e", ["\195\171"] = "e",
    ["\195\174"] = "i", ["\195\175"] = "i",
    ["\195\180"] = "o", ["\195\182"] = "o",
    ["\195\185"] = "u", ["\195\187"] = "u", ["\195\188"] = "u",
    ["\195\128"] = "A", ["\195\130"] = "A", ["\195\132"] = "A",
    ["\195\135"] = "C",
    ["\195\136"] = "E", ["\195\137"] = "E", ["\195\138"] = "E", ["\195\139"] = "E",
    ["\195\142"] = "I", ["\195\143"] = "I",
    ["\195\148"] = "O", ["\195\150"] = "O",
    ["\195\153"] = "U", ["\195\155"] = "U", ["\195\156"] = "U",
    ["\226\128\153"] = "'",
    ["\226\128\156"] = "\"",
    ["\226\128\157"] = "\"",
  }
  for needle, replacement in pairs(replacements) do
    text = text:gsub(needle, replacement)
  end
  return text:gsub("[\128-\255]", "")
end

local function addonVersion()
  if C_AddOns and C_AddOns.GetAddOnMetadata then
    local version = C_AddOns.GetAddOnMetadata("SkillsAlreadyKnown", "Version")
    if version then return version end
  end
  if GetAddOnMetadata then
    return GetAddOnMetadata("SkillsAlreadyKnown", "Version")
  end
end

local function utf8Length(text)
  if strlenutf8 then return strlenutf8(text or "") end
  return #(text or "")
end

function SAK.DebugTextToReport(title, text)
  local className, classFilename, classID
  if UnitClass then
    className, classFilename, classID = UnitClass("player")
  end

  local buildVersion, buildNumber, buildDate, interfaceVersion = "unknown", "unknown", "unknown", "unknown"
  if GetBuildInfo then
    buildVersion, buildNumber, buildDate, interfaceVersion = GetBuildInfo()
  end

  if SAK.Diagnostics and not tostring(text or ""):find("SAM compatibility report", 1, true) then
    text = tostring(text or "") .. "\n\n" .. SAK.Diagnostics.BuildText()
  end
  local sanitized = SAK.AsciiDebugText(text)
  local indented = {}
  for line in (sanitized .. "\n"):gmatch("(.-)\n") do
    indented[#indented + 1] = "    " .. line
  end
  indented[#indented + 1] = "    SAM report: end"

  local lines = {
    "### Skills & More Debug Report",
    "",
    "- Window: " .. tostring(title or "Skills & More Debug"),
    "- Addon version: " .. tostring(addonVersion() or "unknown"),
    "- Client: " .. tostring(buildVersion) .. " (" .. tostring(buildNumber) .. "), interface " .. tostring(interfaceVersion),
    "- Locale: " .. tostring(GetLocale and GetLocale() or "unknown"),
    "- Character: level " .. tostring(UnitLevel and UnitLevel("player") or "unknown") .. " " .. tostring(classFilename or className or "unknown") .. " (classID=" .. tostring(classID) .. ")",
    "",
    "#### Raw log",
    "",
    table.concat(indented, "\n"),
  }

  return SAK.AsciiDebugText(table.concat(lines, "\n"))
end

function SAK.ShowExportWindow(titleText, report, ownerFrame)
  report = SAK.AsciiDebugText(report)
  if not SAK.exportFrame then
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", "SkillsAlreadyKnownExportFrame", UIParent, template)
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
        bgFile = SAK.WHITE,
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
      })
      frame:SetBackdropColor(0.03, 0.03, 0.03, 1)
      frame:SetBackdropBorderColor(0.65, 0.55, 0.36, 1)
    else
      local background = frame:CreateTexture(nil, "BACKGROUND")
      background:SetAllPoints()
      background:SetColorTexture(0.03, 0.03, 0.03, 1)
    end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)

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
      local content = self:GetText() or ""
      local _, newlineCount = string.gsub(content, "\n", "\n")
      self:SetHeight(math.max((newlineCount + 1) * 14 + 16, scrollFrame:GetHeight()))
    end)
    scrollFrame:SetScrollChild(editBox)

    local selectButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    selectButton:SetSize(110, 24)
    selectButton:SetPoint("BOTTOMLEFT", 24, 18)
    selectButton:SetText(L("Select All"))
    selectButton:SetScript("OnClick", function()
      editBox:SetFocus()
      editBox:HighlightText()
    end)

    frame.title = title
    frame.editBox = editBox
    frame:Hide()
    SAK.exportFrame = frame

    if UISpecialFrames then table.insert(UISpecialFrames, frame:GetName()) end
  end

  if ownerFrame and ownerFrame.Hide then ownerFrame:Hide() end

  local frame = SAK.exportFrame
  frame.title:SetText(titleText or "Skills & More Export")
  frame.editBox:SetText("")
  frame.editBox:SetText(report or "")
  frame.editBox:SetCursorPosition(0)
  frame:Show()
  frame:Raise()
  frame.editBox:SetFocus()
  frame.editBox:HighlightText(0, #(report or ""))
end

function SAK.ShowDebugTextWindow(key, titleText, text, refreshFunc)
  SAK.debugFrames = SAK.debugFrames or {}
  key = key or "default"
  local frame = SAK.debugFrames[key]

  if not frame then
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    frame = CreateFrame("Frame", "SkillsAlreadyKnownDebugFrame" .. key, UIParent, template)
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

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 24, -52)
    scrollFrame:SetPoint("BOTTOMRIGHT", -46, 52)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(682)
    content:SetHeight(416)

    local preview = content:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
    preview:SetPoint("TOPLEFT", 4, -4)
    preview:SetJustifyH("LEFT")
    preview:SetJustifyV("TOP")
    preview:SetWidth(672)
    preview:SetTextColor(1, 1, 1)
    scrollFrame:SetScrollChild(content)

    local function updatePreview()
      preview:SetText(SAK.ColorizeDebugText(frame.rawText or ""))
      content:SetHeight(math.max((preview:GetStringHeight() or 0) + 12, scrollFrame:GetHeight()))
    end

    local copyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    copyButton:SetSize(120, 24)
    copyButton:SetPoint("BOTTOMLEFT", 24, 18)
    copyButton:SetText(L("Copy Export"))
    copyButton:SetScript("OnClick", function()
      SAK.ShowExportWindow("Skills & More Export", SAK.DebugTextToReport(frame.titleText, frame.rawText), frame)
    end)

    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(110, 24)
    refreshButton:SetPoint("LEFT", copyButton, "RIGHT", 8, 0)
    refreshButton:SetText(L("Refresh"))
    refreshButton:SetScript("OnClick", function()
      if frame.refreshFunc then
        frame.rawText = frame.refreshFunc() or ""
        updatePreview()
      end
    end)

    frame.title = title
    frame.scrollFrame = scrollFrame
    frame.preview = preview
    frame.previewContent = content
    frame.updatePreview = updatePreview
    frame.copyButton = copyButton
    frame.refreshButton = refreshButton
    frame:Hide()
    SAK.debugFrames[key] = frame

    if UISpecialFrames then table.insert(UISpecialFrames, frame:GetName()) end
  end

  frame.title:SetText(titleText or "Skills & More Debug")
  frame.titleText = titleText or "Skills & More Debug"
  frame.refreshFunc = refreshFunc
  frame.refreshButton:SetShown(type(refreshFunc) == "function")
  frame.rawText = text or ""
  frame.updatePreview()
  frame.scrollFrame:Show()
  frame:Show()
  frame:Raise()
end
