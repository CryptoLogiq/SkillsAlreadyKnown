-- SkillsAlreadyKnown: session compatibility observations and support reports.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then return end
local Diagnostics = {}
SAK.Diagnostics = Diagnostics
local addonName = ...
addonName = type(addonName) == "string" and addonName or "SkillsAlreadyKnown"
local baseName = addonName:gsub("_dev$", "")
local observations, byKey = {}, {}
local limit = 25

local function call(fn, ...)
  if type(fn) ~= "function" then return nil end
  local ok, value = pcall(fn, ...)
  if ok then return value end
end

local function api(name)
  return C_AddOns and C_AddOns[name] or _G[name]
end

local function clean(value, maxLength)
  return SAK.CleanText(tostring(value or "unknown")):gsub("[\r\n]", " "):sub(1, maxLength or 300)
end

function Diagnostics.Record(kind, detail)
  kind, detail = clean(kind, 60), clean(detail)
  local key = kind .. ":" .. detail
  local entry = byKey[key]
  if entry then entry.count = entry.count + 1; return end
  if #observations >= limit then
    local oldest = table.remove(observations, 1)
    byKey[oldest.key] = nil
  end
  entry = { key = key, kind = kind, detail = detail, count = 1,
    time = math.floor(call(GetTime) or 0) }
  observations[#observations + 1] = entry
  byKey[key] = entry
end

local surfaces = {
  AlreadyKnown = "known-item markers", TrainerSpells = "trainer display",
  SkillUpForever = "training/learning display", Bagnon = "bags (integration unverified)",
  Baganator = "bags (integration unverified)", BetterBags = "bags (integration unverified)",
  AdiBags = "bags (integration unverified)", ArkInventory = "bags (integration unverified)",
  ElvUI = "replacement UI (integration unverified)",
  EllesmereUIBags = "bags (supported integration)",
  DarkMode = "UI recoloring (conditional compatibility)",
}

local function appendAddons(lines)
  local count = call(api("GetNumAddOns"))
  if type(count) ~= "number" or type(api("GetAddOnInfo")) ~= "function"
    or type(api("IsAddOnLoaded")) ~= "function" then
    lines[#lines + 1] = "Addon enumeration unavailable on this client."
    return
  end
  local loaded = {}
  for i = 1, count do
    local info = call(api("GetAddOnInfo"), i)
    local name = type(info) == "table" and info.name or info
    if type(name) == "string" and call(api("IsAddOnLoaded"), name) then
      local version = call(api("GetAddOnMetadata"), name, "Version")
      loaded[#loaded + 1] = { name = name, version = clean(version, 80) }
    end
  end
  table.sort(loaded, function(a, b) return a.name < b.name end)
  lines[#lines + 1] = "Loaded addons: " .. #loaded
  for _, addon in ipairs(loaded) do
    local surface = surfaces[addon.name]
    lines[#lines + 1] = string.format("addon=%s version=%s%s", clean(addon.name, 100),
      addon.version, surface and (" | shared UI: " .. surface .. "; not proof of a conflict") or "")
  end
end

local function active(namespace)
  return type(namespace) == "table" and not namespace.disabledByDev
    and type(namespace.Refresh) == "function"
end

local function appendChecks(lines)
  local official, dev = _G[baseName], _G[baseName .. "_dev"]
  lines[#lines + 1] = string.format("Runtime: officialActive=%s devActive=%s", tostring(active(official)), tostring(active(dev)))
  if active(official) and active(dev) then
    lines[#lines + 1] = "[DETECTED] Both copies initialized; disable the older official copy and reload."
  end
  if SAK.slashHandler and (not SlashCmdList or SlashCmdList.SKILLSALREADYKNOWN ~= SAK.slashHandler) then
    lines[#lines + 1] = "[DETECTED] The addon slash-command handler was replaced after initialization."
  end
  local aliases = {}
  for key, value in pairs(_G) do
    if type(key) == "string" and type(value) == "string"
      and (value:lower() == "/sam" or value:lower() == "/skillsandmore" or value:lower() == "/skillsalreadyknown") then
      local group = key:match("^SLASH_(.-)%d+$")
      if group and group ~= "SKILLSALREADYKNOWN" then aliases[#aliases + 1] = key .. "=" .. value end
    end
  end
  table.sort(aliases)
  for _, value in ipairs(aliases) do lines[#lines + 1] = "[CHECK] Another command registration: " .. value end
  lines[#lines + 1] = string.format("Modules: trainer=%s grimoires=%s inventory=%s",
    tostring(SAK.ClassTrainer ~= nil), tostring(SAK.PetGrimoires ~= nil), tostring(SAK.Inventory ~= nil))
  lines[#lines + 1] = string.format("UI available: trainer=%s merchant=%s combinedBags=%s",
    tostring(ClassTrainerFrame ~= nil), tostring(MerchantFrame ~= nil), tostring(ContainerFrameCombinedBags ~= nil))
  if SAK.TrainerSpellsBadges then
    local info = SAK.TrainerSpellsBadges.GetDiagnostics()
    lines[#lines + 1] = string.format("TrainerSpells badges: rows=%s shown=%s narrow=%s",
      tostring(info.rows), tostring(info.shown), tostring(info.narrow))
  end
  if SAK.ContentTags and SAK.ContentTags.GetDiagnostics then
    local info = SAK.ContentTags.GetDiagnostics()
    lines[#lines + 1] = string.format("Content tags: talentFrames=%s talentMatches=%s trainerShown=%s",
      tostring(info.visited), tostring(info.matched), tostring(info.trainerShown))
  end
  if SAK.Compatibility then
    local info = SAK.Compatibility.GetDiagnostics()
    lines[#lines + 1] = string.format("DarkMode: loaded=%s protectedTexts=%s protectedTextures=%s trainerTextMode=%s",
      tostring(info.darkModeLoaded), tostring(info.protectedTexts), tostring(info.protectedTextures), tostring(info.trainerTextMode))
  end
  if SAK.ClassTrainer and SAK.ClassTrainer.GetDiagnostics then
    local info = SAK.ClassTrainer.GetDiagnostics()
    lines[#lines + 1] = string.format("Trainer: updateAvailable=%s updateHooked=%s showHooked=%s scrollHooked=%s rowCallbacks=%s lastRows=%s lastMatched=%s initializerHooked=%s",
      tostring(info.updateAvailable), tostring(info.updateHooked), tostring(info.showHooked), tostring(info.scrollHooked),
      tostring(info.rowCallbacks), tostring(info.rows), tostring(info.matched), tostring(info.initializerHooked))
  end
  if SAK.Inventory and SAK.Inventory.GetDiagnostics then
    local info = SAK.Inventory.GetDiagnostics()
    lines[#lines + 1] = string.format("Ellesmere: available=%s registered=%s callbackIntact=%s trackedButtons=%s",
      tostring(info.available), tostring(info.registered), tostring(info.callbackIntact), tostring(info.trackedButtons))
    if info.registered and not info.callbackIntact then
      lines[#lines + 1] = "[DETECTED] The registered Ellesmere overlay callback is missing or replaced."
    elseif info.available and not info.registered then
      lines[#lines + 1] = "[CHECK] Ellesmere is present but its overlay integration is not registered."
    end
  end
end

local function appendErrors(lines)
  lines[#lines + 1] = "Session observations (bounded to the latest 25 distinct entries):"
  if #observations == 0 then lines[#lines + 1] = "No observations recorded; this does not rule out a conflict." end
  for _, entry in ipairs(observations) do
    lines[#lines + 1] = string.format("time=%ss count=%s kind=%s detail=%s", entry.time, entry.count, entry.kind, entry.detail)
  end
  lines[#lines + 1] = "Blocked-action addon names are client observations, not proof of the original cause."
  local grabber = BugGrabber
  if not (grabber and type(grabber.GetDB) == "function" and type(grabber.GetSessionId) == "function") then
    lines[#lines + 1] = "Lua errors: BugGrabber unavailable; global error handling is unchanged."
    return
  end
  local db, session = call(grabber.GetDB, grabber), call(grabber.GetSessionId, grabber)
  if type(db) ~= "table" or session == nil then
    lines[#lines + 1] = "Lua errors: BugGrabber session unavailable."
    return
  end
  local found = 0
  lines[#lines + 1] = "BugGrabber: current-session errors mentioning this addon (up to 10):"
  for i = #db, 1, -1 do
    local err = db[i]
    if type(err) == "table" and err.session == session then
      local message = tostring(err.message or "")
      local stack = tostring(err.stack or "")
      if (message .. stack):lower():find(baseName:lower(), 1, true) then
        found = found + 1
        lines[#lines + 1] = "Lua error: " .. clean(message, 800)
        lines[#lines + 1] = "Stack: " .. clean(stack, 1600)
        if found >= 10 then break end
      end
    end
  end
  if found == 0 then lines[#lines + 1] = "No matching Lua errors in the current BugGrabber session." end
end

function Diagnostics.BuildText()
  local lines = {
    "SAM compatibility report", "",
    "Detected observations and shared-UI candidates are listed separately.",
    "An installed addon is not automatically incompatible. Silent visual conflicts may need manual isolation.", "",
  }
  appendChecks(lines)
  lines[#lines + 1] = ""
  appendErrors(lines)
  lines[#lines + 1] = ""
  appendAddons(lines)
  lines[#lines + 1] = ""
  lines[#lines + 1] = "How to isolate a conflict:"
  lines[#lines + 1] = "1. Reproduce the problem, then Copy Export from /sam conflicts."
  lines[#lines + 1] = "2. Keep this addon and required dependencies enabled; temporarily disable other addons and reload."
  lines[#lines + 1] = "3. If the problem disappears, re-enable half of the other addons, reload, and test again."
  lines[#lines + 1] = "4. Repeat with the failing half, retaining dependencies, until the smallest failing combination remains."
  lines[#lines + 1] = "5. Compare the same steps with/without that combination; share both exports and reproduction steps."
  lines[#lines + 1] = "If the problem remains with this addon alone, report an addon/client issue rather than assuming a conflict."
  return table.concat(lines, "\n")
end

function Diagnostics.ShowWindow()
  SAK.ShowDebugTextWindow("Conflicts", "Skills & More Compatibility", Diagnostics.BuildText(), Diagnostics.BuildText)
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN" }) do
  local ok = pcall(events.RegisterEvent, events, event)
  if not ok then Diagnostics.Record("Unavailable event", event) end
end
events:SetScript("OnEvent", function(_, event, source, action)
  Diagnostics.Record(event, "addon=" .. clean(source, 100) .. " action=" .. clean(action, 150))
end)
