hs.window.animationDuration = 0
local ww = hs.loadSpoon("WinWin")
ww.gridparts = 20

--==== Moving windows uses 'shift'

---=== Modal versions
WSELECT_MODAL:bind("ctrl", "z", ww.undo)

-- hs.grid.setMargins('5,5')
hs.grid.setGrid('20x20')
local function snapWindows()
  for i,win in ipairs(hs.window.visibleWindows()) do
      hs.grid.snap(win)
  end
  -- cascadeOverlappingWindows()
end
WSELECT_MODAL:bind("shift", "s", "Snap windows", snapWindows)
-- WSELECT_MODAL:bind("shift", "f", hs.grid.show)

--- Window nudging
local function nudgeLeft()  ww:stepMove("left")  end
local function nudgeRight() ww:stepMove("right") end
local function nudgeUp()    ww:stepMove("up")    end
local function nudgeDown()  ww:stepMove("down")  end
WSELECT_MODAL:bind("shift", "left",  nil, nudgeLeft, nudgeLeft, nudgeLeft)
WSELECT_MODAL:bind("shift", "right", nil, nudgeRight, nudgeRight, nudgeRight)
WSELECT_MODAL:bind("shift", "up",    nil, nudgeUp, nudgeUp, nudgeUp)
WSELECT_MODAL:bind("shift", "down",  nil, nudgeDown, nudgeDown, nudgeDown)

---=== Non-modal versions (for navigation speed)
--- Move window to other screen
-- WSELECT_MODAL:bind("shift", "[", nil, function() ww:moveToScreen("left") end)
-- WSELECT_MODAL:bind("shift", "]", nil, function() ww:moveToScreen("right") end)

-- local function resize(deltaX, deltaY)
--   local window = hs.window.focusedWindow()
--   local frame = window:frame()
--   frame.w = frame.w + deltaX
--   frame.h = frame.h + deltaY
--   window:setFrame(frame)
-- end

-- local xIncr=20
-- local yIncr=20
-- local function resizeLeft()  resize(-xIncr,0) end
-- local function resizeRight() resize(xIncr,0) end
-- local function resizeUp()    resize(0,-yIncr) end
-- local function resizeDown()  resize(0,yIncr) end

local function resizeLeft()  ww:stepResize("left" ) end
local function resizeRight() ww:stepResize("right") end
local function resizeUp()    ww:stepResize("up"   ) end
local function resizeDown()  ww:stepResize("down" ) end

WSELECT_MODAL:bind("alt-shift", "j", nil, resizeLeft, resizeLeft, resizeLeft)
WSELECT_MODAL:bind("alt-shift", "l", nil, resizeRight, resizeRight, resizeRight)
WSELECT_MODAL:bind("alt-shift", "i", nil, resizeUp, resizeUp, resizeUp)
WSELECT_MODAL:bind("alt-shift", "k", nil, resizeDown, resizeDown, resizeDown)

WSELECT_MODAL:bind("alt-shift", "left",  nil, resizeLeft, resizeLeft, resizeLeft)
WSELECT_MODAL:bind("alt-shift", "right", nil, resizeRight, resizeRight, resizeRight)
WSELECT_MODAL:bind("alt-shift", "up",    nil, resizeUp, resizeUp, resizeUp)
WSELECT_MODAL:bind("alt-shift", "down",  nil, resizeDown, resizeDown, resizeDown)


--==== Moving across spaces uses 'ctrl'
local spaces=require('spaces')

---=== Modal versions
--- Move window to other space
WSELECT_MODAL:bind("ctrl-shift", "u",     "Moved left",  nil, function() spaces:moveWindowOneSpace("left", true) end)
WSELECT_MODAL:bind("ctrl-shift", "o",     "Moved right", nil, function() spaces:moveWindowOneSpace("right", true) end)
WSELECT_MODAL:bind("ctrl-shift", "left",  "Moved left",  nil, function() spaces:moveWindowOneSpace("left", true) end)
WSELECT_MODAL:bind("ctrl-shift", "right", "Moved right", nil, function() spaces:moveWindowOneSpace("right", true) end)

---=== Non-modal versions (for navigation speed)
--- Move window to other space; BetterTouchTool does this better because window doesn't disapper
hs.hotkey.bind(ctrlcmdshift, "u",     "Moved left",  nil, function() spaces:moveWindowOneSpace("left", true) end)
hs.hotkey.bind(ctrlcmdshift, "o",     "Moved right", nil, function() spaces:moveWindowOneSpace("right", true) end)
hs.hotkey.bind(ctrlcmdshift, "left",  "Moved left",  nil, function() spaces:moveWindowOneSpace("left", true) end)
hs.hotkey.bind(ctrlcmdshift, "right", "Moved right", nil, function() spaces:moveWindowOneSpace("right", true) end)


