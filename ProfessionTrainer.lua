-- Profession milestones come from the trainer API, not character-level intervals.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local ProfessionTrainer = {}
SAK.ProfessionTrainer = ProfessionTrainer

function ProfessionTrainer.NextStepIndex()
  if not GetTrainerServiceStepIndex then
    return nil
  end
  if IsTradeskillTrainer then
    local ok, profession = pcall(IsTradeskillTrainer)
    if ok and not profession then return nil end
  end

  local ok, index = pcall(GetTrainerServiceStepIndex)
  if not ok or type(index) ~= "number" or index < 1 or index % 1 ~= 0 then
    return nil
  end
  if GetNumTrainerServices then
    local success, count = pcall(GetNumTrainerServices)
    if success and type(count) == "number" and index > count then return nil end
  end
  return index
end

function ProfessionTrainer.IsNextStep(index)
  local nextIndex = ProfessionTrainer.NextStepIndex()
  return nextIndex ~= nil and nextIndex == index
end
