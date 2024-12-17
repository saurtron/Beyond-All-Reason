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

-- to test color use the second fontfile here
local fontfile = 'fonts2/NotoEmoji-VariableFont_wght.ttf'
--local fontfile = 'fonts2/NotoColorEmoji.ttf'

function widget:Initialize()
	if not gl.ClearFallbackFonts then
		widgetHandler:RemoveWidget()
	end
end

function widget:MousePress(x, y, button)
	if button == 1 then
		if gl.ClearFallbackFonts then
			if not fenabled then
				fenabled = true
				local res = gl.AddFallbackFont(fontfile)
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

function widget:GameFrame(gf)
	if gf == 3 then
		if not gl.AddFallbackFont then
			Spring.SendCommands("not the right spring version!!")
			widgetHandler:RemoveWidget()
		end
		Spring.SendCommands("say test")
		Spring.SendCommands("say hello 🔥")
	elseif gf == 150 then
		gl.AddFallbackFont(fontfile)
	elseif gf == 152 then
		Spring.SendCommands("say fallbacks enabled")
		Spring.SendCommands("say fallback 🔥")
	elseif gf == 450 then
		gl.ClearFallbackFonts()
	elseif gf == 452 then
		Spring.SendCommands("say fallbacks disabled")
		Spring.SendCommands("say system 🔥")
	end
end
