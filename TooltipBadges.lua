-- A small badge strip follows the tooltip; native tooltip text/layout is untouched.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Badges = {}
SAK.TooltipBadges = Badges
local displays = setmetatable({}, { __mode = "k" })

function Badges.Collect(id, state)
  local result = {}
  -- DEV identifies the code actually executing, independently of appearance settings.
  if SAK.isDev then result[1] = { tag = "dev", spellID = id } end
  if not id or not SAK.DisplayEnabled("icons") or not SAK.DisplayEnabled("iconsTooltips") then return result end
  local function texture(kind)
    local spec = SAK.SPELLBOOK_BADGES[kind]
    if spec then result[#result + 1] = { texture = spec.texture, width = spec.width, height = spec.height } end
  end
  if state then
    texture(state.kind)
    if state.optionalReason and (not SAK.RankPolicy or SAK.RankPolicy.OptionalEnabled()) then texture("optional") end
  end
  local _, class = UnitClass("player")
  local usage = SAK.SpellUsage and (SAK.SpellUsage.ForDisplay or SAK.SpellUsage.ForSpell)(class, id)
  if usage and SAK.DisplayEnabled(usage.tag) then result[#result + 1] = usage end
  local pvp = SAK.DisplayEnabled("contentTags") and SAK.ContentTags and SAK.ContentTags.ForSpell
    and SAK.ContentTags.ForSpell(class, id)
  if pvp then result[#result + 1] = pvp end
  if SAK.RecentLearning and SAK.DisplayEnabled("recent") then
    for _, kind in ipairs({ "spells", "pets", "recipes" }) do
      if SAK.RecentLearning.Contains(kind, id) then
        result[#result + 1] = { tag = "recent", spellID = id }
        break
      end
    end
  end
  return result
end

function Badges.Hide(tooltip)
  local display = displays[tooltip]
  if display then display.id, display.state = nil, nil; display:Hide() end
end

function Badges.Paint(tooltip, id, state)
  if not tooltip or not tooltip.HookScript or not CreateFrame then return end
  local specs = Badges.Collect(id, state)
  local display = displays[tooltip]
  if #specs == 0 then Badges.Hide(tooltip); return end
  if not display then
    display = CreateFrame("Frame", nil, tooltip)
    display:EnableMouse(false)
    display:SetClampedToScreen(true)
    display.items = {}
    displays[tooltip] = display
    tooltip:HookScript("OnTooltipCleared", function() Badges.Hide(tooltip) end)
    tooltip:HookScript("OnHide", function() Badges.Hide(tooltip) end)
    local elapsed = 0
    display:SetScript("OnUpdate", function(_, delta)
      elapsed = elapsed + delta
      if elapsed < 0.1 then return end
      elapsed = 0
      if display.id then Badges.Paint(tooltip, display.id, display.state) end
    end)
  end
  display.id, display.state = id, state
  display:SetFrameStrata("TOOLTIP")
  display:SetFrameLevel(math.min((tooltip.GetFrameLevel and tooltip:GetFrameLevel() or 0) + 20, 65535))
  local limit = math.max(100, tooltip.GetWidth and tooltip:GetWidth() or 320)
  local x, y, width = 0, 0, 0
  for index, spec in ipairs(specs) do
    local item = display.items[index]
    if not item then
      item = CreateFrame("Frame", nil, display)
      item:EnableMouse(false)
      item.texture = item:CreateTexture(nil, "OVERLAY", nil, 7)
      item.texture:SetPoint("BOTTOM", item, "BOTTOM")
      item.label = SAK.ContentTags.CreateBadge()
      item.label:SetParent(item)
      item.label:EnableMouse(false)
      display.items[index] = item
    end
    local w = spec.width or SAK.ContentTags.BadgeWidth(spec.tag)
    if x > 0 and x + w > limit then x, y = 0, y + 22 end
    item:ClearAllPoints()
    item:SetPoint("TOPLEFT", display, "TOPLEFT", x, -y)
    item:SetSize(w, 20)
    if spec.texture then
      item.label:Hide()
      item.texture:SetTexture(spec.texture)
      item.texture:SetSize(spec.width, spec.height or 16)
      if SAK.Compatibility then SAK.Compatibility.ProtectTexture(item.texture) end
      item.texture:Show()
    else
      item.texture:Hide()
      SAK.ContentTags.PrepareBadge(item.label, tooltip, spec)
      item.label:SetScale(1)
      item.label:ClearAllPoints()
      item.label:SetPoint("BOTTOM", item, "BOTTOM")
      item.label:Show()
    end
    item:Show()
    x = x + w + 3
    width = math.max(width, x - 3)
  end
  for index = #specs + 1, #display.items do display.items[index]:Hide() end
  local height = y + 20
  display:SetSize(width, height)
  display:ClearAllPoints()
  local top = tooltip.GetTop and tooltip:GetTop()
  local screenTop = UIParent and UIParent.GetTop and UIParent:GetTop()
  local scale = tooltip.GetEffectiveScale and tooltip:GetEffectiveScale() or 1
  local screenScale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
  if top and screenTop and (top + height) * scale > screenTop * screenScale then
    display:SetPoint("TOPLEFT", tooltip, "BOTTOMLEFT", 0, 0)
  else
    display:SetPoint("BOTTOMLEFT", tooltip, "TOPLEFT", 0, -3)
  end
  display:Show()
end
