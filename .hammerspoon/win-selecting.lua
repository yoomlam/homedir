
--==== Selecting/Navigating to does not use 'shift', which is reserved for moving windows

---=== Modal versions
--- Change focus
-- http://www.hammerspoon.org/docs/hs.window.html#focusWindowEast
WSELECT_MODAL:bind(nil, "j",     "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "l",     "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "i",     "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "k",     "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "left",  "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "right", "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "up",    "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
WSELECT_MODAL:bind(nil, "down",  "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)

---=== Non-modal versions (for navigation speed)
--- Change focus
hs.hotkey.bind(ctrlcmd, "j",     "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
hs.hotkey.bind(ctrlcmd, "l",     "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
hs.hotkey.bind(ctrlcmd, "i",     "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
hs.hotkey.bind(ctrlcmd, "k",     "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(ctrlcmd, "left",  "Focus left",  nil, function() hs.window.focusedWindow():focusWindowWest (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(ctrlcmd, "right", "Focus right", nil, function() hs.window.focusedWindow():focusWindowEast (CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(ctrlcmd, "up",    "Focus up",    nil, function() hs.window.focusedWindow():focusWindowNorth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)
-- hs.hotkey.bind(ctrlcmd, "down",  "Focus down",  nil, function() hs.window.focusedWindow():focusWindowSouth(CURR_SPACE_WINFILTER:getWindows(), false, false) end)


--==== Moving across spaces uses 'ctrl'
function moveOneSpace(direction)
    -- rely on setting this in MacOS: System Preferences > Keyboard > Shortcuts > Mission Control
    if direction == "left" then
        hs.eventtap.keyStroke(hypershift, "[")
    else
        hs.eventtap.keyStroke(hypershift, "]")
    end
end

---=== Modal versions
WSELECT_MODAL:bind("ctrl", "u",     "going to space left", function() moveOneSpace("left") end)
WSELECT_MODAL:bind("ctrl", "o",     "going to space right", function() moveOneSpace("right") end)
WSELECT_MODAL:bind("ctrl", "left",  "going to space left", function() moveOneSpace("left") end)
WSELECT_MODAL:bind("ctrl", "right", "going to space right", function() moveOneSpace("right") end)

---=== Non-modal versions (for navigation speed)
hs.hotkey.bind(ctrlcmd, "u",     "going to space left", function() moveOneSpace("left") end)
hs.hotkey.bind(ctrlcmd, "o",     "going to space right", function() moveOneSpace("right") end)
hs.hotkey.bind(ctrlcmd, "left",  "going to space left", function() moveOneSpace("left") end)
hs.hotkey.bind(ctrlcmd, "right", "going to space right", function() moveOneSpace("right") end)


--- Focused window border
global_border = nil
BORDER_WIDTH = 6
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
    global_border:setStrokeWidth(BORDER_WIDTH)
    global_border:show()
  else
    -- if global_border ~= nil then
    --   global_border:delete()
    -- end
  end
end
redrawBorder()

allwindows = hs.window.filter.new(nil)
-- allwindows:subscribe(hs.window.filter.windowClosed,    redrawBorder)
allwindows:subscribe(hs.window.filter.windowCreated,   redrawBorder)
allwindows:subscribe(hs.window.filter.windowFocused,   redrawBorder)
allwindows:subscribe(hs.window.filter.windowMoved,     redrawBorder)
allwindows:subscribe(hs.window.filter.windowUnfocused, redrawBorder)


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
