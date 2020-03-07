-- https://www.hammerspoon.org/go/

--- Common key modifiers
ctrlcmd = {"ctrl", "cmd"}
ctrlcmdshift = {"ctrl", "cmd", "shift"}
-- used by apps: macpair={"cmd", "alt"}
hyper = {"ctrl", "alt", "cmd"}
hypershift = {"ctrl", "alt", "cmd", "shift"}

-- https://www.hammerspoon.org/Spoons/ReloadConfiguration.html
hs.loadSpoon("ReloadConfiguration")
-- Load manually: (https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md#hotkeys)
spoon.ReloadConfiguration:bindHotkeys({ reloadConfiguration = {ctrlcmdshift, "r"} })
-- OR automatically upon changes:
-- spoon.ReloadConfiguration:start()

--- My monitors
print(hs.inspect(hs.screen.allScreens()))
SCREEN1 = hs.screen.allScreens()[1]:name()
if hs.screen.allScreens()[2] then
  SCREEN2 = hs.screen.allScreens()[2]:name()
end

--- Window filters
CURR_SPACE_WINFILTER = hs.window.filter.new():setCurrentSpace(true)
CURR_SCREEN_WINFILTER = hs.window.filter.new(function(w)
  return w:screen() == hs.screen.mainScreen() and CURR_SPACE_WINFILTER:isWindowAllowed(w)
end)

--- Make this hard to reach since doubletap-flag will be used
-- Keys that work: "pad"*
-- Keys that don't work: "f"*, "home", "end"
-- print(hs.inspect(hs.keycodes.map))

-- FLAGS_FOR_KI_MODES = hypershift
KEY_FOR_KI_ENTITIES_MODE = 'pad-'
KEY_FOR_KI_SELECT_MODE  = 'pad+'
-- KEY_FOR_KI_OTHER_MODE  = 'pad.'

FLAGS_FOR_OTHER_MODES = hypershift
KEY_FOR_HS_EXPOSE  = "pad1"
KEY_FOR_WIN_SELECT = "pad2"


--- Don't need this currently
-- https://github.com/jasonrudolph/ControlEscape.spoon
-- Reminder: System Preferences > Keyboard > Modifier Keys, and set the caps lock key to control.
-- hs.loadSpoon('ControlEscape'):start()

--- double tap a modifier key to send a keystroke, such as to enable a modal
require('doubletap-flag'):start({
    {{"shift"}, {FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_SELECT_MODE}},
    {{"cmd"}, {FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_ENTITIES_MODE}},

    {{"ctrl"}, {FLAGS_FOR_OTHER_MODES, KEY_FOR_WIN_SELECT}},
    {{"alt"}, {FLAGS_FOR_OTHER_MODES, KEY_FOR_HS_EXPOSE}},
})


---- Modals
require('keyboard-modal')

--- Use modal mode for launching applications
APPS_LAUNCH_MODAL = newModal(FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_ENTITIES_MODE, "🍎 App Launch mode")
--- Use modal mode for selecting windows for application
APPS_SELECT_MODAL = newModal(FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_SELECT_MODE, "📚 App Select mode")

require('apps')

function addToAppModals(flags, key, appName)
  APPS_LAUNCH_MODAL:bind(flags, key, "Launch "..appName, function() newWindow(appName) end)
  APPS_SELECT_MODAL:bind(flags, key, "Select "..appName, function() showAppChooser(appName) end)
end

addToAppModals(nil, "x", "iTerm2")
addToAppModals(nil, "s", "Safari")
addToAppModals(nil, "f", "Firefox")
addToAppModals(nil, "g", "Google Chrome")
addToAppModals(nil, "t", "Sublime Text")

--- Use modal mode for window selection/navigation
WSELECT_MODAL = newModal(FLAGS_FOR_OTHER_MODES, KEY_FOR_WIN_SELECT, "🌬 Window Layout mode", "Exited mode")
require('win-selecting')
require('win-moving')


--- Shortcuts to launch applications
local function bindExecuteShortcut(modifiers, key, cmd)
	hs.hotkey.bind(modifiers, key, nil, function()
		-- print("selectedText: "..tostring(hs.uielement.focusedElement():selectedText()))
    local command = cmd
    if (type(cmd) == "function") then
      command = cmd()
    end
    executeCommand(command)
	end)
end
function executeCommand(command)
  status = os.execute(command)
  print("Running: "..command)
  if not status then
    print("Error running "..command)
    hs.alert.show("Error running "..command)
  end
end

print("== Application key bindings:")
bindExecuteShortcut(ctrlcmd, "p", "open -a Screenshot")
bindExecuteShortcut(ctrlcmd, "m", "open -a 'Mission Control'")
bindExecuteShortcut("alt-shift", "z", "pmset displaysleepnow")
-- hs.hotkey.bind(ctrlcmd, "s", )

function openMacCommand()
  return "/Users/yoomlam/bin/open_mac.sh "..hs.pasteboard.readString()
end

bindExecuteShortcut(ctrlcmd, "z", openMacCommand)
APPS_LAUNCH_MODAL:bind(nil, 'z', "Launch open_mac.sh", function()
  exitModal(APPS_LAUNCH_MODAL)
  executeCommand(openMacCommand())
end)
APPS_SELECT_MODAL:bind(nil, 'z', "Open with open_mac.sh", function()
  exitModal(APPS_SELECT_MODAL)
  executeCommand(openMacCommand())
end)


--- Replacement for Clipy
-- https://www.hammerspoon.org/Spoons/ClipboardTool.html
txtClipboard=hs.loadSpoon("ClipboardTool")
txtClipboard.deduplicate=true
txtClipboard.paste_on_select=true
txtClipboard.show_in_menubar=false
-- instance methods
txtClipboard:start()
hs.hotkey.bind(ctrlcmd, "v", "Clipboard", function() txtClipboard:toggleClipboard() end)



--- Other stuff
require('audiodevice')
require('win-switcher')
require('win-expose')

require('menubar')

require('choose-countdown')
APPS_SELECT_MODAL:bind(nil, 'c', "Select Countdown", showChooseCountdown)


-- hotkey to layout current screen; see menubar.lua
hs.hotkey.bind(hyper, "l", nil, layoutCurrentScreen)

cheatsheet=hs.loadSpoon("KSheet")
hs.hotkey.bind(hyper, "/", "Cheatsheet", function() cheatsheet:toggle() end)

--- Keyboard key bindings
hs.hotkey.bind('ctrl', 'left', nil,
  function() hs.eventtap.keyStroke('alt', 'left') end)
hs.hotkey.bind('ctrl', 'right', nil,
  function() hs.eventtap.keyStroke('alt', 'right') end)


require('url-handler')


--- Next
-- When is `local` needed?
-- Quitter replacement
-- Finicky replacement
-- https://github.com/koekeishiya/yabai

--- Ideas
-- make text navigation/editing same across apps
  -- see BTT key bindings

---- To look into ---
-- "subscribe to events on windows" http://www.hammerspoon.org/docs/hs.window.filter.html
-- https://kevzheng.com/hammerspoon-karabiner


hs.alert.show("Config loaded: " .. hs.configdir)
