-- Explications des badges dans les infobulles du grimoire et des sorts.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then
  return
end

local Book = SAK.SpellBook
local Tooltips = {}
SAK.SpellTooltips = Tooltips

local tooltipMarks = setmetatable({}, { __mode = "k" })
local tooltipClears = setmetatable({}, { __mode = "k" })
local recentMarks = setmetatable({}, { __mode = "k" })
local recentHooks = setmetatable({}, { __mode = "k" })

local hintMarks = setmetatable({}, { __mode = "k" })
local hintHooks = setmetatable({}, { __mode = "k" })

local function addSpellHint(tooltip, id)
  if not tooltip or not tooltip.AddLine or not id
    or (SAK.DisplayEnabled and (not SAK.DisplayEnabled("text") or not SAK.DisplayEnabled("combinations"))) then return end
  local _, class = UnitClass("player")
  local hints = SAK.SpellHints and SAK.SpellHints[class]
  local hint = hints and hints[id]
  if not hint and hints then
    local api = C_Spell and C_Spell.GetSpellName or GetSpellInfo
    local name = api and api(id)
    if name then
      for baseID, candidate in pairs(hints) do
        if api(baseID) == name then hint = candidate; break end
      end
    end
  end
  if not hint or hintMarks[tooltip] == id then return end
  if tooltip.HookScript and not hintHooks[tooltip] then
    tooltip:HookScript("OnTooltipCleared", function(tip) hintMarks[tip] = nil end)
    hintHooks[tooltip] = true
  end
  hintMarks[tooltip] = id
  tooltip:AddLine(L(hint.textKey), 1, 0.82, 0.1, true)
end

local function addRecent(tooltip, id)
  if not tooltip or not id or not SAK.RecentLearning or not SAK.DisplayEnabled("recent")
    or not SAK.DisplayEnabled("text") or recentMarks[tooltip] == id then return end
  if not SAK.RecentLearning.Contains("spells", id) and not SAK.RecentLearning.Contains("recipes", id) and not SAK.RecentLearning.Contains("pets", id) then return end
  recentMarks[tooltip] = id
  if tooltip.HookScript and not recentHooks[tooltip] then
    recentHooks[tooltip] = true
    tooltip:HookScript("OnTooltipCleared", function(tip) recentMarks[tip] = nil end)
    recentMarks[tooltip] = id
  end
  tooltip:AddLine("RECENT — " .. SAK.RecentLearning.Description(), 1, 0.82, 0.1, true)
  if SAK.UnusedSpells and SAK.UnusedSpells.ShouldExplain(id) then
    tooltip:AddLine(L("UNUSED_SPELL_TOOLTIP"), 0.25, 0.7, 1, true)
  end
end

Book.Explanations = {
  eco = L("Rang suffisant pour pex selon ton rôle. Économie de pièces d'or en reportant les achats de rangs, pas d'économie de mana garantie."),
  best = L("Plus haut rang appris, même s'il est seul : dégâts, soins et effets de ce rang. Ne garantit pas de toucher ni d'être le rang maximal du jeu."),
  low = L("Rang inférieur appris : dégâts, soins ou effets peuvent être moins efficaces. Certains contrôles ont une limite de niveau. Pas d'économie de mana garantie."),
  mana = L("Dans Forever, le coût en mana peut augmenter avec ton niveau même sans acheter de rang supérieur, selon le sort."),
  effects = L("Les rangs très anciens peuvent moins profiter des bonus de dégâts/soins. Les limites de cible et les pénalités de déclenchement dépendent du sort ; ce n'est pas une pénalité générale au toucher."),
}

local optionalMessages = {
  custom = { title = L("BADGE_CUSTOM_OPTIONAL"), detail = L("BADGE_CUSTOM_REASON") },
  ["rank-one"] = {
    title = L("OPTIONAL — seuls les rangs supplémentaires sont facultatifs."),
    detail = L("Le rang 1 suffit pour l'usage conseillé pendant le leveling selon ton rôle. Le sort lui-même reste utile ; les rangs supérieurs peuvent améliorer ses effets."),
  },
  ["higher-ranks"] = {
    title = L("OPTIONAL — l'achat de ce rang supplémentaire peut attendre pendant le leveling."),
    detail = L("Ce conseil concerne ce rang, pas l'utilité du sort lui-même. Il ne signifie pas que le rang 1 suffit dans tous les cas."),
  },
  spell = {
    title = L("OPTIONAL — achat facultatif pendant le leveling selon tes rôles et spécialisations."),
    detail = L("Utile selon la situation ; tu peux l'apprendre et l'utiliser."),
  },
}

