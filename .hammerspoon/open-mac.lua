
local function openMacCommand(cmd)
  if cmd==nil then
    cmd=hs.pasteboard.readString()
  end
  return "~/bin/open_mac.sh "..cmd
end

local function executeChoice(choice)
  if choice then
    print(hs.inspect(choice));
    executeCommand(openMacCommand(choice['text']))
  end
end

obj={}

function obj:start(bindExecuteCommand, txtClipboard)
  bindExecuteCommand(ctrlcmd, "z", openMacCommand)

  APPS_LAUNCH_MODAL:bind(nil, 'z', "Launch open_mac.sh", function()
    exitModal()
    executeCommand(openMacCommand())
  end)

  APPS_SELECT_MODAL:bind(nil, 'z', "Open with open_mac.sh", function()
    exitModal()
    showChooser(listToChoices(txtClipboard:clipboardContents()), executeChoice)
  end)
end

return obj
