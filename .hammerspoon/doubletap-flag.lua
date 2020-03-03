--- === Double-tap based on ControlEscape ===
-- Detect double-taps of certain modifier key and emit specified keystrokes.
--

local obj={}
obj.__index = obj

-- Metadata
obj.name = 'Doubletap'

function tableLength(tab)
  local count = 0
  for _ in pairs(tab) do count = count + 1 end
  return count
end

obj.FLAGS = { "cmd", "alt", "shift", "ctrl", "fn" }
function flagTabToString(tab)
  local r=""
  hs.fnutils.each(obj.FLAGS, function(key)
    local ch
    if tab[key] ~= nil then ch="1" else ch="0" end
    r = r..ch
  end)
  return r
end

function obj:reset()
  -- print("resetting\n")
  self.lastModifiers = {}
  self.firstFlags = {}
  self.emitStroke = nil
  self.keypressCount = 0
end

function obj:init()
  self:reset()

  -- If `control` is held for this long, don't send `escape`
  local CANCEL_DELAY_SECONDS = 0.150
  self.controlKeyTimer = hs.timer.delayed.new(CANCEL_DELAY_SECONDS, function()
    self:reset()
    self.doublecontrolKeyTimer:stop()
  end)

  local CANCELDOUBLE_DELAY_SECONDS = 0.400
  self.doublecontrolKeyTimer = hs.timer.delayed.new(CANCELDOUBLE_DELAY_SECONDS, function()
    self:reset()
  end)

  -- Create an eventtap to run each time the modifier keys change (i.e., each
  -- time a key like control, shift, option, or command is pressed or released)
  self.controlTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged},
    function(event)
      local newModifiers = event:getFlags()

      -- If this change to the modifier keys does not invole a *change* to the
      -- up/down state of the `control` key, then don't take
      -- any action.
      if #self.lastModifiers>0 and newModifiers.containExactly(self.lastModifiers) then
        return false
      end

      if #self.firstFlags>0 and not newModifiers.containExactly(self.firstFlags) then
        self:reset()
        return false
      end

      -- If the `control` key has changed to the down state, then start the
      -- timer. If the `control` key changes to the up state before the timer
      -- expires, then send `escape`.
      -- print(tostring(tableLength(newModifiers)))
      if tableLength(newModifiers) > 0 then -- key changed to down state
        -- print('keydown '..tostring(self.keypressCount))
        local strokeTab = self.strokeMap[flagTabToString(newModifiers)]
        -- print(flagTabToString(newModifiers).." -> "..tostring(strokeTab).." "..self.keypressCount)
        -- if #self.firstFlags>0 and self.firstFlags.contain(newModifiers) then
        --   return true
        -- end

        if not strokeTab then
          -- print("Ignoring \n")
          -- return false
        else
          -- print('keydown timer started '..tostring(self.keypressCount))
          self.emitStroke = strokeTab
          self.controlKeyTimer:start()
          if self.keypressCount == 0 then
            -- if #self.firstFlags==0 or newModifiers.containExactly(self.firstFlags) then
              self.firstFlags = newModifiers
              self.doublecontrolKeyTimer:start()
            -- end
          end
        end
      else -- key changed to up state
        -- print('keyup ')
        if self.emitStroke then
          if self.keypressCount > 0 then
            self.doublecontrolKeyTimer:stop()
            -- print('keyup '..tostring(self.keypressCount))
            print('Double-tap emitting '..hs.inspect(self.emitStroke))
            hs.eventtap.keyStroke(self.emitStroke[1], self.emitStroke[2], 0)
            self:reset()
          else
            -- check if last press was the same flags
            local strokeTab = self.strokeMap[flagTabToString(self.lastModifiers)]
            if self.emitStroke == strokeTab then
              self.keypressCount = self.keypressCount + 1
            -- elseif tableLength(self.firstFlags)>0 and self.firstFlags.contain(newModifiers) then
            --   print("don't reset")
            else
              self:reset()
            end
            -- print('keyup++ '..tostring(self.keypressCount))
          end
        end
        self.controlKeyTimer:stop()
      end
      self.lastModifiers = newModifiers
      return false
    end
  )

  -- Create an eventtap to run each time a normal key (i.e., a non-modifier key)
  -- enters the down state. We only want to send `escape` if `control` is
  -- pressed and released in isolation. If `control` is pressed in combination
  -- with any other key, we don't want to send `escape`.
  self.keyDownEventTap = hs.eventtap.new({hs.eventtap.event.types.keyDown},
    function(event)
      -- print('ignored '..tostring(self.keypressCount))
      self:reset()
      return false
    end
  )
end

--- ControlEscape:start()
--- Method
--- Example:
--- start({
---     {{"shift"}, {ctrlcmd, 's'}},
---     {{"cmd"}, {ctrlcmd, 'x'}}
--- })
--- Flag options: cmd, alt, shift, ctrl, fn
function obj:start(bindingList)
  self.strokeMap = {}
  print("-- Double-tap:")
  hs.fnutils.each(bindingList, function(binding)
    if tableLength(binding[1])>1 then
      print("More than one flag not supported right now!")
    end
    flagTab = {}
    hs.fnutils.each(binding[1], function(flag) flagTab[flag]=true end)
    self.strokeMap[flagTabToString(flagTab)] = binding[2]
    print("     "..hs.inspect(binding[1]).." --> "..hs.inspect(binding[2]))
  end)

  -- print_r(self.strokeMap)
  self:init()
  self.controlTap:start()
  self.keyDownEventTap:start()
end

--- ControlEscape:stop()
--- Method
--- Stop sending `escape` when `control` is pressed and released in isolation
function obj:stop()
  -- Stop monitoring keystrokes
  self.controlTap:stop()
  self.keyDownEventTap:stop()

  -- Reset state
  self.controlKeyTimer:stop()
  self.doublecontrolKeyTimer:stop()
  self:reset()
end

return obj
