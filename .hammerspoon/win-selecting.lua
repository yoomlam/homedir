
--==== Selecting/Navigating to does not use 'shift', which is reserved for moving windows

---=== Modal versions
--- Change focus
-- http://www.hammerspoon.org/docs/hs.window.html#focusWindowEast
WSELECT_MODAL:bind(nil, "j",     "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
WSELECT_MODAL:bind(nil, "l",     "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
WSELECT_MODAL:bind(nil, "i",     "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)
WSELECT_MODAL:bind(nil, "k",     "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)
WSELECT_MODAL:bind(nil, "h",     "Focus leftish",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, ";",     "Focus rightish", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- WSELECT_MODAL:bind(nil, "left",  "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
-- WSELECT_MODAL:bind(nil, "right", "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
-- WSELECT_MODAL:bind(nil, "up",    "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)
-- WSELECT_MODAL:bind(nil, "down",  "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)

---=== Non-modal versions (for navigation speed)
--- Change focus
hs.hotkey.bind(cmdopt, "j",     "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
hs.hotkey.bind(cmdopt, "l",     "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, true) end)
-- Conflicts with Chrome Dev Tools: hs.hotkey.bind(cmdopt, "i",     "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)
hs.hotkey.bind(cmdopt, "k",     "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, true) end)
hs.hotkey.bind(cmdopt, "h",     "Focus leftish",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
hs.hotkey.bind(cmdopt, ";",     "Focus rightish", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(hyper, "left",  "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(hyper, "right", "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(hyper, "up",    "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(hyper, "down",  "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)


--==== Moving across spaces uses 'ctrl'
function moveOneSpace(direction)
    -- rely on setting this in MacOS: System Preferences > Keyboard > Shortcuts > Mission Control
    if direction == "left" then
        hs.eventtap.keyStroke(hyper, "u")
    else
        hs.eventtap.keyStroke(hyper, "o")
    end
end

---=== Modal versions
WSELECT_MODAL:bind(nil, "u",        "going to space left", function() moveOneSpace("left") end)
WSELECT_MODAL:bind(nil, "o",        "going to space right", function() moveOneSpace("right") end)
-- WSELECT_MODAL:bind("ctrl", "u",     "going to space left", function() moveOneSpace("left") end)
-- WSELECT_MODAL:bind("ctrl", "o",     "going to space right", function() moveOneSpace("right") end)
-- WSELECT_MODAL:bind("ctrl", "left",  "going to space left", function() moveOneSpace("left") end)
-- WSELECT_MODAL:bind("ctrl", "right", "going to space right", function() moveOneSpace("right") end)

---=== Non-modal versions (for navigation speed)
hs.hotkey.bind(ctrlcmd, "u",     nil, function() moveOneSpace("left") end)
hs.hotkey.bind(ctrlcmd, "o",     nil, function() moveOneSpace("right") end)
hs.hotkey.bind(ctrlcmd, "left",  nil, function() moveOneSpace("left") end)
hs.hotkey.bind(ctrlcmd, "right", nil, function() moveOneSpace("right") end)
hs.hotkey.bind(hyper,   "left",  nil, function() moveOneSpace("left") end)
hs.hotkey.bind(hyper,   "right", nil, function() moveOneSpace("right") end)

hs.hotkey.bind(cmdopt,  "u",     nil, function() moveOneSpace("left") end)
hs.hotkey.bind(cmdopt,  "o",     nil, function() moveOneSpace("right") end)


--==== Expose
require('win-expose')
-- hs.hotkey.bind(hypershift, HS_EXPOSE_ModalKey, 'Expose', function() expose:toggleShow() end)
-- hs.hotkey.bind('ctrl-cmd-shift','k','App Expose',function() expose_app:toggleShow() end)
-- hs.hotkey.bind('ctrl-cmd','j','Expose',function()expose:toggleShow()end)
WSELECT_MODAL:bind(nil, "e", 'Expose all',        function() exitModal(); expose:toggleShow() end)
WSELECT_MODAL:bind(nil, "a", 'Expose this app',   function() exitModal(); expose_app:toggleShow() end)
WSELECT_MODAL:bind(nil, "s", 'Expose this space', function() exitModal(); expose_space:toggleShow() end)
WSELECT_MODAL:bind(nil, "b", 'Expose browsers',   function() exitModal(); expose_browsers:toggleShow() end)

--====  Focused window border
local global_border = nil
local BORDER_WIDTH = 3
local strokeWidth=BORDER_WIDTH*2
function redrawBorder()
  win = hs.window.focusedWindow()
  if win ~= nil then
    top_left = win:topLeft()
    size = win:size()
    if global_border ~= nil then
      global_border:delete()
    end
    global_border = hs.drawing.rectangle(hs.geometry.rect(
    	top_left['x']-BORDER_WIDTH/2, top_left['y']-BORDER_WIDTH/2,
    	size['w']+BORDER_WIDTH, size['h']+BORDER_WIDTH))
    global_border:setStrokeColor({["red"]=0.8,["blue"]=0.8,["green"]=0,["alpha"]=0.8})
    global_border:setFill(false)
    global_border:setStrokeWidth(strokeWidth)
    global_border:show()
  else
  end
end
-- redrawBorder()

function eraseBorder()
  if global_border ~= nil then
      global_border:delete()
      global_border=nil
  end
end

allwindows = hs.window.filter.new(nil)
-- allwindows:subscribe(hs.window.filter.windowClosed,    redrawBorder)
-- allwindows:subscribe(hs.window.filter.windowCreated,   redrawBorder)
-- allwindows:subscribe(hs.window.filter.windowFocused,   redrawBorder)
-- allwindows:subscribe(hs.window.filter.windowMoved,     redrawBorder)
-- allwindows:subscribe(hs.window.filter.windowUnfocused, eraseBorder)

local drawBorder = require('drawing').drawBorder
local cfilter = hs.window.filter.new()
  :setCurrentSpace(true)
  :setDefaultFilter()
  :setOverrideFilter({
    fullscreen = false,
    allowRoles = { 'AXStandardWindow' }
  })

cfilter:subscribe({
  -- hs.window.filter.windowCreated,
  -- hs.window.filter.windowDestroyed,
  hs.window.filter.windowMoved,
  hs.window.filter.windowFocused,
  hs.window.filter.windowUnfocused,
}, drawBorder)
drawBorder()

--- This draws a bright red circle around the pointer for a few seconds
function mouseHighlight()
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousepoint = hs.mouse.get()
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
end

function dumpWindows()
  hs.fnutils.each(hs.window.allWindows(), function(win)
    print(hs.inspect({
      id               = win:id(),
      title            = win:title(),
      app              = win:application():name(),
      role             = win:role(),
      subrole          = win:subrole(),
      frame            = win:frame(),
      buttonZoom       = axuiWindowElement(win):attributeValue('AXZoomButton'),
      buttonFullScreen = axuiWindowElement(win):attributeValue('AXFullScreenButton'),
      isResizable      = axuiWindowElement(win):isAttributeSettable('AXSize')
    }))
  end)
end
