-- SkillsAlreadyKnown: bag, bank, and guild bank item overlays.

local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Visuals = SAK.Visuals
local Inventory = {}
SAK.Inventory = Inventory

local coreHooked
local guildBankHooked
local refreshQueued
local ellesmereRegistered
local ellesmereItems = setmetatable({}, { __mode = "k" })

local LOCATION_BAGS = "bags"
local LOCATION_BANK = "bank"
local LOCATION_GUILD_BANK = "guildBank"

local function itemLinkFromContainerButton(button)
  if not button then return nil end
  if type(button.link) == "string" then return button.link end
  if type(button.itemLink) == "string" then return button.itemLink end

  local bag = button.GetBagID and button:GetBagID()
  local slot = button.GetID and button:GetID()
  if bag and slot then return SAK.ContainerItemLink(bag, slot) end

  local parent = button.GetParent and button:GetParent()
  bag = parent and parent.GetID and parent:GetID()
  slot = button.GetID and button:GetID()
  if bag and slot then return SAK.ContainerItemLink(bag, slot) end
end

local function bagLocation(bag)
  bag = tonumber(bag)
  if bag and ((NUM_BAG_SLOTS and bag > NUM_BAG_SLOTS) or bag < 0) then return LOCATION_BANK end
  return LOCATION_BAGS
end

local function classifyItem(itemLink)
  if itemLink and SAK.PetGrimoires and SAK.PetGrimoires.ItemInfoFromLink then
    local info = SAK.PetGrimoires.ItemInfoFromLink(itemLink)
    if info then return "petGrimoire", info end
  end
end

local function itemDuplicateText(info, location)
  local summary = info and SAK.ItemStorageSummary(info.itemID, location)
  if summary and summary ~= "" then return "x" end
end

local function paintItemButton(button, itemLink, location)
  if not button then return end
  Visuals.ClearItemButton(button)
  if SAK.RecentVisuals then SAK.RecentVisuals.Paint(button, button, nil, "pets", "iconsInventory") end
  if not itemLink then return end

  local kind, info = classifyItem(itemLink)
  if not info then
    if location == LOCATION_BAGS and SAK.RecipeKnowledge then
      SAK.RecipeKnowledge.Paint(button, itemLink, "iconsInventory", false)
    end
    return
  end
  local state
  local learnable

  if kind == "petGrimoire" and SAK.PetGrimoires then
    state = SAK.PetGrimoires.ItemState(info)
    learnable = state ~= "known" and SAK.PetGrimoires.ItemLearnable(info)
  end

  if state == "known" then
    Visuals.PaintItemKnownOverlay(button, true)
  elseif learnable then
    Visuals.PaintOutline(button, true, SAK.MERCHANT_LEARNABLE_OUTLINE)
    Visuals.PaintItemLearnableBadge(button, true)
  end

  if SAK.RecentVisuals then
    SAK.RecentVisuals.Paint(button, button.Icon or button.icon or button, info.spellID, "pets", "iconsInventory")
  end
  Visuals.PaintItemPetIcon(button, info)
  Visuals.PaintItemDuplicateBadge(button, itemDuplicateText(info, location))
end

local function scanBagStorage()
  SAK.ClearItemStorageLocation(LOCATION_BAGS)
  for itemID, count in pairs(SAK.ScanBagItemIDs()) do
    SAK.SaveItemStorage(itemID, LOCATION_BAGS, count)
  end
end

local function paintContainerButton(button)
  local itemLink = itemLinkFromContainerButton(button)
  local bag = button and button.GetBagID and button:GetBagID()
  if not bag and button and button.GetParent then
    local parent = button:GetParent()
    bag = parent and parent.GetID and parent:GetID()
  end
  paintItemButton(button, itemLink, bagLocation(bag))
end

local function paintContainerFrame(container)
  if not container then return end
  local name = container.GetName and container:GetName()
  local size = container.size or (container.GetNumItems and container:GetNumItems()) or 0

  if container.EnumerateValidItems then
    for _, itemButton in container:EnumerateValidItems() do
      paintContainerButton(itemButton)
    end
  elseif name and size and size > 0 then
    for i = 1, size do
      paintContainerButton(_G[name .. "Item" .. i])
    end
  end
