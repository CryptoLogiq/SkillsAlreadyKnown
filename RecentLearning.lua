-- Confirmed learning, grouped by trainer visit and saved per character.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end
local Recent = {}
SAK.RecentLearning = Recent
local initialized, visiting, batchStarted = false, false, false
local spellSnapshot, spellLevels, talentSnapshot, talentGroup
local outsideGeneration, visitGeneration = 0, 0

local function storage()
  local db = SAK.EnsureDB()
  if type(db.recentLearning) ~= "table" then
    db.recentLearning = { spells = {}, recipes = {}, talents = {}, pets = {} }
  end
  db.recentLearning.pets = db.recentLearning.pets or {}
  return db.recentLearning
end

local function validID(id)
  return type(id) == "number" and id > 0 and id == math.floor(id)
end

local function spellName(id)
  if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
  if GetSpellInfo then return GetSpellInfo(id) end
end

function Recent.Contains(kind, id)
  local list = storage()[kind]
  if list and list[id] ~= nil then return true end
  -- Classic profession recipes can be reported as learned spells.
  return kind == "recipes" and storage().spells[id] ~= nil or false
end

function Recent.IsUnused(id)
  local entry = storage().spells[id]
  return type(entry) == "table" and entry.used ~= true
end

function Recent.HasUnused()
  for _, entry in pairs(storage().spells) do
    if type(entry) == "table" and entry.used ~= true then return true end
  end
  return false
end

function Recent.MarkUsed(id)
  local entry = storage().spells[id]
  if type(entry) ~= "table" or entry.used == true then return false end
  entry.used = true
  return true
end

function Recent.Record(kind, id, name, rank)
  if not initialized or not validID(id) then return end
  if kind ~= "spells" and kind ~= "recipes" and kind ~= "talents" and kind ~= "pets" then return end
  local current = storage()
  SAK.EnsureDB().recentLearningBootstrapped = true
  if kind == "spells" and current.recipes[id] then return end
  if not batchStarted then
    local previous = current[kind] and current[kind][id]
    if previous and (not rank or previous.rank == rank) then return end
    current = { spells = {}, recipes = {}, talents = {}, pets = {} }
    SAK.EnsureDB().recentLearning = current
    batchStarted = true
  end
  if kind == "recipes" then
    local info = C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo and C_TradeSkillUI.GetRecipeInfo(id)
    name = name or (info and info.name)
    current.spells[id] = nil
  elseif kind == "spells" and current.recipes[id] then
    return
  end
  local previous = current[kind][id]
  current[kind][id] = { name = name or spellName(id), rank = rank, used = previous and previous.used or nil }
  if not visiting then
    outsideGeneration = outsideGeneration + 1
    local generation = outsideGeneration
    C_Timer.After(0.5, function()
      if not visiting and generation == outsideGeneration then batchStarted = false end
    end)
  end
end

local function readSpells()
  local result, levels = {}, {}
  if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo
    and C_SpellBook.GetSpellBookItemInfo then
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or 0
    for tab = 1, C_SpellBook.GetNumSpellBookSkillLines() do
      local line = C_SpellBook.GetSpellBookSkillLineInfo(tab)
      if line and not line.offSpecID and line.itemIndexOffset and line.numSpellBookItems then
        for slot = line.itemIndexOffset + 1, line.itemIndexOffset + line.numSpellBookItems do
          local info = C_SpellBook.GetSpellBookItemInfo(slot, bank)
          if info and not info.isUnlearned and not info.isOffSpec and info.isLearned ~= false
            and validID(info.spellID) and (not SAK.IsPlayerSpellKnown or SAK.IsPlayerSpellKnown(info.spellID) ~= false) then
            result[info.spellID] = info.name or true
            if C_SpellBook.GetSpellBookItemLevelLearned then
              local ok, level = pcall(C_SpellBook.GetSpellBookItemLevelLearned, slot, bank)
              if ok and type(level) == "number" and level > 0 then levels[info.spellID] = level end
            end
          end
        end
      end
    end
  elseif GetNumSpellTabs and GetSpellTabInfo and GetSpellBookItemInfo then
    for tab = 1, GetNumSpellTabs() do
      local _, _, offset, count = GetSpellTabInfo(tab)
      for slot = (offset or 0) + 1, (offset or 0) + (count or 0) do
        local kind, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL or "spell")
        if kind == "SPELL" and validID(id) then result[id] = true end
      end
    end
  else
    return nil
  end
  -- An empty book during loading is not a reliable baseline.
  return next(result) and result or nil, levels
end

function Recent.ScanSpells()
  local ok, current, levels = pcall(readSpells)
  if not ok or not current then return end
  if spellSnapshot and visiting then
    for id, name in pairs(current) do
      if not spellSnapshot[id] then Recent.Record("spells", id, type(name) == "string" and name or nil) end
    end
  end
  spellSnapshot, spellLevels = current, levels
end

function Recent.InitializeDefaults()
  local db, current = SAK.EnsureDB(), storage()
  if db.recentLearningBootstrapped then return end
  if next(current.spells) or next(current.recipes) or next(current.talents) then
    db.recentLearningBootstrapped = true
    return
  end
  if not db.recentLearningInitialLevel then
    local level = UnitLevel and UnitLevel("player")
    if type(level) ~= "number" or level < 1 then return end
    db.recentLearningInitialLevel = level
  end
  if not spellSnapshot or not SAK.RankAvailability or not SAK.RankAvailability.KnownTier then return end
  local _, class = UnitClass("player")
  local selected, tier = SAK.RankAvailability.KnownTier(class, db.recentLearningInitialLevel, spellSnapshot, spellLevels)
  if not selected then return end -- Retry when the book or optional catalogue becomes available.
  for _, id in ipairs(selected) do
    current.spells[id] = { name = type(spellSnapshot[id]) == "string" and spellSnapshot[id] or spellName(id) }
  end
  current.initialTier = tier
  db.recentLearningBootstrapped = true
