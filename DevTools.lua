-- Optional development UI and command routing, disabled by default per character.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
local Dev = {}
SAK.DevTools = Dev

function Dev.IsEnabled()
  return SAK.EnsureDB().devToolsEnabled == true
end

function Dev.SetEnabled(value)
  SAK.EnsureDB().devToolsEnabled = value == true
  if not value then
    for key, frame in pairs(SAK.debugFrames or {}) do
      if key ~= "Summary" then frame:Hide() end
    end
    if SAK.exportFrame then SAK.exportFrame:Hide() end
  end
  if SAK.Settings then SAK.Settings.Notify() end
end

local function requireEnabled()
  if Dev.IsEnabled() then return true end
  print(L("DEV_TOOLS_DISABLED_HINT"))
  return false
end

function Dev.ToggleOption()
  return { type = "toggle", name = L("DEV_TOOLS_ENABLE"), desc = L("DEV_TOOLS_ENABLE_HELP"),
    order = 10, width = "full", get = Dev.IsEnabled,
    set = function(_,value) Dev.SetEnabled(value) end }
end

function Dev.StartupOption()
  local options = {
          type = "execute",
          name = L("Relancer le premier lancement"),
          order = 3,
          width = "full",
          desc = L("Effacer les choix de rôle et rouvrir la fenêtre de lancement avec une nouvelle présélection. La fenêtre sera aussi réaffichée au prochain /reload. Les réglages d'affichage restent conservés."),
          confirm = true,
          confirmText = L("Effacer les choix de rôle et relancer la fenêtre de premier lancement ?"),
          disabled = function() return InCombatLockdown and InCombatLockdown() end,
          func = function()
            if SAK.Settings.RestartFirstUse() then
              SAK.Settings.OfferReload()
            end
          end,
        }
  options.hidden = function() return not Dev.IsEnabled() end
  local run = options.func
  options.func = function() if requireEnabled() then run() end end
  return options
end

function Dev.Options(command)
  local function guarded(name, slash, description, order, callback)
    return command(name, slash, description, order, function()
      if requireEnabled() then callback() end
    end)
  end
  local command = guarded
  local options = { type = "group", name = "Diagnostics", order = 3, args = {
      intro = { type = "description", order = 1, fontSize = "medium",
        name = L("Ces boutons ouvrent les mêmes rapports copiables que les commandes du chat. Le panneau d'options se ferme pour laisser le rapport visible.") },
      reports = { type = "group", name = L("Rapports"), inline = true, order = 2, args = {
        spellbook = command(L("Grimoire du joueur (/sam bookdebug)"), "/sam bookdebug", L("Ouvre le grimoire du joueur avant ce rapport pour relever les sorts visibles et les marqueurs."), 0,
          function() if SAK.SpellBook then SAK.SpellBook.ShowDebugWindow() end end),
        trainer = command(L("Maître de classe (/sam debug)"), "/sam debug", L("Exporter les sorts du joueur, les services du maître et la correspondance des lignes."), 1,
          function() SAK.ClassTrainer.ShowDebugWindow() end),
        pet = command(L("Sorts du familier (/sam pet)"), "/sam pet", L("Consulter les sorts enregistrés pour le familier actif."), 2,
          function() SAK.PetGrimoires.ShowSummaryWindow() end),
        grimoires = command(L("Livres du familier (/sam petdebug)"), "/sam petdebug", L("Exporter les données des grimoires et du familier."), 3,
          function() SAK.PetGrimoires.ShowDebugWindow() end),
        conflicts = command(L("Compatibilité (/sam conflicts)"), L("/sam conflicts (ou /samconflicts)"), L("Consulter les observations de compatibilité de cette session."), 4,
          function() SAK.Diagnostics.ShowWindow() end),
      } },
      steps = { type = "group", name = L("Préparer un signalement"), inline = true, order = 3, args = {
        reproduce = { type = "description", order = 1, name = L("1. Reproduis le problème avec la fenêtre concernée ouverte : maître de classe, marchand ou sacs.") },
        export = { type = "description", order = 2, name = L("2. Ouvre le rapport correspondant, puis utilise son export pour copier le texte.") },
        isolate = { type = "description", order = 3, name = L("3. Si nécessaire, compare après avoir désactivé manuellement un addon suspect et rechargé l'interface. Un addon présent dans le rapport n'est pas une preuve de conflit.") },
      } },
      commands = { type = "description", order = 4,
        name = L("Options : /sam settings. Résumé : /sam ou /skillsandmore. Tous les rapports restent accessibles par les commandes indiquées sur les boutons.") },
    } }
  options.name = L("DEV_TOOLS_TITLE")
  options.hidden = function() return not Dev.IsEnabled() end
  return options
end

local commands = {
  bookdebug = function()
    if SAK.SpellBook then SAK.SpellBook.ShowDebugWindow() end
  end,
  debug = function() SAK.ClassTrainer.ShowDebugWindow() end,
  conflicts = function() SAK.Diagnostics.ShowWindow() end,
  pet = function() SAK.PetGrimoires.ShowSummaryWindow() end,
  petdebug = function() SAK.PetGrimoires.ShowDebugWindow() end,
}

function Dev.RunCommand(text)
  local callback = commands[text]
  if not callback then return false end
  if requireEnabled() then callback() end
  return true
end

function Dev.CommandSummary()
  if not Dev.IsEnabled() then return {} end
  return { L("/sam debug — maître de classe"), L("DEV_TOOLS_BOOK_COMMAND"),
    L("/sam pet — sorts du familier"), L("/sam petdebug — grimoires du familier"),
    L("/sam conflicts — compatibilité") }
end
