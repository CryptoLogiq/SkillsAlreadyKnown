-- Read only the game's positive "already known" recipe indication, without hover.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Recipes = {}
SAK.RecipeKnowledge = Recipes
local known, requested = {}, {}
local displays = setmetatable({}, { __mode = "k" })
local scanTooltip, driver, queued
local elapsed = 0

local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function enabled(zone)
  return not SAK.DisplayEnabled or (SAK.DisplayEnabled("icons")
    and SAK.DisplayEnabled("recipes") and SAK.DisplayEnabled(zone))
end

local function requestItem(id)
  if requested[id] or not C_Item or not C_Item.RequestLoadItemDataByID then return end
  requested[id] = true
  pcall(C_Item.RequestLoadItemDataByID, id)
end

local function recipeID(link)
  if type(link) ~= "string" then return nil end
  local info = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
  if not info then return nil end
  local ok, id, _, _, _, _, classID, subclassID = pcall(info, link)
  if not ok or not id then
    local pendingID = tonumber(link:match("item:(%d+)"))
    if pendingID then requestItem(pendingID) end
    return nil
  end
  local recipeClass = Enum and Enum.ItemClass and Enum.ItemClass.Recipe or 9
  -- Generic books include pet grimoires; profession recipes have their own subclass.
  if classID ~= recipeClass or type(subclassID) ~= "number" or subclassID <= 0 then return nil end
  return id
end

local function normalized(text)
  return SAK.NormalizeText(SAK.CleanText(text))
end

local function knownLine(text)
  return type(ITEM_SPELL_KNOWN) == "string" and ITEM_SPELL_KNOWN ~= ""
    and type(text) == "string" and normalized(text) == normalized(ITEM_SPELL_KNOWN)
end

local function scanLegacy(link)
  if not scanTooltip then
    scanTooltip = CreateFrame("GameTooltip", "SkillsAlreadyKnownRecipeScan", UIParent, "GameTooltipTemplate")
  end
  scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  scanTooltip:ClearLines()
  local ok = pcall(scanTooltip.SetHyperlink, scanTooltip, link)
  local result = false
  if ok then
    for index = 1, scanTooltip:NumLines() do
      local left = _G[scanTooltip:GetName() .. "TextLeft" .. index]
      local right = _G[scanTooltip:GetName() .. "TextRight" .. index]
      if (left and knownLine(left:GetText())) or (right and knownLine(right:GetText())) then
        result = true
        break
      end
    end
  end
  scanTooltip:Hide()
  return result
end

function Recipes.IsKnown(link)
  local id = recipeID(link)
  if not id then return nil end
  if known[id] then return true end
  local confirmed = false
  if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
    local ok, data = pcall(C_TooltipInfo.GetHyperlink, link)
    if ok and data and type(data.lines) == "table" then
      for _, line in ipairs(data.lines) do
        if knownLine(line.leftText) or knownLine(line.rightText) then
          confirmed = true
          break
        end
      end
    end
  else
    confirmed = scanLegacy(link)
  end
  if confirmed then
    known[id] = true
    return true
  end
  requestItem(id)
  -- Missing or incomplete tooltip data never means "learnable".
  return nil
end

function Recipes.Clear(owner)
  local display = displays[owner]
  if display then
    display:Hide()
    display.link = nil
  end
end

local function itemIcon(owner)
  local host = owner.IconFrame or owner.Item or owner
  local icon = host.Icon or host.icon or owner.Icon or owner.icon
  if type(icon) == "table" or type(icon) == "userdata" then return icon end
  return host
end

function Recipes.Paint(owner, link, zone, lootRoll)
  if not owner or not visible(owner) or not enabled(zone) or not Recipes.IsKnown(link) then
    if owner then Recipes.Clear(owner) end
    return
  end
  local display = displays[owner]
  if not display then
    display = CreateFrame("Frame", nil, UIParent)
    display:EnableMouse(false)
    display.texture = display:CreateTexture(nil, "OVERLAY", nil, 7)
    display.texture:SetAllPoints(display)
    display.texture:SetTexture(SAK.RECIPE_KNOWN_BADGE)
    if SAK.Compatibility then SAK.Compatibility.ProtectTexture(display.texture) end
    displays[owner] = display
  end
  local icon = itemIcon(owner)
  display.link, display.zone = link, zone
  SAK.SpellBook.PrepareOverlay(display, owner)
  display:ClearAllPoints()
  if lootRoll then
    display:SetSize(88, 16)
    display:SetPoint("LEFT", icon, "RIGHT", 6, -10)
  else
    local width = icon.GetWidth and icon:GetWidth() or 36
    if not width or width <= 0 then width = 36 end
    display:SetSize(width, math.max(8, width * 0.2))
    display:SetPoint("BOTTOM", icon, "BOTTOM", 0, 0)
  end
  display:Show()
end

function Recipes.RefreshRolls()
  local seen = {}
  local function paint(frame)
    if not frame or seen[frame] then return end
    seen[frame] = true
    if frame.IsForbidden and frame:IsForbidden() then return end
    local link
    if visible(frame) and frame.rollID and GetLootRollItemLink then
      local ok, value = pcall(GetLootRollItemLink, frame.rollID)
      if ok then link = value end
    end
    Recipes.Paint(frame, link, "iconsLoot", true)
  end
  for index = 1, (NUM_GROUP_LOOT_FRAMES or 16) do paint(_G["GroupLootFrame" .. index]) end
  if GroupLootContainer and type(GroupLootContainer.rollFrames) == "table" then
    for _, frame in pairs(GroupLootContainer.rollFrames) do paint(frame) end
  end
  for owner, display in pairs(displays) do
    if not visible(owner) or not enabled(display.zone) then display:Hide() end
    if display.zone == "iconsLoot" and not seen[owner] then Recipes.Clear(owner) end
  end
end

function Recipes.QueueRollRefresh()
  if queued then return end
  queued = true
  local function refresh()
    queued = false
    Recipes.RefreshRolls()
  end
  if C_Timer and C_Timer.After then C_Timer.After(0.05, refresh) else refresh() end
end

function Recipes.Invalidate()
  known, requested = {}, {}
end

function Recipes.Initialize()
  if driver then return end
  driver = CreateFrame("Frame")
  driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.25 then
      elapsed = 0
      Recipes.RefreshRolls()
    end
  end)
end
