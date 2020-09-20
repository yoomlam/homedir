
------------------------------------------------
-- Expose
hs.expose.ui.maxHintLetters = 6
------------------------------------------------
-- set up your instance(s)
expose = hs.expose.new(nil,{showThumbnails=true,includeOtherSpaces=true}) -- default windowfilter
expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
expose_space = hs.expose.new(nil,{includeOtherSpaces=false}) -- only windows in the current Mission Control Space
expose_browsers = hs.expose.new{'Microsoft Edge','Firefox','Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- for your dozens of browser windows :)

