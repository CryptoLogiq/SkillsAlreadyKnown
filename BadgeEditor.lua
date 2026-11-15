-- AceConfig editor for the current class; edits are a draft until Save.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
local Editor = {}
SAK.BadgeEditor = Editor
local draft = { scope = "character", allRanks = true, filter = "all" }
local fields = { "usage", "combat", "advice" }

local function rules() return SAK.BadgeRules end
local function choose(id)
  draft.id = id
  draft.input = id and tostring(id) or ""
  local saved = id and rules().Storage(draft.scope, rules().Class())[id]
  draft.allRanks = not saved or saved.allRanks ~= false
  for _, field in ipairs(fields) do draft[field] = saved and saved[field] or nil end
end
local function notify() if SAK.Settings then SAK.Settings.Notify() end end

local function defaults()
  local class, ids = rules().Class(), {}
  local function add(list)
    for id, entry in pairs(list or {}) do
      ids[entry.spellID or entry.baseID or id] = true
    end
  end
  for _, catalogue in ipairs({ SAK.AreaSpells or {}, SAK.AreaTalents or {}, SAK.SurvivalAdvice or {}, SAK.ClassSkills or {}, SAK.UtilitySpells or {}, SAK.RoleStances or {} }) do
    add(catalogue[class])
  end
  local content = SAK.ContentUsage and SAK.ContentUsage.classes[class]
  if content then add(content.spells); add(content.talents) end
  for _, spec in pairs(SAK.LevelingAdvice and SAK.LevelingAdvice[class] or {}) do add(spec.spells) end
  for id in pairs(SAK.RankOneRules and SAK.RankOneRules[class] or {}) do ids[id] = true end
  for _, scope in ipairs({ "character", "class" }) do
    for id in pairs(rules().Storage(scope, class)) do ids[id] = true end
  end
  if draft.id then ids[draft.id] = true end
  return ids
end

local function matches(id)
  if draft.filter == "all" then return true end
  local class = rules().Class()
  local field = (draft.filter == "eco" or draft.filter == "optional") and "advice"
    or (draft.filter == "pvp" or draft.filter == "mixed") and "combat" or "usage"
  local override = rules().Resolve(class, id, field)
  if override then return override == draft.filter end
  if field == "usage" then
    local entry = SAK.SpellUsage and SAK.SpellUsage.ForSpell(class, id)
    if not entry then return false end
    for _, tag in ipairs(entry.tags or { entry.tag }) do if tag == draft.filter then return true end end
    return false
  elseif field == "combat" then
    local entry = SAK.ContentTags and SAK.ContentTags.ForSpell(class, id)
    return entry and entry.tag == draft.filter
  end
  for _, spec in pairs(SAK.LevelingAdvice and SAK.LevelingAdvice[class] or {}) do
    for _, spell in ipairs(spec.spells) do
      if spell.baseID == id and ((draft.filter == "eco" and spell.category == "rang_1_suffisant")
        or (draft.filter == "optional" and spell.category ~= "rang_1_suffisant")) then return true end
    end
  end
  return draft.filter == "eco" and SAK.RankOneRules and SAK.RankOneRules[class] and SAK.RankOneRules[class][id]
end

function Editor.List()
  local list = {}
  for id in pairs(defaults()) do
    if matches(id) then list[id] = (rules().SpellName(id) or ("#" .. id)) .. " (" .. id .. ")" end
  end
  return list
end

local function validateID(text)
  local id = tonumber(text)
  if not id or id < 1 or id ~= math.floor(id) then return L("BADGE_INVALID_ID") end
  if not rules().SpellName(id) then
    if C_Spell and C_Spell.RequestLoadSpellData then C_Spell.RequestLoadSpellData(id) end
    return L("BADGE_UNKNOWN_ID")
  end
  return true
end

function Editor.ResetDraft()
  draft.scope, draft.filter = "character", "all"
  choose(nil)
end

