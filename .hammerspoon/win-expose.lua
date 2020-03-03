
------------------------------------------------
-- Expose
------------------------------------------------
-- set up your instance(s)
expose = hs.expose.new(nil,{showThumbnails=false}) -- default windowfilter, no thumbnails
expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
expose_space = hs.expose.new(nil,{includeOtherSpaces=false}) -- only windows in the current Mission Control Space
expose_browsers = hs.expose.new{'Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- for your dozens of browser windows :)

-- then bind to a hotkey
hs.expose.ui.maxHintLetters = 6
hs.hotkey.bind(FLAGS_FOR_OTHER_MODES, KEY_FOR_HS_EXPOSE, 'Expose', function()expose:toggleShow()end)
hs.hotkey.bind('ctrl-cmd-shift','k','App Expose',function()expose_app:toggleShow()end)
-- hs.hotkey.bind('ctrl-cmd','j','Expose',function()expose:toggleShow()end)
