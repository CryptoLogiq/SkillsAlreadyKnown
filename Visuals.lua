-- SkillsAlreadyKnown: shared visual helpers.

local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Visuals = {}
SAK.Visuals = Visuals

local styledTexts = setmetatable({}, { __mode = "k" })
local textLayers = setmetatable({}, { __mode = "k" })
local function enabled(key) return not SAK.DisplayEnabled or SAK.DisplayEnabled(key) end
local function colorOf(font)
  if not font.GetTextColor then return nil end
  local r, g, b, a = font:GetTextColor()
  if r then return { r, g, b, a or 1 } end
end
local function sameColor(a, b)
  if not a or not b then return false end
  for i = 1, 4 do if math.abs(a[i] - b[i]) > 0.001 then return false end end
  return true
end
local function paintColor(font, color, trainer)
  if not font or not font.SetTextColor then return end
  local current, entry = colorOf(font), styledTexts[font]
  if not entry then entry = {}; styledTexts[font] = entry end
  if not entry.original or (current and not sameColor(current, entry.applied)) then
    entry.original = current
  end
  local text = font.GetText and font:GetText()
  if text ~= entry.appliedText then entry.originalText = text end
  entry.trainer = trainer or entry.trainer
  if trainer and SAK.Compatibility then
    SAK.Compatibility.SetTrainerNameColor(font, color[1], color[2], color[3])
  end
  font:SetTextColor(color[1], color[2], color[3], color[4] or 1)
  entry.applied = colorOf(font) or { color[1], color[2], color[3], color[4] or 1 }
  entry.appliedText = font.GetText and font:GetText()
end
local function restoreText(font)
  local entry = font and styledTexts[font]
  if not entry then return end
  if entry.trainer and SAK.Compatibility and SAK.Compatibility.CanModifyTrainerText
    and not SAK.Compatibility.CanModifyTrainerText() then return end
  if entry.original and sameColor(colorOf(font), entry.applied) then
    font:SetTextColor(entry.original[1], entry.original[2], entry.original[3], entry.original[4])
  end
  if entry.trainer and entry.originalText and font.GetText and font.SetText
    and font:GetText() == entry.appliedText and entry.appliedText ~= entry.originalText then
    font:SetText(entry.originalText)
  end
  styledTexts[font] = nil
end

function Visuals.ResetTextStyles()
  if SAK.Compatibility and SAK.Compatibility.ClearTrainerTextColors then
    SAK.Compatibility.ClearTrainerTextColors()
  end
  for font in pairs(styledTexts) do restoreText(font) end
  for font, original in pairs(textLayers) do
    local layer, level = font:GetDrawLayer()
    if layer == "OVERLAY" and level == 7 then font:SetDrawLayer(original[1], original[2]) end
    textLayers[font] = nil
  end
end

function Visuals.PaintParts(name, sub, state, trainer)
  if not enabled("text") then restoreText(name); restoreText(sub); return end
  local color = SAK.COLORS[state]
  if color then
    paintColor(name, color, trainer)
    if sub and sub.SetTextColor then
      if state == "unavailable" then
        paintColor(sub, { HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b })
      else
        paintColor(sub, color)
      end
    end
  else
    paintColor(name, { NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b }, trainer)
    paintColor(sub, { HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b })
  end
end

function Visuals.PaintTrainerParts(name, sub, state)
  if SAK.Compatibility and SAK.Compatibility.CanModifyTrainerText
    and not SAK.Compatibility.CanModifyTrainerText() then return end
  if not enabled("text") then restoreText(name); restoreText(sub); return end
  if SAK.Compatibility and not SAK.Compatibility.ShouldStyleTrainerText() then return end
  Visuals.PaintParts(name, sub, state, true)
  if sub and styledTexts[sub] then styledTexts[sub].trainer = true end
end

local function protectTexture(texture, tint, solid)
  if SAK.Compatibility then SAK.Compatibility.ProtectTexture(texture, tint, solid) end
