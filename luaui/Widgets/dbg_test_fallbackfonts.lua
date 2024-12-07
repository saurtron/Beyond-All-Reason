function widget:GetInfo()
    return {
        name = "Test fallback fonts",
        desc = "testing for the fallback fonts",
        author = "Saurtron",
        date = "2024",
        version = 41,
        license = "GNU GPL, v2 or later",
        layer = -4,
        enabled = true,
    }
end

local fenabled = false

function widget:MousePress(x, y, button)
	if button == 1 then
		if gl.ClearFallbackFonts then
			if not fenabled then
				fenabled = true
				--gl.AddFallbackFont('fonts2/NotoColorEmoji.ttf')
				local res = gl.AddFallbackFont('fonts2/NotoEmoji-VariableFont_wght.ttf')
				if not res then
					Spring.Echo("No fallback font")
				end
				res = gl.AddFallbackFont('fonts2/badfont.ttf')
				if not res then
					Spring.Echo("Bad fallback ok")
				end
				Spring.Echo("Fallback fonts", fenabled)
			else
				fenabled = false
				gl.ClearFallbackFonts()
				Spring.Echo("Fallback fonts", fenabled)
			end
		end
	end
end
