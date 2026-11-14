-- Optional advice in TrainerSpells' catalogue; its availability UI stays untouched.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Adapter = {}
SAK.TrainerSpellsBadges = Adapter
local displays = setmetatable({}, { __mode = "k" })
local driver, elapsed
local rowSnapshots = setmetatable({}, { __mode = "k" })
local previousScroll, previousCount
local stats = { rows = 0, shown = 0, narrow = 0 }

local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function enabled()
  return not SAK.DisplayEnabled or (SAK.DisplayEnabled("icons") and SAK.DisplayEnabled("iconsTrainerSpells"))
end

local function hide(row)
  local display = displays[row]
  if display then display:Hide() end
end

local function rowEntry(row)
  if not row.GetElementData then return nil end
  local ok, data = pcall(row.GetElementData, row)
  if not ok or type(data) ~= "table" then return nil end
  if data.isHeader or data.isWeaponSkill or data.isTrainer or data.isHunterBeast or data.isProfession then return nil end
  local entry = data.entry
  if type(entry) ~= "table" or type(entry.spellID) ~= "number" or entry.spellID <= 0 then return nil end
  if entry.petKey or entry.petLabel or entry.professionKey then return nil end
  return entry
end

local function createDisplay()
  local display = CreateFrame("Frame", nil, UIParent)
  display:EnableMouse(false)
  display.purchase = display:CreateTexture(nil, "OVERLAY", nil, 7)
  display.purchase:SetPoint("LEFT", display, "LEFT", 0, 0)
  if SAK.Compatibility then SAK.Compatibility.ProtectTexture(display.purchase) end
  display.usage = SAK.ContentTags.CreateBadge()
  display.usage:SetParent(display)
  return display
end

local function paint(row, class)
  local entry = rowEntry(row)
  local name = row.nameFS
  if not entry or not name or not name.GetWidth or not name.GetStringWidth then hide(row); return end

  local advice
  if not entry.questReward then
    advice = SAK.RankPolicy.PurchaseAdvice(class, entry.spellID, entry.rankNum)
  end
  local spec = advice and SAK.SPELLBOOK_BADGES[advice]
  local usage = SAK.DisplayEnabled("contentTags") and SAK.ContentTags.ForSpell(class, entry.spellID)
  local purchaseWidth = spec and spec.width or 0
  local usageWidth = usage and SAK.ContentTags.BadgeWidth(usage.tag) or 0
  local recent = SAK.RecentLearning and SAK.DisplayEnabled("recent")
    and SAK.RecentLearning.Contains("spells", entry.spellID)
  local recentWidth = recent and 58 or 0
  local gap = spec and usage and 3 or 0
  local previousWidth = purchaseWidth + usageWidth + gap
  local recentGap = recent and previousWidth > 0 and 3 or 0
  local total = previousWidth + recentWidth + recentGap
  if total == 0 then hide(row); return end

  -- Use only the empty space after the name; never move another addon's text.
  local free = math.max(0, name:GetWidth() - name:GetStringWidth() - 6)
  local height = row.GetHeight and row:GetHeight() or 20
  local factor = math.min(1, free / total, math.max(0, height - 2) / 16)
  if factor < 0.6 then
    stats.narrow = stats.narrow + 1
    hide(row)
    return
  end

  local display = displays[row]
  if not display then
    display = createDisplay()
    displays[row] = display
  end
  SAK.SpellBook.PrepareOverlay(display, row)
  local scale = row:GetEffectiveScale() / UIParent:GetEffectiveScale()
  display:SetScale(scale * factor)
  display:SetSize(total, 16)
  display:ClearAllPoints()
  display:SetPoint("RIGHT", name, "RIGHT", -2, 0)
  if spec then
    display.purchase:SetTexture(spec.texture)
    display.purchase:SetSize(spec.width, spec.height)
    display.purchase:Show()
  else
    display.purchase:Hide()
  end
  if usage then
    SAK.ContentTags.PrepareBadge(display.usage, row, usage)
    display.usage:SetScale(1)
    display.usage:SetFrameLevel(display:GetFrameLevel() + 1)
    display.usage:ClearAllPoints()
    display.usage:SetPoint("LEFT", display, "LEFT", purchaseWidth + gap, 0)
    display.usage:Show()
  else
    display.usage.entry = nil
    display.usage:Hide()
  end
  display:Show()
  if SAK.RecentVisuals then
    -- The RECENT frame sits inside the measured rightmost space.
    SAK.RecentVisuals.Paint(display, display, recent and entry.spellID, "spells", "iconsTrainerSpells")
  end
  stats.shown = stats.shown + 1
end

function Adapter.Refresh()
  stats.rows, stats.shown, stats.narrow = 0, 0, 0
  local root, scroll = TrainerSpellsFrame, TrainerSpellsScrollBox
  local seen = {}
  if enabled() and visible(root) and visible(scroll) and scroll.ForEachFrame then
    local _, class = UnitClass("player")
    scroll:ForEachFrame(function(row)
      if visible(row) and not (row.IsForbidden and row:IsForbidden()) then
        seen[row] = true
        stats.rows = stats.rows + 1
        paint(row, class)
      end
    end)
  end
  for row, display in pairs(displays) do
    if not seen[row] then display:Hide() end
  end
end

-- ScrollBox recycles rows between rendered frames. Detect that immediately,
-- without repeating spell-policy lookups for every frame of a stable list.
local function layoutChanged()
  local root, scroll = TrainerSpellsFrame, TrainerSpellsScrollBox
  local active = enabled() and visible(root) and visible(scroll) and scroll.ForEachFrame
  if not active then
    local changed = previousScroll ~= nil
    previousScroll, previousCount = nil, nil
    return changed
  end

  local changed = scroll ~= previousScroll
  local count = 0
  scroll:ForEachFrame(function(row)
    if not visible(row) or (row.IsForbidden and row:IsForbidden()) then return end
    count = count + 1
    local entry = rowEntry(row)
    local name = row.nameFS
    local width = name and name.GetWidth and name:GetWidth()
    local textWidth = name and name.GetStringWidth and name:GetStringWidth()
    local height = row.GetHeight and row:GetHeight()
    local scale = row.GetEffectiveScale and row:GetEffectiveScale()
    local snapshot = rowSnapshots[row]
    if not snapshot then
      snapshot = {}
      rowSnapshots[row] = snapshot
    end
    if snapshot.entry ~= entry or snapshot.name ~= name or snapshot.width ~= width
      or snapshot.textWidth ~= textWidth or snapshot.height ~= height or snapshot.scale ~= scale then
      changed = true
      snapshot.entry, snapshot.name = entry, name
      snapshot.width, snapshot.textWidth = width, textWidth
      snapshot.height, snapshot.scale = height, scale
    end
  end)
  changed = changed or count ~= previousCount
  previousScroll, previousCount = scroll, count
  return changed
end

function Adapter.Initialize()
  if driver then return end
  elapsed = 0
  driver = CreateFrame("Frame")
  driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    local changed = layoutChanged()
    if changed or elapsed >= 0.15 then
      elapsed = 0
      Adapter.Refresh()
    end
  end)
end

function Adapter.GetDiagnostics()
  return { rows = stats.rows, shown = stats.shown, narrow = stats.narrow }
end
