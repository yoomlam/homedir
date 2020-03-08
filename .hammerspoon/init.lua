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

-- interferes with doubletapping Ctrl: hs.loadSpoon('ControlEscape'):start()
-- Reminder: System Preferences > Keyboard > Modifier Keys, and set the caps lock key to a modifier key.
-- Use Karabiner to map CapsLock to Fn
require('modkey-to-escape'):start('fn')

--- Keyboard key bindings
--- See Karabiner https://ke-complex-modifications.pqrs.org
-- hs.hotkey.bind('ctrl', 'left', nil,
--   function() hs.eventtap.keyStroke('alt', 'left', 0) end)
-- hs.hotkey.bind('ctrl', 'right', nil,
--   function() hs.eventtap.keyStroke('alt', 'right', 0) end)

--- Make this hard to reach since doubletap-flag will be used
-- Keys that don't work: "f"*, "home", "end"
-- print(hs.inspect(hs.keycodes.map))
local ENTITIES_ModalKey   = 'pad-'
local SELECT_ModalKey     = 'pad+'
local WIN_SELECT_ModalKey = "pad1"
local HS_EXPOSE_ModalKey  = "pad5"
--- double tap a modifier key to send a keystroke, such as to enable a modal
require('doubletap-flag'):start({
    {{"shift"}, {hypershift, SELECT_ModalKey}},
    {{"cmd"},   {hypershift, ENTITIES_ModalKey}},
    {{"ctrl"},  {hypershift, WIN_SELECT_ModalKey}},
    {{"alt"},   {hypershift, HS_EXPOSE_ModalKey}},
})

require('helpers')


-------------------------------------------------
---- Modals
local kbModal=require('keyboard-modal')
local apps=require('apps')

--- Use modal mode for launching applications
local appChoices={}
APPS_LAUNCH_MODAL = kbModal:newModal(hypershift, ENTITIES_ModalKey, "🍎 App Launch mode",
  nil, function()
    showChooser(appChoices, function(choice) apps:newWindow(choice['subText']) end)
  end)

--- Use modal mode for selecting windows for application
APPS_SELECT_MODAL = kbModal:newModal(hypershift, SELECT_ModalKey, "📚 App Select mode",
  nil, function()
    local win=hs.window.focusedWindow()
    apps:showAppChooser(win:application():name())
  end)

function addToAppModals(flags, key, appName)
  table.insert( appChoices, {text=key, subText=appName} )
  APPS_LAUNCH_MODAL:bind(flags, key, "Launch "..appName, function() apps:newWindow(appName) end)
  APPS_SELECT_MODAL:bind(flags, key, "Select "..appName, function() apps:showAppChooser(appName) end)
end

addToAppModals(nil, "x", "iTerm2")
addToAppModals(nil, "s", "Safari")
addToAppModals(nil, "f", "Firefox")
addToAppModals(nil, "g", "Google Chrome")
addToAppModals(nil, "t", "Sublime Text")

table.insert( appChoices, {text="n", subText="mdNotes (Sublime ~/Documents/mdNotes)"} )
APPS_LAUNCH_MODAL:bind(nil, 'n', "mdNotes", function()
  exitModal()
  executeCommand("~/bin/subl ~/Documents/mdNotes/")
end)

--- Countdown progress bar
local countdown=require('choose-countdown')
table.insert( appChoices, {text="c", subText="Countdown"} )
APPS_SELECT_MODAL:bind(nil, 'c', "Select Countdown", countdown.showChooseCountdown)
APPS_LAUNCH_MODAL:bind(nil, 'c', "Select Countdown", countdown.showChooseCountdown)

--- URL Chooser
local urlChooser=require('choose-url')
table.insert( appChoices, {text="e", subText="URL chooser"} )
APPS_LAUNCH_MODAL:bind(nil, 'e', "Select URL", urlChooser.showUrlChooser)
APPS_SELECT_MODAL:bind(nil, 'e', "Select URL", urlChooser.showUrlChooser)

--- Use modal mode for window selection/navigation
WSELECT_MODAL = kbModal:newModal(hypershift, WIN_SELECT_ModalKey, "🌬 Window Layout mode")
require('win-selecting')
require('win-moving')


-------------------------------------------------
--- Shortcuts to launch applications via commandline
local function bindExecuteCommand(modifiers, key, cmd)
	hs.hotkey.bind(modifiers, key, nil, function()
		-- print("selectedText: "..tostring(hs.uielement.focusedElement():selectedText()))
    local command = cmd
    if (type(cmd) == "function") then
      command = cmd()
    end
    executeCommand(command)
	end)
end

print("== Application key bindings:")
bindExecuteCommand(ctrlcmd, "p", "open -a Screenshot")
bindExecuteCommand(ctrlcmd, "m", "open -a 'Mission Control'")
bindExecuteCommand("alt-shift", "z", "pmset displaysleepnow")
-- hs.hotkey.bind(ctrlcmd, "s", )


-------------------------------------------------
--- Replacement for Clipy
-- https://www.hammerspoon.org/Spoons/ClipboardTool.html
txtClipboard=hs.loadSpoon("ClipboardTool")
txtClipboard.deduplicate=true
txtClipboard.paste_on_select=true
txtClipboard.show_in_menubar=false
-- instance methods
txtClipboard:start()
hs.hotkey.bind(ctrlcmd, "v", "Clipboard", function() txtClipboard:toggleClipboard() end)

local openMac=require('open-mac')
openMac:start(bindExecuteCommand, txtClipboard)

--- Replacement for Finicky
local urlHandler=require('url-handler')
urlHandler:start()

-- require('audiodevice')

-------------------------------------------------
--- Window management
require('win-switcher')

require('win-expose')
hs.hotkey.bind(hypershift, HS_EXPOSE_ModalKey, 'Expose', function() expose:toggleShow() end)
hs.hotkey.bind('ctrl-cmd-shift','k','App Expose',function() expose_app:toggleShow() end)
-- hs.hotkey.bind('ctrl-cmd','j','Expose',function()expose:toggleShow()end)

require('menubar')

-------------------------------------------------
--- Other stuff

-- Cheatsheet for application key bindings
cheatsheet=hs.loadSpoon("KSheet")
hs.hotkey.bind(hyper, "/", "Cheatsheet", function() cheatsheet:toggle() end)

--- Next
-- play with win-expose
-- Quitter replacement
-- https://github.com/koekeishiya/yabai

--- Ideas
-- make text navigation/editing same across apps
  -- see BTT key bindings

---- To look into ---
-- "subscribe to events on windows" http://www.hammerspoon.org/docs/hs.window.filter.html
-- https://kevzheng.com/hammerspoon-karabiner


hs.alert.show("Config loaded: " .. hs.configdir)
collectgarbage("collect")