-- SkillsAlreadyKnown: proc-style halos on addon-owned trainer badge hosts.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Glow = {}
SAK.Glow = Glow

local function engine()
  if LibStub then
    local ok, lib = pcall(function() return LibStub("LibButtonGlow-1.0", true) end)
    if ok and lib and type(lib.ShowOverlayGlow) == "function" and type(lib.HideOverlayGlow) == "function" then
      return lib.ShowOverlayGlow, lib.HideOverlayGlow, "LibButtonGlow"
    end
  end
  if type(ActionButton_ShowOverlayGlow) == "function" and type(ActionButton_HideOverlayGlow) == "function" then
    return ActionButton_ShowOverlayGlow, ActionButton_HideOverlayGlow, "Blizzard"
  end
end

local function report(err)
  if SAK.Diagnostics then SAK.Diagnostics.Record("Trainer badge glow error", err) end
end

local function fallback(entry)
  if entry.pulse then return end
  local halo = entry.host:CreateTexture(nil, "OVERLAY", nil, 7)
  halo:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  halo:SetBlendMode("ADD")
  halo:SetPoint("TOPLEFT", entry.host, "TOPLEFT", -5, 5)
  halo:SetPoint("BOTTOMRIGHT", entry.host, "BOTTOMRIGHT", 5, -5)
  halo:SetVertexColor(1, 0.82, 0.15, 1)
  if SAK.Compatibility then SAK.Compatibility.ProtectTexture(halo, { 1, 0.82, 0.15, 1 }) end
  local pulse = halo:CreateAnimationGroup()
  pulse:SetLooping("REPEAT")
  for order, values in ipairs({{0.35, 0.9}, {0.9, 0.35}}) do
    local alpha = pulse:CreateAnimation("Alpha")
    alpha:SetOrder(order)
    alpha:SetDuration(0.65)
    alpha:SetFromAlpha(values[1])
    alpha:SetToAlpha(values[2])
  end
  entry.pulse, entry.halo, entry.mode = pulse, halo, "Pulsed border"
end

function Glow.Hide(row)
  local entry = row and row.sakTrainerGlow
  if not entry then return end
  if entry.active and entry.hide then
    local ok, err = pcall(entry.hide, entry.host)
    if not ok then report(err) end
  end
  if entry.pulse then entry.pulse:Stop() end
  entry.host:Hide()
  entry.active = false
end

function Glow.SetBadge(row, badge, kind, width, height)
  if SAK.DisplayEnabled and not SAK.DisplayEnabled("icons") then Glow.Hide(row); return end
  if not (row and badge) or kind ~= "new" then Glow.Hide(row); return end
  local entry = row.sakTrainerGlow
  if not entry then
    local host = CreateFrame("Frame", nil, row)
    host:EnableMouse(false)
    host:SetFrameLevel(row:GetFrameLevel() + 4)
    host:SetPoint("CENTER", badge, "CENTER")
    local show, hide, mode = engine()
    entry = { host = host, show = show, hide = hide, mode = mode }
    row.sakTrainerGlow = entry
    -- Stop rather than leave a pulse running on a recycled/hidden row.
    host:HookScript("OnHide", function()
      if entry.pulse then entry.pulse:Stop() end
      entry.active = false
    end)
  end
  if entry.kind ~= kind and entry.active then Glow.Hide(row) end
  entry.kind = kind
  entry.host:SetSize(width, height)
  entry.host:Show()
  if entry.active then return end
  if entry.show then
    local ok, err = pcall(entry.show, entry.host)
    if not ok then
      report(err)
      if entry.hide then pcall(entry.hide, entry.host) end
      entry.show, entry.hide = nil, nil
    end
  end
  if not entry.show then
    fallback(entry)
    entry.pulse:Play()
  end
  entry.active = true
end