-- https://github.com/scottwhudson/Lunette/
local lunette_cmd = dofile("Spoons/Lunette.spoon/command.lua")
local function lunetteExec(commandName)
  local window = hs.window.focusedWindow()
  local newFrame

  if commandName == "undo" then
    newFrame = self.history:retrievePrevState()
  elseif commandName == "redo" then
    newFrame = self.history:retrieveNextState()
  else
    -- print("Lunette: " .. commandName)
    -- newFrame = self.Command[commandName](window:frame(), window:screen():frame())
    newFrame = lunette_cmd[commandName](window:frame(), window:screen():frame())
    -- self.history:push(window:frame(), newFrame)
  end
  window:setFrame(newFrame)
end

WSELECT_MODAL:bind("shift", "j", function() lunetteExec("leftHalf") end)
-- WSELECT_MODAL:bind("shift", "space", function() lunetteExec("center") end)
WSELECT_MODAL:bind("shift", ";", function() lunetteExec("center") end)
WSELECT_MODAL:bind("shift", "l", function() lunetteExec("rightHalf") end)

WSELECT_MODAL:bind("shift", "i", function() lunetteExec("topHalf") end)
WSELECT_MODAL:bind("shift", "k", function() lunetteExec("bottomHalf") end)
WSELECT_MODAL:bind("shift", ",", function() lunetteExec("bottomHalf") end)

hs.hotkey.bind(hypershift, "j",   "Snap left",  nil, function() lunetteExec("leftHalf") end)
hs.hotkey.bind(hypershift, ";", "Snap center",  nil, function() lunetteExec("center") end)
hs.hotkey.bind(hypershift, "l",  "Snap right",  nil, function() lunetteExec("rightHalf") end)
hs.hotkey.bind(hypershift, "i",    "Snap top",  nil, function() lunetteExec("topHalf") end)
hs.hotkey.bind(hypershift, "k", "Snap bottom",  nil, function() lunetteExec("bottomHalf") end)
hs.hotkey.bind(hypershift, ",", "Snap bottom",  nil, function() lunetteExec("bottomHalf") end)

WSELECT_MODAL:bind("shift", "u", function() lunetteExec("topLeft") end)
WSELECT_MODAL:bind("shift", "m", function() lunetteExec("bottomLeft") end)
WSELECT_MODAL:bind("shift", "o", function() lunetteExec("topRight") end)
WSELECT_MODAL:bind("shift", ".", function() lunetteExec("bottomRight") end)

hs.hotkey.bind(hypershift, "u",     "Snap topLeft",  nil, function() lunetteExec("topLeft") end)
hs.hotkey.bind(hypershift, "m",  "Snap bottomLeft",  nil, function() lunetteExec("bottomLeft") end)
hs.hotkey.bind(hypershift, "o",    "Snap topRight",  nil, function() lunetteExec("topRight") end)
hs.hotkey.bind(hypershift, ".", "Snap bottomRight",  nil, function() lunetteExec("bottomRight") end)

WSELECT_MODAL:bind("shift", "-", function() lunetteExec("shrink") end)
WSELECT_MODAL:bind("shift", "=", function() lunetteExec("enlarge") end)
WSELECT_MODAL:bind("shift", "n", function() lunetteExec("shrink") end)
WSELECT_MODAL:bind("shift", "h", function() lunetteExec("enlarge") end)

hs.hotkey.bind(hypershift, "n",  "Shrink",  nil, function() lunetteExec("shrink") end)
hs.hotkey.bind(hypershift, "h", "Enlarge",  nil, function() lunetteExec("enlarge") end)

WSELECT_MODAL:bind("shift", "return", function() lunetteExec("fullScreen") end)


--- toggle (simulated) window shading
local shadeHeightTab = {
  ["Sublime Text"] = 100,
  ["Google Chrome"] = 10,
  ["Safari"] = 10
}
local frameDimsTab = {}
local function toggleShade()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  -- local screen = win:screen()
  -- local max = screen:frame()
  -- print("f.height = " .. tostring(frameDimsTab[win:id()] and frameDimsTab[win:id()].isSmall or "-") )
  if not frameDimsTab[win:id()] or not frameDimsTab[win:id()].isSmall then
    frameDimsTab[win:id()]=f:copy()
    frameDimsTab[win:id()].isSmall=true
    f.h = 10
    -- print(win:application():name().." "..shadeHeightTab[win:application():name()])
    if win:application() and shadeHeightTab[win:application():name()] then
      f.h = shadeHeightTab[win:application():name()]
    end
  else
    f.h = frameDimsTab[win:id()].h
    frameDimsTab[win:id()].isSmall = nil
  end
  win:setFrame(f)
end

WSELECT_MODAL:bind("shift", "space", "Shade window", toggleShade)
hs.hotkey.bind({'cmd','option'}, "space", "Shade window", toggleShade)


