-- SkillsAlreadyKnown: shared AceConfig model for startup and Blizzard options.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(text) return text end
if SAK.disabledByDev then return end
local Config = {}
SAK.Settings = Config
local APP = "SkillsAlreadyKnown"
local addonName = ...
local title = "Skills & More — By CryptoLogiq"
if type(addonName) == "string" and addonName:sub(-4) == "_dev" then title = title .. " [DEV]" end
local registered, panel, category, legacyGroup

local function lib(name)
  return LibStub and LibStub(name, true)
end

local popupLayers = setmetatable({}, { __mode = "k" })

local function restorePopupLayer(popup)
  local previous = popupLayers[popup]
  if previous then
    popup:SetFrameStrata(previous.strata)
    popup:SetFrameLevel(previous.level)
    popupLayers[popup] = nil
  end
end

local function placePopup(popup)
  if not popup then
    return
  end
  popup:ClearAllPoints()
  popup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  if not popup.GetFrameStrata or not popup.GetFrameLevel then
    return
  end

  if not popupLayers[popup] then
    popupLayers[popup] = { strata = popup:GetFrameStrata(), level = popup:GetFrameLevel() }
  end
  local dialog = lib("AceConfigDialog-3.0")
  local widget = dialog and dialog.OpenFrames and dialog.OpenFrames[APP]
  local owner = widget and widget.frame
  local level = owner and owner:GetFrameLevel() or 100
  -- AceGUI uses FULLSCREEN_DIALOG; native popups normally sit below that layer.
  popup:SetFrameStrata("FULLSCREEN_DIALOG")
  popup:SetFrameLevel(math.max(popup:GetFrameLevel(), level + 30))
end

local function roles()
  return SAK.RankPolicy.RoleLabels()
end

local function profile()
  local selection = SAK.PlayerRoles.GetSelection()
  for _, role in ipairs(SAK.PlayerRoles.Order) do
    if SAK.PlayerRoles.IsSelectionRoleEnabled(role) then
      return selection
    end
  end
end

local function update(key, value)
  if key == "role" then SAK.RankPolicy.SetRole(value)
  elseif key == "eco" or key == "optional" or key == "buyRank" then
    SAK.PlayerRoles.SetSelectionPreference(key, value)
  end
end

local function specializationSummaries()
  local _, class = UnitClass("player")
  local data = SAK.ClassRoles and SAK.ClassRoles.classes[class]
  local groups = {}
  for index, tree in ipairs(data and data.talentTrees or {}) do
    local descriptions = {}
    for order, spec in ipairs(tree.specs) do
      descriptions[spec] = {
        type = "description",
        order = order,
        width = "full",
        fontSize = "medium",
        name = function()
          if not SAK.TalentTooltips then
            return ""
          end

          local text = SAK.TalentTooltips.SpecializationText(class, spec)
          if #tree.specs > 1 then
            return "|cffffd100" .. data.specializations[spec] .. "|r\n" .. text
          end
          return text
        end,
      }
    end
    groups["tree" .. index] = {
      type = "group",
      name = tree.name,
      inline = true,
      order = index,
      args = descriptions,
    }
  end
  return groups
end

