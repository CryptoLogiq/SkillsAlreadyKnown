-- Compact role label to the left of the active native spellbook school title.
local SAK = SkillsAlreadyKnown
if SAK.disabledByDev then
  return
end

local Roles = {}
SAK.SpellBookRoles = Roles
local display

local function visible(frame)
  return frame and (not frame.IsVisible or frame:IsVisible())
    and (not frame.GetAlpha or frame:GetAlpha() > 0)
    and (not frame.GetEffectiveAlpha or frame:GetEffectiveAlpha() > 0)
end

local function findTitle(root, names)
  local best, match, largest = nil, nil, -1
  local visited = 0
  local function visit(frame, depth)
    if not visible(frame) or depth > 8 or visited >= 500 then return end
    if frame.IsForbidden and frame:IsForbidden() then return end
    visited = visited + 1
    if frame.GetRegions then
      for _, region in ipairs({frame:GetRegions()}) do
        if visible(region) and region.GetText then
          local text = region:GetText()
          local entry = type(text) == "string" and names[SAK.NormalizeText(SAK.CleanText(text))]
          if entry then
            local size = 0
            if region.GetFont then
              local _, fontSize = region:GetFont()
              size = tonumber(fontSize) or 0
            end
            if size > largest then
              best, match, largest = region, entry, size
            end
          end
        end
      end
    end
    if frame.GetChildren then
      for _, child in ipairs({frame:GetChildren()}) do visit(child, depth + 1) end
    end
  end
  visit(root, 0)
  return best, match
end

local function hide()
  if display then display:Hide() end
end

function Roles.Refresh()
  local book = PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame
  local content = book and book.PagedSpellsFrame
  if not visible(book) or not visible(content) then hide(); return end
  if SAK.DisplayEnabled and (not SAK.DisplayEnabled("text") or not SAK.DisplayEnabled("iconsSpellbook")) then
    hide()
    return
  end
  if book.bookType == "pet" then hide(); return end

  local _, class = UnitClass("player")
  local title, entry = findTitle(content, SAK.TalentTooltips.TreeNames(class))
  if not title then hide(); return end
  local roles, tree = SAK.TalentRoles.RolesForTree(class, entry.index)
  if not roles or #roles == 0 then hide(); return end

  if not display then
    display = SAK.TalentRoles.CreateRoleDisplay()
    display.text:SetFontObject("GameFontNormalSmall")
    display.text:SetJustifyH("CENTER")
    display.leveling:Hide()
  end

  local labels = SAK.PlayerRoles.RoleLabels()
  local text = {}
  for _, role in ipairs(roles) do
    local label = labels[role]
    if SAK.DisplayEnabled and not SAK.DisplayEnabled("icons") then
      label = label:gsub("|T.-|t%s*", "")
    elseif #roles == 1 then
      label = label:gsub(":16:16:", ":20:20:", 1)
    end
    text[#text + 1] = label
  end
  display.roles, display.specs = roles, tree.specs
  display.class, display.treeName = class, tree.name
  display.text:SetText(table.concat(text, "\n"))
  display:SetSize(64, #roles > 1 and 44 or 36)
  local outlines = not SAK.DisplayEnabled or SAK.DisplayEnabled("outlines")
  local backgrounds = not SAK.DisplayEnabled or SAK.DisplayEnabled("backgrounds")
  display:SetBackdropBorderColor(1, 0.78, 0.15, outlines and 1 or 0)
  display:SetBackdropColor(0.06, 0.04, 0.01, backgrounds and 0.65 or 0)

  local offset = -8
  if title.GetWidth and title.GetStringWidth and title.GetJustifyH then
    local spare = math.max(0, title:GetWidth() - title:GetStringWidth())
    local alignment = title:GetJustifyH()
    if alignment == "CENTER" then offset = offset + spare / 2
    elseif alignment == "RIGHT" then offset = offset + spare end
  end
  display:ClearAllPoints()
  display:SetPoint("RIGHT", title, "LEFT", offset, 0)
  SAK.SpellBook.PrepareOverlay(display, title)
  if not title.GetEffectiveScale and book.GetEffectiveScale and UIParent.GetEffectiveScale then
    display:SetScale(book:GetEffectiveScale() / UIParent:GetEffectiveScale())
  end
  display:Show()
end
