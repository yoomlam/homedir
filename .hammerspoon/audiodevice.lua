

function adjustAudioVolume(increment, absolute)
	local dev=hs.audiodevice.defaultOutputDevice()
  if dev:muted() then
    dev:setMuted(false)
  end
	if increment then
		dev:setOutputVolume(dev:volume()+increment)
	else
		dev:setOutputVolume(absolute)
	end
end

local function toggleMute()
  local dev = hs.audiodevice.defaultOutputDevice()
  dev:setMuted(not dev:muted())
end

-- MAYBE add to modal
hs.hotkey.bind(ctrlcmdshift, "=", "increasing volume", function() adjustAudioVolume(5) end)
hs.hotkey.bind(ctrlcmdshift, "-", "decreasing volume", function() adjustAudioVolume(-5) end)
-- hs.hotkey.bind(ctrlcmdshift, "0", "muting volume", function() hs.audiodevice.defaultOutputDevice():setOutputMuted() end)
hs.hotkey.bind(ctrlcmdshift, "0", "un/muting volume", function() toggleMute() end)