local function patchnoteGroups()
  local groups = {}
  for index, entry in ipairs(SAK.Patchnotes or {}) do
    local title = "Version " .. entry.version
    if entry.status == "development" then
      title = L("En développement — après ") .. (entry.basedOn or L("la dernière version"))
    end
    local sections = {}
    for order, category in ipairs({
      { key = "additions", title = L("Ajouts de fonctionnalités") },
      { key = "fixes", title = L("Corrections de bugs") },
    }) do
      local lines = {}
      for _, text in ipairs(entry[category.key]) do
        lines[#lines + 1] = "• " .. L(text)
      end
      if #lines > 0 then
        sections[category.key] = {
          type = "group",
          name = category.title,
          inline = true,
          order = order,
          args = {
            notes = {
              type = "description",
              name = table.concat(lines, "\n\n"),
              fontSize = "medium",
              width = "full",
              order = 1,
            },
          },
        }
      end
    end
    if next(sections) then
      groups["version" .. index] = {
        type = "group",
        name = title,
        inline = true,
        order = index,
        args = sections,
      }
    end
  end
  return groups
end

function Config.Options()
  local function roleGroup(role, order)
    local function uniqueSpec()
      local values = SAK.RankPolicy.SpecsForRole(role)
      local key = next(values)
      if key and not next(values, key) then return values[key] end
    end
    return { type = "group", name = "", inline = true, order = order,
      hidden = function() return not next(SAK.RankPolicy.SpecsForRole(role)) end, args = {
      enabled = { type = "toggle", name = roles()[role], order = 1, width = "full",
        desc = function() return SAK.RankPolicy.RoleDescription(role) .. L("\nTu peux cocher plusieurs choix.") end,
        disabled = function() return not next(SAK.RankPolicy.SpecsForRole(role)) end,
        get = function() return SAK.PlayerRoles.IsSelectionRoleEnabled(role) end,
        set = function(_, value) SAK.PlayerRoles.SetSelectionRole(role, value) end },
      specialization = { type = "select", name = L("Spécialisation"), order = 2, width = "full",
        hidden = function() return uniqueSpec() ~= nil end,
        desc = L("Spécialisation suivie pour ce rôle. La sélection est conservée si tu décoches puis recoches le rôle."),
        values = function() return SAK.RankPolicy.SpecsForRole(role) end,
        disabled = function() return not SAK.PlayerRoles.IsSelectionRoleEnabled(role) end,
        get = function() return SAK.PlayerRoles.SelectionSpec(role) end,
        set = function(_, value) SAK.PlayerRoles.SetSelectionSpec(role, value) end },
      singleSpec = { type = "description", order = 3,
        hidden = function() return not uniqueSpec() or not SAK.PlayerRoles.IsSelectionRoleEnabled(role) end,
        name = function() return L("Spécialisation : ") .. (uniqueSpec() or "") end },
    } }
  end
  local function appearanceToggle(key, name, desc, order)
    return { type = "toggle", name = name, desc = desc, order = order, width = "full",
      get = function() return SAK.DisplayEnabled(key) end,
      set = function(_, value) SAK.SetDisplayOption(key, value) end }
  end
  local function command(name, slash, description, order, callback)
    return { type = "execute", name = name, order = order, width = "full",
      desc = description .. L("\nCommande : ") .. slash,
      func = function() Config.LaunchReport(callback) end }
  end
  local function marker(name, kind, badges, order)
    local badge = badges and badges[kind]
    return { type = "description", name = name, order = order,
      image = badge and badge.texture, imageWidth = badge and badge.width,
      imageHeight = badge and badge.height }
  end
  local function toggle(key, name, desc, order)
    return { type = "toggle", name = name, desc = desc, order = order, width = "full",
      disabled = function() return not profile() end,
      get = function()
        local p = profile()
        if key == "eco" then return SAK.PlayerRoles.SelectionPreference("eco") end
        if key == "optional" then return SAK.PlayerRoles.SelectionPreference("optional") end
        if key == "buyRank" then return SAK.PlayerRoles.SelectionPreference("buyRank") end
        return p and p[key] == true or false
      end,
      set = function(_, value) update(key, value) end }
  end
  return { type = "group", name = title, childGroups = "tab", args = {
    language = {
      type = "group", name = L("Langue"), order = 0.5, args = {
        choice = { type = "select", name = L("Langue de l’interface"), order = 1, width = "full",
          desc = L("Choisir la langue des options, conseils et infobulles. Un rechargement est nécessaire pour appliquer ce choix partout."),
          values = { auto = L("Automatique (client du jeu)"), ["fr_FR"] = "Français", ["en-EN"] = "English" },
          get = function() return SAK.Localization and SAK.Localization.GetPreference() or "auto" end,
          set = function(_, value)
            if SAK.Localization and SAK.Localization.SetLanguage(value) then
              Config.Notify()
              Config.OfferReload(L("Recharger l'interface pour appliquer la langue choisie ?"))
            end
          end,
        },
      },
    },
    display = { type = "group", name = L("Affichage"), order = 1, args = {
      intro = { type = "description", order = 1, fontSize = "medium",
        name = L("Active séparément les ajouts visuels de l'addon. Ces choix sont enregistrés pour ce personnage et s'appliquent immédiatement aux fenêtres ouvertes ; les icônes et textes du jeu restent disponibles.") },
      minimap = {
        type = "toggle",
        name = L("Afficher le bouton de minicarte"),
        desc = L("Ouvrir les options avec un clic gauche, le résumé avec un clic droit. Masquer ce bouton conserve le lanceur disponible dans les panneaux DataBroker comme HidingBar et Titan Panel."),
        order = 1.2,
        width = "full",
        get = function() return not SAK.Launcher or SAK.Launcher.IsVisible() end,
        set = function(_, value)
          if SAK.Launcher then SAK.Launcher.SetVisible(value) end
        end,
      },
      contentTags = {
        type = "toggle",
        name = L("Afficher les repères PVP / PVE PVP"),
        desc = L("PVP : principalement intéressant contre les joueurs, sans exclure un usage PvE. PVE PVP : utile dans les deux activités. Ces repères apparaissent sur les talents vérifiés et les sorts apprenables du maître de classe. Survole un repère pour lire son explication. Ils ne rendent aucun achat obligatoire ou facultatif ; les entrées non vérifiées restent sans marqueur."),
        order = 1.3,
        width = "full",
        disabled = function() return not SAK.DisplayEnabled("icons") end,
        get = function() return SAK.DisplayEnabled("contentTags") end,
        set = function(_, value) SAK.SetDisplayOption("contentTags", value) end,
      },
      recipes = {
        type = "toggle",
        name = L("Signaler les recettes déjà apprises"),
        desc = L("Afficher ALREADY KNOWN dans les sacs et les fenêtres de jet de dés lorsque l’infobulle du jeu confirme que la recette est déjà connue. Aucun survol ni scan de métier n’est nécessaire. L’absence de cette indication ne signifie pas que la recette est apprenable."),
        order = 1.4,
        width = "full",
        disabled = function() return not SAK.DisplayEnabled("icons") end,
        get = function() return SAK.DisplayEnabled("recipes") end,
        set = function(_, value) SAK.SetDisplayOption("recipes", value) end,
      },
      categories = {
        type = "group",
        name = L("Icônes par zone"),
        disabled = function() return not SAK.DisplayEnabled("icons") end,
        inline = true,
        order = 1.5,
        args = {
          note = {
            type = "description", order = 0,
            name = L("Choisis où afficher les marqueurs de l'addon. Le réglage général Icônes et surimpressions reste prioritaire. Ces cases ne changent pas les contours ni la coloration des textes."),
          },
          spellbook = appearanceToggle("iconsSpellbook", L("Grimoire"), L("Afficher les badges des sorts, les icônes de la légende et l’indication de rôle à gauche du titre de spécialisation du grimoire."), 1),
          trainer = appearanceToggle("iconsTrainer", L("Maître de classe"), L("Afficher les badges des sorts, les repères PVP / PVE PVP, les surimpressions et le halo NEW + chez le maître de classe."), 2),
          merchant = appearanceToggle("iconsMerchant", L("Marchand"), L("Afficher les marqueurs de livres et de démons chez le marchand."), 3),
          inventory = appearanceToggle("iconsInventory", L("Sacs et banques"), L("Afficher les marqueurs de livres dans les sacs, la banque et la banque de guilde, y compris les sacs EllesmereUI."), 4),
          trainerSpells = appearanceToggle("iconsTrainerSpells", L("Liste TrainerSpells"), L("Ajouter ECO / OPTIONAL et PVP / PVE PVP aux sorts renseignés dans la liste de classe de TrainerSpells, selon tes rôles et réglages. Son propre affichage de disponibilité reste conservé."), 7),
          professions = appearanceToggle("iconsProfessions", L("Métiers"), L("Afficher RECENT sur les recettes récemment apprises dans les listes de métiers du jeu reconnues."), 8),
          loot = appearanceToggle("iconsLoot", L("Jets de dés de groupe / raid"), L("Afficher ALREADY KNOWN sur les recettes déjà apprises dans les fenêtres de butin du jeu. Ne change aucun choix Besoin, Cupidité ou Passer."), 6),
          talents = appearanceToggle("iconsTalents", L("Arbre de talents"), L("Afficher les indications de rôle à côté des titres et les repères PVP / PVE PVP sur les talents, avec leurs infobulles."), 5),
        },
      },
      controls = { type = "group", name = L("Éléments affichés"), inline = true, order = 2, args = {
        recent = appearanceToggle("recent", L("Derniers apprentissages : RECENT"), L("Signaler les sorts, talents et recettes récemment appris. La liste est conservée après rechargement et remplacée lorsqu’un nouvel apprentissage est enregistré. Une visite sans achat conserve la liste précédente. À la première utilisation, les sorts déjà connus du dernier palier accessible sont présélectionnés si leurs niveaux sont connus."), 0),
        icons = appearanceToggle("icons", L("Icônes et surimpressions"), L("Afficher NEW +, la coche, NEXT, NOT NOW, ECO, BEST, OPTIONAL, BUY NEW RANK et LOW, ainsi que les marqueurs de livres et de démons. Désactiver retire aussi le halo de NEW + et les surimpressions assombries ; les icônes d'origine restent visibles."), 1),
        iconsPreview = { type = "description", order = 2,
          image = function()
            if SAK.DisplayEnabled("icons") then return SAK.TRAINER_BADGES and SAK.TRAINER_BADGES.new.texture end
            return nil
          end, imageWidth = 40, imageHeight = 16,
          name = function() return SAK.DisplayEnabled("icons") and L("Aperçu : badge ajouté au-dessus du sort.") or L("Aperçu : icône du sort seule, sans badge ajouté.") end },
        outlines = appearanceToggle("outlines", L("Contours de couleur"), L("Ajouter les contours de statut chez le maître de classe et autour des livres reconnus chez le marchand et dans les sacs. Désactiver retire uniquement les contours de notre addon."), 3),
        outlinesPreview = { type = "description", order = 4, name = function()
          return SAK.DisplayEnabled("outlines") and L("Aperçu schématique : |cff00ff00[ Apprenable ]|r  |cffffd100[ Prochain palier ]|r  |cffff3333[ Indisponible ]|r  |cff888888[ Appris ]|r") or L("Aperçu : aucun contour de statut ajouté.")
        end },
        text = appearanceToggle("text", L("Couleurs et annotations de texte"), L("Colorer les textes lorsque c'est compatible, ajouter les mentions des livres, les compteurs de doublons, les informations dans les infobulles et les indications de rôle à droite des titres des arbres de talents. Désactiver retire nos ajouts ; les textes du jeu et des autres addons restent gérés par eux. Les prochaines infobulles reflètent ce choix. Avant le niveau 10, les onglets de spécialisation du grimoire présentent aussi leur résumé. ECO et OPTIONAL apparaissent aussi dans les infobulles de sorts hors du grimoire (barres d'action, liens de sorts compatibles), selon ton rôle."), 5),
        textPreview = { type = "description", order = 6, name = function()
          return SAK.DisplayEnabled("text") and L("Aperçu : |cff555555Sort appris|r  |cffff2626Sort indisponible|r  |cff40ff40[Already in your Bag]|r") or L("Aperçu : nom et informations d'origine, sans couleur ni annotation ajoutée.")
        end },
        compatibility = { type = "description", order = 7, name = L("Avec TrainerSpells actif, les textes du maître de classe restent sous son contrôle même si cette case est cochée. Les réglages des autres catégories restent indépendants.") },
        backgrounds = appearanceToggle("backgrounds", L("Fonds de statut"), L("Ajouter un fond vert discret aux lignes apprenables, jaune aux prochains paliers et sombre aux sorts déjà appris. Ce réglage est indépendant des contours et des icônes ; il ne modifie pas le fond général des fenêtres."), 8),
        backgroundsPreview = { type = "description", order = 9, name = function()
          return SAK.DisplayEnabled("backgrounds") and L("Fonds activés : vert pour l'apprentissage, jaune pour le prochain palier, sombre pour les sorts déjà connus.") or L("Fonds désactivés : aucun fond de statut ajouté aux lignes.")
        end },
      } },
      trainer = { type = "group", name = L("Guide des marqueurs — maîtres de classe"), inline = true, order = 3, args = {
        available = marker(L("|cff33ff33NEW +|r : sort apprenable maintenant, contour vert et halo animé."), "new", SAK.TRAINER_BADGES, 1),
        known = marker(L("Coche verte et contour gris : sort déjà appris."), "known", SAK.TRAINER_BADGES, 2),
        soon = marker(L("|cffffd100NEXT|r : disponible au prochain palier de niveau pair, contour et fond jaunes."), "next", SAK.TRAINER_BADGES, 3),
        locked = marker(L("|cffff3333NOT NOW|r : autre indisponibilité, contour rouge."), "notnow", SAK.TRAINER_BADGES, 4),
      } },
      books = { type = "group", name = L("Guide des marqueurs — livres du familier et inventaire"), inline = true, order = 4, args = {
        known = { type = "description", order = 1, name = L("Livre déjà appris : surimpression assombrie et indication du démon concerné.") },
        available = { type = "description", order = 2, name = L("Livre apprenable : contour jaune et marqueur + lorsque les informations du familier sont disponibles.") },
        owned = { type = "description", order = 3, name = L("Les livres déjà possédés sont signalés chez le marchand. Le stockage en banque correspond aux dernières informations observées.") },
      } },
      refresh = { type = "execute", name = L("Actualiser les marqueurs"), order = 5, width = "full",
        desc = L("Relire les sorts appris et actualiser les fenêtres ouvertes."),
        func = function()
          if SAK.ClassTrainer then SAK.ClassTrainer.MarkDirty() end
          if SAK.SpellBook then SAK.SpellBook.MarkDirty() end
          SAK.Refresh()
        end },
      summary = command(L("Ouvrir le résumé (/sam)"), "/sam", L("Afficher le résumé et la liste des commandes dans une fenêtre séparée."), 6,
        function() SAK.ShowSummaryWindow() end),
    } },
    spellbook = { type = "group", name = L("Talent Spec and Role"), order = 2, args = {
      intro = { type = "description", order = 1, fontSize = "medium",
        name = L("Choisis tes rôles parmi ceux de ta classe. Si plusieurs spécialisations sont possibles, sélectionne celle que tu suis. Au premier lancement, une spécialisation est proposée selon tes points de talents ; sans arbre dominant, le choix conseillé pour le leveling solo est proposé. Tu peux modifier cette sélection. Les conseils ne sont activés qu’après « Valider mes choix » puis OK dans le récapitulatif. Sans validation, cette fenêtre revient au prochain login ou /reload.") },
      usageLegend = {
        type = "description",
        order = 1.5,
        name = L("|cffff5966[PVP]|r : principalement intéressant contre les joueurs. |cff59d9ff[PVE PVP]|r : utile dans les deux activités. Ces repères d’usage apparaissent sur les talents vérifiés et les sorts apprenables du maître ; ils ne rendent aucun choix obligatoire et restent indépendants d’ECO / OPTIONAL."),
      },
      roles = { type = "group", name = L("Rôles et spécialisations"), inline = true, order = 2, args = {
        tank = roleGroup("tank", 1), heal = roleGroup("heal", 2), dps = roleGroup("dps", 3),
      } },
      summaries = { type = "group", name = L("Comprendre les trois arbres de talents"), inline = true, order = 2.7, args = specializationSummaries() },
      activities = { type = "group", name = L("Activité"), inline = true, order = 2.5, args = {
        note = { type = "description", order = 0, name = L("PvP : joueur contre joueur. Toutes les classes peuvent pratiquer cette activité.") },
        pvp = roleGroup("pvp", 1),
      } },
      context = { type = "group", name = L("Conseils de leveling"), inline = true, order = 3, args = {
        eco = toggle("eco", L("Activer les conseils ECO"), L("Marquer le rang 1 des sorts retenus pour tes rôles et spécialisations. Les conseils spécifiques attendent le choix de la spécialisation."), 1),
        optional = toggle("optional", L("Afficher les conseils OPTIONAL"), L("Signaler les achats facultatifs chez le maître de classe et dans les infobulles ; dans le grimoire, OPTIONAL se place à droite de BEST. Pendant le leveling (avant le niveau 60), selon tous tes rôles et spécialisations. L'infobulle distingue le sort facultatif, le rang supplémentaire reportable et le cas où le rang 1 suffit pour l'usage conseillé, sans afficher les notes de recherche. Ce conseil ne retire aucun sort et reste indépendant d'ECO. La case Icônes doit aussi être activée pour voir le badge."), 2),
        buyRank = toggle("buyRank", L("Signaler les rangs supérieurs à acheter"), L("Afficher BUY NEW RANK sur le plus haut rang appris si un rang supérieur est accessible à ton niveau et n'est pas classé facultatif pour ton rôle. Les prix ne sont pas vérifiés. Catalogue fourni par TrainerSpells s'il est chargé ; sinon, informations observées chez le maître actuellement ouvert. Les données incertaines n'entraînent pas d'alerte."), 3),
        note = { type = "description", order = 4, name = L("ECO et OPTIONAL doivent convenir à tous les rôles cochés. Si PvP est coché, ces conseils sont suspendus ; BEST et LOW continuent de comparer les rangs appris. Seuls les sorts vérifiés sont concernés.") },
      } },
      legend = { type = "group", name = L("Comprendre les marqueurs"), inline = true, order = 4, args = {
        eco = marker(L("|cff00ccffECO|r : rang suffisant pour le leveling selon ton rôle ; économie d'or en reportant des achats, pas d'économie de mana garantie."), "eco", SAK.SPELLBOOK_BADGES, 1),
        best = marker(L("|cff33ff33BEST|r : plus haut rang appris, même s'il est seul ; puissance et effets de ce rang."), "best", SAK.SPELLBOOK_BADGES, 2),
        low = marker(L("|cffaaaaaaLOW|r : rang inférieur appris, aux dégâts, soins ou effets potentiellement réduits. Certains contrôles ont une limite de niveau."), "low", SAK.SPELLBOOK_BADGES, 3),
        optional = marker(L("|cff00ccffOPTIONAL|r : achat facultatif en leveling pour ton rôle. S'ajoute à droite de BEST ; L'infobulle rappelle qu'il s'agit d'une économie d'or sur un achat facultatif. Facultatif ne veut pas dire inutile."), "optional", SAK.SPELLBOOK_BADGES, 4),
        buy = marker(L("|cffffd100BUY NEW RANK|r : un rang supérieur accessible à ton niveau reste à apprendre. Les achats ECO / OPTIONAL ne déclenchent pas cette alerte. LOW signifie qu'un rang supérieur est déjà appris."), "buy", SAK.SPELLBOOK_BADGES, 5),
        note = { type = "description", order = 6, name = L("Dans Forever, le coût en mana peut évoluer avec ton niveau selon le sort. ECO vise l'or d'apprentissage. BEST ne garantit pas de toucher ; un rang 1 conseillé garde ECO même si un rang supérieur affiche BEST.") },
      } },
      ranks = { type = "description", order = 4.5,
        name = L("Active « Afficher tous les rangs » dans les options du grimoire du jeu pour voir les anciens rangs. Exemple : Plaie d'agonie affiche BEST sur le plus haut rang appris et LOW sur les autres, sans ECO.") },
      confirmSelection = {
        type = "execute",
        name = L("Valider mes choix"),
        order = 4.8,
        width = "full",
        hidden = function()
          return SAK.EnsureDB().levelingDraft == nil or (SAK.StartupFooter and SAK.StartupFooter.IsVisible())
        end,
        disabled = function()
          return (InCombatLockdown and InCombatLockdown()) or not SAK.PlayerRoles.SelectionSnapshot()
        end,
        desc = L("Vérifier le récapitulatif avant d'activer les conseils pour ces rôles et spécialisations."),
        func = function() Config.ConfirmSelection() end,
      },
      later = { type = "execute", name = L("Plus tard"), order = 5,
        hidden = function()
          return SAK.EnsureDB().levelingDraft == nil or (SAK.StartupFooter and SAK.StartupFooter.IsVisible())
        end,
        desc = L("Fermer la fenêtre de premier lancement. Tu pourras choisir avec /sam settings."),
        func = function() Config.CloseStartup() end },
    } },
    recentLearning = {
      type = "group", name = L("Apprentissages récents"), order = 2.5,
      args = { summary = { type = "description", order = 1, width = "full",
        name = function() return SAK.RecentLearning and SAK.RecentLearning.Summary() or L("Aucun apprentissage enregistré.") end } },
    },
    patchnotes = {
      type = "group",
      name = "Patchnotes",
      order = 5,
      args = patchnoteGroups(),
    },
    maintenance = {
      type = "group",
      name = L("Réinitialisation"),
      order = 4,
      args = {
        intro = {
          type = "description",
          order = 1,
          fontSize = "medium",
          name = L("Rétablis les réglages ou teste à nouveau le premier lancement. Les sorts du familier et les livres enregistrés sont conservés."),
        },
        defaults = {
          type = "execute",
          name = L("Rétablir les options par défaut"),
          order = 2,
          width = "full",
          desc = L("Réactiver les catégories d'affichage et les conseils. Les rôles sont reproposés selon tes talents actuels ou le leveling conseillé."),
          confirm = true,
          confirmText = L("Rétablir l'affichage, les conseils et les choix de rôle par défaut pour ce personnage ?"),
          disabled = function() return InCombatLockdown and InCombatLockdown() end,
          func = function()
            if Config.ResetDefaults() then
              Config.OfferReload()
            end
          end,
        },
        startup = {
          type = "execute",
          name = L("Relancer le premier lancement"),
          order = 3,
          width = "full",
          desc = L("Effacer les choix de rôle et rouvrir la fenêtre de lancement avec une nouvelle présélection. La fenêtre sera aussi réaffichée au prochain /reload. Les réglages d'affichage restent conservés."),
          confirm = true,
          confirmText = L("Effacer les choix de rôle et relancer la fenêtre de premier lancement ?"),
          disabled = function() return InCombatLockdown and InCombatLockdown() end,
          func = function()
            if Config.RestartFirstUse() then
              Config.OfferReload()
            end
          end,
        },
      },
    },
    diagnostics = { type = "group", name = "Diagnostics", order = 3, args = {
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
    } },
  } }
end

function Config.LaunchReport(callback)
  local dialog = lib("AceConfigDialog-3.0")
  if dialog then dialog:Close(APP) end
  -- Our copyable report windows use DIALOG strata, below the game options.
  -- Close the visible options panel before opening the requested report.
  if not (InCombatLockdown and InCombatLockdown()) then
    if SettingsPanel and SettingsPanel.IsShown and SettingsPanel:IsShown() and HideUIPanel then
      HideUIPanel(SettingsPanel)
    elseif InterfaceOptionsFrame and InterfaceOptionsFrame.IsShown and InterfaceOptionsFrame:IsShown() then
      InterfaceOptionsFrame:Hide()
    end
  end
  callback()
end

function Config.Notify()
  if SAK.StartupFooter then
    SAK.StartupFooter.Refresh()
  end
  if not registered then return end
  local registry = lib("AceConfigRegistry-3.0")
  if registry then registry:NotifyChange(APP) end
end

function Config.Register()
  if panel then return true end
  local config, dialog = lib("AceConfig-3.0"), lib("AceConfigDialog-3.0")
  if not config or not dialog then return false end
  if not registered then
    config:RegisterOptionsTable(APP, Config.Options()) -- /sam remains ours.
    dialog:SetDefaultSize(APP, 620, 620)
    registered = true
  end
  if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    panel, category = dialog:AddToBlizOptions(APP, title)
  elseif InterfaceOptions_AddCategory then
    -- Current upstream AceConfigDialog targets Settings. On older clients feed
    -- the same model into an upstream BlizOptionsGroup without patching Ace3.
    local gui = lib("AceGUI-3.0")
    if gui then
      legacyGroup = gui:Create("BlizOptionsGroup")
      legacyGroup:SetName(title); legacyGroup:SetTitle(title)
      legacyGroup:SetCallback("OnShow", function() dialog:Open(APP, legacyGroup) end)
      legacyGroup:SetCallback("OnHide", function() legacyGroup:ReleaseChildren() end)
      panel = legacyGroup.frame
      InterfaceOptions_AddCategory(panel)
    end
  end
  Config.panel, Config.category = panel, category
  return true
end

function Config.Open(firstUse)
  if not SAK.RankPolicy.GetProfile() then
    SAK.PlayerRoles.InitializeFirstUse()
  end
  if not Config.Register() then return false end
  local dialog = lib("AceConfigDialog-3.0")
  Config.promptOpen = firstUse == true
  Config.Notify()
  if firstUse then
    local db = SAK.EnsureDB()
    db.replayStartupOnLogin = nil
    dialog:Open(APP, "spellbook")
  elseif category and Settings and Settings.OpenToCategory then
    dialog:Close(APP)
    Settings.OpenToCategory(category)
  elseif category and C_SettingsUtil and C_SettingsUtil.OpenSettingsPanel then
    C_SettingsUtil.OpenSettingsPanel(category)
  elseif panel and InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(panel)
  else
    dialog:Open(APP)
  end
  if SAK.StartupFooter then
    SAK.StartupFooter.Refresh()
    Config.Notify()
  end
  return true
end

local function refreshAfterReset()
  if SAK.ClassTrainer then
    SAK.ClassTrainer.MarkDirty()
  end
  if SAK.SpellBook then
    SAK.SpellBook.MarkDirty()
  end
  Config.Notify()
  if SAK.Refresh then
    SAK.Refresh()
  end
end

function Config.ResetDefaults()
  if InCombatLockdown and InCombatLockdown() then
    return false
  end

  local db = SAK.EnsureDB()
  db.replayStartupOnLogin = nil
  if SAK.Launcher then
    SAK.Launcher.ResetDefaults()
  end
  db.language = nil
  db.displayOptions = {}
  db.levelingProfile = nil
  db.levelingDraft = nil
  db.profilePromptSeen = nil
  SAK.PlayerRoles.InitializeFirstUse()
  SAK.RankPolicy.pending = nil
  SAK.RankPolicy.pendingFirstUse = nil
  refreshAfterReset()
  return true
end

function Config.RestartFirstUse()
  if InCombatLockdown and InCombatLockdown() then
    return false
  end

  local db = SAK.EnsureDB()
  db.levelingProfile = nil
  db.levelingDraft = nil
  db.profilePromptSeen = nil
  SAK.RankPolicy.pending = nil
  SAK.RankPolicy.pendingFirstUse = nil
  -- Close the native options before displaying the standalone startup window.
  Config.LaunchReport(function()
    SAK.PlayerRoles.InitializeFirstUse()
    SAK.RankPolicy.ShowSettings(true)
  end)
  -- Keep the next reload useful for reproducing startup behavior.
  db.replayStartupOnLogin = true
  refreshAfterReset()
  return true
end

function Config.OfferReload(message)
  if not StaticPopupDialogs or not StaticPopup_Show then
    return false
  end

  local popupName = APP .. "_RELOAD_SETTINGS"
  StaticPopupDialogs[popupName] = {
    text = message or L("Réinitialisation effectuée. Recharger l'interface maintenant ?\nAvec « Plus tard », tes choix sont conservés et tu peux utiliser /reload quand tu le souhaites."),
    button1 = L("Recharger l'interface"),
    button2 = L("Plus tard"),
    OnAccept = function()
      if InCombatLockdown and InCombatLockdown() then
        print(L("|cffffcc00Skills & More:|r utilise /reload après le combat."))
        return
      end
      if ReloadUI then
        ReloadUI()
      end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnHide = restorePopupLayer,
  }
  local popup = StaticPopup_Show(popupName)
  placePopup(popup)
  return true
end

function Config.ConfirmSelection()
  local snapshot = SAK.PlayerRoles.SelectionSnapshot()
  if not snapshot or not StaticPopupDialogs or not StaticPopup_Show then
    return false
  end

  local labels = SAK.PlayerRoles.Specs[snapshot.class]
  local lines = { L("Confirmer tes choix pour ") .. SAK.ClassRoles.classes[snapshot.class].name .. " ?", "" }
  for _, role in ipairs(SAK.PlayerRoles.Order) do
    local choice = snapshot.roles[role]
    if choice then
      lines[#lines + 1] = SAK.PlayerRoles.Roles[role] .. " : " .. labels[choice.spec]
    end
  end
  lines[#lines + 1] = ""
  for _, advice in ipairs({ {"eco", "ECO"}, {"optional", "OPTIONAL"}, {"buyRank", "BUY NEW RANK"} }) do
    lines[#lines + 1] = advice[2] .. " : " .. (snapshot[advice[1]] and L("activé") or L("désactivé"))
  end

  local popupName = APP .. "_CONFIRM_ROLES"
  StaticPopupDialogs[popupName] = {
    text = table.concat(lines, "\n"),
    button1 = "OK",
    button2 = L("Annuler"),
    OnAccept = function()
      if SAK.PlayerRoles.ConfirmSelection(snapshot) then
        Config.promptOpen = false
        local dialog = lib("AceConfigDialog-3.0")
        if dialog then dialog:Close(APP) end
      end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnHide = restorePopupLayer,
  }
  local popup = StaticPopup_Show(popupName)
  placePopup(popup)
  return true
end

function Config.CloseStartup()
  local dialog = lib("AceConfigDialog-3.0")
  if dialog then
    dialog:Close(APP)
  end
  if SAK.StartupFooter then
    SAK.StartupFooter.Refresh()
  end
end
