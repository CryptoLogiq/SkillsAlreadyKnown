-- Sparse user overrides: character > account/class > shipped advice.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
local Rules = {}
SAK.BadgeRules = Rules
local names = {}
local allowed = {
  usage = { aoe = true, survival = true, class = true, kick = true, taunt = true, aggro = true, tank = true, heal = true, dps = true, none = true },
  combat = { pvp = true, mixed = true, none = true },
  advice = { eco = true, optional = true, none = true },
}

function Rules.SpellName(id)
  if names[id] then return names[id] end
  local api = C_Spell and C_Spell.GetSpellName or GetSpellInfo
  if not api then return end
  local ok, name = pcall(api, id)
  if ok and type(name) == "string" and name ~= "" then names[id] = name; return name end
end

function Rules.Class()
  return select(2, UnitClass("player"))
end

function Rules.Storage(scope, class)
  local db
  if scope == "class" then
    SkillsAlreadyKnownAccountDB = SkillsAlreadyKnownAccountDB or {}
    db = SkillsAlreadyKnownAccountDB
  else
    db = SAK.EnsureDB()
  end
  db.badgeRules = db.badgeRules or {}
  db.badgeRules[class] = db.badgeRules[class] or {}
  return db.badgeRules[class]
end

local function match(rules, id, field)
  local exact = rules[id]
  if exact and exact[field] ~= nil then return exact[field] end
  local name = Rules.SpellName(id)
  if not name then return end
  local ids = {}
  for baseID, rule in pairs(rules) do
    if rule.allRanks and rule[field] ~= nil then ids[#ids + 1] = baseID end
  end
  table.sort(ids)
  for _, baseID in ipairs(ids) do
    if Rules.SpellName(baseID) == name then return rules[baseID][field] end
  end
end

function Rules.Resolve(class, id, field)
  if class ~= Rules.Class() or type(id) ~= "number" then return end
  for _, scope in ipairs({ "character", "class" }) do
    local value = match(Rules.Storage(scope, class), id, field)
    if value ~= nil then return value, scope end
  end
end

function Rules.Refresh()
  if SAK.ContentTags and SAK.ContentTags.MarkDirty then SAK.ContentTags.MarkDirty() end
  if SAK.RankAvailability and SAK.RankAvailability.MarkDirty then SAK.RankAvailability.MarkDirty() end
  if SAK.SpellBook and SAK.SpellBook.MarkDirty then SAK.SpellBook.MarkDirty() end
  if SAK.ClassTrainer and SAK.ClassTrainer.MarkDirty then SAK.ClassTrainer.MarkDirty() end
  if SAK.Settings then SAK.Settings.Notify() end
  if SAK.Refresh then SAK.Refresh() end
end

function Rules.Save(scope, id, rule)
  if scope ~= "character" and scope ~= "class" then return false end
  if type(id) ~= "number" or id < 1 or id ~= math.floor(id) or not Rules.SpellName(id) then return false end
  local copy = { allRanks = rule.allRanks ~= false }
  for field, choices in pairs(allowed) do
    if rule[field] ~= nil and not choices[rule[field]] then return false end
    copy[field] = rule[field]
  end
  local class = Rules.Class()
  if not class then return false end
  local storage = Rules.Storage(scope, class)
  -- A family has one broad rule per scope; exact-rank exceptions remain intact.
  if copy.allRanks then
    for otherID, other in pairs(storage) do
      if otherID ~= id and other.allRanks and Rules.SpellName(otherID) == Rules.SpellName(id) then
        storage[otherID] = nil
      end
    end
  end
  storage[id] = copy
  Rules.Refresh()
  return true
end

function Rules.Remove(scope, id)
  Rules.Storage(scope, Rules.Class())[id] = nil
  Rules.Refresh()
end

function Rules.Reason()
  return L("BADGE_CUSTOM_REASON")
end
