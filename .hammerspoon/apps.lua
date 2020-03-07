local obj={}

function obj:newWindow(appName)
  hs.alert.show("Launching new "..appName)
  app=hs.application.find(appName)
  app:selectMenuItem("New Window")
  exitModal(APPS_LAUNCH_MODAL)
  app:activate()
end

local function buildChoices(appName)
  local wins=hs.window.filter.new{appName}:getWindows()
  -- print(hs.inspect(wins))
  local choices = {}
  for k, win in pairs(wins) do
    -- print("===>", k, win:id())
    choice = {
      ["text"] = win:application():name()..": "..win:title(),
      ["subText"] = win:application():name().." screen:"..win:screen():name().." id:"..win:id(),
      ["winId"] = win:id(),
      ["appName"] = win:application():name(),
      ["title"] = win:title()
    }
    table.insert(choices, choice)
  end
  return choices
end

local function raiseWindow(choice)
  if choice then
    print(hs.inspect(choice))
    local win=hs.window.get(choice['winId'])
    if win then
      win:raise()
      win:focus()
    else
      local found=selectWindowViaMenu(choice)
      if not found then
        -- FIXME: doesn't work for iTerm2
        hs.alert.show("Cannot find "..tostring(choice['winId']), 4)
      end
    end
  end
end

local function selectWindowViaMenu(choice)
  local app=hs.application.find(choice['appName'])
  app:activate()
  return app:selectMenuItem({"Window", choice['title']})
end

function obj:showAppChooser(appName)
  exitModal(APPS_SELECT_MODAL)
  local chooser=hs.chooser.new(function(choice) raiseWindow(choice) end)
  chooser:choices(buildChoices(appName))
  chooser:show()
end


return obj