function Editor.Options()
  local function selector(field, name, values, order)
    return { type = "select", name = name, values = values, order = order, width = "full",
      disabled = function() return not draft.id end,
      get = function() return draft[field] or "default" end,
      set = function(_, value) draft[field] = value ~= "default" and value or nil end }
  end
  local common = { default = L("BADGE_INHERIT"), none = L("BADGE_NONE") }
  local function choices(extra)
    local result = {}; for k,v in pairs(common) do result[k] = v end
    for k,v in pairs(extra) do result[k] = v end; return result
  end
  return { type = "group", name = L("BADGE_EDITOR_TITLE"), order = 2.2, args = {
    intro = { type = "description", order = 1, name = L("BADGE_EDITOR_HELP") },
    class = { type = "description", order = 1.1, name = function()
      local name = UnitClass("player"); return string.format(L("BADGE_CURRENT_CLASS"), name or rules().Class()) end },
    scope = { type = "select", name = L("BADGE_SCOPE"), order = 2, width = "full",
      values = { character = L("BADGE_SCOPE_CHARACTER"), class = L("BADGE_SCOPE_CLASS") },
      get = function() return draft.scope end,
      set = function(_,value) draft.scope = value; choose(draft.id); notify() end },
    precedence = { type = "description", order = 2.1, name = L("BADGE_PRECEDENCE") },
    filter = { type = "select", name = L("BADGE_FILTER"), order = 3, width = "full",
      values = { all = L("BADGE_ALL"), aoe = "AOE", survival = "SURVIVAL", class = "CLASS", kick = "KICK", taunt = "TAUNT", aggro = "AGGRO", tank = "TANK", heal = "HEAL", dps = "DPS", eco = "ECO", optional = "OPTIONAL", pvp = "PVP", mixed = "PVE PVP" },
      get = function() return draft.filter end,
      set = function(_,value) draft.filter = value; choose(nil); notify() end },
    spell = { type = "select", name = L("BADGE_SPELL"), order = 4, width = "full",
      values = Editor.List, get = function() return draft.id end,
      set = function(_,id) choose(id); notify() end },
    add = { type = "input", name = L("BADGE_ADD_ID"), desc = L("BADGE_ADD_HELP"), order = 5, width = "full",
      validate = function(_,value) return validateID(value) end,
      get = function() return draft.input or "" end,
      set = function(_,value) draft.input = value; draft.filter = "all"; choose(tonumber(value)); notify() end },
    ranks = { type = "toggle", name = L("BADGE_ALL_RANKS"), desc = L("BADGE_RANK_HELP"), order = 6, width = "full",
      get = function() return draft.allRanks end, set = function(_,value) draft.allRanks = value end },
    effective = { type = "description", order = 6.1, name = function()
      if not draft.id then return "" end
      local parts = {}
      for _,field in ipairs(fields) do
        local value,scope = rules().Resolve(rules().Class(),draft.id,field)
        if value == nil then
          local class = rules().Class()
          if field == "usage" then
            local entry = SAK.SpellUsage and SAK.SpellUsage.ForSpell(class,draft.id)
            value = entry and (entry.tags and table.concat(entry.tags, " / ") or entry.tag) or "none"
          elseif field == "combat" then
            local entry = SAK.ContentTags and SAK.ContentTags.ForSpell(class,draft.id)
            value = entry and entry.tag or "none"
          else
            value = SAK.RankPolicy and SAK.RankPolicy.PurchaseAdvice(class,draft.id) or "none"
          end
        end
        parts[#parts+1] = string.format(L("BADGE_EFFECTIVE_FIELD"),
          L("BADGE_FIELD_"..field), value == "none" and L("BADGE_NONE") or value == "mixed" and "PVE PVP" or (value and value:upper()) or L("BADGE_DEFAULT"),
          scope == "character" and L("BADGE_SCOPE_CHARACTER") or scope == "class" and L("BADGE_SCOPE_CLASS") or L("BADGE_DEFAULT"))
      end
      return table.concat(parts,"\n")
    end },
    usage = selector("usage", L("BADGE_FIELD_usage"), choices({aoe="AOE",survival="SURVIVAL",class="CLASS",kick="KICK",taunt="TAUNT",aggro="AGGRO",tank="TANK",heal="HEAL",dps="DPS"}),7),
    combat = selector("combat", L("BADGE_FIELD_combat"), choices({pvp="PVP",mixed="PVE PVP"}),8),
    advice = selector("advice", L("BADGE_FIELD_advice"), choices({eco="ECO",optional="OPTIONAL"}),9),
    save = { type = "execute", name = L("BADGE_SAVE"), order = 10,
      disabled = function() return not draft.id end,
      func = function() if rules().Save(draft.scope,draft.id,draft) then draft.filter = "all"; choose(draft.id); notify() end end },
    reset = { type = "execute", name = L("BADGE_RESTORE"), order = 11,
      disabled = function() return not draft.id or not rules().Storage(draft.scope,rules().Class())[draft.id] end,
      confirm = function() return L("BADGE_RESTORE_CONFIRM") end,
      func = function() rules().Remove(draft.scope,draft.id); choose(draft.id); notify() end },
  } }
end
