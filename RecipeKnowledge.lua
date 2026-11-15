-- Read only the game's positive "already known" recipe indication, without hover.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Recipes = {}
SAK.RecipeKnowledge = Recipes
local known, requested, unlearned = {}, {}, {}
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

-- An absent "known" line alone is insufficient: require a cached recipe title
-- and its complete localized Use line before treating the plan as unlearned.
function Recipes.IsUnlearned(link)
  local id = recipeID(link)
  if not id or known[id] then return false end
  if unlearned[id] then return true end
  if Recipes.IsKnown(link) then return false end
  local info = C_Item and C_Item.GetItemInfo or GetItemInfo
  if not info or type(ITEM_SPELL_TRIGGER_ONUSE) ~= "string" then return false end
  local ok, name = pcall(info, link)
  if not ok or type(name) ~= "string" or name == "" then return false end
  local lines
  if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
    local success, data = pcall(C_TooltipInfo.GetHyperlink, link)
    if success and data then lines = data.lines end
  elseif scanTooltip and scanTooltip.NumLines and scanTooltip:GetName() then
    lines = {}
    for index = 1, scanTooltip:NumLines() do
      local left = _G[scanTooltip:GetName() .. "TextLeft" .. index]
      lines[index] = { leftText = left and left:GetText() }
    end
  end
  if type(lines) ~= "table" or not lines[1] or normalized(lines[1].leftText) ~= normalized(name) then return false end
  local prefix = normalized(ITEM_SPELL_TRIGGER_ONUSE)
  if prefix == "" then return false end
  for _, line in ipairs(lines) do
    for _, text in pairs({ line.leftText, line.rightText }) do
      local value = type(text) == "string" and normalized(text)
      if value and value:sub(1, #prefix) == prefix and #value > #prefix then
        unlearned[id] = true
        return true
      end
    end
  end
  return false
end

function Recipes.Clear(owner, keepSparkles)
  if not keepSparkles and SAK.RecentSparkles then SAK.RecentSparkles.PaintIcon(owner, nil, false, "iconsLoot") end
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
  local name = owner.GetName and owner:GetName()
  local named = name and _G[name .. "IconTexture"]
  if named then return named end
  -- A missing icon must not turn an entire merchant/loot row into a particle field.
  if host.GetWidth and host:GetWidth() <= 64 then return host end
end

function Recipes.Paint(owner, link, zone, lootRoll)
  local isKnown = owner and visible(owner) and enabled(zone) and Recipes.IsKnown(link)
  if owner and SAK.RecentSparkles and (zone == "iconsMerchant" or zone == "iconsLoot") then
    local show = visible(owner) and enabled(zone) and not isKnown and Recipes.IsUnlearned(link)
    SAK.RecentSparkles.PaintIcon(owner, itemIcon(owner), show, zone)
  end
  if not isKnown then
    if owner then Recipes.Clear(owner, true) end
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
  if not icon then Recipes.Clear(owner); return end
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

function Recipes.RefreshMerchant()
  if not visible(MerchantFrame) or not GetMerchantItemLink then return end
  local perPage = MERCHANT_ITEMS_PER_PAGE or 10
  local page = MerchantFrame.page or 1
  local selling = MerchantFrame.selectedTab ~= 2
  for index = 1, perPage do
    local row = _G["MerchantItem" .. index]
    local button = _G["MerchantItem" .. index .. "ItemButton"] or (row and row.ItemButton)
    if button then
      local slot = (page - 1) * perPage + index
      local ok, link = pcall(GetMerchantItemLink, slot)
      local available = true
      if GetMerchantItemInfo then
        local success, _, _, _, _, stock = pcall(GetMerchantItemInfo, slot)
        if success and stock == 0 then available = false end
      end
      Recipes.Paint(button, selling and available and visible(row or button) and ok and link or nil, "iconsMerchant", false)
    end
  end
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
  if visible(LootFrame) and GetLootSlotLink then
    for index = 1, (LOOTFRAME_NUMBUTTONS or 8) do
      local button = _G["LootButton" .. index]
      if button then
        seen[button] = true
        local slot = button.slot or (button.GetID and button:GetID()) or index
        local ok, link = pcall(GetLootSlotLink, slot)
        Recipes.Paint(button, visible(button) and ok and link or nil, "iconsLoot", false)
      end
    end
  end
  Recipes.RefreshMerchant()
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
  known, requested, unlearned = {}, {}, {}
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
