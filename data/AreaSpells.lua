-- Area damage and cleave families; first-rank IDs, never rank-number ordering.
local SAK = SkillsAlreadyKnown
local L = SAK.L or function(key) return key end
if SAK.disabledByDev then return end
SAK.AreaSpells = {
  DRUID = {
    [779] = { spellID = 779, name = "Swipe", tag = "aoe", reason = L("AOE_MELEE") },
    [16914] = { spellID = 16914, name = "Hurricane", tag = "aoe", reason = L("AOE_CHANNEL") },
  },
  HUNTER = {
    [13813] = { spellID = 13813, name = "Explosive Trap", tag = "aoe", reason = L("AOE_GROUND") },
    [2643] = { spellID = 2643, name = "Multi-Shot", tag = "aoe", reason = L("AOE_MULTITARGET") },
    [1510] = { spellID = 1510, name = "Volley", tag = "aoe", reason = L("AOE_CHANNEL") },
  },
  MAGE = {
    [10] = { spellID = 10, name = "Blizzard", tag = "aoe", reason = L("AOE_CHANNEL") },
    [1449] = { spellID = 1449, name = "Arcane Explosion", tag = "aoe", reason = L("AOE_AROUND") },
    [2120] = { spellID = 2120, name = "Flamestrike", tag = "aoe", reason = L("AOE_GROUND") },
    [120] = { spellID = 120, name = "Cone of Cold", tag = "aoe", reason = L("AOE_CONE") },
  },
  PALADIN = {
    [26573] = { spellID = 26573, name = "Consecration", tag = "aoe", reason = L("AOE_AROUND") },
    [2812] = { spellID = 2812, name = "Holy Wrath", tag = "aoe", reason = L("AOE_UNDEAD_DEMON") },
  },
  PRIEST = {
    [15237] = { spellID = 15237, name = "Holy Nova", tag = "aoe", reason = L("AOE_AROUND") },
  },
  ROGUE = {
    [13877] = { spellID = 13877, name = "Blade Flurry", tag = "aoe", reason = L("AOE_CLEAVE") },
  },
  SHAMAN = {
    [421] = { spellID = 421, name = "Chain Lightning", tag = "aoe", reason = L("AOE_MULTITARGET") },
    [408341] = { spellID = 408341, name = "Fire Nova", tag = "aoe", reason = L("AOE_FIRE_NOVA") },
    [8190] = { spellID = 8190, name = "Magma Totem", tag = "aoe", reason = L("AOE_TOTEM") },
  },
  WARLOCK = {
    [5740] = { spellID = 5740, name = "Rain of Fire", tag = "aoe", reason = L("AOE_CHANNEL") },
    [1949] = { spellID = 1949, name = "Hellfire", tag = "aoe", reason = L("AOE_SELF_DAMAGE") },
  },
  WARRIOR = {
    [845] = { spellID = 845, name = "Cleave", tag = "aoe", reason = L("AOE_CLEAVE") },
    [1680] = { spellID = 1680, name = "Whirlwind", tag = "aoe", reason = L("AOE_MELEE") },
    [6343] = { spellID = 6343, name = "Thunder Clap", tag = "aoe", reason = L("AOE_AROUND") },
  },
}
if SAK.Localization then SAK.Localization.RegisterTable(SAK.AreaSpells) end
