-- Verifie les rangs accessibles sans embarquer les donnees privees de recherche.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Availability = {}
SAK.RankAvailability = Availability

local knownSpell = SAK.IsPlayerSpellKnown
local observedRevision = 0
local spellNames = {}
local cache = { revision = -1, candidates = {} }

local function markSpellBookDirty()
  if SAK.SpellBook then
    SAK.SpellBook.MarkDirty()
  end
end

local function spellName(spellID)
  if spellNames[spellID] then
    return spellNames[spellID]
  end

  local getName = C_Spell and C_Spell.GetSpellName or GetSpellInfo
  if not getName then
    return nil
  end

  local ok, name = pcall(getName, spellID)
  if ok and type(name) == "string" and name ~= "" then
    spellNames[spellID] = SAK.NormalizeText(name)
    return spellNames[spellID]
  end
end

function Availability.Observe(service)
  if not service or type(service.spellID) ~= "number" or service.spellID <= 0 then
    return
  end

  local rank = SAK.RankNumber(service.subText)
  local level = tonumber(service.levelReq)
  local _, class = UnitClass("player")
  if not class or not rank or not level then
    return
  end

  local db = SAK.EnsureDB()
  db.observedTrainerRanks = db.observedTrainerRanks or {}
  db.observedTrainerRanks[class] = db.observedTrainerRanks[class] or {}

  local savedRanks = db.observedTrainerRanks[class]
  local previous = savedRanks[service.spellID]
  if not previous or previous.rank ~= rank or previous.level ~= level then
    savedRanks[service.spellID] = { rank = rank, level = level }
    observedRevision = observedRevision + 1
    markSpellBookDirty()
  end
end

local function collectProviderRanks(source)
  local candidates = {}
  for level, spells in pairs(type(source) == "table" and source or {}) do
    if type(level) == "number" and type(spells) == "table" then
      for spellID, data in pairs(spells) do
        if type(spellID) == "number" and type(data) == "table" then
          candidates[#candidates + 1] = {
            id = spellID,
            level = level,
            rank = data.rank,
            requires = data.requires,
            race = data.race,
            faction = data.faction,
            provider = "TrainerSpells",
          }
        end
      end
    end
  end
  return candidates
end

local function appendObservedRanks(candidates, class)
  local savedRanks = SAK.EnsureDB().observedTrainerRanks
  for spellID, data in pairs(savedRanks and savedRanks[class] or {}) do
    candidates[#candidates + 1] = {
      id = spellID,
      level = data.level,
      rank = data.rank,
      provider = "observed trainer",
    }
  end
end

local function getCandidates(class)
  local source = type(TrainerSpellsBuiltin) == "table" and TrainerSpellsBuiltin[class] or nil
  if cache.class == class and cache.source == source and cache.revision == observedRevision then
    return cache.candidates
  end

  local candidates = collectProviderRanks(source)
  appendObservedRanks(candidates, class)

  cache.class = class
  cache.source = source
  cache.revision = observedRevision
  cache.candidates = candidates
  return candidates
end

function Availability.MarkDirty()
  cache.revision = -1
end

local function matchesRace(candidate)
  if not candidate.race then
    return true
  end

  local race
  if UnitRace then
    local _, playerRace = UnitRace("player")
    race = playerRace
  end
  return type(candidate.race) == "string" and candidate.race == race
end

local function matchesFaction(candidate)
  if not candidate.faction then
    return true
  end

  local faction = UnitFactionGroup and UnitFactionGroup("player")
  local shortName = faction == "Alliance" and "A" or faction == "Horde" and "H"
  return candidate.faction == faction or candidate.faction == shortName
end