end

local function ensureOutline(frame)
  if frame.sakOutline then return frame.sakOutline end

  local top = frame:CreateTexture(nil, "OVERLAY")
  local bottom = frame:CreateTexture(nil, "OVERLAY")
  local left = frame:CreateTexture(nil, "OVERLAY")
  local right = frame:CreateTexture(nil, "OVERLAY")

  for _, tex in ipairs({ top, bottom, left, right }) do
    tex:SetTexture(SAK.WHITE)
    tex:SetColorTexture(SAK.OUTLINE[1], SAK.OUTLINE[2], SAK.OUTLINE[3], SAK.OUTLINE[4])
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

function Visuals.PaintOutline(frame, show, color)
  show = show and enabled("outlines")
  if not frame then return end
  local outline = ensureOutline(frame)
  color = color or SAK.OUTLINE
  for _, tex in ipairs(outline) do
    protectTexture(tex, nil, color)
    tex:SetColorTexture(color[1], color[2], color[3], color[4])
    tex:SetShown(show and true or false)
  end
end

local function ensureSimpleBg(frame, key, layer, sublevel, color)
  if frame[key] then return frame[key] end
  local tex = frame:CreateTexture(nil, layer, nil, sublevel)
  tex:SetTexture(SAK.WHITE)
  tex:SetColorTexture(color[1], color[2], color[3], color[4])
  tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
  tex:Hide()
  frame[key] = tex
  protectTexture(tex, nil, color)
  return tex
end

function Visuals.PaintLearnableBg(frame, show)
  show = show and enabled("backgrounds")
  if not frame then return end
  ensureSimpleBg(frame, "sakLearnableBg", "BACKGROUND", 7, SAK.LEARNABLE_BG):SetShown(show and true or false)
end

function Visuals.PaintSoonBg(frame, show)
  show = show and enabled("backgrounds")
  if not frame then return end
  ensureSimpleBg(frame, "sakSoonBg", "BACKGROUND", 7, SAK.SOON_BG):SetShown(show and true or false)
end

function Visuals.PaintKnownBg(frame, show)
  show = show and enabled("backgrounds")
  if not frame then return end
  ensureSimpleBg(frame, "sakKnownBg", "BACKGROUND", 6, SAK.KNOWN_BG):SetShown(show and true or false)
end

local function iconTexture(frame)
  if not frame then return nil end
  if frame.icon and frame.icon.GetTexture then return frame.icon end
  if frame.Icon and frame.Icon.GetTexture then return frame.Icon end
  if frame.IconTexture and frame.IconTexture.GetTexture then return frame.IconTexture end
  if frame.texture and type(frame.texture) ~= "number" and frame.texture.GetTexture then return frame.texture end
  if frame.GetName then
    local name = frame:GetName()
    return _G[name .. "Icon"] or _G[name .. "IconTexture"] or _G[name .. "IconTextureTexture"] or _G[name .. "Texture"]
  end
end

local function ensureIconKnownOverlay(frame)
  if not frame then return nil end
  if frame.sakIconKnownOverlay then return frame.sakIconKnownOverlay end

  local source = iconTexture(frame)
  local overlay = frame:CreateTexture(nil, "OVERLAY", nil, 4)
  if source then
    overlay:SetAllPoints(source)
  else
    overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
    overlay:SetSize(32, 32)
  end
  overlay:SetDesaturated(true)
  overlay:SetVertexColor(0.35, 0.35, 0.35, 0.86)
  overlay:Hide()
  protectTexture(overlay, { 0.35, 0.35, 0.35, 0.86 })
  frame.sakIconKnownOverlay = overlay
  return overlay
end

