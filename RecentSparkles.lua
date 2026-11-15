-- Decorative spellbook hints; action bars and protected spell buttons remain read-only.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Sparkles = {}
SAK.RecentSparkles = Sparkles
local hosts = setmetatable({}, { __mode = "k" })
local learningHosts = setmetatable({}, { __mode = "k" })
local actions, actionsKnown, dirty = {}, false, true
local events

function Sparkles.Invalidate()
  dirty = true
end

local function scanActions()
  actions, actionsKnown, dirty = {}, false, false
  local forms = SAK.UnusedSpells
  if forms and forms.StanceCount and forms.StanceSpell then
    for index = 1, forms.StanceCount() do
      local id = forms.StanceSpell(index)
      if id then actions[id] = true end
    end
  end
  local read = C_ActionBar and C_ActionBar.GetActionInfo or GetActionInfo
  if not read then return end
  actionsKnown = true
  -- Include inactive pages and stance pages, not just the currently visible bar.
  local slots = math.max(180, (NUM_ACTIONBAR_BUTTONS or 12) * (NUM_ACTIONBAR_PAGES or 10))
  for slot = 1, math.min(slots, 240) do
    local ok, kind, id = pcall(read, slot)
    if not ok then actionsKnown = false; return end
    if kind == "spell" and type(id) == "number" then actions[id] = true end
    if kind == "macro" then
      local macro = C_Macro and C_Macro.GetMacroSpell or GetMacroSpell
      local success, first, _, third
      if macro then success, first, _, third = pcall(macro, id) end
      local spellID = type(first) == "number" and first or third
      if success and type(spellID) == "number" then actions[spellID] = true end
    end
  end
end

function Sparkles.IsAssigned(id)
  if dirty then scanActions() end
  if actions[id] then return true end
  local find = C_ActionBar and C_ActionBar.FindSpellActionButtons or FindSpellActionButtons
  if find then
    local ok, buttons = pcall(find, id)
    if ok then
      if type(buttons) == "table" and next(buttons) then return true end
      if buttons == nil or type(buttons) == "table" then return false end
    end
  end
  if actionsKnown then return false end
  -- Unknown API data does not establish that a spell is missing from the bars.
end

local function eligible(state)
  if not state or state.pet or not SAK.DisplayEnabled("icons") or not SAK.DisplayEnabled("iconsSpellbook")
    or not SAK.DisplayEnabled("recent") or not SAK.RecentLearning
    or not SAK.RecentLearning.Contains("spells", state.id) then return false end
  local assigned = Sparkles.IsAssigned(state.id)
  if assigned == false then return SAK.DisplayEnabled("recentSparkles") end
  return assigned == true and SAK.DisplayEnabled("unusedSparkles") and SAK.UnusedSpells and SAK.UnusedSpells.IsUnused(state.id)
end

local function hostEnabled(host)
  if host.zone then
    return SAK.DisplayEnabled("icons") and SAK.DisplayEnabled(host.style and host.style.option or "learningSparkles")
      and SAK.DisplayEnabled(host.zone)
  end
  return eligible(host.state)
end

local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function stop(host)
  if host.native and AutoCastShine_AutoCastStop then pcall(AutoCastShine_AutoCastStop, host) end
  host.running = false
end

