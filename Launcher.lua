-- Shared DataBroker launcher for minimap buttons and display addons.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Launcher = {}
SAK.Launcher = Launcher
local name = "SkillsAlreadyKnown"
local object

local function minimapSettings()
  local db = SAK.EnsureDB()
  if type(db.minimap) ~= "table" then
    db.minimap = { hide = false, minimapPos = 220 }
  end
  return db.minimap
end

local function library(id)
  return LibStub and LibStub(id, true)
end

local function onClick(_, button)
  if button == "RightButton" then
    SAK.ShowSummaryWindow()
  else
    SAK.RankPolicy.ShowSettings()
  end
end

local function onTooltipShow(tooltip)
  tooltip:AddLine("Skills & More", 1, 0.82, 0.05)
  tooltip:AddLine("By CryptoLogiq", 0.8, 0.8, 0.8)
  tooltip:AddLine("Clic gauche : options", 1, 1, 1)
  tooltip:AddLine("Clic droit : résumé et commandes", 1, 1, 1)
end

function Launcher.IsVisible()
  return minimapSettings().hide ~= true
end

function Launcher.Refresh()
  local broker = library("LibDataBroker-1.1")
  local icons = library("LibDBIcon-1.0")
  if not broker or not icons then
    return false
  end

  if not object then
    object = broker:GetDataObjectByName(name) or broker:NewDataObject(name, {
      type = "launcher",
      label = "Skills & More",
      text = "Skills & More",
      icon = "Interface\\AddOns\\SkillsAlreadyKnown\\assets\\launcher-icon.tga",
      OnClick = onClick,
      OnTooltipShow = onTooltipShow,
    })
  end

  local settings = minimapSettings()
  if not icons:IsRegistered(name) then
    icons:Register(name, object, settings)
  end
  if settings.hide then
    icons:Hide(name)
  else
    icons:Show(name)
  end
  return true
end

function Launcher.SetVisible(visible)
  minimapSettings().hide = visible ~= true
  Launcher.Refresh()
  if SAK.Settings then
    SAK.Settings.Notify()
  end
end

function Launcher.ResetDefaults()
  local settings = minimapSettings()
  settings.hide = false
  settings.minimapPos = 220
  local icons = library("LibDBIcon-1.0")
  if icons and icons:IsRegistered(name) then
    icons:Refresh(name, settings)
  end
  Launcher.Refresh()
end

function Launcher.Initialize()
  local icons = library("LibDBIcon-1.0")
  if object and icons and icons:IsRegistered(name) then
    return true
  end
  return Launcher.Refresh()
end
