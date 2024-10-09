function widget:GetInfo()
   return {
      name      = "Mouse Buildspacing",
      desc      = "Use mousebuttons 4 and 5 for buildspacing",
      author    = "Auswaschbar",
      version   = "v1.0",
      date      = "Mar, 2010",
      license   = "GNU GPL, v3 or later",
      layer     = 200,
      enabled   = true,
   }
end

function widget:MousePress(mx, my, button)
	local alt,ctrl,meta,shift = Spring.GetModKeyState()
	-- Make sure not to conflict with usage of mouse 4-5 without modifiers.
	if alt or ctrl or meta or shift then
		if button == 4 then
			-- Spring.SetActiveCommand("selfd")
			Spring.SendCommands("buildspacing inc")
			return true
		elseif button == 5 then
			Spring.SendCommands("buildspacing dec")
			return true
		end
	end
	return false
end