local function createHost(parent)
  local host
  if AutoCastShine_AutoCastStart and AutoCastShine_AutoCastStop then
    local ok, frame = pcall(CreateFrame, "Frame", nil, parent, "AutoCastShineTemplate")
    if ok then host = frame; host.native = true end
  end
  host = host or CreateFrame("Frame", nil, parent)
  host:EnableMouse(false)
  host:HookScript("OnHide", stop)
  if not host.native then
    host.stars = {}
    for i = 1, 4 do
      local star = host:CreateTexture(nil, "OVERLAY", nil, 7)
      star:SetTexture("Interface\\Cooldown\\star4")
      star:SetBlendMode("ADD")
      star:SetVertexColor(1, 0.88, 0.4, 1)
      star:SetSize(11, 11)
      if SAK.Compatibility then SAK.Compatibility.ProtectTexture(star, { 1, 0.88, 0.4, 1 }) end
      host.stars[i] = star
    end
  end
  host.time, host.check = 0, 0
  host:HookScript("OnUpdate", function(self, delta)
    self.time, self.check = self.time + delta, self.check + delta
    if self.check >= 0.15 then
      self.check = 0
      if not visible(self.owner) or not visible(self.icon) or not hostEnabled(self) then self:Hide(); return end
    end
    if self.stars then
      local width, height = self:GetWidth(), self:GetHeight()
      for i, star in ipairs(self.stars) do
        local phase = (self.time / 1.8 + (i - 1) / 4) % 1
        local x = ((i * 0.29) % 1 - 0.5) * width * 0.85
        star:ClearAllPoints()
        star:SetPoint("CENTER", self, "CENTER", x, (phase - 0.5) * height)
        star:SetAlpha(math.sin(phase * math.pi) * 0.85)
      end
    end
  end)
  return host
end

local gold = { 1, 0.88, 0.4 }
local function start(host, color)
  color = color or gold
  if host.color ~= color then
    if host.running then stop(host) end
    host.color = color
    for _, star in ipairs(host.stars or {}) do
      star:SetVertexColor(color[1], color[2], color[3], 1)
      if SAK.Compatibility then SAK.Compatibility.ProtectTexture(star, color) end
    end
  end
  if host.running then return end
  if host.native then
    local ok = pcall(AutoCastShine_AutoCastStart, host, color[1], color[2], color[3])
    if not ok then host:Hide(); return end
  end
  host.running = true
end

local function initialize()
  if events then return end
  events = CreateFrame("Frame")
  for _, event in ipairs({ "ACTIONBAR_SLOT_CHANGED", "UPDATE_MACROS", "SPELLS_CHANGED", "PLAYER_ENTERING_WORLD", "ACTIONBAR_PAGE_CHANGED", "UPDATE_SHAPESHIFT_FORMS", "UPDATE_SHAPESHIFT_FORM" }) do
    events:RegisterEvent(event)
  end
  events:SetScript("OnEvent", function()
    Sparkles.Invalidate()
    if SAK.SpellBook then SAK.SpellBook.QueueRefresh() end
  end)
end

Sparkles.Initialize = initialize

function Sparkles.Paint(parent, owner, icon, state)
  initialize()
  local host = hosts[parent]
  if not visible(owner) or not visible(icon) or not eligible(state) then
    if host then host:Hide() end
    return
  end
  if not host then host = createHost(parent); hosts[parent] = host end
  host.owner, host.icon, host.state = owner, icon, state
  host:ClearAllPoints()
  host:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
  host:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
  host:SetFrameLevel(parent:GetFrameLevel() + 1)
  host:Show()
  local style = SAK.UnusedSpells and SAK.UnusedSpells.Style
  local color = style and Sparkles.IsAssigned(state.id) == true and style.color
  start(host, color)
end

-- Learning opportunities use the same particles, strictly bounded to an icon.
function Sparkles.PaintIcon(owner, icon, show, zone, style)
  if not owner then return end
  local host = learningHosts[owner]
  if not show or not visible(owner) or not visible(icon) or not SAK.DisplayEnabled("icons")
    or not SAK.DisplayEnabled(style and style.option or "learningSparkles") or not SAK.DisplayEnabled(zone) then
    if host then host:Hide() end
    return
  end
  if not host then host = createHost(UIParent); learningHosts[owner] = host end
  host.owner, host.icon, host.zone, host.style = owner, icon, zone, style
  host:ClearAllPoints()
  host:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
  host:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
  SAK.SpellBook.PrepareOverlay(host, owner)
  host:Show()
  start(host, style and style.color)
end
