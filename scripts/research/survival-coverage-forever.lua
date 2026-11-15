-- Runtime catalogue is data/SurvivalAdvice.lua; do not maintain a second spell list.
return {
  reviewed = "2026-11-15",
  catalogue = "data/SurvivalAdvice.lua",
  coverage = { classes = 9, spellFamilies = 56 },
  criteria = {
    "Temporary immunities, damage absorption/mitigation, escape or threat reduction.",
    "Defensive control and emergency sustain with contextual caveats.",
    "Survival can protect an ally or pet; the reason must say so explicitly.",
    "Does not imply rank 1 suffices, universal necessity or guaranteed survival.",
  },
  verifiedAliases = { [498] = {5573}, [642] = {1020} },
  exclusions = {
    { spellID = 1719, name = "Recklessness", reason = "Offensive cooldown with defensive risks; not classified as survival." },
    { spellID = 1454, name = "Life Tap", reason = "Converts health into mana; indirect sustain does not justify a direct survival label." },
    { spellID = 19752, name = "Divine Intervention", reason = "Sacrifices the caster; do not present it as personal survival." },
    { spellID = 45438, name = "Ice Block in other editions", reason = "Forever’s reviewed talent anchor is 11958; do not import expansion-specific IDs." },
  },
}
