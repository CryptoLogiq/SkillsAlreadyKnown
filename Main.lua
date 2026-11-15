-- SkillsAlreadyKnown: addon bootstrap, slash commands, and event routing.

local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end

function SAK.Refresh()
  if SAK.UnusedSpells then SAK.UnusedSpells.Refresh() end
  if SAK.RecentVisuals then SAK.RecentVisuals.Refresh() end
  if SAK.TrainerSpellsBadges then
    SAK.TrainerSpellsBadges.Refresh()
  end
  if SAK.RecipeKnowledge then
    SAK.RecipeKnowledge.RefreshRolls()
  end
  if SAK.ContentTags then
    SAK.ContentTags.Refresh()
  end
  if SAK.ClassTrainer then
    SAK.ClassTrainer.Refresh()
  end
  if SAK.PetGrimoires then
    SAK.PetGrimoires.Paint()
  end
  if SAK.Inventory then
    SAK.Inventory.Refresh()
  end
  if SAK.SpellBook then
    SAK.SpellBook.Refresh()
  end
  if SAK.TalentRoles then
    SAK.TalentRoles.Refresh()
  end
end

function SAK.SummaryText()
  local lines = {
    "Skills & More — By CryptoLogiq",
    "",
    L("Maîtres : NEW + = apprenable, coche verte = appris, NEXT = prochain palier, NOT NOW = indisponible."),
    L("Métiers : NEXT indique le prochain palier d'apprentissage."),
    L("Grimoire : BEST = plus haut rang appris ; LOW = ancien rang déjà remplacé ; BUY NEW RANK = rang supérieur accessible à apprendre."),
    L("Conseils : ECO = rang suffisant pour l'usage conseillé ; OPTIONAL = achat reportable selon tes rôles. L'économie concerne l'or d'apprentissage."),
    L("RECENT : derniers sorts, talents et recettes appris, conservés après rechargement. Consulte Apprentissages récents dans les options."),
    L("Rôles et talents : résumés des spécialisations, recommandation LEVELING et repères PVP / PVE PVP sur les entrées renseignées."),
    L("Livres de démons : grimoires appris, apprenables et déjà possédés. Invoque chaque démon pour enregistrer ses sorts."),
    L("ALREADY KNOWN : recettes déjà apprises dans les sacs et les jets de dés reconnus."),
    L("Affichage : icônes par zone, contours, textes et fonds réglables séparément."),
    L("Minicarte : clic gauche pour les options, clic droit pour ce résumé."),
    "",
    L("Commandes :"),
    L("/sam settings — options, rôles et spécialisations"),

  }
  if SAK.DevTools then
    for _, line in ipairs(SAK.DevTools.CommandSummary()) do lines[#lines + 1] = line end
  end
  return table.concat(lines, "\n")
end

function SAK.ShowSummaryWindow()
  SAK.ClassTrainer.MarkDirty()
  SAK.Refresh()
  SAK.ShowDebugTextWindow("Summary", "Skills & More", SAK.SummaryText(), SAK.SummaryText)
end

SLASH_SKILLSALREADYKNOWN1 = "/skillsandmore"
SLASH_SKILLSALREADYKNOWN3 = "/skillsalreadyknown"
SLASH_SKILLSALREADYKNOWN2 = "/sam"
SlashCmdList.SKILLSALREADYKNOWN = function(text)
  text = (text or ""):lower()
  if text == "settings" or text == "profile" then
    if SAK.RankPolicy then SAK.RankPolicy.ShowSettings() end
    return
  end
  if SAK.DevTools and SAK.DevTools.RunCommand(text) then return end

  SAK.ShowSummaryWindow()
end
SAK.slashHandler = SlashCmdList.SKILLSALREADYKNOWN
SLASH_SKILLSALREADYKNOWNCONFLICTS1 = "/samconflicts"
SlashCmdList.SKILLSALREADYKNOWNCONFLICTS = function() if SAK.DevTools then SAK.DevTools.RunCommand("conflicts") end end
