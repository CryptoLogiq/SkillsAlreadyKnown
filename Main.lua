-- SkillsAlreadyKnown: addon bootstrap, slash commands, and event routing.

local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local loadedMessage

function SAK.Refresh()
  if SAK.ClassTrainer then SAK.ClassTrainer.Refresh() end
  if SAK.PetGrimoires then SAK.PetGrimoires.Paint() end
  if SAK.Inventory then SAK.Inventory.Refresh() end
end

function SAK.SummaryText()
  local lines = {
    "SkillsAlreadyKnown",
    "",
    "Class trainer:",
    "- Grey = already known.",
    "- Red = locked by character level.",
    "- Green outline = learnable now.",
    "",
    "Warlock pet grimoires:",
    "- [Already Learned!] marks saved pet spells.",
    "- Yellow outline/text = learnable now.",
    "- Red text = locked by level.",
    "- Bags, bank, and guild bank show known/learnable grimoire markers when data is available.",
    "",
    "Commands:",
    "/sak",
    "/sak debug",
    "/sak pet",
    "/sak petdebug",
  }
  return table.concat(lines, "\n")
end

function SAK.ShowSummaryWindow()
  SAK.ClassTrainer.MarkDirty()
  SAK.Refresh()
  SAK.ShowDebugTextWindow("Summary", "Skills Already Known", SAK.SummaryText(), SAK.SummaryText)
end

SLASH_SKILLSALREADYKNOWN1 = "/skillsalreadyknown"
SLASH_SKILLSALREADYKNOWN2 = "/sak"
SlashCmdList.SKILLSALREADYKNOWN = function(text)
  text = (text or ""):lower()
  if text == "debug" then
    SAK.ClassTrainer.ShowDebugWindow()
    return
  elseif text == "pet" then
    SAK.PetGrimoires.ShowSummaryWindow()
    return
  elseif text == "petdebug" then
    SAK.PetGrimoires.ShowDebugWindow()
    return
  end

  SAK.ShowSummaryWindow()
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
  "PLAYER_LOGIN",
  "PLAYER_LEVEL_UP",
  "SPELLS_CHANGED",
  "TRAINER_SHOW",
  "TRAINER_UPDATE",
  "UNIT_PET",
}) do
  pcall(events.RegisterEvent, events, event)
end

events:SetScript("OnEvent", function(_, event, addonName)
  if event == "ADDON_LOADED" then
    if addonName ~= "SkillsAlreadyKnown" and addonName ~= "Blizzard_TrainerUI" and addonName ~= "Blizzard_Merchant" and addonName ~= "Blizzard_GuildBankUI" and addonName ~= "EllesmereUIBags" then return end
    SAK.EnsureDB()
  end

  if event == "PLAYER_LOGIN" and not loadedMessage then
    loadedMessage = true
    SAK.EnsureDB()
    print("|cffffcc00SkillsAlreadyKnown:|r loaded. /sak")
  end

  SAK.ClassTrainer.Hook()
  SAK.PetGrimoires.Hook()
  SAK.Inventory.Hook()
  if event == "PLAYER_LEVEL_UP" or event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
    SAK.ClassTrainer.MarkDirty()
    C_Timer.After(0, SAK.Refresh)
    C_Timer.After(0.05, SAK.Refresh)
  end

  if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
    SAK.PetGrimoires.QueuePetSync()
    C_Timer.After(0, SAK.PetGrimoires.Paint)
    C_Timer.After(0.1, SAK.PetGrimoires.Paint)
  elseif event == "SPELLS_CHANGED" or (event == "UNIT_PET" and addonName == "player") then
    SAK.PetGrimoires.QueuePetSync()
    C_Timer.After(0.6, SAK.PetGrimoires.Paint)
  end

  if event == "PLAYER_LOGIN" or event == "PLAYER_LEVEL_UP" or event == "GET_ITEM_INFO_RECEIVED" or event == "BAG_UPDATE_DELAYED" or event == "BANKFRAME_OPENED" or event == "GUILDBANKFRAME_OPENED" or event == "GUILDBANKBAGSLOTS_CHANGED" or event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" or event == "SPELLS_CHANGED" or event == "UNIT_PET" then
    SAK.Inventory.QueueRefresh()
  end
end)
