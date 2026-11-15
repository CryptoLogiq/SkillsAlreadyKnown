-- Classe les rangs appris, puis ajoute les conseils d'achat.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local SpellRanks = {}
SAK.SpellRanks = SpellRanks

local function collectFamilies(spells)
  local families = {}

  for _, spell in ipairs(spells) do
    local name = SAK.NormalizeText(spell.name)
    local family = families[name]

    if not family then
      family = { ids = {}, ranks = {}, max = 0, count = 0 }
      families[name] = family
    end

    local previousID = family.ranks[spell.rank]
    if previousID and previousID ~= spell.id then
      family.ambiguous = true
    end

    -- Un sous-texte absent ne permet pas d'ordonner deux sorts différents.
    if family.count > 0 and (family.unranked or spell.ranked == false) and not family.ids[spell.id] then
      family.ambiguous = true
    end

    family.unranked = family.unranked or spell.ranked == false
    if not previousID then
      family.count = family.count + 1
    end

    family.ranks[spell.rank] = spell.id
    family.ids[spell.id] = true
    family.max = math.max(family.max, spell.rank)
  end

  return families
end

local function classifyLearnedRank(spell, family, class)
  local override = not spell.pet and SAK.BadgeRules and SAK.BadgeRules.Resolve(class,spell.id,"advice")
  if override ~= nil then
    if override == "eco" and SAK.RankPolicy.EcoEnabled() then return "eco", SAK.BadgeRules.Reason() end
    return spell.rank == family.max and "best" or "low"
  end
  local policy = not spell.pet and SAK.RankPolicy
  local ecoReason = policy and policy.RankOneAdvice(class, family)

  if spell.rank == 1 and ecoReason then
    return "eco", ecoReason
  end

  if spell.rank == family.max then
    return "best"
  end

  return "low"
end

local function addPurchaseAdvice(state, spell, family, class)
  if state.kind ~= "best" then
    return
  end

  if spell.pet then
    local upgrade = SAK.PetGrimoires and SAK.PetGrimoires.FindUpgrade(family, spell)
    if upgrade then state.kind, state.upgrade = "buy", upgrade end
    return
  end
  local override = SAK.BadgeRules and SAK.BadgeRules.Resolve(class,spell.id,"advice")
  if override == "optional" and SAK.RankPolicy.OptionalEnabled() then
    state.optionalReason, state.optionalScope = SAK.BadgeRules.Reason(), "custom"
    return
  end
  local essential = SAK.SpellUsage and SAK.SpellUsage.EssentialSkill(class, { ids = { [spell.id] = true } })
  -- CLASS describes a required utility; rank-one utility does not demand upgrades.
  if essential and essential.rankOneUtility then return end
  local policy = SAK.RankPolicy
  if policy and override == nil then
    state.optionalReason, state.optionalScope = policy.OptionalAdvice(class, family, spell.rank)
  end

  if not SAK.RankAvailability then
    return
  end

  local upgrade, waitReason, waitScope = SAK.RankAvailability.FindUpgrade(class, family, spell)
  if upgrade then
    state.kind = "buy"
    state.upgrade = upgrade
  elseif waitReason and override == nil and policy.OptionalEnabled() and not state.optionalReason then
    state.optionalReason = waitReason
    state.optionalScope = waitScope
  end
end

function SpellRanks.Classify(spells, class)
  local families = collectFamilies(spells)
  local states = {}

  for _, spell in ipairs(spells) do
    local family = families[SAK.NormalizeText(spell.name)]

    if not family.ambiguous then
      local kind, reason = classifyLearnedRank(spell, family, class)
      local state = {
        kind = kind,
        pet = spell.pet,
        rank = spell.rank,
        highest = family.max,
        highestID = family.ranks[family.max],
        id = spell.id,
        name = spell.name,
        reason = reason,
      }

      addPurchaseAdvice(state, spell, family, class)
      states[spell.slot] = state
    end
  end

  return states
end