local function addRankDescription(tooltip, state, adviceOnly)
  if state.kind == "eco" then
    tooltip:AddLine("ECO — " .. Book.Explanations.eco, 0, 0.8, 1, true)
    tooltip:AddLine(state.reason, 0.8, 0.9, 1, true)
    tooltip:AddLine(Book.Explanations.mana, 0.8, 0.8, 0.8, true)
  elseif state.kind == "buy" then
    tooltip:AddLine(L("BUY NEW RANK — rang ") .. state.upgrade.rank .. L(" accessible à ton niveau, pas encore appris."), 1, 0.82, 0.1, true)
    tooltip:AddLine(L("Rang appris : ") .. state.rank .. L(". Niveau requis : ") .. state.upgrade.level .. L(". Vérifie le prix chez le maître de classe."), 1, 0.9, 0.6, true)
  elseif not adviceOnly and state.kind == "best" then
    tooltip:AddLine("BEST — " .. Book.Explanations.best, 0.2, 1, 0.2, true)
    tooltip:AddLine(Book.Explanations.effects, 0.8, 0.8, 0.8, true)
  elseif not adviceOnly then
    tooltip:AddLine(L("LOW — rang inférieur au rang ") .. state.highest .. L(" appris. ") .. Book.Explanations.low, 0.7, 0.7, 0.7, true)
    tooltip:AddLine(Book.Explanations.effects, 0.8, 0.8, 0.8, true)
  end
end

local function addOptionalDescription(tooltip, state)
  if not state.optionalReason then
    return
  end

  local message = optionalMessages[state.optionalScope] or optionalMessages.spell
  tooltip:AddLine(message.title, 0, 0.8, 1, true)

  if message == optionalMessages.spell then
    tooltip:AddLine(message.detail, 0.8, 0.8, 0.8, true)
  else
    tooltip:AddLine(message.detail, 0.8, 0.9, 1, true)
  end

  tooltip:AddLine(L("Reporter cet achat permet d'économiser de l'or pendant le leveling."), 0.8, 0.8, 0.8, true)
end

local function hasPurchaseAdvice(state)
  return state.kind == "eco" or state.kind == "buy" or state.optionalReason
end

local function markTooltip(tooltip, spellID)
  if tooltipMarks[tooltip] == spellID then
    return false
  end

  -- Plusieurs API peuvent remplir la meme infobulle pendant un seul survol.
  if not tooltipClears[tooltip] and tooltip.HookScript then
    tooltipClears[tooltip] = true
    tooltip:HookScript("OnTooltipCleared", function(clearedTooltip)
      tooltipMarks[clearedTooltip] = nil
    end)
  end

  tooltipMarks[tooltip] = spellID
  return true
end

local function annotateTooltip(tooltip, state, adviceOnly)
  if SAK.DisplayEnabled and not SAK.DisplayEnabled("text") then
    return
  end
  if not state or not tooltip or not tooltip.AddLine then
    return
  end
  if adviceOnly and not hasPurchaseAdvice(state) then
    return
  end
  if not markTooltip(tooltip, state.id) then
    return
  end

  tooltip:AddLine("Skills & More", 1, 0.82, 0.05)
  addRankDescription(tooltip, state, adviceOnly)
  addOptionalDescription(tooltip, state)
end

function Book.AddTooltip(tooltip, slot, spellBank)
  if spellBank ~= Book.PlayerBank() and (not Book.PetBank or spellBank ~= Book.PetBank()) then
    return
  end
  local state = Book.StateForSlot(slot, spellBank)
  if SAK.TooltipBadges then SAK.TooltipBadges.Paint(tooltip, state and state.id, state) end
  addSpellHint(tooltip, state and state.id)
  addRecent(tooltip, state and state.id)
  if SAK.SpellUsage then SAK.SpellUsage.AddTooltip(tooltip, state and state.id) end
  annotateTooltip(tooltip, state, false)