end

-- Ellesmere's extension API supplies the actual icon button in grid and list
-- views. Keep addon state on our own frame, never on its secure item button.
local function paintEllesmereItem(button, data)
  if not button then return end
  local entry = ellesmereItems[button]
  if not entry then
    local parent = button._textOverlay or button
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetAllPoints(button.icon or button.Icon or parent)
    frame.icon = button.icon or button.Icon
    entry = { frame = frame }
    ellesmereItems[button] = entry
  end
  entry.bag = data and data.bag
  entry.slot = data and data.slot
  -- The caller reuses data tables, so retain only the location values.
  local link = data and data.itemLink
  if not link and entry.bag and entry.slot and entry.slot > 0 then
    link = SAK.ContainerItemLink(entry.bag, entry.slot)
  end
  paintItemButton(entry.frame, link, bagLocation(entry.bag))
end

local function hookEllesmere()
  local bags = EUI_Bags
  if ellesmereRegistered == bags then return end
  if not (bags and type(bags.RegisterItemOverlayIcon) == "function") then return end
  bags.RegisterItemOverlayIcon("SkillsAlreadyKnown", paintEllesmereItem)
  ellesmereRegistered = bags
end

local function refreshEllesmereItems()
  for button, entry in pairs(ellesmereItems) do
    if button:IsShown() then
      local link = entry.bag and entry.slot and entry.slot > 0
        and SAK.ContainerItemLink(entry.bag, entry.slot) or nil
      paintItemButton(entry.frame, link, bagLocation(entry.bag))
    end
  end
end

local function bankItemLink(button)
  local itemLink = itemLinkFromContainerButton(button)
  if itemLink then return itemLink end
  if button and button.GetInventorySlot and GetInventoryItemLink then
    return GetInventoryItemLink("player", button:GetInventorySlot())
  end
end

local function paintBankButton(button)
  paintItemButton(button, bankItemLink(button), LOCATION_BANK)
end

local function paintBank()
  if not (BankFrame and BankFrame:IsShown()) then return end
  SAK.ClearItemStorageLocation(LOCATION_BANK)
  local counts = {}

  for i = 1, 120 do
    local button = _G["BankFrameItem" .. i]
    if button and button:IsShown() then
      local itemLink = bankItemLink(button)
      local itemID = SAK.ItemIDFromLink(itemLink)
      if itemID then counts[itemID] = (counts[itemID] or 0) + 1 end
      paintItemButton(button, itemLink, LOCATION_BANK)
    end
  end

  for itemID, count in pairs(counts) do
    SAK.SaveItemStorage(itemID, LOCATION_BANK, count)
  end
end

local function paintGuildBank()
  if not (GuildBankFrame and GuildBankFrame:IsShown() and GetCurrentGuildBankTab and GetGuildBankItemLink) then return end
  local tab = GetCurrentGuildBankTab()
  if not tab then return end

  SAK.ClearItemStorageLocation(LOCATION_GUILD_BANK)
  local counts = {}

  if GuildBankFrame.Columns then
    for _, column in ipairs(GuildBankFrame.Columns) do
      for _, button in ipairs(column.Buttons or {}) do
        local slot = button.GetID and button:GetID()
        local itemLink = slot and GetGuildBankItemLink(tab, slot)
        local itemID = SAK.ItemIDFromLink(itemLink)
        if itemID then counts[itemID] = (counts[itemID] or 0) + 1 end
        paintItemButton(button, itemLink, LOCATION_GUILD_BANK)
      end
    end
  end

  for itemID, count in pairs(counts) do
    SAK.SaveItemStorage(itemID, LOCATION_GUILD_BANK, count)
  end
end

local function addTooltipLine(tooltip, text, color)
  if not (tooltip and tooltip.AddLine and text and text ~= "") then return end
  local name = tooltip.GetName and tooltip:GetName()
  if name and tooltip.NumLines then
    for i = 1, tooltip:NumLines() do
      local fs = _G[name .. "TextLeft" .. i]
      if fs and fs.GetText and fs:GetText() == text then return end
    end
  end
  color = color or { 1, 1, 1 }
  tooltip:AddLine(text, color[1], color[2], color[3])
