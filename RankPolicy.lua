-- Conseils d'achat selon les roles choisis et les donnees de sorts.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local playerRoles = SAK.PlayerRoles
local Policy = {
  Specs = playerRoles.Specs,
  Roles = playerRoles.Roles,
  RoleDescription = playerRoles.RoleDescription,
  RoleLabels = playerRoles.RoleLabels,
  SpecsForRole = playerRoles.SpecsForRole,
  IsRoleEnabled = playerRoles.IsRoleEnabled,
  SelectedSpec = playerRoles.SelectedSpec,
  EcoEnabled = playerRoles.EcoEnabled,
  BuyRankEnabled = playerRoles.BuyRankEnabled,
  OptionalEnabled = playerRoles.OptionalEnabled,
  GetProfile = playerRoles.GetProfile,
  SetRoleEnabled = playerRoles.SetRoleEnabled,
  SetRole = playerRoles.SetRole,
  SetSpecialization = playerRoles.SetSpecialization,
  SetEco = playerRoles.SetEco,
  SetOptional = playerRoles.SetOptional,
  SetBuyRank = playerRoles.SetBuyRank,
}
SAK.RankPolicy = Policy

local order = playerRoles.Order
local rules = SAK.RankOneRules

local function matchingRoleSelection(class)
  local profile = Policy.GetProfile()
  return profile and profile.class == class and not Policy.IsRoleEnabled("pvp")
end

local function roleAllowsRule(role, rule)
  local allowed = rule.contexts[role]
  if allowed == true then
    return true
  end
  return type(allowed) == "table" and allowed[Policy.SelectedSpec(role)]
end

local function everyRoleAllowsRule(rule)
  for _, role in ipairs(order) do
    if Policy.IsRoleEnabled(role) and not roleAllowsRule(role, rule) then
      return false
    end
  end
  return true
end

local function rankOneAdvice(class, family)
  if not matchingRoleSelection(class) then
    return nil
  end

  for spellID, rule in pairs(rules[class] or {}) do
    if family.ids[spellID] and everyRoleAllowsRule(rule) then
      return rule.reason
    end
  end
end

function Policy.RankOneAdvice(class, family)
  if not Policy.EcoEnabled() then
    return nil
  end
  return rankOneAdvice(class, family)
end

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function buildPurchaseCatalogue()
  local catalogue = {}
  local classes = SAK.LevelingAdvice or {}

  for _, class in ipairs(sortedKeys(classes)) do
    for _, spec in ipairs(sortedKeys(classes[class])) do
      local data = classes[class][spec]
      for _, spell in ipairs(data.spells) do
        catalogue[#catalogue + 1] = {
          class = class,
          spec = spec,
          role = data.role,
          baseID = spell.baseID,
          minRank = spell.minRank,
          maxRank = spell.maxRank,
          reason = spell.name .. " : " .. spell.reason,
          name = spell.name,
          category = spell.category,
          source = data.source,
        }
      end
    end
  end

  return catalogue
end

-- La table maintenue reste dans data/ ; cet index n'existe qu'en memoire.
local purchaseCatalogue = buildPurchaseCatalogue()
Policy.PurchaseCatalogue = purchaseCatalogue

local spellNames = {}

local function spellName(spellID)
  if spellNames[spellID] then
    return spellNames[spellID]
  end

  if C_Spell and C_Spell.GetSpellName then
    local ok, name = pcall(C_Spell.GetSpellName, spellID)
    if ok and type(name) == "string" and name ~= "" then
      spellNames[spellID] = name
      return name
    end
  end

  if GetSpellInfo then
    local ok, name = pcall(GetSpellInfo, spellID)
    if ok and type(name) == "string" and name ~= "" then
      spellNames[spellID] = name
      return name
    end
  end
end

local function sameFamily(family, baseID)
  if family.ids[baseID] then
    return true
  end

  local baseName = spellName(baseID)
  if not baseName then
    return false
  end

  -- Comparer les noms resolus par ID, jamais le texte tronque d'une ligne.
  for spellID in pairs(family.ids) do
    if spellName(spellID) == baseName then
      return true
    end
  end
  return false
end

local function ruleMatchesPurchase(rule, class, role, rank, family)
  return rule.class == class
    and rule.role == role
    and rule.spec == Policy.SelectedSpec(role)
    and rank >= rule.minRank
    and (not rule.maxRank or rank <= rule.maxRank)
    and sameFamily(family, rule.baseID)
end

local function adviceScope(rankOneOnly, extraRanksOnly)
  if rankOneOnly then
    return "rank-one"
  elseif extraRanksOnly then
    return "higher-ranks"
  end
  return "spell"
end

