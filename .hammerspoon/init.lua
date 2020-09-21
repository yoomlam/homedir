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

-- Use Karabiner to map CapsLock to Fn
-- Karabiner overrides this: System Preferences > Keyboard > Modifier Keys, and set the caps lock key to a modifier key.
require('modkey-to-escape'):start('fn')
-- interferes with doubletapping Ctrl: hs.loadSpoon('ControlEscape'):start()

--- Keyboard key bindings
--- See Karabiner https://ke-complex-modifications.pqrs.org
-- hs.hotkey.bind('ctrl', 'left', nil,
--   function() hs.eventtap.keyStroke('alt', 'left', 0) end)
-- hs.hotkey.bind('ctrl', 'right', nil,
--   function() hs.eventtap.keyStroke('alt', 'right', 0) end)
hs.hotkey.bind('ctrl', 'up', nil,
  function() hs.eventtap.keyStroke(nil, 'pageup', 0) end)
hs.hotkey.bind('ctrl', 'down', nil,
  function() hs.eventtap.keyStroke(nil, 'pagedown', 0) end)

--- Make this hard to reach since doubletap-flag will be used
-- Keys that don't work: "f"*, "home", "end"
-- print(hs.inspect(hs.keycodes.map))
local ENTITIES_ModalKey   = 'pad-'
local SELECT_ModalKey     = 'pad+'
local WINDOWING_ModalKey = "pad1"
local HS_EXPOSE_ModalKey  = "pad5"
--- double tap a modifier key to send a keystroke, such as to enable a modal
require('doubletap-flag'):start({
    {{"shift"}, {hypershift, SELECT_ModalKey}},
    {{"cmd"},   {hypershift, ENTITIES_ModalKey}},
    {{"ctrl"},  {hypershift, WINDOWING_ModalKey}},
    {{"alt"},   {hypershift, HS_EXPOSE_ModalKey}},
})

require('helpers')


-------------------------------------------------
---- Modals
local kbModal=require('keyboard-modal')
local apps=require('apps')
local KEY_FUNC_MAP={}

--- Use modal mode for launching applications
local appChoices={}
APPS_LAUNCH_MODAL = kbModal:newModal(hypershift, ENTITIES_ModalKey, "🍎 App Launch mode",
  nil, function()
    showChooser(appChoices, function(choice)
      if choice then
        if choice['execCommand'] then
          executeCommand(choice['execCommand'])
        elseif choice['funcKey'] then
          KEY_FUNC_MAP[choice['funcKey']]()
        else
          apps:newWindow(choice['subText'])
        end
      end
    end)
  end)

--- Use modal mode for selecting windows for application
APPS_SELECT_MODAL = kbModal:newModal(hypershift, SELECT_ModalKey, "📚 App Select mode",
  nil, function()
    local win=hs.window.focusedWindow()
    apps:showAppChooser(win:application():name(), KEY_FUNC_MAP)
  end)

function addToAppModals(flags, key, appName)
  table.insert( appChoices, {text=key, subText=appName} )
  APPS_LAUNCH_MODAL:bind(flags, key, "Launch "..appName, function() apps:newWindow(appName) end)
  APPS_SELECT_MODAL:bind(flags, key, "Select "..appName, function() apps:showAppChooser(appName) end)
end

addToAppModals(nil, "x", "kitty") -- net.kovidgoyal.kitty; iTerm
addToAppModals(nil, "a", "Microsoft Edge")
addToAppModals(nil, "s", "Safari")
addToAppModals(nil, "f", "Firefox")
addToAppModals(nil, "g", "Google Chrome")
addToAppModals(nil, "t", "Sublime Text")

-- table.insert( appChoices, { text="n", subText="mdNotes (Sublime ~/Documents/mdNotes)",
--   execCommand="~/bin/subl ~/Documents/mdNotes/" } )
-- APPS_LAUNCH_MODAL:bind(nil, 'n', "mdNotes", function()
--   exitModal()
--   executeCommand("~/bin/subl ~/Documents/mdNotes/")
-- end)

table.insert( appChoices, { text="h", subText="~/.hammerspoon (Sublime ~/.hammerspoon/)",
  execCommand="~/bin/subl ~/.hammerspoon/" } )
APPS_LAUNCH_MODAL:bind(nil, 'h', "hammerspoon", function()
  exitModal()
  executeCommand("~/bin/subl ~/.hammerspoon/")
end)

table.insert( appChoices, { text="r", subText=".my_repl.rb (Sublime ~/.my_homedir/my_repl.rb)",
  execCommand="~/bin/subl ~/.my_homedir/my_repl.rb" } )
APPS_LAUNCH_MODAL:bind(nil, 'r', "my_repl.rb", function()
  exitModal()
  executeCommand("~/bin/subl ~/.my_homedir/my_repl.rb")
end)

--- textual window chooser
table.insert( appChoices, {text="q", subText="Window chooser"} )
APPS_SELECT_MODAL:bind(nil, 'q', "Select Window", function()
  local wins=hs.window.filter.new():getWindows()
  apps:showAppChooser(nil, nil, apps:buildChoicesFromWindows(wins))
end)

--- Countdown progress bar
local countdown=require('choose-countdown')
table.insert( appChoices, {text="c", subText="Countdown", funcKey='countdown'} )
KEY_FUNC_MAP['countdown']=countdown.showChooseCountdown
APPS_SELECT_MODAL:bind(nil, 'c', "Select Countdown", countdown.showChooseCountdown)
APPS_LAUNCH_MODAL:bind(nil, 'c', "Select Countdown", countdown.showChooseCountdown)

--- URL Chooser
local urlChooser=require('choose-url')
table.insert( appChoices, {text="e", subText="URL chooser"} )
APPS_LAUNCH_MODAL:bind(nil, 'e', "Select URL", urlChooser.showUrlChooser)
APPS_SELECT_MODAL:bind(nil, 'e', "Select URL", urlChooser.showUrlChooser)

--- Paste clip
local clipPaster=require('paste-clip')
table.insert( appChoices, {text="v", subText="Clip chooser"} )
APPS_LAUNCH_MODAL:bind(nil, 'v', "Select Snippets", clipPaster.showClipChooser)
APPS_SELECT_MODAL:bind(nil, 'v', "Select Snippets", clipPaster.showClipChooser)

--- Use modal mode for window selection/navigation
local winLayoutTips="\n⇧ = snap (or nudge with arrows)\n⌥ = resize\n⌃⇧ = move to space"

WSELECT_MODAL = kbModal:newModal(hypershift, WINDOWING_ModalKey, "🌬 Window Layout mode"..winLayoutTips)
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
-- hs.hotkey.bind(ctrlcmd, "i", function() apps:newWindow("iTerm") end)
hs.hotkey.bind(ctrlcmd, "x", function() apps:cmdN("net.kovidgoyal.kitty", "/usr/local/bin/kitty -d=$HOME &") end)
hs.hotkey.bind(ctrlcmdshift, "x", function() executeCommand("/usr/local/bin/kitty -d=$HOME &") end)
bindExecuteCommand(ctrlcmd, "p", "open -a Screenshot")
-- bindExecuteCommand(ctrlcmd, "m", "open -a 'Mission Control'")
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

require('menubar')

-------------------------------------------------
--- Other stuff

-- Cheatsheet for application key bindings
cheatsheet=hs.loadSpoon("KSheet")
hs.hotkey.bind(hyper, "/", "Cheatsheet", function() cheatsheet:toggle() end)

--- Next
-- Markdown keybindings
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