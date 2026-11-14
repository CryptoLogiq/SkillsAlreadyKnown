-- Roles, specialisations et preferences du personnage.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local PlayerRoles = {
  Specs = {},
  Roles = {},
  Order = { "tank", "heal", "dps", "pvp" },
}
SAK.PlayerRoles = PlayerRoles

local classRoles = SAK.ClassRoles
local specsByRole = {}

for class, data in pairs(classRoles.classes) do
  PlayerRoles.Specs[class] = data.specializations
  specsByRole[class] = data.roles
end

for role, data in pairs(classRoles.roles) do
  PlayerRoles.Roles[role] = data.name
end

for activity, data in pairs(classRoles.activities) do
  PlayerRoles.Roles[activity] = data.name
end

local function getPlayerClass()
  if UnitClass then
    local _, class = UnitClass("player")
    return class
  end
end

function PlayerRoles.RoleDescription(role)
  local data = classRoles.roles[role] or classRoles.activities[role]
  return data and data.description or ""
end

function PlayerRoles.RoleLabels()
  local texture = "|TInterface\\LFGFrame\\UI-LFG-ICON-ROLES:16:16:0:0:256:256:"
  return {
    tank = texture .. "0:66:67:132|t Tank",
    heal = texture .. "67:132:0:66|t " .. L("Heal"),
    dps = texture .. "67:132:67:132|t DPS",
    pvp = "|TInterface\\Icons\\Ability_DualWield:16:16|t PvP",
  }
end

function PlayerRoles.SpecsForRole(role)
  local class = getPlayerClass()
  local labels = PlayerRoles.Specs[class] or {}
  local choices = {}

  if role == "pvp" then
    for spec, label in pairs(labels) do
      choices[spec] = label
    end
  else
    local roleSpecs = (specsByRole[class] or {})[role] or {}
    for _, spec in ipairs(roleSpecs) do
      choices[spec] = labels[spec]
    end
  end

  return choices
end

local function getSingleSpecialization(role)
  local choices = PlayerRoles.SpecsForRole(role)
  local spec = next(choices)
  if spec and not next(choices, spec) then
    return spec
  end
end

local function getLegacyRole(settings, class)
  if settings.role then
    return settings.role
  end

  if not PlayerRoles.Specs[class][settings.spec] then
    return nil
  end

  if settings.pvp then
    return "pvp"
  elseif settings.tank or settings.spec == "protection" or settings.spec == "guardian" then
    return "tank"
  elseif settings.healer or settings.spec == "restoration" or settings.spec == "holy" or settings.spec == "discipline" then
    return "heal"
  end

  return "dps"
end

local function migrateLegacyRoles(settings, class)
  local role = getLegacyRole(settings, class)
  settings.roles = {}

  if PlayerRoles.Roles[role] and next(PlayerRoles.SpecsForRole(role)) then
    local validSpec = PlayerRoles.SpecsForRole(role)[settings.spec]
    settings.roles[role] = {
      enabled = true,
      spec = validSpec and settings.spec or getSingleSpecialization(role),
    }
  end

  settings.healer = nil
  settings.tank = nil
  settings.pvp = nil
end

local function getSavedSettings()
  local settings = SAK.EnsureDB().levelingProfile
  local class = getPlayerClass()

  if type(settings) ~= "table" or settings.class ~= class or not PlayerRoles.Specs[class] then
    return nil
  end

  -- Older builds saved automatic suggestions as active choices.
  if settings.initialSuggestion and not settings.confirmed then
    local db = SAK.EnsureDB()
    db.levelingDraft = db.levelingDraft or settings
    db.levelingProfile = nil
    db.profilePromptSeen = nil
    return nil
  end

  if type(settings.roles) ~= "table" then
    migrateLegacyRoles(settings, class)
  end

  return settings
end

function PlayerRoles.IsRoleEnabled(role)
  local settings = getSavedSettings()
  local choice = settings and settings.roles[role]
  return type(choice) == "table"
    and choice.enabled == true
    and next(PlayerRoles.SpecsForRole(role)) ~= nil
end

function PlayerRoles.SelectedSpec(role)
  local settings = getSavedSettings()
  local choice = settings and settings.roles[role]

  if type(choice) == "table" and PlayerRoles.SpecsForRole(role)[choice.spec] then
    return choice.spec
  end
end

