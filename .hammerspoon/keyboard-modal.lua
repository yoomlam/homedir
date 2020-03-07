
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
  b:level(hs.drawing.windowLevels.modalPanel)
  b:show()
  b:hswindow():raise()
  b:focus()
  return b
end
hs.hotkey.bind(ctrlcmdshift, "/", "Hotkeys help", showHotkeysHelp)

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
  modal:bind(nil, 'space', 'Exit modal',
    function() exitModal(modal) end)
  modal:bind(flags, key, 'Exit modal',
    function() exitModal(modal) end)
  return modal
end
