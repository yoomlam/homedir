local obj={}

function obj:newWindow(appName)
  exitModal()
  hs.alert.show("Launching new "..appName)
  app=hs.application.find(appName)

  -- hs.application.watcher.new(winWatcher)

  if app then
    app:selectMenuItem("New Window")
    app:activate()
  else
    hs.application.launchOrFocus(appName)
  end
end

function obj:cmdN(appName, startAppCmd)
  exitModal()
  hs.alert.show("Launching new "..appName)
  app=hs.application.find(appName)

  -- hs.application.watcher.new(winWatcher)

  if app then
    app:activate()
    hs.eventtap.keyStroke({"cmd"}, "n")
  else
    if startAppCmd then
      executeCommand(startAppCmd)
    else
      hs.application.launchOrFocus(appName)
    end
  end
end

-- local function winWatcher(appName, event, app)

-- end

function obj:buildChoicesFromWindows(wins)
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

local function buildChoices(appName)
  local wins=hs.window.filter.new{appName}:getWindows()
  return obj:buildChoicesFromWindows(wins)
end

local function selectWindowViaMenu(choice)
  local app=hs.application.find(choice['appName'])
  if app then
    app:selectMenuItem({"Window", choice['title']})
    return app:activate()
  else
    return nil
  end
end

local function raiseWindow(choice)
  if choice then
    print(hs.inspect(choice))
    local win=hs.window.get(choice['winId'])
    if not win then
      win=hs.window.get(choice['title'])
    end

    if win then
      win:raise()
      win:focus()
    else
      local found=selectWindowViaMenu(choice)
      print("Could not look up window; searched by application: "..tostring(found))
      if not found then
        -- FIXME: doesn't work for iTerm2
        hs.alert.show("Cannot find winId: "..tostring(choice['winId']), 4)
      end
    end
  end
end

function obj:showAppChooser(appName, KEY_FUNC_MAP, choices)
  exitModal()
  local chooser=hs.chooser.new(function(choice)
    if choice then
      if choice['funcKey'] then
        KEY_FUNC_MAP[choice['funcKey']]()
      else
        raiseWindow(choice)
      end
    end
  end)

  if not choices then
    choices=buildChoices(appName)
  end

  chooser:choices(choices)
  chooser:show()
end


return obj
