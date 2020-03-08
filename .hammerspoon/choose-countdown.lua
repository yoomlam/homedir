-- https://www.hammerspoon.org/Spoons/CountDown.html
countDown=hs.loadSpoon("CountDown")
countDown:init()

countdownChoices = {
  { text="1 minute", value=1 },
  { text="3 minutes", value=3 },
  { text="5 minutes", value=5 },
  { text="10 minutes", value=10 },
  { text="15 minutes", value=15 },
  { text="20 minutes", value=20 },
  { text="30 minutes (approx)", value=28 },
  { text="45 minutes", value=45 },
  { text="60 minutes (approx)", value=55 },
}

local function startCountdown(choice)
  if choice then
    -- print(hs.inspect(choice));
    countDown:stop()
    countDown:startFor(choice['value'])
  end
end

---

obj={}

function obj:showChooseCountdown()
  exitModal()
  showChooser(countdownChoices, startCountdown)
end

return obj