end

local function enhanceItemTooltip(tooltip, itemLink, location)
  if SAK.DisplayEnabled and not SAK.DisplayEnabled("text") then return end
  local kind, info = classifyItem(itemLink)
  if not info then return end

  if kind == "petGrimoire" and SAK.PetGrimoires then
    if SAK.PetGrimoires.KnowsItemInfo(info) then
      addTooltipLine(tooltip, SAK.MERCHANT_LEARNED_LABEL, SAK.MERCHANT_LEARNED_TOOLTIP)
    elseif SAK.PetGrimoires.ItemLearnable(info) then
      addTooltipLine(tooltip, string.format("You can learn it! Your %s will love it!", info.pet or "pet"), SAK.MERCHANT_LEARNABLE_TEXT)
    end
  end

  local storage = SAK.ItemStorageSummary(info.itemID, location)
  if storage then
    addTooltipLine(tooltip, "Also seen in: " .. storage, SAK.MERCHANT_LEARNABLE_TEXT)
  end

  if tooltip and tooltip.Show then tooltip:Show() end
end

local function hookTooltips()
  if not GameTooltip then return end
  if GameTooltip.SetBagItem then
    hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, bag, slot)
      enhanceItemTooltip(tooltip, SAK.ContainerItemLink(bag, slot), bagLocation(bag))
    end)
  end
  if GameTooltip.SetGuildBankItem then
    hooksecurefunc(GameTooltip, "SetGuildBankItem", function(tooltip, tab, slot)
      local itemLink = GetGuildBankItemLink and GetGuildBankItemLink(tab, slot)
      enhanceItemTooltip(tooltip, itemLink, LOCATION_GUILD_BANK)
    end)
  end
end

function Inventory.Refresh()
  hookEllesmere()
  scanBagStorage()
  refreshEllesmereItems()

  for i = 1, 13 do
    local container = _G["ContainerFrame" .. i]
    if container and container:IsShown() then paintContainerFrame(container) end
  end

  if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() and ContainerFrameCombinedBags.EnumerateValidItems then
    paintContainerFrame(ContainerFrameCombinedBags)
  end

  paintGuildBank()
  paintBank()
end

function Inventory.QueueRefresh()
  if refreshQueued then return end
  refreshQueued = true
  if C_Timer and C_Timer.After then
    C_Timer.After(0.05, function()
      refreshQueued = nil
      Inventory.Refresh()
    end)
  else
    refreshQueued = nil
    Inventory.Refresh()
  end
end

function Inventory.Hook()
  hookEllesmere()
  if not coreHooked then
    coreHooked = true

    if type(ContainerFrame_Update) == "function" then
      hooksecurefunc("ContainerFrame_Update", function(container)
        Inventory.QueueRefresh()
        paintContainerFrame(container)
      end)
    end

    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.UpdateItems then
      hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", Inventory.QueueRefresh)
    end

    if type(BankFrameItemButton_Update) == "function" then
      hooksecurefunc("BankFrameItemButton_Update", function(button)
        if button and not button.isBag then
          Inventory.QueueRefresh()
          paintBankButton(button)
        end
      end)
    end

    hookTooltips()
  end

  if not guildBankHooked and GuildBankFrame and GuildBankFrame.Update then
    guildBankHooked = true
    hooksecurefunc(GuildBankFrame, "Update", function()
      Inventory.QueueRefresh()
      paintGuildBank()
    end)
  end
end

function Inventory.GetDiagnostics()
  local count = 0
  for _ in pairs(ellesmereItems) do count = count + 1 end
  return {
    available = EUI_Bags ~= nil,
    registered = ellesmereRegistered ~= nil and ellesmereRegistered == EUI_Bags,
    callbackIntact = EUI_Bags ~= nil and EUI_Bags.itemOverlayIcons ~= nil
      and EUI_Bags.itemOverlayIcons["SkillsAlreadyKnown"] == paintEllesmereItem or false,
    trackedButtons = count,
  }
end
