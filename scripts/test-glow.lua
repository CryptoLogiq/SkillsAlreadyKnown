-- Run from the development repository: lua scripts/test-glow.lua
local root=arg[1] or "."
local function setup(mode)
  SkillsAlreadyKnown={Diagnostics={Record=function() end}}
  local calls={show=0,hide=0,play=0,stop=0,created=0}
  local function show() calls.show=calls.show+1; if mode=="error" then error("native glow failed") end end
  local function hide() calls.hide=calls.hide+1 end
  ActionButton_ShowOverlayGlow,ActionButton_HideOverlayGlow,LibStub=nil,nil,nil
  if mode=="native" or mode=="error" then ActionButton_ShowOverlayGlow,ActionButton_HideOverlayGlow=show,hide end
  if mode=="library" then LibStub=setmetatable({}, {__call=function(_,key,silent)
    assert(key=="LibButtonGlow-1.0" and silent)
    return {ShowOverlayGlow=show,HideOverlayGlow=hide}
  end}) end
  CreateFrame=function(_,_,parent)
    calls.created=calls.created+1
    local host={parent=parent}
    function host:EnableMouse(enabled) assert(not enabled) end
    function host:SetFrameLevel(level) self.level=level end
    function host:SetPoint(_,badge) self.badge=badge end
    function host:SetSize(w,h) self.width,self.height=w,h end
    function host:Show() self.shown=true end
    function host:Hide() self.shown=false;if self.onHide then self.onHide() end end
    function host:HookScript(event,fn) assert(event=="OnHide");self.onHide=fn end
    function host:CreateTexture()
      return {SetTexture=function() end,SetBlendMode=function() end,SetPoint=function() end,SetVertexColor=function() end,
        CreateAnimationGroup=function()
          local group={}
          function group:SetLooping(value) assert(value=="REPEAT") end
          function group:CreateAnimation(kind)
            assert(kind=="Alpha")
            return {SetOrder=function() end,SetDuration=function() end,SetFromAlpha=function() end,SetToAlpha=function() end}
          end
          function group:Play() calls.play=calls.play+1 end
          function group:Stop() calls.stop=calls.stop+1 end
          return group
        end}
    end
    return host
  end
  assert(loadfile(root.."/Glow.lua"))()
  return SkillsAlreadyKnown.Glow,calls
end
for _, mode in ipairs({"native","library","fallback","error"}) do
  local glow,calls=setup(mode)
  local row={GetFrameLevel=function() return 10 end}
  local badge={}
  glow.SetBadge(row,badge,"new",40,14)
  local entry=row.sakTrainerGlow
  assert(entry.active and entry.host.parent==row and entry.host.badge==badge and entry.host.level==14)
  local started=calls.show+calls.play
  glow.SetBadge(row,badge,"new",40,14)
  assert(calls.show+calls.play==started,"Must not restart on each repaint")
  glow.SetBadge(row,badge,"known",20,20)
  assert(calls.created==1 and not entry.active and not entry.host.shown)
  glow.Hide(row)
  assert(not entry.active and not entry.host.shown)
  glow.SetBadge(row,badge,"next",36,14)
  assert(not entry.active and not entry.host.shown)
  glow.SetBadge(row,badge,"notnow",52,16)
  assert(not entry.active and not entry.host.shown)
  glow.SetBadge(row,badge,"new",40,14)
  assert(entry.active)
  entry.host.onHide()
  assert(not entry.active)
  if mode=="fallback" or mode=="error" then assert(calls.play>0 and calls.stop>0) end
  print("PASS: "..mode.." glow only for NEW +, reused host, repaint deduplication and hide cleanup")
end
SkillsAlreadyKnown={disabledByDev=true};CreateFrame=function() error("inactive addon must not create frames") end
assert(loadfile(root.."/Glow.lua"))()
assert(SkillsAlreadyKnown.Glow==nil)
print("PASS: inactive official copy does not initialize glows")