end

local function readTalents()
  local result = {}
  local config = C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
  if config and C_Traits and C_Traits.GetConfigInfo and C_Traits.GetTreeNodes and C_Traits.GetNodeInfo then
    local info = C_Traits.GetConfigInfo(config)
    if not info or not info.treeIDs then return nil end
    for _, tree in ipairs(info.treeIDs) do
      for _, node in ipairs(C_Traits.GetTreeNodes(tree) or {}) do
        local data = C_Traits.GetNodeInfo(config, node)
        if data then
          local active = data.activeEntry and data.activeEntry.entryID
          local entry = active and C_Traits.GetEntryInfo and C_Traits.GetEntryInfo(config, active)
          local definition = entry and entry.definitionID and C_Traits.GetDefinitionInfo
            and C_Traits.GetDefinitionInfo(entry.definitionID)
          local name = definition and definition.spellID and spellName(definition.spellID)
          result[node] = { name = name, rank = data.activeRank or 0 }
        end
      end
    end
    return result, "config:" .. config
  end
  if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then return nil end
  for tree = 1, GetNumTalentTabs() do
    for index = 1, GetNumTalents(tree) do
      local name, _, _, _, rank = GetTalentInfo(tree, index)
      if type(rank) == "number" then result[tree * 1000 + index] = { name = name, rank = rank } end
    end
  end
  local group = GetActiveTalentGroup and GetActiveTalentGroup() or 1
  return result, "legacy:" .. group
end

function Recent.ScanTalents()
  local ok, current, group = pcall(readTalents)
  if not ok or not current then return end
  if talentSnapshot and talentGroup == group then
    for id, entry in pairs(current) do
      if talentSnapshot[id] and entry.rank > talentSnapshot[id].rank then
        Recent.Record("talents", id, entry.name, entry.rank)
      end
    end
  end
  talentSnapshot, talentGroup = current, group
end

function Recent.Description()
  local tier = storage().initialTier
  if tier then
    return L("Sélection initiale : sorts déjà connus du palier de niveau ") .. tier .. L(". Les prochains apprentissages remplaceront cette liste.")
  end
  return L("Fait partie de tes derniers apprentissages enregistrés. La liste est conservée après rechargement.")
end

function Recent.Summary()
  local lines = { L("RECENT — derniers apprentissages"), L("La liste est remplacée lorsqu'une nouvelle visite apporte des apprentissages. Les talents et recettes appris hors visite sont aussi suivis."), "" }
  if storage().initialTier then
    lines[#lines + 1] = L("Première utilisation : sorts déjà connus du palier de niveau ") .. storage().initialTier .. L(". Il s'agit d'une sélection initiale, pas d'un historique d'achats.")
    lines[#lines + 1] = ""
  end
  for _, category in ipairs({ { "spells", L("Sorts / compétences") }, { "recipes", L("Recettes") }, { "talents", L("Talents") }, { "pets", L("PET_ABILITIES_LABEL") } }) do
    lines[#lines + 1] = category[2]
    local entries = {}
    for id, entry in pairs(storage()[category[1]] or {}) do
      entries[#entries + 1] = (entry.name or (category[1] ~= "talents" and spellName(id)) or ("#" .. id))
        .. (entry.rank and (L(" — rang ") .. entry.rank) or "")
    end
    table.sort(entries)
    if #entries == 0 then lines[#lines + 1] = L("Aucun apprentissage enregistré.") end
    for _, name in ipairs(entries) do lines[#lines + 1] = "• " .. name end
    lines[#lines + 1] = ""
  end
  return table.concat(lines, "\n")
end

function Recent.HandleEvent(event, detail)
  if event == "PLAYER_LOGIN" then
    initialized = true
    Recent.ScanSpells()
    Recent.ScanTalents()
    Recent.InitializeDefaults()
  elseif not initialized then
    return
  elseif event == "TRAINER_SHOW" or event == "MERCHANT_SHOW" then
    visitGeneration = visitGeneration + 1
    visiting, batchStarted = false, false
    Recent.ScanSpells()
    Recent.InitializeDefaults()
    visiting = true
  elseif event == "TRAINER_CLOSED" or event == "MERCHANT_CLOSED" then
    Recent.ScanSpells()
    local generation = visitGeneration
    -- Learning events can arrive just after the trainer closes.
    C_Timer.After(0.5, function()
      if generation == visitGeneration then
        Recent.ScanSpells()
        visiting, batchStarted = false, false
      end
    end)
  elseif event == "LEARNED_SPELL_IN_SKILL_LINE" then
    Recent.Record("spells", detail)
  elseif event == "NEW_RECIPE_LEARNED" then
    Recent.Record("recipes", detail)
  elseif event == "SPELLS_CHANGED" or event == "TRAINER_UPDATE" then
    Recent.ScanSpells()
    Recent.InitializeDefaults()
  elseif event == "ADDON_LOADED" and detail == "TrainerSpells" then
    Recent.InitializeDefaults()
  elseif event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" then
    Recent.ScanTalents()
  elseif event == "TRAIT_CONFIG_UPDATED" then
    C_Timer.After(0, Recent.ScanTalents)
  end
end
