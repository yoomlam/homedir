--- Helper methods

function listToChoices(array)
  choices={}
  for k,v in pairs(array) do
    if (type(v) == "string") then
       table.insert(choices, {text=v})
    end
  end
  return choices
end

function showChooser(choices, onChoice)
  exitModal()
  -- local onChoiceFunc
  -- if onChoice==nil then
  --   onChoiceFunc=function(choice) raiseWindow(choice) end
  -- else
  --   onChoiceFunc=onChoice
  -- end
  local chooser=hs.chooser.new(onChoice)

  local chooserChoices=choices
  if type(choices)=="function" then
    chooserChoices=choices()
  end
  chooser:choices(choices)
  chooser:show()
end

function executeCommand(command)
  print("Running: "..command)
  status = os.execute(command)
  if not status then
    print("Error running "..command)
    hs.alert.show("Error running "..command)
  end
  print("  returning from executeCommand function")
end
