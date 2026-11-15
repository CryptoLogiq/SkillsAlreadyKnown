-- Audit notes, not runtime data. Readable sources are also beside UtilitySpells entries.
return {
  reviewed = "2026-11-15",
  edition = "WoW Forever",
  classesReviewed = { "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR" },
  exclusions = {
    { name = "Maul", reason = "Current native text does not explicitly state additional threat; do not infer the badge from Classic reputation.", source = "https://www.wowhead.com/forever/spell=6807/maul" },
    { name = "Demoralizing Shout", reason = "No explicit additional threat; Forever guide says the former threat modifier is absent.", source = "https://www.wowhead.com/forever/guide/classes/warrior/protection/level-20-tank-overview" },
    { name = "Feral Charge (Cat)", reason = "Cat variant does not interrupt. Bear entry is exact-only.", source = "https://www.wowhead.com/forever/news/druid-and-hunter-class-deep-dives-in-world-of-warcraft-forever-383190" },
    { name = "Hunter controls / Priest Silence / Paladin Hammer of Justice", reason = "Do not label every silence, stun or disorient as a school-lock interrupt. No verified general KICK entry added for these classes." },
    { name = "Way of Earth / tank Earth Shock variant", reason = "Generic spell database can retain SoD-era records; not evidence of current availability in Forever." },
  },
  distinctions = {
    "Counterspell and baseline Earth Shock explicitly interrupt and generate high threat: KICK / AGGRO.",
    "Distracting Shot and pet Growl/Torment use threat, not tank-style forced taunts.",
    "Mocking Blow and challenging cries force attacks temporarily without guaranteeing threat equalization.",
    "Righteous Fury is a threat multiplier, not a direct taunt; Seal of Fury taunts through Judgement only.",
  },
}