end

local function purchaseState(spellID)
  local policy = SAK.RankPolicy
  if not policy or not policy.PurchaseAdvice then
    return nil
  end

  local _, class = UnitClass("player")
  local kind, reason, scope = policy.PurchaseAdvice(class, spellID)
  if not kind then
    return nil
  end

  return {
    id = spellID,
    kind = kind == "eco" and "eco" or "best",
    reason = kind == "eco" and reason or nil,
    optionalReason = kind == "optional" and reason or nil,
    optionalScope = scope,
  }
end

function Book.AddSpellTooltip(tooltip, spellID)
  if type(spellID) ~= "number" then
    return
  end

  if SAK.TalentAdvice then SAK.TalentAdvice.AddTooltip(tooltip, spellID) end
  addSpellHint(tooltip, spellID)
  addRecent(tooltip, spellID)
  if SAK.SpellUsage then SAK.SpellUsage.AddTooltip(tooltip, spellID) end
  local state = Book.StateForSpell(spellID) or purchaseState(spellID)
  if SAK.TooltipBadges then SAK.TooltipBadges.Paint(tooltip, spellID, state) end
  annotateTooltip(tooltip, state, true)
end

local function hookSpellTooltips()
  if Book.spellTooltipHooked then
    return
  end

  local spellType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Spell
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and spellType then
    TooltipDataProcessor.AddTooltipPostCall(spellType, function(tooltip, data)
      Book.AddSpellTooltip(tooltip, data and data.id)
    end)
    Book.spellTooltipHooked = true
    return
  end

  if not GameTooltip or not GameTooltip.HookScript then
    return
  end
  if GameTooltip.HasScript and not GameTooltip:HasScript("OnTooltipSetSpell") then
    return
  end

  GameTooltip:HookScript("OnTooltipSetSpell", function(tooltip)
    if tooltip.GetSpell then
      local _, spellID = tooltip:GetSpell()
      Book.AddSpellTooltip(tooltip, spellID)
    end
  end)
  Book.spellTooltipHooked = true
end

local function hookBookTooltips()
  if Book.tooltipHooked or not GameTooltip or not GameTooltip.SetSpellBookItem or not hooksecurefunc then
    return
  end

  hooksecurefunc(GameTooltip, "SetSpellBookItem", Book.AddTooltip)
  Book.tooltipHooked = true
end

local function hookTrainerTooltips()
  if Book.trainerTooltipHooked or not GameTooltip or not GameTooltip.SetTrainerService or not hooksecurefunc then
    return
  end

  hooksecurefunc(GameTooltip, "SetTrainerService", function(tooltip, index)
    if not C_TooltipInfo or not C_TooltipInfo.GetTrainerService then
      return
    end

    local ok, data = pcall(C_TooltipInfo.GetTrainerService, index)
    if ok and data then
      Book.AddSpellTooltip(tooltip, data.id)
    end
  end)
  Book.trainerTooltipHooked = true
end

local function hookActionTooltips()
  if Book.actionTooltipHooked or not GameTooltip or not GameTooltip.SetAction or not hooksecurefunc then return end
  hooksecurefunc(GameTooltip, "SetAction", function(tooltip, slot)
    local id = SAK.UnusedSpells and SAK.UnusedSpells.SpellForSlot(slot)
    if id then Book.AddSpellTooltip(tooltip, id) end
  end)
  Book.actionTooltipHooked = true
end

local function hookStanceTooltips()
  if Book.stanceTooltipHooked or not GameTooltip or not GameTooltip.SetShapeshift or not hooksecurefunc then return end
  hooksecurefunc(GameTooltip, "SetShapeshift", function(tooltip, index)
    local id = SAK.UnusedSpells and SAK.UnusedSpells.StanceSpell(index)
    if id then Book.AddSpellTooltip(tooltip, id) end
  end)
  Book.stanceTooltipHooked = true
end

function Tooltips.Hook()
  hookStanceTooltips()
  hookActionTooltips()
  hookSpellTooltips()
  hookBookTooltips()
  hookTrainerTooltips()
end

if SAK.Localization then
  SAK.Localization.RegisterTable(Book.Explanations)
  SAK.Localization.RegisterTable(optionalMessages)
end
