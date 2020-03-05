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
SCREEN2 = hs.screen.allScreens()[2]:name()

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


--- Replacement for Clipy
-- http://www.hammerspoon.org/Spoons/TextClipboardHistory.html
txtClipboard=hs.loadSpoon("TextClipboardHistory")
txtClipboard.deduplicate=true
txtClipboard.paste_on_select=true
txtClipboard.show_in_menubar=false
-- instance methods
txtClipboard:start()
hs.hotkey.bind(ctrlcmd, "v", "Clipboard", function() txtClipboard:toggleClipboard() end)


--- Helper methods

hotkeyHelpRect = hs.geometry.rect(250, 250, 300, 400)
function showHotkeysHelp()
  local hotkeyMsgTab=hs.fnutils.map(hs.hotkey.getHotkeys(), function(elem) return elem.msg end)
  local hotkeyMsg=""
  for i,msg in ipairs(hotkeyMsgTab) do
    hotkeyMsg = hotkeyMsg.."<li>"..msg.."</li>"
  end
  -- hs.dialog.alert(20, 20, nil, "Hotkeys", hotkeyMsg, "Single Button")
  local b=hs.webview.newBrowser(hotkeyHelpRect)
  b:html("<h3>Hotkeys</h3><ul>"..hotkeyMsg.."</ul>")
  b:closeOnEscape(true)
  b:deleteOnClose(true)
  b:show()
  return b
end
hs.hotkey.bind(ctrlcmdshift, "/", "Hotkeys help", showHotkeysHelp)

---- Modals
-- show help when entering modal
showModalHelpUponEntry = false
function enteredModal(modal)
  if showModalHelpUponEntry then
    modalHelpWindow=showHotkeysHelp()
  else
    hs.alert.show('Press Ctrl-Cmd-Shift-/ to see hotkeys', 4)
  end
end

function exitModal(modal, exitMsg)
  if modalHelpWindow then
    modalHelpWindow:delete(true, 1)
    modalHelpWindow=nil
  end
  if modalMsgUuid then
    hs.alert.closeAll()
    modalMsgUuid=nil
  end
  if exitMsg then
    hs.alert.show(exitMsg, 2)
  end
  modal:exit()
end

function newModal(flags, key, enterMsg, exitMsg, enterMsgDuration)
  if not enterMsgDuration then
    enterMsgDuration="until exit"
  end

  local modal=hs.hotkey.modal.new(flags, key)
  function modal:entered()
    modalMsgUuid=hs.alert.show(enterMsg, enterMsgDuration)
    enteredModal(self)
  end

  -- TODO: add timeout to exit modal
  -- several ways to exit modal
  modal:bind(nil, 'escape', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(nil, 'return', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(flags, key, 'Exit modal',
    function() exitModal(modal) end)
  return modal
end

--- Use modal mode for launching applications
APPS_LAUNCH_MODAL = newModal(FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_ENTITIES_MODE, "🍎 App Launch mode")
--- Use modal mode for selecting windows for application
APPS_SELECT_MODAL = newModal(FLAGS_FOR_OTHER_MODES, KEY_FOR_KI_SELECT_MODE, "🚂 App Select mode")
require('apps')

function addToAppModals(flags, key, appName)
  APPS_LAUNCH_MODAL:bind(flags, key, "Launch "..appName, function() newWindow(appName) end)
  APPS_SELECT_MODAL:bind(flags, key, "Select "..appName, function() showChooser(appName) end)
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
		status = os.execute(command)
    print("Running: "..command)
		if not status then
      print("Error running "..command)
			hs.alert.show("Error running "..command)
		end
	end)
end

print("== Application key bindings:")
bindExecuteShortcut(ctrlcmd, "z", function() return "/Users/yoomlam/bin/open_mac.sh "..hs.pasteboard.readString() end)
bindExecuteShortcut(ctrlcmd, "p", "open -a Screenshot")
bindExecuteShortcut("alt-shift", "z", "pmset displaysleepnow")
-- hs.hotkey.bind(ctrlcmd, "s", )

--- Other stuff
require('audiodevice')
require('win-switcher')
require('win-expose')

require('menubar')
-- hotkey to layout current screen; see menubar.lua
hs.hotkey.bind(hyper, "l", nil, layoutCurrentScreen)




--- Next
-- Quitter replacement
-- Finicky replacement

--- Ideas
-- make text navigation/editing same across apps
  -- see BTT key bindings

---- To look into ---
-- "subscribe to events on windows" http://www.hammerspoon.org/docs/hs.window.filter.html
-- https://kevzheng.com/hammerspoon-karabiner


hs.alert.show("Config loaded: " .. hs.configdir)
