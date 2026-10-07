-- SkillsAlreadyKnown: shared visual helpers.

local SAK = SkillsAlreadyKnown
local Visuals = {}
SAK.Visuals = Visuals

function Visuals.PaintParts(name, sub, state)
  local color = SAK.COLORS[state]
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
  if not frame then return end
  local outline = ensureOutline(frame)
  color = color or SAK.OUTLINE
  for _, tex in ipairs(outline) do
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
  return tex
end

function Visuals.PaintLearnableBg(frame, show)
  if not frame then return end
  ensureSimpleBg(frame, "sakLearnableBg", "BACKGROUND", 7, SAK.LEARNABLE_BG):SetShown(show and true or false)
end

function Visuals.PaintKnownBg(frame, show)
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
  frame.sakIconKnownOverlay = overlay
  return overlay
end

function Visuals.PaintIconKnownOverlay(frame, show)
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
  frame.sakLearnableBadge = badge
  return badge
end

function Visuals.PaintLearnableBadge(frame, show)
  if not frame then return end
  local badge = ensureLearnableBadge(frame)
  if show then
    badge:Show()
  else
    badge:Hide()
  end
end

function Visuals.PaintMerchantBg(frame, showInactiveKnown)
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
  if show and fontString and fontString.SetTextColor then
    fontString:SetTextColor(SAK.MERCHANT_LEARNABLE_TEXT[1], SAK.MERCHANT_LEARNABLE_TEXT[2], SAK.MERCHANT_LEARNABLE_TEXT[3])
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

  itemButton.sakKnownBookOverlay = overlay
  return overlay
end

function Visuals.PaintMerchantKnownBookOverlay(itemButton, show)
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

  itemButton.sakPetIconBg = bg
  itemButton.sakPetIcon = icon
  return icon
end

function Visuals.PaintMerchantPetIcon(itemButton, info)
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
  icon:SetTexture(SAK.MERCHANT_LEARNABLE_ICON)
  icon:SetSize(24, 24)
  icon:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 10, 8)
  icon:Hide()

  itemButton.sakLearnableBadge = icon
  return icon
end

function Visuals.PaintMerchantLearnableBadge(itemButton, show)
  if not itemButton then return end
  local icon = ensureMerchantLearnableBadge(itemButton)
  if show then
    icon:Show()
  elseif icon then
    icon:Hide()
  end
end

function Visuals.EnsureMerchantTextLayer(fontString)
  if not (fontString and fontString.SetDrawLayer) then return end
  pcall(fontString.SetDrawLayer, fontString, "OVERLAY", 7)
end

function Visuals.PaintMerchantKnownPrefix(fontString, show)
  if not (fontString and fontString.GetText and fontString.SetText) then return end
  local text = fontString:GetText()
  if type(text) ~= "string" then return end

  text = text:gsub("^|cffffffff%[Already Learned!%]|r%s*", "")
  text = text:gsub("^%[Already Learned!%]%s*", "")
  text = text:gsub("^|cff40ff40%[Read the Book%]|r%s*", "")
  text = text:gsub("^%[Read the Book%]%s*", "")
  text = text:gsub("^|cffffffff%[Learned!%]|r%s*", "")
  text = text:gsub("^%[Learned!%]%s*", "")
  if show then text = "|cffffffff" .. SAK.MERCHANT_LEARNED_LABEL .. "|r " .. text end
  fontString:SetText(text)
end

function Visuals.PaintMerchantReadBookPrefix(fontString, show)
  if not (fontString and fontString.GetText and fontString.SetText) then return end
  local text = fontString:GetText()
  if type(text) ~= "string" then return end

  text = text:gsub("^|cffffffff%[Already Learned!%]|r%s*", "")
  text = text:gsub("^%[Already Learned!%]%s*", "")
  text = text:gsub("^|cff40ff40%[Read the Book%]|r%s*", "")
  text = text:gsub("^%[Read the Book%]%s*", "")
  text = text:gsub("^|cffffffff%[Learned!%]|r%s*", "")
  text = text:gsub("^%[Learned!%]%s*", "")
  if show then text = "|cff40ff40" .. SAK.MERCHANT_READ_BOOK_LABEL .. "|r " .. text end
  fontString:SetText(text)
end

function Visuals.ClearRow(row)
  if not row then return end
  Visuals.PaintParts(row.name or row.Name or row.Text, row.subText or row.SubText, nil)
  Visuals.PaintOutline(row, false)
  Visuals.PaintLearnableBg(row, false)
  Visuals.PaintKnownBg(row, false)
  Visuals.PaintIconKnownOverlay(row, false)
  Visuals.PaintLearnableBadge(row, false)
end