local function catalogueAdvice(class, family, rank)
  if not matchingRoleSelection(class) then
    return nil
  end

  local reasons = {}
  local seenReasons = {}
  local extraRanksOnly = true
  local rankOneOnly = true

  for _, role in ipairs(order) do
    if Policy.IsRoleEnabled(role) then
      local matched = false
      for _, rule in ipairs(purchaseCatalogue) do
        if ruleMatchesPurchase(rule, class, role, rank, family) then
          matched = true
          if rule.minRank <= 1 then
            extraRanksOnly = false
          end
          if rule.category ~= "rang_1_suffisant" then
            rankOneOnly = false
          end
          if not seenReasons[rule.reason] then
            reasons[#reasons + 1] = rule.reason
            seenReasons[rule.reason] = true
          end
        end
      end

      if not matched then
        return nil
      end
    end
  end

  if #reasons > 0 then
    return table.concat(reasons, "\n"), adviceScope(rankOneOnly, extraRanksOnly)
  end
end

local function expandRankOneAnchors(class, family)
  local expanded = { ids = {} }
  for spellID in pairs(family.ids) do
    expanded.ids[spellID] = true
  end
  for baseID in pairs(rules[class] or {}) do
    if sameFamily(expanded, baseID) then
      expanded.ids[baseID] = true
    end
  end
  return expanded
end

function Policy.OptionalAdvice(class, family, rank)
  if not Policy.OptionalEnabled() then
    return nil
  end

  local level = UnitLevel and UnitLevel("player")
  if type(level) ~= "number" or level < 1 or level >= 60 then
    return nil
  end

  if rank > 1 then
    local reason = rankOneAdvice(class, family)
    if reason then
      return L("Rangs supplémentaires facultatifs pendant le leveling. ") .. reason, "rank-one"
    end
  end

  return catalogueAdvice(class, family, rank)
end

function Policy.UpgradeCanWait(class, family, rank)
  local level = UnitLevel and UnitLevel("player")
  if type(level) ~= "number" or level >= 60 then
    return nil
  end

  local expanded = expandRankOneAnchors(class, family)
  if rank > 1 then
    local reason = rankOneAdvice(class, expanded)
    if reason then
      return reason, "rank-one"
    end
  end

  -- Masquer un badge facultatif ne rend pas l'achat obligatoire.
  return catalogueAdvice(class, expanded, rank)
end

local function resolveSpellRank(spellID, rank)
  if not rank and C_Spell and C_Spell.GetSpellSubtext then
    local ok, subtext = pcall(C_Spell.GetSpellSubtext, spellID)
    if ok then
      rank = SAK.RankNumber(subtext)
    end
  end
  if not rank and GetSpellInfo then
    local ok, _, subtext = pcall(GetSpellInfo, spellID)
    if ok then
      rank = SAK.RankNumber(subtext)
    end
  end
  return rank
end

function Policy.PurchaseAdvice(class, spellID, rank)
  if type(spellID) ~= "number" or spellID <= 0 then
    return nil
  end

  local family = expandRankOneAnchors(class, { ids = { [spellID] = true } })
  rank = resolveSpellRank(spellID, rank)

  local optional, scope = Policy.OptionalAdvice(class, family, rank or 1)
  if optional then
    return "optional", optional, scope
  end

  if rank == 1 then
    local eco = Policy.RankOneAdvice(class, family)
    if eco then
      return "eco", eco
    end
  end
end

function Policy.ShowSettings(firstUse)
  if InCombatLockdown and InCombatLockdown() then
    Policy.pending = true
    Policy.pendingFirstUse = firstUse == true
    print(L("|cffffcc00Skills & More:|r configuration disponible après le combat."))
    return
  end

  if SAK.Settings then
    return SAK.Settings.Open(firstUse)
  end
end

local startupChecked = false

function Policy.MaybePrompt()
  if Policy.pending then
    local firstUse = Policy.pendingFirstUse
    Policy.pending = nil
    Policy.pendingFirstUse = nil
    if firstUse then
      startupChecked = true
    end
    Policy.ShowSettings(firstUse)
    return
  end

  if startupChecked then
    return
  end
  startupChecked = true

  if not Policy.GetProfile() then
    if SAK.PlayerRoles then
      SAK.PlayerRoles.InitializeFirstUse()
    end
    Policy.ShowSettings(true)
  end
end

if SAK.Localization then
  SAK.Localization.RegisterInitializer(function()
    -- Keep the existing catalogue reference used by rank comparisons.
    for index = #purchaseCatalogue, 1, -1 do purchaseCatalogue[index] = nil end
    for _, rule in ipairs(buildPurchaseCatalogue()) do
      purchaseCatalogue[#purchaseCatalogue + 1] = rule
    end
  end)
end
