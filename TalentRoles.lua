-- Place les roles a cote des titres de talents, sans modifier les boutons du jeu.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local TalentRoles = {}
SAK.TalentRoles = TalentRoles

local overlays = {}
local hookedFrames = setmetatable({}, { __mode = "k" })
local driver
local elapsed = 0
local matchedHeaders = 0
local cachedRoot, cachedTitles

local function isVisible(frame)
  return frame
    and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function getTalentFrame()
  return PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
end

local function treeSupportsRole(classData, tree, role)
  for _, spec in ipairs(classData.roles[role] or {}) do
    for _, treeSpec in ipairs(tree.specs) do
      if spec == treeSpec then
        return true
      end
    end
  end
  return false
end

function TalentRoles.RolesForTree(class, index)
  local classData = SAK.ClassRoles.classes[class]
  local tree = classData and classData.talentTrees and classData.talentTrees[index]
  if not tree then
    return nil
  end

  local roles = {}
  for _, role in ipairs({ "tank", "heal", "dps" }) do
    if treeSupportsRole(classData, tree, role) then
      roles[#roles + 1] = role
    end
  end
  return roles, tree
end

local function getTitleNames(index, tree)
  local names = { [SAK.NormalizeText(SAK.CleanText(tree.name))] = true }
  if SAK.Localization then
    for _, name in ipairs(SAK.Localization.NameVariants(tree.name)) do
      names[SAK.NormalizeText(SAK.CleanText(name))] = true
    end
  end
  if GetTalentTabInfo then
    local ok, first, second = pcall(GetTalentTabInfo, index)
    local name = type(first) == "string" and first or second
    if ok and type(name) == "string" and name ~= "" then
      names[SAK.NormalizeText(SAK.CleanText(name))] = true
    end
  end
  return names
end

local function findTitles(root, wanted)
  local titles = {}
  local visited = 0

  local function visit(frame, depth)
    if depth > 8 or visited >= 800 or not isVisible(frame) then
      return
    end
    visited = visited + 1

    if frame.GetRegions then
      for _, region in ipairs({ frame:GetRegions() }) do
        if region.GetText and isVisible(region) then
          local text = region:GetText()
          local name = type(text) == "string" and SAK.NormalizeText(SAK.CleanText(text))
          for index, names in ipairs(wanted) do
            if names[name] and not titles[index] then
              titles[index] = region
            end
          end
        end
      end
    end

    if frame.GetChildren then
      for _, child in ipairs({ frame:GetChildren() }) do
        visit(child, depth + 1)
      end
    end
  end

  visit(root, 0)
  return titles
end

local function cachedTitlesMatch(root, wanted)
  if cachedRoot ~= root or not cachedTitles then
    return false
  end

  for index, names in ipairs(wanted) do
    local title = cachedTitles[index]
    if not isVisible(title) or not title.GetText then
      return false
    end
    if not names[SAK.NormalizeText(SAK.CleanText(title:GetText() or ""))] then
      return false
    end
  end
  return true
end

local function getTitles(root, classData)
  local wanted = {}
  for index, tree in ipairs(classData.talentTrees) do
    wanted[index] = getTitleNames(index, tree)
  end

  if not cachedTitlesMatch(root, wanted) then
    cachedRoot = root
    cachedTitles = findTitles(root, wanted)
  end
  return cachedTitles
end

local function hideAll()
  for _, overlay in pairs(overlays) do
    overlay:Hide()
  end
end

local function createOverlay()
  local overlay = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  overlay:SetSize(200, 40)
  overlay:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  overlay:EnableMouse(true)
  overlay.text = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  overlay.text:SetPoint("TOPLEFT", overlay, "TOPLEFT", 8, -4)
  overlay.text:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", -8, 4)
  overlay.text:SetJustifyH("LEFT")
  overlay.text:SetTextColor(1, 1, 1)
  overlay.text:SetShadowColor(0, 0, 0, 1)
  overlay.text:SetShadowOffset(1, -1)
  overlay.leveling = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
  overlay.leveling:SetSize(78, 16)
  overlay.leveling:SetPoint("BOTTOMLEFT", overlay, "TOPLEFT", 6, -3)
  overlay.leveling:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  overlay.leveling:SetBackdropColor(0.06, 0.04, 0.01, 0.95)
  overlay.leveling:SetBackdropBorderColor(1, 0.78, 0.15, 1)
  overlay.leveling:EnableMouse(false)
  overlay.leveling.text = overlay.leveling:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  overlay.leveling.text:SetAllPoints(overlay.leveling)
  overlay.leveling.text:SetText("LEVELING")
  overlay.leveling.text:SetTextColor(1, 0.82, 0.05)
  overlay:SetScript("OnEnter", SAK.TalentTooltips.Show)
  overlay:SetScript("OnLeave", SAK.TalentTooltips.Hide)
  return overlay
end

TalentRoles.CreateRoleDisplay = createOverlay

local function positionOverlay(overlay, title)
  local offset = 12
  if title.GetWidth and title.GetStringWidth and title.GetJustifyH then
    local spareWidth = math.max(0, title:GetWidth() - title:GetStringWidth())
    local alignment = title:GetJustifyH()
    if alignment == "LEFT" then
      offset = offset - spareWidth
    elseif alignment == "CENTER" then
      offset = offset - spareWidth / 2
    end
  end

  overlay:ClearAllPoints()
  overlay:SetPoint("LEFT", title, "RIGHT", offset, 0)
end

local function prepareOverlay(overlay, root)
  local level = 0
  local strata = "HIGH"
  local current = root

  for _ = 1, 16 do
    if not current then
      break
    end
    if current.GetFrameLevel then
      level = math.max(level, current:GetFrameLevel())
    end

    local candidate = current.GetFrameStrata and current:GetFrameStrata()
    if candidate == "DIALOG" or candidate == "FULLSCREEN" or candidate == "FULLSCREEN_DIALOG" then
      strata = candidate
    end
    current = current.GetParent and current:GetParent()
  end

  overlay:SetFrameStrata(strata)
  overlay:SetFrameLevel(math.min(level + 20, 65535))
  overlay.leveling:SetFrameStrata(strata)
  overlay.leveling:SetFrameLevel(math.min(level + 21, 65535))
  if root.GetEffectiveScale and UIParent.GetEffectiveScale then
    overlay:SetScale(root:GetEffectiveScale() / UIParent:GetEffectiveScale())
  end
end

local function showTreeRoles(index, class, roles, tree, title, root, labels)
  local overlay = overlays[index]
  if not overlay then
    overlay = createOverlay()
    overlays[index] = overlay
  end

  local text = {}
  for _, role in ipairs(roles) do
    text[#text + 1] = labels[role]:gsub(":16:16:", ":32:32:", 1)
  end

  overlay.roles = roles
  overlay.treeName = tree.name
  overlay.class = class
  overlay.specs = tree.specs
  local showLeveling = SAK.TalentTooltips.IsLevelingTree(class, tree.specs)
    and (not SAK.DisplayEnabled or SAK.DisplayEnabled("icons"))
  overlay.leveling:SetShown(showLeveling)
  overlay.text:SetText(table.concat(text, "  "))
  overlay:SetSize(math.max(72, overlay.text:GetStringWidth() + 20), 40)
  local outlines = not SAK.DisplayEnabled or SAK.DisplayEnabled("outlines")
  local backgrounds = not SAK.DisplayEnabled or SAK.DisplayEnabled("backgrounds")
  overlay:SetBackdropBorderColor(1, 0.78, 0.15, outlines and 1 or 0)
  overlay:SetBackdropColor(0.06, 0.04, 0.01, backgrounds and 0.65 or 0)
  positionOverlay(overlay, title)
  prepareOverlay(overlay, root)
  overlay:Show()
end

function TalentRoles.Refresh()
  local root = getTalentFrame()
  if not isVisible(root) or (SAK.DisplayEnabled and (not SAK.DisplayEnabled("text") or not SAK.DisplayEnabled("iconsTalents"))) then
    hideAll()
    return
  end

  local _, class = UnitClass("player")
  local classData = SAK.ClassRoles.classes[class]
  if not classData or not classData.talentTrees then
    hideAll()
    return
  end

  local titles = getTitles(root, classData)
  local labels = SAK.RankPolicy.RoleLabels()
  if SAK.DisplayEnabled and not SAK.DisplayEnabled("icons") then
    for role, label in pairs(labels) do
      labels[role] = label:gsub("|T.-|t%s*", "")
    end
  end
  matchedHeaders = 0

  for index in ipairs(classData.talentTrees) do
    local roles, tree = TalentRoles.RolesForTree(class, index)
    local title = titles[index]
    if title and roles and #roles > 0 then
      showTreeRoles(index, class, roles, tree, title, root, labels)
      matchedHeaders = matchedHeaders + 1
    elseif overlays[index] then
      overlays[index]:Hide()
    end
  end
end

local function createDriver()
  local frame = CreateFrame("Frame")
  frame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.3 then
      elapsed = 0
      TalentRoles.Refresh()
    end
  end)
  frame:Hide()
  return frame
end

function TalentRoles.Hook()
  local root = getTalentFrame()
  if not root then
    return
  end
  if not driver then
    driver = createDriver()
  end

  if not hookedFrames[root] and root.HookScript then
    hookedFrames[root] = true
    root:HookScript("OnShow", function()
      driver:Show()
      TalentRoles.Refresh()
    end)
    root:HookScript("OnHide", function()
      driver:Hide()
      hideAll()
    end)
  end

  driver:SetShown(isVisible(root) == true)
  TalentRoles.Refresh()
end

function TalentRoles.DebugText()
  return "Talent roles: nativeVisible=" .. tostring(isVisible(getTalentFrame()) == true)
    .. " matchedHeaders=" .. matchedHeaders
end