-- Initial RECENT selection shares the same level catalogue as rank upgrades.
-- Already-known spells need no current trainer availability or prerequisite check.
function Availability.KnownTier(class, level, knownIDs, bookLevels)
  if type(level) ~= "number" or level < 1 or type(knownIDs) ~= "table" then return nil end
  local levels = {}
  for id, required in pairs(bookLevels or {}) do
    if type(required) == "number" and required > 0 then levels[id] = required end
  end
  for _, candidate in ipairs(getCandidates(class)) do
    if matchesRace(candidate) and matchesFaction(candidate) then
      levels[candidate.id] = candidate.level
    end
  end
  local tier
  for _, required in pairs(levels) do
    if type(required) == "number" and required > 0 and required <= level then
      tier = math.max(tier or 0, required)
    end
  end
  if not tier then return nil end
  local selected = {}
  for id, required in pairs(levels) do
    if required == tier and knownIDs[id] then selected[#selected + 1] = id end
  end
  table.sort(selected)
  return selected, tier
end

local function prerequisitesKnown(candidate, family)
  if candidate.requires == nil then
    return true
  end
  if type(candidate.requires) ~= "table" then
    return false
  end

  for _, requiredID in ipairs(candidate.requires) do
    if type(requiredID) ~= "number" or requiredID == candidate.id then
      return false
    end
    if not family.ids[requiredID] and knownSpell(requiredID) ~= true then
      return false
    end
  end
  return true
end

local function isEligible(candidate, family)
  if not matchesRace(candidate) or not matchesFaction(candidate) then
    return false
  end

  -- Une ancienne observation ne prouve pas que les conditions sont encore reunies.
  if candidate.provider == "observed trainer" then
    local services = Availability.currentServices
    return services and services[candidate.id] == "available" or false
  end

  return prerequisitesKnown(candidate, family)
end

local function servicesChanged(previous, current)
  for spellID, status in pairs(previous) do
    if current[spellID] ~= status then
      return true
    end
  end
  for spellID, status in pairs(current) do
    if previous[spellID] ~= status then
      return true
    end
  end
  return false
end

function Availability.SetServices(services)
  local previous = Availability.currentServices or {}
  local current = {}
  Availability.currentServices = current

  for _, service in ipairs(services) do
    if service.spellID then
      current[service.spellID] = service.serviceType
    end
    Availability.Observe(service)
  end

  Availability.MarkDirty()
  if servicesChanged(previous, current) then
    markSpellBookDirty()
  end
end

local function roleSelectionComplete(policy, class)
  local profile = policy.GetProfile()
  if not profile or profile.class ~= class then
    return false
  end

  for _, role in ipairs({ "tank", "heal", "dps", "pvp" }) do
    if policy.IsRoleEnabled(role) and not policy.SelectedSpec(role) then
      return false
    end
  end
  return true
end

local function isMissingUpgrade(candidate, family, expectedName, playerLevel)
  return type(candidate.rank) == "number"
    and candidate.rank > family.max
    and type(candidate.level) == "number"
    and candidate.level <= playerLevel
    and not family.ids[candidate.id]
    and knownSpell(candidate.id) == false
    and spellName(candidate.id) == expectedName
    and isEligible(candidate, family)
end

local function betterUpgrade(candidate, current)
  return not current
    or candidate.rank > current.rank
    or (candidate.rank == current.rank and candidate.id < current.id)
end

function Availability.FindUpgrade(class, family, spell)
  if spell.ranked == false then
    return
  end

  local policy = SAK.RankPolicy
  if not policy or not policy.BuyRankEnabled() or not roleSelectionComplete(policy, class) then
    return
  end

  local playerLevel = UnitLevel and UnitLevel("player")
  if type(playerLevel) ~= "number" or playerLevel < 1 then
    return
  end

  local expectedName = SAK.NormalizeText(spell.name)
  local upgrade, waitReason, waitScope

  for _, candidate in ipairs(getCandidates(class)) do
    if isMissingUpgrade(candidate, family, expectedName, playerLevel) then
      local override = SAK.BadgeRules and SAK.BadgeRules.Resolve(class,candidate.id,"advice")
      local reason, scope
      if override == "eco" or override == "optional" then
        reason, scope = SAK.BadgeRules.Reason(), "custom"
      elseif override == nil then
        reason, scope = policy.UpgradeCanWait(class, family, candidate.rank)
      end
      if reason then
        if not waitReason then
          waitReason = reason
          waitScope = scope
        end
      elseif betterUpgrade(candidate, upgrade) then
        upgrade = candidate
      end
    end
  end

  return upgrade, waitReason, waitScope
end

function Availability.SourceText(class)
  local candidates = getCandidates(class)
  local source = cache.source and "TrainerSpells + observed trainers" or "observed trainers"
  return source .. " candidates=" .. #candidates
end
