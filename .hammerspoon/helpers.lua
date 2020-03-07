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