function Visuals.PaintIconKnownOverlay(frame, show)
  show = show and (enabled("icons") and enabled("iconsTrainer"))
  if not frame then return end
  local overlay = ensureIconKnownOverlay(frame)
  if show then
    local source = iconTexture(frame)
    local texture = source and source.GetTexture and source:GetTexture()
    if texture then overlay:SetTexture(texture) end
    overlay:Show()
  else
    overlay:Hide()
  end
end

local function ensureLearnableBadge(frame)
  if not frame then return nil end
  if frame.sakLearnableBadge then return frame.sakLearnableBadge end

  local source = iconTexture(frame)
  local badge = frame:CreateTexture(nil, "OVERLAY", nil, 7)
  badge:SetTexture(SAK.MERCHANT_LEARNABLE_ICON)
  badge:SetSize(18, 18)
  if source then
    badge:SetPoint("TOPRIGHT", source, "TOPRIGHT", 7, 7)
  else
    badge:SetPoint("TOPLEFT", frame, "TOPLEFT", 28, 4)
  end
  badge:Hide()
  protectTexture(badge)
  frame.sakLearnableBadge = badge
  return badge
end

function Visuals.PaintLearnableBadge(frame, show)
  show = show and (enabled("icons") and enabled("iconsTrainer"))
  if not frame then return end
  local badge = ensureLearnableBadge(frame)
  if show then
    badge:Show()
  else
    badge:Hide()
  end
end

-- Trainer badges are distinct from merchant/book plus markers.
function Visuals.PaintTrainerAdvice(frame, kind)
  if not frame then return end
  if not (enabled("icons") and enabled("iconsTrainer")) then kind = nil end
  local spec = kind and SAK.SPELLBOOK_BADGES[kind]
  local primary = frame.sakTrainerBadge
  local badge = frame.sakTrainerAdvice
  if not spec or not primary then if badge then badge:Hide() end; return end
  if not badge then
    badge = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    badge:SetPoint("LEFT", primary, "RIGHT", 2, 0)
    protectTexture(badge)
    frame.sakTrainerAdvice = badge
  end
  badge:SetTexture(spec.texture)
  badge:SetSize(spec.width, spec.height)
  badge:Show()
end

function Visuals.PaintTrainerBadge(frame, kind)
  if not (enabled("icons") and enabled("iconsTrainer")) then kind = nil end
  if not frame then return end
  local spec = kind and SAK.TRAINER_BADGES[kind]
  local badge = frame.sakTrainerBadge
  if not spec then
    if SAK.Glow then SAK.Glow.Hide(frame) end
    if badge then badge:Hide() end
    return
  end
  if not badge then
    badge = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    local source = iconTexture(frame)
    if source then
      badge:SetPoint("TOPRIGHT", source, "TOPRIGHT", 7, 12)
    else
      badge:SetPoint("TOPLEFT", frame, "TOPLEFT", 28, 9)
    end
    protectTexture(badge)
    frame.sakTrainerBadge = badge
  end
  badge:SetTexture(spec.texture)
  badge:SetSize(spec.width, spec.height)
  badge:Show()
  if SAK.Glow then SAK.Glow.SetBadge(frame, badge, kind, spec.width, spec.height) end
end

function Visuals.PaintMerchantBg(frame, showInactiveKnown)
  showInactiveKnown = showInactiveKnown and enabled("backgrounds")
  if not frame then return end
  local tex = ensureSimpleBg(frame, "sakMerchantBg", "ARTWORK", 1, SAK.MERCHANT_INACTIVE_KNOWN_BG)
  if showInactiveKnown then
    tex:SetColorTexture(SAK.MERCHANT_INACTIVE_KNOWN_BG[1], SAK.MERCHANT_INACTIVE_KNOWN_BG[2], SAK.MERCHANT_INACTIVE_KNOWN_BG[3], SAK.MERCHANT_INACTIVE_KNOWN_BG[4])
    tex:Show()
  else
    tex:Hide()
  end
end

