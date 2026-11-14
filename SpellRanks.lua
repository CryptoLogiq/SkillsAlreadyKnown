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
  local policy = SAK.RankPolicy
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

  local policy = SAK.RankPolicy
  if policy then
    state.optionalReason, state.optionalScope = policy.OptionalAdvice(class, family, spell.rank)
  end

  if not SAK.RankAvailability then
    return
  end

  local upgrade, waitReason, waitScope = SAK.RankAvailability.FindUpgrade(class, family, spell)
  if upgrade then
    state.kind = "buy"
    state.upgrade = upgrade
  elseif waitReason and policy.OptionalEnabled() and not state.optionalReason then
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
