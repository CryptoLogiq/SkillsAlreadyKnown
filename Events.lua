-- Evenements du jeu et rafraichissements des modules.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local addonName = ...
addonName = type(addonName) == "string" and addonName or "SkillsAlreadyKnown"
local loadedMessage = false
local watchedAddons = {
  SkillsAlreadyKnown = true,
  Blizzard_TrainerUI = true,
  Blizzard_Merchant = true,
  Blizzard_GuildBankUI = true,
  Blizzard_Settings = true,
  Blizzard_TalentUI = true,
  Blizzard_ClassTalentUI = true,
  Blizzard_PlayerSpells = true,
  Blizzard_SpellBook = true,
  EllesmereUIBags = true,
  EllesmereUIForeverEssentials = true,
  DarkMode = true,
  TrainerSpells = true,
  TalentsForeverBook = true,
}

local spellbookEvents = {
  PLAYER_LOGIN = true,
  PLAYER_LEVEL_UP = true,
  UNIT_PET = true,
  SPELLS_CHANGED = true,
  LEARNED_SPELL_IN_SKILL_LINE = true,
}

local trainerEvents = {
  PLAYER_LEVEL_UP = true,
  TRAINER_SHOW = true,
  TRAINER_UPDATE = true,
}

local merchantEvents = {
  MERCHANT_SHOW = true,
  MERCHANT_UPDATE = true,
}

local inventoryEvents = {
  PLAYER_LOGIN = true,
  PLAYER_LEVEL_UP = true,
  GET_ITEM_INFO_RECEIVED = true,
  BAG_UPDATE_DELAYED = true,
  BANKFRAME_OPENED = true,
  GUILDBANKFRAME_OPENED = true,
  GUILDBANKBAGSLOTS_CHANGED = true,
  MERCHANT_SHOW = true,
  MERCHANT_UPDATE = true,
  SPELLS_CHANGED = true,
  UNIT_PET = true,
}

local function initializeHooks()
  if SAK.RecentVisuals then SAK.RecentVisuals.Initialize() end
  if SAK.TrainerSpellsBadges then
    SAK.TrainerSpellsBadges.Initialize()
  end
  if SAK.RecipeKnowledge then
    SAK.RecipeKnowledge.Initialize()
  end
  if SAK.ContentTags then
    SAK.ContentTags.Initialize()
  end
  if SAK.Launcher then
    SAK.Launcher.Initialize()
  end
  if SAK.Settings then
    SAK.Settings.Register()
  end
  if SAK.TalentRoles then
    SAK.TalentRoles.Hook()
  end

  SAK.ClassTrainer.Hook()
  SAK.PetGrimoires.Hook()
  SAK.Inventory.Hook()
end

local function refreshSpellBook(event, detail)
  if not SAK.SpellBook then
    return
  end

  SAK.SpellBook.Hook()
  local providerLoaded = event == "ADDON_LOADED" and detail == "TrainerSpells"
  if (spellbookEvents[event] and (event ~= "UNIT_PET" or detail == "player")) or providerLoaded then
    if SAK.RankAvailability then
      SAK.RankAvailability.MarkDirty()
    end
    SAK.SpellBook.MarkDirty()
  end
  SAK.SpellBook.QueueRefresh()
end

local function refreshTrainer(event)
  if not trainerEvents[event] then
    return
  end

  SAK.ClassTrainer.MarkDirty()
  C_Timer.After(0, SAK.Refresh)
  C_Timer.After(0.05, SAK.Refresh)
end

local function refreshPetSpells(event, unit)
  if not SAK.PetGrimoires or not SAK.PetGrimoires.QueuePetSync then return end
  if merchantEvents[event] then
    SAK.PetGrimoires.QueuePetSync()
    C_Timer.After(0, SAK.PetGrimoires.Paint)
    C_Timer.After(0.1, SAK.PetGrimoires.Paint)
  elseif event == "PLAYER_LOGIN" or event == "SPELLS_CHANGED" or (event == "UNIT_PET" and unit == "player") then
    SAK.PetGrimoires.QueuePetSync()
    C_Timer.After(0.6, SAK.PetGrimoires.Paint)
  end
end

