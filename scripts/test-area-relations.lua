SkillsAlreadyKnown = nil
SkillsAlreadyKnownDB = nil
GetLocale = function() return 'frFR' end
UnitClass = function() return 'Paladin', 'PALADIN', 2 end
local names = { [26573] = 'Consécration', [2812] = 'Colère divine' }
local requests, missing = {}, {}
C_Spell = {
  GetSpellName = function(id) return not missing[id] and (names[id] or 'Native spell ' .. id) or nil end,
  GetSpellTexture = function(id) return 100000 + id end,
  GetSpellDescription = function(id) return not missing[id] and 'Native description ' .. id or nil end,
  GetSpellSubtext = function() return 'Rang 1' end,
  RequestLoadSpellData = function(id) requests[id] = (requests[id] or 0) + 1 end,
}
dofile('Core.lua')
dofile('traductions/fr_FR.lua')
dofile('traductions/en-EN.lua')
dofile('Localization.lua')
dofile('data/AreaSpells.lua')
dofile('data/AreaTalents.lua')
dofile('SpellUsage.lua')
local s = SkillsAlreadyKnown
SkillsAlreadyKnownDB = { language = 'en-EN' }
s.Localization.Initialize()
local related = 0
for class, talents in pairs(s.AreaTalents) do
  for _, entry in pairs(talents) do
    if entry.relatedSpells then
      related = related + 1
      assert(#entry.relatedSpells > 0 and entry.source and entry.reviewed)
      local seen = {}
      for _, id in ipairs(entry.relatedSpells) do
        assert(type(id) == 'number' and not seen[id] and id ~= entry.spellID)
        seen[id] = true
      end
    else
      assert(entry.reason == s.L('AOE_TALENT_ACTIVE'), 'Every indirect AoE talent has reviewed spell links')
    end
  end
end
assert(related == 17)
local function tooltip()
  local tip = { lines = {}, hooks = {} }
  function tip:AddLine(text) self.lines[#self.lines + 1] = text end
  function tip:HookScript(event, callback) self.hooks[event] = callback end
  return tip
end
local tip = tooltip()
s.SpellUsage.AddTooltip(tip, 1237268)
assert(tip.lines[1]:find('Reduces the mana cost', 1, true))
assert(tip.lines[2] == 'Affected spells')
assert(tip.lines[3]:find('|T126573:18:18:0:0|t Consécration (Rang 1)', 1, true))
assert(tip.lines[4] == 'Native description 26573')
assert(tip.lines[5]:find('Colère divine', 1, true) and tip.lines[6] == 'Native description 2812')
assert(#tip.lines == 6)
s.SpellUsage.AddTooltip(tip, 1237268); assert(#tip.lines == 6, 'No duplicate descriptions on repeated hooks')
tip.hooks.OnTooltipCleared(tip)
s.SpellUsage.AddTooltip(tip, 1237268); assert(#tip.lines == 12)
missing[26573] = true
for _ = 1, 2 do
  local pending = tooltip()
  s.SpellUsage.AddRelatedSpells(pending, s.AreaTalents.PALADIN[1310905])
  assert(pending.lines[2]:find('Spell 26573', 1, true))
  assert(pending.lines[3] == s.L('AOE_RELATED_PENDING'))
end
assert(requests[26573] == 1, 'Request absent data only once, retry reading on next hover')
missing[26573] = nil
local recovered = tooltip()
s.SpellUsage.AddRelatedSpells(recovered, s.AreaTalents.PALADIN[1310905])
assert(recovered.lines[3] == 'Native description 26573', 'Do not cache missing descriptions')
C_Spell.GetSpellDescription = nil
GetSpellDescription = function() return 'Legacy spell description' end
local legacy = tooltip()
s.SpellUsage.AddRelatedSpells(legacy, s.AreaTalents.PALADIN[1310905])
assert(legacy.lines[3] == 'Legacy spell description')
local noRelation = tooltip()
s.SpellUsage.AddRelatedSpells(noRelation, { tag = 'aoe' })
assert(#noRelation.lines == 0, 'Custom usage badges do not invent inherited relationships')
s.EnsureDB().displayOptions.aoe = false
local hidden = tooltip()
s.SpellUsage.AddTooltip(hidden, 1237268)
assert(#hidden.lines == 0)
print('PASS: 17 reviewed indirect AoE talents, icons/native descriptions, reference ranks, language override, missing data, legacy API and recycled tooltips')
