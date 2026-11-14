-- SkillsAlreadyKnown: addon bootstrap, slash commands, and event routing.

local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end

function SAK.Refresh()
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
    "Maîtres : NEW + = apprenable, coche verte = appris, NEXT = prochain palier, NOT NOW = indisponible.",
    "Métiers : NEXT indique le prochain palier d'apprentissage.",
    "Grimoire : BEST = plus haut rang appris ; LOW = ancien rang déjà remplacé ; BUY NEW RANK = rang supérieur accessible à apprendre.",
    "Conseils : ECO = rang suffisant pour l'usage conseillé ; OPTIONAL = achat reportable selon tes rôles. L'économie concerne l'or d'apprentissage.",
    "RECENT : derniers sorts, talents et recettes appris, conservés après rechargement. Consulte Apprentissages récents dans les options.",
    "Rôles et talents : résumés des spécialisations, recommandation LEVELING et repères PVP / PVE PVP sur les entrées renseignées.",
    "Livres de démons : grimoires appris, apprenables et déjà possédés. Invoque chaque démon pour enregistrer ses sorts.",
    "ALREADY KNOWN : recettes déjà apprises dans les sacs et les jets de dés reconnus.",
    "Affichage : icônes par zone, contours, textes et fonds réglables séparément.",
    "Minicarte : clic gauche pour les options, clic droit pour ce résumé.",
    "",
    "Commandes :",
    "/sam settings — options, rôles et spécialisations",
    "/sam debug — maître de classe",
    "/sam bookdebug — grimoire",
    "/sam pet — sorts du familier",
    "/sam petdebug — grimoires du familier",
    "/sam conflicts — compatibilité",
  }
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
  elseif text == "bookdebug" then
    if SAK.SpellBook then SAK.SpellBook.ShowDebugWindow()
    else SAK.ShowDebugTextWindow("SpellBook", "Skills & More — Spellbook Debug", "Spellbook module not loaded.") end
    return
  elseif text == "debug" then
    SAK.ClassTrainer.ShowDebugWindow()
    return
  elseif text == "conflicts" then
    SAK.Diagnostics.ShowWindow()
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
SAK.slashHandler = SlashCmdList.SKILLSALREADYKNOWN
SLASH_SKILLSALREADYKNOWNCONFLICTS1 = "/samconflicts"
SlashCmdList.SKILLSALREADYKNOWNCONFLICTS = function() SAK.Diagnostics.ShowWindow() end
