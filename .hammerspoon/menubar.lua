-- http://www.hammerspoon.org/docs/hs.menubar.html

--- Keep monitors on
mymenu = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        mymenu:setTitle("A")
    else
        mymenu:setTitle("S")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if mymenu then
    mymenu:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

---

function getScreenWindows()
	local windowsOnScreenByName = {}
  hs.fnutils.each(CURR_SCREEN_WINFILTER:getWindows(), function(win)
    if win:application() and win:application():name() then
      windowsOnScreenByName[win:application():name()]=win
    end
  end)

  print("Windows on screen:\n"..hs.inspect(windowsOnScreenByName))
  -- hs.alert.show("getScreenWindows: "..dumpObj(windowsOnScreenByName))
  return hs.screen.mainScreen(), windowsOnScreenByName
end

function getWindowTitle(winByName, appName)
  if not winByName[appName] then return nil else return winByName[appName]:title() end
end

function notesSlackMailLayout()
  local focusedScreen, winByName = getScreenWindows()
  hs.layout.apply({
    {nil, getWindowTitle(winByName, "Google Chrome"), focusedScreen, {x=0, y=0, w=0.8, h=1}, nil, nil},
    {nil, getWindowTitle(winByName, "Sublime Text"), focusedScreen, {x=0.3, y=0, w=0.7, h=0.7}, nil, nil},
    {"Slack", nil, SCREEN1, {x=0, y=0.3, w=1, h=0.7}, nil, nil},
  })
end

function forkFirefoxSafariLayout()
  local focusedScreen, winByName = getScreenWindows()
  hs.layout.apply({
    {"Fork", nil, SCREEN1, {x=0, y=0, w=0.9, h=0.8}, nil, nil},
    {nil, getWindowTitle(winByName, "Safari"), focusedScreen, {x=0.5, y=0, w=0.5, h=1}, nil, nil},
    {nil, getWindowTitle(winByName, "Firefox"), focusedScreen, {x=0, y=0.2, w=0.6, h=.8}, nil, nil},
    {nil, getWindowTitle(winByName, "Google Chrome"), focusedScreen, {x=0.2, y=0.1, w=0.6, h=0.9}, nil, nil},
  })
end

-- TODO: How to layout multiple windows from same app, e.g., iTerm: make run, cf term, bet
function rubymineTermsLayout()
  local focusedScreen, winByName = getScreenWindows()
  hs.layout.apply({
    {nil, getWindowTitle(winByName, "RubyMine"), focusedScreen, {x=0, y=0, w=1, h=0.7}, nil, nil},
    {nil, getWindowTitle(winByName, "iTerm2"), focusedScreen, {x=0, y=0.7, w=0.5, h=0.3}, nil, nil},
  })
end

-- TODO: Pairing: Slack chat, cf terms, RubyMine, Chrome Caseflow

function readingSublimeFirefoxSafariLayout()
  local focusedScreen, winByName = getScreenWindows()
  hs.layout.apply({
    {nil, getWindowTitle(winByName, "Safari"), focusedScreen, {x=0, y=0.1, w=0.5, h=0.8}, nil, nil},
    {nil, getWindowTitle(winByName, "Firefox"), focusedScreen, {x=0.2, y=0, w=0.6, h=0.9}, nil, nil},
    {nil, getWindowTitle(winByName, "Sublime Text"), focusedScreen, {x=0, y=0.5, w=0.5, h=0.5}, nil, nil},
    {nil, getWindowTitle(winByName, "iTerm2"), focusedScreen, {x=0.5, y=0.5, w=0.5, h=0.5}, nil, nil},
  })
end

function zoomHuddleLayout()
  local focusedScreen, winByName = getScreenWindows()
  hs.layout.apply({
    {"zoom.us", "Zoom", SCREEN2, {x=0, y=0, w=0.6, h=0.6}, nil, nil}, -- main presentation
    -- TODO regex title
    {"zoom.us", "Zoom Meeting ID%", SCREEN1, {x=0, y=0, w=0.5, h=0.5}, nil, nil},
    {nil, getWindowTitle(winByName, "Google Chrome"), SCREEN2, {x=0.5, y=0, w=0.5, h=1}, nil, nil},
  })
end

function tileWindows()
    local wins = hs.window.filter.new():setCurrentSpace(true):getWindows()
    local screen = hs.screen.mainScreen():currentMode()
    local rect = hs.geometry(0, 0, screen['w'], screen['h'])
    hs.window.tiling.tileWindows(wins, rect)
end

layoutTab = {
  Slack = notesSlackMailLayout,
  Safari = readingSublimeFirefoxSafariLayout,
  ["zoom.us"] = zoomHuddleLayout
}
function layoutCurrentScreen()
  local windows=CURR_SCREEN_WINFILTER:getWindows()
  local foundWin=hs.fnutils.find(windows, function(win)
    return win:application() and layoutTab[win:application():name()] ~= nil
  end)
  local appName=foundWin:application():name()
  if foundWin then
    hs.alert.show("Arranging windows for "..appName)
    layoutTab[appName]()
  else
    print("Cannot determine desired layout: "..hs.inspect(windows))
  end
end


winmenu = hs.menubar.new()
winmenu:setTitle("Layout")
winmenu:setMenu({
	{ title = "my menu item", fn = function() hs.alert.show("You clicked my menu item!") end },
	{ title = "-" },
	{ title = "Laptop screen layout" },
	{ indent = 1, title = "Mail, Notes, Slack", fn = notesSlackMailLayout },
	{ indent = 1, title = "Fork, Firefox, Safari", fn = forkFirefoxSafariLayout },
	{ title = "Big screen layout" },
	{ indent = 1, title = "RubyMine, iTerms", fn = rubymineTermsLayout },
	{ indent = 1, title = "Zoom Huddle", fn = zoomHuddleLayout },
	{ indent = 1, title = "Reading: Sublime, browsers, iTerm", fn = readingSublimeFirefoxSafariLayout },
	{ title = "-" },
	{ title = "Layout" },
	{ indent = 1, title = "Tile windows", fn = tileWindows },
  { indent = 1, title = "Based on current screen", fn = layoutCurrentScreen },
	{ title = "examples", menu = {
		{ title = "disabled item", disabled = true },
		{ title = "checked item", checked = true },
	}}
})



