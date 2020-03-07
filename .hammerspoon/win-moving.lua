hs.window.animationDuration = 0
local ww = hs.loadSpoon("WinWin")
ww.gridparts = 20

--==== Moving windows uses 'shift'

---=== Modal versions
--- Window nudging
WSELECT_MODAL:bind("shift", "left",  function() ww:stepMove("left") end)
WSELECT_MODAL:bind("shift", "right", function() ww:stepMove("right") end)
WSELECT_MODAL:bind("shift", "up",    function() ww:stepMove("up") end)
WSELECT_MODAL:bind("shift", "down",  function() ww:stepMove("down") end)

---=== Non-modal versions (for navigation speed)
--- Move window to other screen
WSELECT_MODAL:bind("shift", "[", function() ww:moveToScreen("left") end)
WSELECT_MODAL:bind("shift", "]", function() ww:moveToScreen("right") end)


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

WSELECT_MODAL:bind("shift", "u", function() lunetteExec("topLeft") end)
WSELECT_MODAL:bind("shift", "m", function() lunetteExec("bottomLeft") end)
WSELECT_MODAL:bind("shift", "o", function() lunetteExec("topRight") end)
WSELECT_MODAL:bind("shift", ".", function() lunetteExec("bottomRight") end)

WSELECT_MODAL:bind("shift", "-", function() lunetteExec("shrink") end)
WSELECT_MODAL:bind("shift", "=", function() lunetteExec("enlarge") end)
WSELECT_MODAL:bind("shift", "n", function() lunetteExec("shrink") end)
WSELECT_MODAL:bind("shift", "h", function() lunetteExec("enlarge") end)

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
    f.h = 50
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
hs.hotkey.bind(ctrlcmdshift, "space", "Shade window", toggleShade)


