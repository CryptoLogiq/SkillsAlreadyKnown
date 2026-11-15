-- Tracks first successful use of RECENT player spells; never alters action buttons.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Unused = {}
SAK.UnusedSpells = Unused
local driver, elapsed
local painted = setmetatable({}, { __mode = "k" })
local blue = { 0.25, 0.7, 1 }
Unused.Style = { option = "unusedSparkles", color = blue }
local prefixes = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
  "MultiBarLeftButton", "MultiBarRightButton", "MultiBar5Button", "MultiBar6Button", "MultiBar7Button" }

function Unused.IsUnused(id)
  return SAK.RecentLearning and SAK.RecentLearning.IsUnused(id) or false
end

function Unused.ShouldExplain(id)
  return SAK.DisplayEnabled("unusedSparkles") and Unused.IsUnused(id)
    and SAK.RecentSparkles and SAK.RecentSparkles.IsAssigned(id) == true
end

function Unused.StanceCount()
  if not GetShapeshiftFormInfo then return 0 end
  if GetNumShapeshiftForms then
    local ok, count = pcall(GetNumShapeshiftForms)
    if ok and type(count) == "number" then return math.max(0, math.min(count, 20)) end
  end
  return NUM_SHAPESHIFT_SLOTS or 10
end

function Unused.StanceSpell(index)
  if not GetShapeshiftFormInfo then return end
  local ok, _, second, third, fourth, fifth = pcall(GetShapeshiftFormInfo, index)
  if not ok then return end
  -- Modern clients return the ID fourth; older clients include a name before it.
  local id = type(fourth) == "number" and fourth or type(fifth) == "number" and fifth
  if not id or id <= 0 then return end
  local active = type(fourth) == "number" and second == true or type(fifth) == "number" and third == true
  -- Dedicated form/aura bars upgrade automatically, unlike manually placed ranks.
  local state = SAK.SpellBook and SAK.SpellBook.StateForSpell and SAK.SpellBook.StateForSpell(id)
  return state and state.highestID or id, active
end

function Unused.SpellForSlot(slot)
  if type(slot) ~= "number" or slot <= 0 then return end
  local api = C_ActionBar and C_ActionBar.GetActionInfo or GetActionInfo
  if not api then return end
  local ok, kind, id = pcall(api, slot)
  if not ok then return end
  if kind == "spell" then return id end
  if kind == "macro" then
    local macro = C_Macro and C_Macro.GetMacroSpell or GetMacroSpell
    if macro then
      local success, first, _, third = pcall(macro, id)
      if success then return type(first) == "number" and first or third end
    end
  end
end

local function spellForButton(button)
  local slot = button.action
  if button.GetAttribute then
    local ok, value = pcall(button.GetAttribute, button, "action")
    if ok and type(value) == "number" and value > 0 then slot = value end
  end
  return Unused.SpellForSlot(slot)
end

local function iconFor(button)
  local icon = button.Icon or button.icon or button.IconTexture
  if type(icon) == "table" or type(icon) == "userdata" then return icon end
  local name = button.GetName and button:GetName()
  return name and _G[name .. "Icon"] or name and _G[name .. "IconTexture"]
end

function Unused.Refresh()
  if not SAK.RecentSparkles then return end
  local seen, forms = {}, {}
  for index = 1, Unused.StanceCount() do
    local id = Unused.StanceSpell(index)
    forms[index] = { id = id }
  end
  local enabled = SAK.DisplayEnabled("icons") and SAK.DisplayEnabled("recent")
    and SAK.DisplayEnabled("unusedSparkles") and SAK.DisplayEnabled("iconsActionBars")
    and SAK.RecentLearning and SAK.RecentLearning.HasUnused()
  if not enabled then
    for button in pairs(painted) do SAK.RecentSparkles.PaintIcon(button, nil, false, "iconsActionBars", Unused.Style) end
    return
  end
  local function paint(button, stanceID)
    if not button or seen[button] or (button.IsForbidden and button:IsForbidden()) then return end
    seen[button] = true
    local id = stanceID or spellForButton(button)
    local show = id and Unused.IsUnused(id)
    SAK.RecentSparkles.PaintIcon(button, iconFor(button), show, "iconsActionBars", Unused.Style)
    painted[button] = true
  end
  for _, prefix in ipairs(prefixes) do for index = 1, 12 do paint(_G[prefix .. index]) end end
  -- Ellesmere reuses these native stance/aura buttons rather than action slots.
  for index, form in ipairs(forms) do
    paint(_G["StanceButton" .. index], form.id)
    paint(_G["ShapeshiftButton" .. index], form.id)
  end
  -- Ellesmere uses its own named secure buttons with a public action attribute.
  for index = 1, 180 do paint(_G["EABButton" .. index]) end
  for button in pairs(painted) do
    if not seen[button] then SAK.RecentSparkles.PaintIcon(button, nil, false, "iconsActionBars", Unused.Style) end
  end
end

function Unused.HandleCast(unit, _, id)
  if unit ~= "player" or type(id) ~= "number" then return end
  if SAK.RecentLearning and SAK.RecentLearning.MarkUsed(id) then
    Unused.Refresh()
    if SAK.SpellBook then SAK.SpellBook.QueueRefresh() end
  end
end

function Unused.Initialize()
  if driver then return end
  if SAK.RecentSparkles then SAK.RecentSparkles.Initialize() end
  driver, elapsed = CreateFrame("Frame"), 0
  driver:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  driver:SetScript("OnEvent", function(_, _, unit, castGUID, id) Unused.HandleCast(unit, castGUID, id) end)
  driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.25 then elapsed = 0; Unused.Refresh() end
  end)
end