function Visuals.PaintMerchantLearnableText(fontString, show)
  if not enabled("text") then restoreText(fontString); return end
  if show and fontString and fontString.SetTextColor then
    paintColor(fontString, SAK.MERCHANT_LEARNABLE_TEXT)
  end
end

function Visuals.MerchantItemButton(visible, merchantButton)
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

  protectTexture(overlay, { 0.36, 0.36, 0.36, 0.92 })
  itemButton.sakKnownBookOverlay = overlay
  return overlay
end

function Visuals.PaintMerchantKnownBookOverlay(itemButton, show, category)
  show = show and (enabled("icons") and enabled(category or "iconsMerchant"))
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
  bg:SetTexture(SAK.WHITE)
  bg:SetColorTexture(0, 0, 0, 0.82)
  bg:SetSize(23, 23)
  bg:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 2, -2)
  bg:Hide()

  local icon = itemButton:CreateTexture(nil, "OVERLAY", nil, 6)
  icon:SetSize(21, 21)
  icon:SetPoint("CENTER", bg, "CENTER")
  icon:Hide()

  protectTexture(bg, nil, { 0, 0, 0, 0.82 })
  protectTexture(icon)
  itemButton.sakPetIconBg = bg
  itemButton.sakPetIcon = icon
  return icon
end

local function paintActivePetBorder(button, info)
  local active = info and enabled("outlines") and SAK.PetGrimoires
    and SAK.PetGrimoires.ActivePetForInfo
    and SAK.PetGrimoires.ActivePetForInfo(info)
  local border = button.sakActivePetBorder
  if active and not border then
    border = button:CreateTexture(nil, "OVERLAY", nil, 6)
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -7, 7)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 7, -7)
    border:SetVertexColor(1, 0.82, 0.15, 1)
    protectTexture(border, { 1, 0.82, 0.15, 1 })
    button.sakActivePetBorder = border
  end
  if border then border:SetShown(not not active) end
end

function Visuals.PaintMerchantPetIcon(itemButton, info, category)
  if not (enabled("icons") and enabled(category or "iconsMerchant")) then info = nil end
  if not itemButton then return end
  paintActivePetBorder(itemButton, info)
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
  icon:SetTexture(SAK.MERCHANT_LEARNABLE_ICON)
  icon:SetSize(24, 24)
  icon:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 10, 8)
  icon:Hide()

  protectTexture(icon)
  itemButton.sakLearnableBadge = icon
  return icon
end

function Visuals.PaintMerchantLearnableBadge(itemButton, show, category)
  show = show and (enabled("icons") and enabled(category or "iconsMerchant"))
  if not itemButton then return end
  local icon = ensureMerchantLearnableBadge(itemButton)
  if show then
    icon:Show()
  elseif icon then
    icon:Hide()
  end
end

local function ensureItemDuplicateBadge(itemButton)
  if not itemButton then return nil end
  if itemButton.sakDuplicateBadge then return itemButton.sakDuplicateBadge end

  local badge = itemButton:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
  badge:SetPoint("BOTTOMLEFT", itemButton, "BOTTOMLEFT", 1, 1)
  badge:SetTextColor(1, 0.82, 0.05)
  badge:SetShadowColor(0, 0, 0, 1)
  badge:SetShadowOffset(1, -1)
  badge:Hide()
  itemButton.sakDuplicateBadge = badge
  return badge
end

function Visuals.PaintItemDuplicateBadge(itemButton, text)
  if not enabled("text") then text = nil end
  if not itemButton then return end
  local badge = ensureItemDuplicateBadge(itemButton)
  if text and text ~= "" then
    badge:SetText(text)
    badge:Show()
  else
    badge:Hide()
  end
end

function Visuals.PaintItemKnownOverlay(itemButton, show)
  Visuals.PaintMerchantKnownBookOverlay(itemButton, show, "iconsInventory")
end

function Visuals.PaintItemPetIcon(itemButton, info)
  Visuals.PaintMerchantPetIcon(itemButton, info, "iconsInventory")
end