local function showLoadedMessage(event)
  if event ~= "PLAYER_LOGIN" or loadedMessage then
    return
  end

  loadedMessage = true
  SAK.EnsureDB()
  print("|cffffcc00Skills & More:|r loaded. /sam")
end

local function handleEvent(_, event, detail)
  if event == "ADDON_LOADED" then
    if not watchedAddons[detail] then
      return
    end

    SAK.EnsureDB()
    if detail == "DarkMode" then
      C_Timer.After(0, SAK.Refresh)
    end
  end

  if SAK.Localization and (event == "PLAYER_LOGIN"
    or (event == "ADDON_LOADED" and detail == addonName)) then
    SAK.Localization.Initialize()
  end

  if SAK.RecentLearning then SAK.RecentLearning.HandleEvent(event, detail) end

  showLoadedMessage(event)
  if SAK.ContentTags and (event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_TALENT_UPDATE"
    or event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED") then
    SAK.ContentTags.MarkDirty()
  end

  if event == "TRAINER_CLOSED" and SAK.RankAvailability then
    SAK.RankAvailability.SetServices({})
  end

  initializeHooks()
  if SAK.RecipeKnowledge then
    if event == "SPELLS_CHANGED" or event == "SKILL_LINES_CHANGED"
      or event == "TRADE_SKILL_LIST_UPDATE" or event == "NEW_RECIPE_LEARNED" then
      SAK.RecipeKnowledge.Invalidate()
      SAK.Inventory.QueueRefresh()
    end
    if event == "START_LOOT_ROLL" or event == "CANCEL_LOOT_ROLL"
      or event == "GET_ITEM_INFO_RECEIVED" or event == "SPELLS_CHANGED"
      or event == "SKILL_LINES_CHANGED" or event == "TRADE_SKILL_LIST_UPDATE" or event == "NEW_RECIPE_LEARNED" then
      SAK.RecipeKnowledge.QueueRollRefresh()
    end
  end
  refreshSpellBook(event, detail)

  local startupEvent = event == "PLAYER_LOGIN"
  local deferredOptions = event == "PLAYER_REGEN_ENABLED" and SAK.RankPolicy and SAK.RankPolicy.pending
  if SAK.RankPolicy and (startupEvent or deferredOptions) then
    if event == "PLAYER_LOGIN" and SAK.EnsureDB().replayStartupOnLogin then
      SAK.RankPolicy.pending = true
      SAK.RankPolicy.pendingFirstUse = true
    end
    C_Timer.After(0, SAK.RankPolicy.MaybePrompt)
  end

  refreshTrainer(event)
  refreshPetSpells(event, detail)

  if inventoryEvents[event] then
    SAK.Inventory.QueueRefresh()
  end
end

local events = CreateFrame("Frame")
for _, event in ipairs({
  "ADDON_LOADED",
  "BAG_UPDATE_DELAYED",
  "GET_ITEM_INFO_RECEIVED",
  "BANKFRAME_OPENED",
  "BANKFRAME_CLOSED",
  "GUILDBANKFRAME_OPENED",
  "GUILDBANKFRAME_CLOSED",
  "GUILDBANKBAGSLOTS_CHANGED",
  "MERCHANT_SHOW",
  "MERCHANT_UPDATE",
  "MERCHANT_CLOSED",
  "PLAYER_LOGIN",
  "PLAYER_REGEN_ENABLED",
  "LEARNED_SPELL_IN_SKILL_LINE",
  "PLAYER_LEVEL_UP",
  "SPELLS_CHANGED",
  "TRAINER_CLOSED",
  "TRAINER_SHOW",
  "TRAINER_UPDATE",
  "UNIT_PET",
  "TRAIT_CONFIG_UPDATED",
  "PLAYER_TALENT_UPDATE",
  "CHARACTER_POINTS_CHANGED",
  "START_LOOT_ROLL",
  "CANCEL_LOOT_ROLL",
  "SKILL_LINES_CHANGED",
  "TRADE_SKILL_LIST_UPDATE",
  "NEW_RECIPE_LEARNED",
}) do
  pcall(events.RegisterEvent, events, event)
end

events:SetScript("OnEvent", handleEvent)
