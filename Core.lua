-- SkillsAlreadyKnown: shared state, constants, and helpers.

local SAK = _G.SkillsAlreadyKnown or {}
_G.SkillsAlreadyKnown = SAK

SAK.WHITE = "Interface\\Buttons\\WHITE8X8"
SAK.COLORS = {
  known = { 0.34, 0.34, 0.34 },
  unavailable = { 1, 0.15, 0.15 },
}
SAK.OUTLINE = { 0, 1, 0, 0.85 }
SAK.LEARNABLE_BG = { 0.10, 0.45, 0.12, 0.22 }
SAK.KNOWN_BG = { 0.05, 0.05, 0.05, 0.38 }
SAK.MERCHANT_INACTIVE_KNOWN_BG = { 0.02, 0.28, 0.04, 0.62 }
SAK.MERCHANT_LEARNABLE_TEXT = { 1, 0.82, 0.05 }
SAK.MERCHANT_LEARNABLE_OUTLINE = { 1, 0.82, 0.05, 0.95 }
SAK.MERCHANT_LEARNED_TOOLTIP = { 0.25, 1, 0.25 }
SAK.MERCHANT_LEARNABLE_ICON = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\learnable-plus.tga"
SAK.MERCHANT_LEARNED_LABEL = "[Already Learned!]"
SAK.MERCHANT_READ_BOOK_LABEL = "[Read the Book]"
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
  return SkillsAlreadyKnownDB
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

  local sanitized = SAK.AsciiDebugText(text)
  local indented = {}
  for line in (sanitized .. "\n"):gmatch("(.-)\n") do
    indented[#indented + 1] = "    " .. line
  end
  indented[#indented + 1] = "    SAK report: end"

  local lines = {
    "### Skills Already Known Debug Report",
    "",
    "- Window: " .. tostring(title or "Skills Already Known Debug"),
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
    selectButton:SetText("Select All")
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
  frame.title:SetText(titleText or "Skills Already Known Export")
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
    copyButton:SetText("Copy Export")
    copyButton:SetScript("OnClick", function()
      SAK.ShowExportWindow("Skills Already Known Export", SAK.DebugTextToReport(frame.titleText, frame.rawText), frame)
    end)

    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(110, 24)
    refreshButton:SetPoint("LEFT", copyButton, "RIGHT", 8, 0)
    refreshButton:SetText("Refresh")
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

  frame.title:SetText(titleText or "Skills Already Known Debug")
  frame.titleText = titleText or "Skills Already Known Debug"
  frame.refreshFunc = refreshFunc
  frame.refreshButton:SetShown(type(refreshFunc) == "function")
  frame.rawText = text or ""
  frame.updatePreview()
  frame.scrollFrame:Show()
  frame:Show()
  frame:Raise()
end
