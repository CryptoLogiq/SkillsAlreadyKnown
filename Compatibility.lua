-- SkillsAlreadyKnown: targeted optional-addon rendering compatibility.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Compatibility = {}
SAK.Compatibility = Compatibility
local texts = setmetatable({}, { __mode = "k" })
local textures = setmetatable({}, { __mode = "k" })

local function addonLoaded(name)
  local fn = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
  if type(fn) ~= "function" then return false end
  local ok, loaded = pcall(fn, name)
  return ok and loaded == true
end

local function darkModeLoaded()
  return addonLoaded("DarkMode")
end

function Compatibility.CanModifyTrainerText()
  return not addonLoaded("TrainerSpells")
end

function Compatibility.ShouldStyleTrainerText()
  return Compatibility.CanModifyTrainerText() and (not SAK.DisplayEnabled or SAK.DisplayEnabled("text"))
end

function Compatibility.ClearTrainerTextColors()
  for _, entry in pairs(texts) do entry.color = nil end
end

local function eligible(widget, marker)
  if not widget or (widget.IsForbidden and widget:IsForbidden()) then return false end
  return widget[marker] == true or darkModeLoaded()
end

local function report(err)
  if SAK.Diagnostics then SAK.Diagnostics.Record("DarkMode compatibility error", err) end
end

-- DarkMode 0.8.46 has no public text exclusion API. Its per-widget hook guards
-- are used only while applying our own colors and restored even on failure.
-- Never alter DarkMode's settings, private addon table, or global functions.
local function applyText(text, entry)
  if not Compatibility.ShouldStyleTrainerText() then entry.color = nil; return end
  if entry.applying or not entry.color or not text.dm_setup_text or text.dm_settextcolor then return end
  entry.applying = true
  local previous = text.dm_settextcolor
  text.dm_settextcolor = true
  local ok, err = pcall(function()
    if entry.stripInline and text.GetText and text.SetText then
      local value = text:GetText()
      if type(value) == "string" then text:SetText(SAK.CleanText(value)) end
    end
    text:SetTextColor(entry.color[1], entry.color[2], entry.color[3], entry.color[4])
  end)
  text.dm_settextcolor = previous
  entry.applying = false
  if not ok then report(err) end
end

local function textChanged(text, entry)
  if entry.applying then return end
  if text.dm_settextcolor then
    if not entry.queued and C_Timer and C_Timer.After then
      entry.queued = true
      C_Timer.After(0, function() entry.queued = false; applyText(text, entry) end)
    end
    return
  end
  applyText(text, entry)
end

function Compatibility.SetTrainerNameColor(text, r, g, b)
  if not Compatibility.ShouldStyleTrainerText() then return end
  if not eligible(text, "dm_setup_text") or type(hooksecurefunc) ~= "function" then return end
  local entry = texts[text]
  if not entry then
    entry = { stripInline = true }
    texts[text] = entry
    hooksecurefunc(text, "SetTextColor", function() textChanged(text, entry) end)
    -- Detect DarkMode installing its hook after ours, or a later injected prefix.
    if text.SetText then
      hooksecurefunc(text, "SetText", function()
        textChanged(text, entry)
      end)
    end
  end
  entry.color = { r, g, b, 1 }
  applyText(text, entry)
end

local function applyTexture(texture, entry)
  if entry.applying or texture.dm_setvertexcolor then return end
  if not texture.dm_setup_texture and not darkModeLoaded() then return end
  entry.applying = true
  local previous = texture.dm_setvertexcolor
  texture.dm_setvertexcolor = true
  local ok, err = pcall(function()
    if entry.solid then
      texture:SetColorTexture(entry.solid[1], entry.solid[2], entry.solid[3], entry.solid[4])
    end
    texture:SetVertexColor(entry.tint[1], entry.tint[2], entry.tint[3], entry.tint[4])
  end)
  texture.dm_setvertexcolor = previous
  entry.applying = false
  if not ok then report(err) end
end

local function textureChanged(texture, entry)
  if entry.applying then return end
  if texture.dm_setvertexcolor then
    if not entry.queued and C_Timer and C_Timer.After then
      entry.queued = true
      C_Timer.After(0, function() entry.queued = false; applyTexture(texture, entry) end)
    end
    return
  end
  applyTexture(texture, entry)
end

function Compatibility.ProtectTexture(texture, tint, solid)
  if not eligible(texture, "dm_setup_texture") or type(hooksecurefunc) ~= "function" then return end
  if not texture.SetVertexColor then return end
  local entry = textures[texture]
  if not entry then
    entry = {}
    textures[texture] = entry
    hooksecurefunc(texture, "SetVertexColor", function() textureChanged(texture, entry) end)
    if texture.SetColorTexture then
      hooksecurefunc(texture, "SetColorTexture", function() textureChanged(texture, entry) end)
    end
  end
  entry.tint = tint or { 1, 1, 1, 1 }
  entry.solid = solid
  applyTexture(texture, entry)
end

function Compatibility.GetDiagnostics()
  local textCount, textureCount = 0, 0
  for text in pairs(texts) do if text.dm_setup_text then textCount = textCount + 1 end end
  for _ in pairs(textures) do textureCount = textureCount + 1 end
  return { darkModeLoaded = darkModeLoaded(), protectedTexts = textCount, protectedTextures = textureCount,
    trainerTextMode = not Compatibility.CanModifyTrainerText() and "icons-only (TrainerSpells)"
      or (Compatibility.ShouldStyleTrainerText() and "standard" or "disabled (display settings)") }
end
