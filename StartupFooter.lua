-- Startup buttons use the same parent and template as AceGUI's Close button.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Footer = {}
SAK.StartupFooter = Footer
local app = "SkillsAlreadyKnown"
local owner, statusBar, later, confirm
local elapsed = 0

local function releaseOwner()
  if later then
    later:Hide()
    confirm:Hide()
  end
  if statusBar then
    statusBar:Show()
  end
  owner, statusBar = nil, nil
end

local function createButtons(root)
  if not later then
    later = CreateFrame("Button", nil, root, "UIPanelButtonTemplate")
    later:SetText("Plus tard")
    later:SetHeight(20)
    later:SetScript("OnClick", function() SAK.Settings.CloseStartup() end)

    confirm = CreateFrame("Button", nil, root, "UIPanelButtonTemplate")
    confirm:SetText("Valider mes choix")
    confirm:SetHeight(20)
    confirm:SetScript("OnClick", function() SAK.Settings.ConfirmSelection() end)
  end
  later:SetParent(root)
  confirm:SetParent(root)
  later:ClearAllPoints()
  later:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", 20, 17)
  confirm:ClearAllPoints()
  confirm:SetPoint("BOTTOMLEFT", later, "BOTTOMRIGHT", 10, 0)
  confirm:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT", -137, 17)
end

function Footer.Refresh()
  local dialog = LibStub and LibStub("AceConfigDialog-3.0", true)
  local widget = dialog and dialog.OpenFrames and dialog.OpenFrames[app]
  local root = widget and widget.frame
  if not root or not root:IsShown() then
    releaseOwner()
    return
  end

  if owner ~= root then
    releaseOwner()
    owner = root
    statusBar = widget.statustext and widget.statustext:GetParent()
    createButtons(root)
  end
  if statusBar then
    statusBar:Hide()
  end

  local draft = SAK.EnsureDB().levelingDraft
  if not draft then
    later:Hide()
    confirm:Hide()
    return
  end

  later:SetWidth(math.max(70, (root:GetWidth() - 167) * 0.38))
  for _, button in ipairs({later, confirm}) do
    button:SetFrameStrata(root:GetFrameStrata())
    button:SetFrameLevel(root:GetFrameLevel() + 3)
    button:Show()
  end
  local inCombat = InCombatLockdown and InCombatLockdown()
  confirm:SetEnabled(not inCombat and SAK.PlayerRoles.SelectionSnapshot() ~= nil)
end

function Footer.IsVisible()
  return owner and owner:IsShown() and later and later:IsShown() or false
end

-- This driver stays active even if the options frame is shown after Config.Open.
-- Restore the shared status bar as soon as AceGUI releases our window.
local driver = CreateFrame("Frame", nil, UIParent)
driver:SetScript("OnUpdate", function(_, delta)
  elapsed = elapsed + delta
  if elapsed >= 0.15 then
    elapsed = 0
    Footer.Refresh()
  end
end)
