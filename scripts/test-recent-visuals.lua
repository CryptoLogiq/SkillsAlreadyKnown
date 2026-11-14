local made, options, known = {}, {}, { spells = { [20] = true }, recipes = { [30] = true }, talents = { [101] = true } }
local function font()
  return { SetAllPoints = function() end, SetText = function() end, SetTextColor = function() end,
    GetFont = function() return 'font', 10 end, SetFont = function() end }
end
local function frame()
  local f = { shown = true, scripts = {}, alpha = 1 }
  function f:IsVisible() return self.shown end
  function f:GetEffectiveAlpha() return self.alpha end
  function f:GetWidth() return 40 end
  function f:Show() self.shown = true end
  function f:Hide() self.shown = false end
  function f:SetScript(key, callback) self.scripts[key] = callback end
  function f:CreateFontString() return font() end
  for _, key in ipairs({ 'SetBackdrop', 'SetBackdropColor', 'SetBackdropBorderColor', 'EnableMouse', 'ClearAllPoints', 'SetPoint', 'SetSize' }) do f[key] = function() end end
  made[#made + 1] = f
  return f
end
CreateFrame = frame
UIParent = frame()
SkillsAlreadyKnown = {
  WHITE = 'white',
  DisplayEnabled = function(key) return options[key] ~= false end,
  RecentLearning = { Contains = function(kind, id) return known[kind] and known[kind][id] or false end },
  SpellBook = { PrepareOverlay = function() end },
}
dofile('RecentVisuals.lua')
local visuals = SkillsAlreadyKnown.RecentVisuals
local owner, icon = frame(), frame()
visuals.Paint(owner, icon, 20, 'spells', 'iconsSpellbook')
local badge = made[#made]
assert(badge.shown and badge.id == 20)
local count = #made
visuals.Paint(owner, icon, 20, 'spells', 'iconsSpellbook')
assert(#made == count, 'No duplicate frames')
visuals.Paint(owner, icon, 21, 'spells', 'iconsSpellbook')
assert(not badge.shown, 'Recycled row must clear')
visuals.Paint(owner, icon, 20, 'spells', 'iconsSpellbook')
owner.alpha = 0
visuals.Refresh()
assert(not badge.shown, 'Transparent foreign tabs must hide badges')
owner.alpha = 1
for _, key in ipairs({ 'icons', 'recent', 'iconsSpellbook' }) do
  options[key] = false
  visuals.Paint(owner, icon, 20, 'spells', 'iconsSpellbook')
  assert(not badge.shown, 'Respect ' .. key)
  options[key] = true
end
local talent = frame()
talent.nodeID, talent.icon = 101, 12345 -- Native icon can be a file ID, not a texture.
PlayerSpellsFrame = { TalentsFrame = talent }
visuals.Refresh()
assert(made[#made].kind == 'talents' and made[#made].shown)
local recipe = frame()
local data = { recipeInfo = { recipeID = 30 } }
function recipe:GetElementData() return data end
local scroll = { ForEachFrame = function(_, callback) callback(recipe) end }
TradeSkillFrame = frame()
TradeSkillFrame.RecipeList = { ScrollBox = scroll }
visuals.Refresh()
local recipeBadge = made[#made]
assert(recipeBadge.kind == 'recipes' and recipeBadge.shown)
data = { recipeInfo = { recipeID = 31 } }
visuals.Refresh()
assert(not recipeBadge.shown)
visuals.Initialize(); count = #made
visuals.Initialize(); assert(#made == count)
print('PASS: RECENT recycling, foreign tabs, category settings, native talent and recipe rows')