local function synchronizeActiveRole(settings)
  -- Ces deux champs gardent la compatibilite avec les anciennes sauvegardes.
  if not PlayerRoles.IsRoleEnabled(settings.role) then
    settings.role = nil
    for _, role in ipairs(PlayerRoles.Order) do
      if PlayerRoles.IsRoleEnabled(role) then
        settings.role = role
        break
      end
    end
  end

  settings.spec = settings.role and PlayerRoles.SelectedSpec(settings.role) or nil
end

function PlayerRoles.GetProfile()
  local settings = getSavedSettings()
  if not settings then
    return nil
  end

  synchronizeActiveRole(settings)
  return settings.role and settings or nil
end

local function notifyRoleChanges()
  SAK.EnsureDB().profilePromptSeen = true

  if SAK.Settings then
    SAK.Settings.Notify()
  end
  if SAK.ClassTrainer and SAK.ClassTrainer.Refresh then
    SAK.ClassTrainer.Refresh()
  end
  if SAK.SpellBook then
    SAK.SpellBook.MarkDirty()
    SAK.SpellBook.Refresh()
  end
end

function PlayerRoles.SetRoleEnabled(role, enabled)
  local class = getPlayerClass()
  if not PlayerRoles.Roles[role] or not PlayerRoles.Specs[class] or not next(PlayerRoles.SpecsForRole(role)) then
    return false
  end

  local settings = getSavedSettings() or { class = class, roles = {}, eco = true }
  SAK.EnsureDB().levelingProfile = settings

  local choice = settings.roles[role]
  if type(choice) ~= "table" then
    choice = {}
    settings.roles[role] = choice
  end

  choice.enabled = enabled == true
  if not PlayerRoles.SpecsForRole(role)[choice.spec] then
    choice.spec = getSingleSpecialization(role)
  end
  if enabled then
    settings.role = role
  end

  synchronizeActiveRole(settings)
  notifyRoleChanges()
  return true
end

function PlayerRoles.SetRole(role)
  if not PlayerRoles.Roles[role] or not next(PlayerRoles.SpecsForRole(role)) then
    return false
  end

  local settings = getSavedSettings()
  if settings then
    for _, choice in pairs(settings.roles) do
      if type(choice) == "table" then
        choice.enabled = false
      end
    end
  end

  return PlayerRoles.SetRoleEnabled(role, true)
end

function PlayerRoles.SetSpecialization(role, spec)
  if not PlayerRoles.IsRoleEnabled(role) or not PlayerRoles.SpecsForRole(role)[spec] then
    return false
  end

  local settings = getSavedSettings()
  settings.roles[role].spec = spec
  synchronizeActiveRole(settings)
  notifyRoleChanges()
  return true
end

local function preferenceEnabled(key)
  local settings = getSavedSettings()
  return not settings or settings[key] ~= false
end

local function setPreference(key, enabled)
  local settings = getSavedSettings()
  if not settings then
    return false
  end

  settings[key] = enabled == true
  notifyRoleChanges()
  return true
end

function PlayerRoles.EcoEnabled()
  return preferenceEnabled("eco")
end

function PlayerRoles.OptionalEnabled()
  return preferenceEnabled("optional")
end

function PlayerRoles.BuyRankEnabled()
  return preferenceEnabled("buyRank")
end

function PlayerRoles.SetEco(enabled)
  return setPreference("eco", enabled)
end

function PlayerRoles.SetOptional(enabled)
  return setPreference("optional", enabled)
end

function PlayerRoles.SetBuyRank(enabled)
  return setPreference("buyRank", enabled)
end

local function levelingSpecialization(class)
  local advice = SAK.LevelingRecommendations and SAK.LevelingRecommendations[class]
  return advice and advice.solo[1]
end

local function dominantTalentTree(class)
  if not GetTalentTabInfo then
    return nil
  end

  local group = GetActiveTalentGroup and GetActiveTalentGroup(false)
  local bestTree, mostPoints, tied = nil, 0, false
  for index, tree in ipairs(classRoles.classes[class].talentTrees) do
    local ok, tabIDOrName, _, legacyPoints, _, modernPoints = pcall(GetTalentTabInfo, index, false, false, group)
    -- Forever uses the fifth return value; older Classic APIs use the third.
    local points = modernPoints
    if type(tabIDOrName) == "string" then
      points = legacyPoints
    end
    if ok and type(points) == "number" and points > 0 then
      if points > mostPoints then
        bestTree, mostPoints, tied = tree, points, false
      elseif points == mostPoints then
        tied = true
      end
    end
  end

  if not tied then
    return bestTree
  end
end

