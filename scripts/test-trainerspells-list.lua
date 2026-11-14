local frames = {}
local function frame()
  local f = { shown = true, scripts = {} }
  function f:Show() self.shown = true end
  function f:Hide() self.shown = false end
  function f:IsVisible() return self.shown end
  function f:GetEffectiveScale() return 1 end
  function f:GetFrameLevel() return 500 end
  function f:SetScript(key, value) self.scripts[key] = value end
  for _, method in ipairs({ 'EnableMouse', 'SetParent', 'SetPoint', 'ClearAllPoints', 'SetScale', 'SetSize', 'SetFrameLevel', 'SetFrameStrata', 'SetTexture' }) do
    f[method] = function() end
  end
  function f:CreateTexture() self.texture = frame(); return self.texture end
  frames[#frames + 1] = f
  return f
end
CreateFrame = frame
UIParent = frame()
UnitClass = function() return 'Mage', 'MAGE' end
local options = {}
local advice = 'optional'
local usage = { tag = 'mixed' }
SkillsAlreadyKnown = {
  DisplayEnabled = function(key) return options[key] ~= false end,
  SPELLBOOK_BADGES = { optional = { width = 60, height = 16, texture = 'optional' }, eco = { width = 40, height = 16, texture = 'eco' } },
  RankPolicy = { PurchaseAdvice = function(class, id) assert(class == 'MAGE' and id == 1008); return advice end },
  SpellBook = { PrepareOverlay = function() end },
  ContentTags = {
    CreateBadge = frame,
    PrepareBadge = function(display, owner, entry) display.entry = entry end,
    BadgeWidth = function() return 60 end,
    ForSpell = function() return usage end,
  },
}
local row = frame()
local data = { entry = { spellID = 1008, rankNum = 1 } }
function row:GetElementData() return data end
function row:GetHeight() return 24 end
local free = 200
row.nameFS = { GetWidth = function() return 100 + free end, GetStringWidth = function() return 100 end }
TrainerSpellsFrame = frame()
TrainerSpellsScrollBox = frame()
function TrainerSpellsScrollBox:ForEachFrame(callback) callback(row) end
dofile('TrainerSpellsBadges.lua')
local adapter = SkillsAlreadyKnown.TrainerSpellsBadges
local function check(shown, narrow)
  adapter.Refresh()
  local stats = adapter.GetDiagnostics()
  assert(stats.shown == shown and stats.narrow == (narrow or 0))
end
check(1)
local count = #frames
check(1)
assert(#frames == count, 'Refresh must reuse badges')
data.isHeader = true; check(0); data.isHeader = nil
options.iconsTrainerSpells = false; check(0); options.iconsTrainerSpells = true
options.icons = false; check(0); options.icons = true
TrainerSpellsFrame:Hide(); check(0); TrainerSpellsFrame:Show()
free = 10; check(0, 1); free = 200
advice = nil; check(1)
options.contentTags = false; check(0)
advice = 'eco'; check(1)
data.entry.questReward = true; check(0); data.entry.questReward = nil
options.contentTags = true
for _, key in ipairs({ 'petKey', 'petLabel', 'professionKey' }) do
  data.entry[key] = 'pet'; check(0); data.entry[key] = nil
end
for _, key in ipairs({ 'isWeaponSkill', 'isTrainer', 'isHunterBeast', 'isProfession' }) do
  data[key] = true; check(0); data[key] = nil
end
adapter.Initialize()
count = #frames
adapter.Initialize()
assert(#frames == count, 'Driver must be initialized once')
local tick = frames[count].scripts.OnUpdate
tick(nil, 0.001)
assert(adapter.GetDiagnostics().shown == 1)
-- A recycled row must clear before the next rendered frame, not 150 ms later.
data = { isHeader = true }
tick(nil, 0.001)
assert(adapter.GetDiagnostics().shown == 0)
data = { entry = { spellID = 1008, rankNum = 1 } }
tick(nil, 0.001)
assert(adapter.GetDiagnostics().shown == 1)
free = 10
tick(nil, 0.001)
assert(adapter.GetDiagnostics().narrow == 1)
free = 200
tick(nil, 0.001)
assert(adapter.GetDiagnostics().shown == 1)
TrainerSpellsFrame = nil
tick(nil, 0.001)
assert(adapter.GetDiagnostics().shown == 0)
print('TrainerSpells catalogue badges: OK')
