obj={}

obj.hotkeyHelpRect = hs.geometry.rect(250, 250, 300, 400)
local function showHotkeysHelp()
  local hotkeyMsgTab=hs.fnutils.map(hs.hotkey.getHotkeys(), function(elem) return elem.msg end)
  local hotkeyMsg=""
  for i,msg in ipairs(hotkeyMsgTab) do
    hotkeyMsg = hotkeyMsg.."<li>"..msg.."</li>"
  end
  -- hs.dialog.alert(20, 20, nil, "Hotkeys", hotkeyMsg, "Single Button")
  local b=hs.webview.newBrowser(obj.hotkeyHelpRect)
  b:html("<h3>Hotkeys</h3><ul>"..hotkeyMsg.."</ul>")
  b:closeOnEscape(true)
  b:deleteOnClose(true)
  b:level(hs.drawing.windowLevels.modalPanel)
  b:show()
  b:hswindow():activate()
  return b
end
hs.hotkey.bind(ctrlcmdshift, "/", "Hotkeys help", showHotkeysHelp)

-- show help when entering modal
obj.showModalHelpUponEntry = false
obj.modalHelpWindow = nil

local function enteredModal(modal)
  if obj.showModalHelpUponEntry then
    obj.modalHelpWindow=showHotkeysHelp()
  else
    hs.alert.show('Press Ctrl-Cmd-Shift-/ to see hotkeys', 4)
  end
end

obj.currentModal=nil

-- define as global function to allow exiting from modal anywhere
function exitModal(modal, exitMsg)
  if obj.modalHelpWindow then
    obj.modalHelpWindow:delete(true, 1)
    obj.modalHelpWindow=nil
  end
  if modalMsgUuid then
    hs.alert.closeAll()
    modalMsgUuid=nil
  end
  if exitMsg then
    hs.alert.show(exitMsg, 2)
  end
  if modal==nil then
    modal=obj.currentModal
  end
  if modal then
    modal:exit()
  end
end

function obj:newModal(flags, key, enterMsg, enterMsgDuration, showChooserFunc)
  if not enterMsgDuration then
    enterMsgDuration="until exit"
  end

  local modal=hs.hotkey.modal.new(flags, key)
  function modal:entered()
    obj.currentModal=self
    modalMsgUuid=hs.alert.show(enterMsg, enterMsgDuration)
    enteredModal(self)
  end
  function modal:exited()
    obj.currentModal=nil
  end

  if showChooserFunc then
    modal:bind(nil, 'tab', nil, showChooserFunc)
  end

  -- TODO: add timeout to exit modal
  -- several ways to exit modal
  modal:bind(nil, 'escape', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(nil, 'return', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(nil, 'space', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(flags, key, 'Exit modal',
    function() exitModal(modal) end)
  return modal
end

return obj