function Visuals.PaintItemLearnableBadge(itemButton, show)
  Visuals.PaintMerchantLearnableBadge(itemButton, show, "iconsInventory")
end

function Visuals.ClearItemButton(itemButton)
  if not itemButton then return end
  if SAK.RecipeKnowledge then SAK.RecipeKnowledge.Clear(itemButton) end
  Visuals.PaintOutline(itemButton, false)
  Visuals.PaintItemKnownOverlay(itemButton, false)
  Visuals.PaintItemPetIcon(itemButton, nil)
  Visuals.PaintItemLearnableBadge(itemButton, false)
  Visuals.PaintItemDuplicateBadge(itemButton, nil)
end

function Visuals.EnsureMerchantTextLayer(fontString)
  if not enabled("text") then return end
  if not (fontString and fontString.SetDrawLayer) then return end
  if not textLayers[fontString] and fontString.GetDrawLayer then
    textLayers[fontString] = { fontString:GetDrawLayer() }
  end
  pcall(fontString.SetDrawLayer, fontString, "OVERLAY", 7)
end

function Visuals.PaintMerchantKnownPrefix(fontString, show)
  show = show and enabled("text")
  if not (fontString and fontString.GetText and fontString.SetText) then return end
  local text = fontString:GetText()
  if type(text) ~= "string" then return end

  text = text:gsub("^|cffffffff%[Already Learned!%]|r%s*", "")
  text = text:gsub("^%[Already Learned!%]%s*", "")
  text = text:gsub("^|cff40ff40%[Read the Book%]|r%s*", "")
  text = text:gsub("^%[Read the Book%]%s*", "")
  text = text:gsub("^|cff40ff40%[Already in your Bag%]|r%s*", "")
  text = text:gsub("^%[Already in your Bag%]%s*", "")
  text = text:gsub("^|cffffffff%[Learned!%]|r%s*", "")
  text = text:gsub("^%[Learned!%]%s*", "")
  if show then text = "|cffffffff" .. SAK.MERCHANT_LEARNED_LABEL .. "|r " .. text end
  if fontString:GetText() ~= text then fontString:SetText(text) end
end

function Visuals.PaintMerchantReadBookPrefix(fontString, show)
  show = show and enabled("text")
  if not (fontString and fontString.GetText and fontString.SetText) then return end
  local text = fontString:GetText()
  if type(text) ~= "string" then return end

  text = text:gsub("^|cffffffff%[Already Learned!%]|r%s*", "")
  text = text:gsub("^%[Already Learned!%]%s*", "")
  text = text:gsub("^|cff40ff40%[Read the Book%]|r%s*", "")
  text = text:gsub("^%[Read the Book%]%s*", "")
  text = text:gsub("^|cff40ff40%[Already in your Bag%]|r%s*", "")
  text = text:gsub("^%[Already in your Bag%]%s*", "")
  text = text:gsub("^|cffffffff%[Learned!%]|r%s*", "")
  text = text:gsub("^%[Learned!%]%s*", "")
  if show then text = "|cff40ff40" .. SAK.MERCHANT_READ_BOOK_LABEL .. "|r " .. text end
  if fontString:GetText() ~= text then fontString:SetText(text) end
end

function Visuals.ClearRow(row)
  if not row then return end
  if SAK.ContentTags then SAK.ContentTags.HideTrainer(row) end
  Visuals.PaintTrainerParts(row.name or row.Name or row.Text, row.subText or row.SubText, nil)
  Visuals.PaintOutline(row, false)
  Visuals.PaintLearnableBg(row, false)
  Visuals.PaintSoonBg(row, false)
  Visuals.PaintKnownBg(row, false)
  Visuals.PaintIconKnownOverlay(row, false)
  Visuals.PaintLearnableBadge(row, false)
  Visuals.PaintTrainerBadge(row, nil)
  Visuals.PaintTrainerAdvice(row, nil)
end