function PlayerRoles.InitializeFirstUse()
  local db = SAK.EnsureDB()
  local class = getPlayerClass()
  if db.levelingDraft or db.levelingProfile ~= nil or not classRoles.classes[class] then
    return false
  end

  local recommended = levelingSpecialization(class)
  local level = UnitLevel and UnitLevel("player")
  local tree
  if level and level >= 10 then
    tree = dominantTalentTree(class)
  end

  local spec = recommended
  if tree then
    spec = tree.specs[1]
  end
  if not spec then
    return false
  end

  -- Farouche shares one tree: prefer DPS, without inferring tanking from points alone.
  local role
  for _, candidate in ipairs({ "dps", "tank", "heal" }) do
    if PlayerRoles.SpecsForRole(candidate)[spec] then
      role = candidate
      break
    end
  end
  if not role then
    return false
  end

  db.levelingDraft = {
    class = class,
    role = role,
    spec = spec,
    roles = { [role] = { enabled = true, spec = spec } },
    eco = true,
    initialSuggestion = tree and "talents" or "leveling",
  }
  return true
end

local function selectionDraft()
  local draft = SAK.EnsureDB().levelingDraft
  if type(draft) == "table" and draft.class == getPlayerClass() then
    return draft
  end
end

function PlayerRoles.GetSelection()
  return selectionDraft() or getSavedSettings()
end

function PlayerRoles.IsSelectionRoleEnabled(role)
  local selection = PlayerRoles.GetSelection()
  local choice = selection and selection.roles[role]
  return choice and choice.enabled == true or false
end

function PlayerRoles.SelectionSpec(role)
  local selection = PlayerRoles.GetSelection()
  local choice = selection and selection.roles[role]
  return choice and choice.spec
end

local function notifyDraftChanges()
  if SAK.Settings then
    SAK.Settings.Notify()
  end
end

function PlayerRoles.SetSelectionRole(role, enabled)
  local draft = selectionDraft()
  if not draft then
    return PlayerRoles.SetRoleEnabled(role, enabled)
  end
  if not next(PlayerRoles.SpecsForRole(role)) then
    return false
  end

  local choice = draft.roles[role] or {}
  draft.roles[role] = choice
  choice.enabled = enabled == true
  if not PlayerRoles.SpecsForRole(role)[choice.spec] then
    choice.spec = getSingleSpecialization(role)
  end
  notifyDraftChanges()
  return true
end

function PlayerRoles.SetSelectionSpec(role, spec)
  local draft = selectionDraft()
  if not draft then
    return PlayerRoles.SetSpecialization(role, spec)
  end
  if not PlayerRoles.IsSelectionRoleEnabled(role) or not PlayerRoles.SpecsForRole(role)[spec] then
    return false
  end

  draft.roles[role].spec = spec
  notifyDraftChanges()
  return true
end

function PlayerRoles.SelectionPreference(key)
  local selection = PlayerRoles.GetSelection()
  return not selection or selection[key] ~= false
end

function PlayerRoles.SetSelectionPreference(key, enabled)
  if key ~= "eco" and key ~= "optional" and key ~= "buyRank" then
    return false
  end
  local draft = selectionDraft()
  if not draft then
    return setPreference(key, enabled)
  end
  draft[key] = enabled == true
  notifyDraftChanges()
  return true
end

function PlayerRoles.SelectionSnapshot()
  local draft = selectionDraft()
  if not draft then
    return nil
  end

  local snapshot = {
    class = draft.class,
    roles = {},
    eco = draft.eco ~= false,
    optional = draft.optional ~= false,
    buyRank = draft.buyRank ~= false,
  }
  for _, role in ipairs(PlayerRoles.Order) do
    local choice = draft.roles[role]
    if choice and choice.enabled then
      if not PlayerRoles.SpecsForRole(role)[choice.spec] then
        return nil
      end
      snapshot.roles[role] = { enabled = true, spec = choice.spec }
      snapshot.role = snapshot.role or role
    end
  end
  if not snapshot.role then
    return nil
  end
  snapshot.spec = snapshot.roles[snapshot.role].spec
  return snapshot
end

function PlayerRoles.ConfirmSelection(snapshot)
  if not selectionDraft() or not snapshot or snapshot.class ~= getPlayerClass() then
    return false
  end
  if InCombatLockdown and InCombatLockdown() then
    return false
  end

  local db = SAK.EnsureDB()
  snapshot.confirmed = true
  db.levelingProfile = snapshot
  db.levelingDraft = nil
  db.replayStartupOnLogin = nil
  notifyRoleChanges()
  return true
end

if SAK.Localization then
  SAK.Localization.RegisterTable(PlayerRoles.Roles)
end
