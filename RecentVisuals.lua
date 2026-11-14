-- Shared RECENT badge; never changes native button fields or scripts.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Visuals = {}
SAK.RecentVisuals = Visuals
local displays = setmetatable({}, { __mode = "k" })
local driver, elapsed = nil, 0

local function visible(frame)
  if type(frame) ~= "table" and type(frame) ~= "userdata" then return false end
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function enabled(zone)
  return SAK.DisplayEnabled("icons") and SAK.DisplayEnabled("recent") and SAK.DisplayEnabled(zone)
end

function Visuals.Paint(owner, icon, id, kind, zone)
  if not owner then return end
  local display = displays[owner]
  if not id or not visible(owner) or not visible(icon) or not enabled(zone)
    or not SAK.RecentLearning.Contains(kind, id) then
    if display then display:Hide() end
    return
  end
  if not display then
    display = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    display:SetBackdrop({ bgFile = SAK.WHITE, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
      insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    display:SetBackdropColor(0.03, 0.03, 0.02, 0.95)
    display:SetBackdropBorderColor(0.8, 0.63, 0.25, 1)
    display.text = display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    display.text:SetAllPoints(display)
    display.text:SetText("RECENT")
    display.text:SetTextColor(1, 0.82, 0.1)
    display:EnableMouse(true)
    display:SetScript("OnEnter", function(self)
      if not SAK.DisplayEnabled("text") or not GameTooltip then return end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine("RECENT — récemment appris", 1, 0.82, 0.1)
      GameTooltip:AddLine(SAK.RecentLearning.Description(), 1, 1, 1, true)
      GameTooltip:Show()
    end)
    display:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    display:SetScript("OnHide", function(self)
      if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)
    displays[owner] = display
  end
  display.id, display.kind, display.zone = id, kind, zone
  display:ClearAllPoints()
  if icon == owner and zone ~= "iconsTalents" then
    display:SetPoint("RIGHT", owner, "RIGHT", -2, 0)
    display:SetSize(58, 16)
  else
    display:SetPoint("TOP", icon, "BOTTOM", 0, 0)
    local width = icon.GetWidth and icon:GetWidth() or 40
    width = math.min(58, math.max(32, width))
    display:SetSize(width, 14)
    local font, _, flags = display.text:GetFont()
    display.text:SetFont(font, width < 45 and 8 or 10, flags)
  end
  SAK.SpellBook.PrepareOverlay(display, owner)
  display:Show()
end

local function iconFor(owner)
  local icon = owner.Icon or owner.icon
  if type(icon) == "table" or type(icon) == "userdata" then return icon end
  return owner
end

local function recipeRows(root)
  local list = root and root.RecipeList
  local scroll = list and list.ScrollBox
  if not visible(root) or not scroll or not scroll.ForEachFrame then return end
  scroll:ForEachFrame(function(row)
    local data = row.GetElementData and row:GetElementData()
    local info = data and (data.recipeInfo or data)
    local id = type(info) == "table" and info.recipeID
    Visuals.Paint(row, iconFor(row), id, "recipes", "iconsProfessions")
  end)
end

local function talentRows()
  local root = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
  if not visible(root) then return end
  local visited = 0
  local function visit(button, depth)
    if depth > 10 or visited >= 1000 or not visible(button) or (button.IsForbidden and button:IsForbidden()) then return end
    visited = visited + 1
    local id = button.nodeID
    if button.GetNodeID then
      local ok, value = pcall(button.GetNodeID, button)
      if ok then id = value end
    end
    if type(id) == "number" then
      Visuals.Paint(button, iconFor(button), id, "talents", "iconsTalents")
    end
    if button.GetChildren then
      for _, child in ipairs({button:GetChildren()}) do visit(child, depth + 1) end
    end
  end
  visit(root, 0)
end

function Visuals.Refresh()
  for owner, display in pairs(displays) do
    if not visible(owner) or not enabled(display.zone) or not SAK.RecentLearning.Contains(display.kind, display.id) then
      display:Hide()
    end
  end
  talentRows()
  recipeRows(ProfessionsFrame and ProfessionsFrame.CraftingPage)
  recipeRows(TradeSkillFrame)
  if visible(TradeSkillFrame) and GetTradeSkillRecipeLink then
    for index = 1, 40 do
      local row = _G["TradeSkillSkill" .. index]
      if row and visible(row) and row.GetID then
        local index = row:GetID()
        local ok, link
        if type(index) == "number" and index > 0 then ok, link = pcall(GetTradeSkillRecipeLink, index) end
        if not ok then link = nil end
        local id = type(link) == "string" and tonumber(link:match("enchant:(%d+)"))
        Visuals.Paint(row, row, id, "recipes", "iconsProfessions")
      end
    end
  end
end

function Visuals.Initialize()
  if driver then return end
  driver = CreateFrame("Frame")
  driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.15 then elapsed = 0; Visuals.Refresh() end
  end)
end
