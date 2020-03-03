-- Code from https://github.com/Hammerspoon/hammerspoon/issues/235
-- Make sure to install spaces module https://github.com/asmagill/hs._asm.undocumented.spaces

local spaces = require "hs._asm.undocumented.spaces"

local function getGoodFocusedWindow(nofull)
   local win = hs.window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end

local function errorScreen(screen)
  hs.sound.getByName("Funk"):play()
  hs.alert.show('End of space')
end

-- function switchSpace(skip,dir)
--    for i=1,skip do
--       hs.eventtap.keyStroke({"ctrl"},dir)
--    end
-- end

function moveWindowOneSpace(dir,switch)
   local win = getGoodFocusedWindow(true)
   if not win then return end
   local screen=win:screen()
   local uuid=screen:spacesUUID()
   local userSpaces=spaces.layout()[uuid]
   local thisSpace=win:spaces() -- first space win appears on
   if not thisSpace then return else thisSpace=thisSpace[1] end
   local last=nil
   local skipSpaces=0
   for _, spc in ipairs(userSpaces) do
      if spaces.spaceType(spc)~=spaces.types.user then -- skippable space
         skipSpaces=skipSpaces+1
      else 			-- A good user space, check it
   	 if last and
   	    (dir=="left"  and spc==thisSpace) or
   	    (dir=="right" and last==thisSpace)
   	 then
   	    win:spacesMoveTo(dir=="left" and last or spc)
   	    if switch then
            --  switchSpace(skipSpaces+1,dir)
   	      win:focus()
   	    end
   	    return
   	 end
   	 last=spc	 -- Haven't found it yet...
   	 skipSpaces=0
      end
   end
   errorScreen(screen)   -- Shouldn't get here, so no space found
end

-- hs.hotkey.bind(hypershift, "7", nil, function() moveWindowOneSpace("left", true) end)
-- hs.hotkey.bind(hypershift, "8", nil, function() moveWindowOneSpace("right", true) end)

function moveToSpace(dir,switch)
   local win = getGoodFocusedWindow(true)
   if not win then return end
   local screen=win:screen()
   local uuid=screen:spacesUUID()
   local userSpaces=spaces.layout()[uuid]
   local thisSpace=win:spaces() -- first space win appears on
   if not thisSpace then return else thisSpace=thisSpace[1] end
   local last=nil
   local skipSpaces=0
   for _, spc in ipairs(userSpaces) do
      if spaces.spaceType(spc)~=spaces.types.user then -- skippable space
         skipSpaces=skipSpaces+1
      else        -- A good user space, check it
       if last and
          (dir=="left"  and spc==thisSpace) or
          (dir=="right" and last==thisSpace)
       then
          win:x(dir=="left" and last or spc)
          if switch then
            --  switchSpace(skipSpaces+1,dir)
            win:focus()
          end
          return
       end
       last=spc    -- Haven't found it yet...
       skipSpaces=0
      end
   end
   errorScreen(screen)   -- Shouldn't get here, so no space found
end

