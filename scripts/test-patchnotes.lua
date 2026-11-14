-- Run: lua scripts/test-patchnotes.lua
local root = arg[1] or "."
UnitClass = function() return "Mage", "MAGE" end
for _, file in ipairs({"Core.lua", "data/Patchnotes.lua", "data/ClassRoles.lua",
  "data/RankOneAdvice.lua", "PlayerRoles.lua", "RankPolicy.lua", "Settings.lua"}) do
  assert(loadfile(root .. "/" .. file))()
end
local s = SkillsAlreadyKnown
local toc = assert(io.open(root .. "/SkillsAlreadyKnown.toc")):read("*a")
local version = assert(toc:match("## Version:%s*([^%s]+)"))
assert(#s.Patchnotes >= 8 and s.Patchnotes[1].status == "development")
assert(s.Patchnotes[1].basedOn == version and s.Patchnotes[2].version == version)
local groups = s.Settings.Options().args.patchnotes.args
for index, entry in ipairs(s.Patchnotes) do
  local group = groups["version" .. index]
  if #entry.additions + #entry.fixes == 0 then
    assert(group == nil, "Empty versions must stay hidden")
  else
  assert(group and group.order == index)
  for _, key in ipairs({"additions", "fixes"}) do
    if #entry[key] == 0 then
      assert(not group.args[key])
    else
      local text = group.args[key].args.notes.name
      for _, note in ipairs(entry[key]) do
        assert(type(note) == "string" and #note > 0)
        assert(text:find(note, 1, true))
      end
    end
  end
  end
end
SkillsAlreadyKnown = {disabledByDev=true}
assert(loadfile(root .. "/data/Patchnotes.lua"))()
assert(SkillsAlreadyKnown.Patchnotes == nil)
print("PASS: version history, explicit development status, feature/fix sections, empty section omission and inactive official guard")
