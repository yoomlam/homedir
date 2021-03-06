-- http://www.hammerspoon.org/docs/hs.window.switcher.html
local switcher=hs.window.switcher
switcher.ui.showThumbnails = false
switcher.ui.textSize = 10
switcher.ui.showSelectedThumbnail = true
switcher.ui.fontName = ".AppleSystemUIFont"

-- all spaces
switcher_all = switcher.new(hs.window.filter.new():setCurrentSpace(nil), {
	showSelectedThumbnail = true,
})
hs.hotkey.bind('option',      'tab',function()switcher_all:next()end)
hs.hotkey.bind('option-shift', 'tab',function()switcher_all:previous()end)

-- Current space only
switcher_space = switcher.new(CURR_SPACE_WINFILTER, {
	showSelectedThumbnail = true,
})
hs.hotkey.bind(ctrlcmd,'tab',function()switcher_space:next()end)
hs.hotkey.bind(ctrlcmdshift,'tab',function()switcher_space:previous()end)

-- specialized switcher for your dozens of browser windows :)
switcher_browsers = switcher.new({'Safari','Google Chrome','Firefox'}, {
	showSelectedThumbnail = true,
	selectedThumbnailSize = 400
})
hs.hotkey.bind({'ctrl','option'},'tab',function()switcher_browsers:next()end)
hs.hotkey.bind({'ctrl','option','shift'},'tab',function()switcher_browsers:previous()end)

-- relative to focused screen in current space
-- print("000 "..hs.inspect(hs.window.filter.default:getFilters()))
-- print("AAA "..hs.inspect(CURR_SCREEN_WINFILTER:getFilters()))

-- switcher_TEST = hs.window.switcher.new(CURR_SCREEN_WINFILTER, {
-- 	showSelectedThumbnail = true,
-- })
-- hs.hotkey.bind('ctrl',           'tab',function()switcher_TEST:next()end)
-- hs.hotkey.bind({'ctrl','shift'}, 'tab',function()switcher_TEST:previous()end)

