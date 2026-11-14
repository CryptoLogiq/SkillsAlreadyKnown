-- Beginner summaries on native spellbook school tabs, before talents unlock.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Tabs = {}
SAK.SpellBookTabs = Tabs
local hooked = setmetatable({}, { __mode = "k" })
local marked = setmetatable({}, { __mode = "k" })
local tooltipHooked = false

local function enabled()
  local level = UnitLevel and UnitLevel("player")
  return type(level) == "number" and level > 0 and level < 10
    and (not SAK.DisplayEnabled or SAK.DisplayEnabled("text"))
end

local function tooltipTitle(tooltip)
  local line = GameTooltipTextLeft1
  if line and line.GetText then return line:GetText() end
end

local function treeFor(tab, class, tooltip)
  local names = SAK.TalentTooltips.TreeNames(class)
  local function match(name)
    local entry = type(name) == "string" and names[SAK.NormalizeText(SAK.CleanText(name))]
    return entry and entry.tree
  end
  local tree = match(tab.tooltip) or match(tab.tooltipText)
  if not tree and tab.GetText then tree = match(tab:GetText()) end
  if not tree and tooltip then tree = match(tooltipTitle(tooltip)) end
  return tree
end

function Tabs.Annotate(tab)
  if not enabled() or not GameTooltip or not GameTooltip.GetOwner
    or GameTooltip:GetOwner() ~= tab or (GameTooltip.IsShown and not GameTooltip:IsShown()) then
    return false
  end
  local _, class = UnitClass("player")
  local tree = treeFor(tab, class, GameTooltip)
  if not tree then return false end
  local previous = marked[GameTooltip]
  if previous and previous.owner == tab and previous.tree == tree then return false end
  marked[GameTooltip] = { owner = tab, tree = tree }
  SAK.TalentTooltips.AddTreeSummary(GameTooltip, class, tree)
  GameTooltip:Show()
  return true
end

local function euiText(class, tree, title)
  local data = SAK.ClassRoles.classes[class]
  local lines = { title, "", "|cffffd100Skills & More|r" }
  for _, spec in ipairs(tree.specs) do
    if #tree.specs > 1 then lines[#lines + 1] = "|cffffd100" .. data.specializations[spec] .. "|r" end
    lines[#lines + 1] = SAK.TalentTooltips.SpecializationText(class, spec)
  end
  return table.concat(lines, "\n\n")
end

local function onEnter(tab)
  if not enabled() then return end
  if EUI_ClassicSpellbook and tab.GetParent and tab:GetParent() == EUI_ClassicSpellbook
    and EllesmereUI and EllesmereUI.ShowWidgetTooltip then
    local _, class = UnitClass("player")
    local tree = treeFor(tab, class)
    if tree then
      EllesmereUI.ShowWidgetTooltip(tab, euiText(class, tree, tab.tooltip or tree.name),
        { anchor = "right", width = 380, justify = "LEFT" })
    end
    return
  end

  Tabs.Annotate(tab)
  if C_Timer and C_Timer.After then
    C_Timer.After(0, function() Tabs.Annotate(tab) end)
  end
end

local function hookTab(tab)
  if not tab or hooked[tab] or not tab.HookScript then return end
  if tab.IsForbidden and tab:IsForbidden() then return end
  if tab.GetScript and not tab:GetScript("OnEnter") then return end
  hooked[tab] = true
  tab:HookScript("OnEnter", onEnter)
end

function Tabs.Hook()
  if not enabled() then return end
  if not tooltipHooked and GameTooltip and GameTooltip.HookScript then
    tooltipHooked = true
    GameTooltip:HookScript("OnTooltipCleared", function(tooltip) marked[tooltip] = nil end)
  end

  local visited = 0
  local function visit(frame, depth)
    if not frame or depth > 6 or visited >= 400 then return end
    if frame.IsForbidden and frame:IsForbidden() then return end
    visited = visited + 1
    hookTab(frame)
    if frame.GetChildren then
      for _, child in ipairs({frame:GetChildren()}) do visit(child, depth + 1) end
    end
  end
  for _, frame in pairs({
    modern = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame,
    legacy = SpellBookFrame,
    eui = EUI_ClassicSpellbook,
  }) do visit(frame, 0) end
  for index = 1, 12 do hookTab(_G["SpellBookSkillLineTab" .. index]) end
end
