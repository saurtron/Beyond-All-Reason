function widget:GetInfo()
    return {
        name    = "Ping Wheel",
        desc    =
        "Displays a ping wheel when a keybind is held down. Default keybind is 'alt-w', rebindable. Left click (or mouse 4) to bring up commands wheel, right click (or mouse 5) for messages wheel.",
        author  = "Errrrrrr, IceXuick, Saurtron",
        date    = "June 27, 2023",
        license = "GNU GPL, v2 or later",
        version = "3.0 alpha1",
        layer   = -1,
        enabled = true,
    }
end

-----------------------------------------------------------------------------------------------
-- The wheel is opened by holding the keybind (default: alt-w), left click to select an option.
--
-- Also supports pressrelease interface meaning mouse press or keybind press makes wheel appear,
-- and release selects the option.
--
-- Bindable action name: ping_wheel_on
--
-- Default is just one wheel, but two wheel mode can be activated through options gui.
--
-- You can add or change the options in the pingWheel tables editing this or through json files.
-- Files for custom items are: commands.json and/or messages.json (inside LuaUI/Config/pingwheel/).
-- the two tables pingCommands and pingMessages are main (left) and secondary (right) click options respectively.
--
-- Other features: I18N support, configurable through gui, different styles, background blur.
-----------------------------------------------------------------------------------------------


local iconDir = 'anims/icexuick_75/'
local configDir = 'LuaUI/Config/pingwheel/'

-- Wheel item attributes for the pingCommands and pingMessages tables:
-- * name: The item label and message.
-- * msg: (optional) If set, will override the msg sent for that item.
-- * color (optional): Color for the message, note it will only be displayed if use colors is activated in options gui.
-- * icon (optional): Icon for the item, will also be sent on the ping message and can be displayed by ping renderer.
-- * icon_offset (optional): Offset for the icon, for off-center icons.
-- * icon_size (optional): Scale to icon (default is 1 meaning normal size).

local attackCommands = {
    { name = "All-in", icon = iconDir..'cursordgun_4.png' },
    { name = "Push", icon = iconDir..'cursorcapture_7.png', icon_offset={0, -4} },
    { name = "Pressure", icon = iconDir..'cursorattack_15.png' },
}
local defendCommands = {
    { name = "ui.wheel.retreat" },
    { name = "Protect", icon = iconDir..'cursordefend_55.png' },
    { name = "Hold", icon = iconDir..'cursorcentroid_0.png' },
}
local paidCommands = {
    { name = "T1 con", msg = "T1 con pls" },
    { name = "Transport", msg = "Transport pls" },
    { name = "Scout", msg = "Scout pls" },
}
local alertCommands = {
    { name = "Danger", icon = iconDir..'cursorsettarget_57.png' },
    { name = "Caution", icon = iconDir..'cursorsettarget_38.png' },
    { name = "T3", icon = iconDir..'cursorselfd_11.png' },
}
local helpCommands = {
    { name = "Air", icon = iconDir..'cursorunload_31.png' },
    { name = "Vision", icon = iconDir..'cursordwatch_0.png' },
    { name = "Support", icon = iconDir..'cursorrepair_44.png' },
}

local pingCommands = {                             -- the options in the ping wheel, displayed clockwise from 12 o'clock
    { name = "ui.wheel.attack",  color = { 1, 0.3, 0.3, 1 }, icon = iconDir..'cursorattack_2.png', children=attackCommands },
    --{ name = "Rally",   color = { 0.4, 0.8, 0.4, 1 }, icon = iconDir..'cursorfight_11.png', icon_offset={7, -8} },
    { name = "Defend",  color = { 0.7, 0.9, 1, 1 }, icon = iconDir..'cursordefend_59.png', icon_size=0.8, children=defendCommands },
    { name = "Help",    color = { 0.9, 0.7, 1, 1 }, children=helpCommands, icon=iconDir..'cursorgather_0.png' },
    { name = "Alert",   color = { 1, 1, 0.5, 1 }, children=alertCommands, icon=iconDir..'cursorsettarget_0.png' },
    { name = "Reclaim", color = { 0.7, 1, 0.7, 1 }, icon = iconDir..'cursorreclamate_55.png' },
    { name = "On my way",  color = { 0.5, 0, 1, 1 }, icon = iconDir..'cursormove_24.png', icon_offset={7, -8} },
    { name = "Paid",    color = { 1, 0.2, 0.2, 1 }, children=paidCommands, icon=iconDir..'cursorpurchase_0.png', icon_size=0.6 },
    --{ name = "Wait",    color = { 0.7, 0.6, 0.3, 1 }, icon = iconDir..'cursorwait_31.png' },
}

local pingMessages = {
    { name = "TY!",      color = { 1, 1, 1, 1 } },
    { name = "GJ!",      color = { 1, 0.5, 0, 1 } },
    { name = "DANGER!",  color = { 1, 1, 0, 1 } },
    { name = "Sorry!",   color = { 0, 1, 0, 1 } },
    { name = "LOL",      color = { 0, 1, 1, 1 } },
    { name = "No",       color = { 0, 0, 1, 1 } },
    { name = "ui.wheel.omw",  color = { 0.5, 0, 1, 1 }, icon = iconDir..'cursormove_24.png', icon_offset={7, -8} },
    { name = "ui.wheel.paid", color = { 1, 0, 1, 1 } },
    -- example using msg attribute:
    -- { name = "Shop Open", msg = "shop open; 440m per each (paying is mandatory)", color = { 0.5, 0, 1, 1 } },
}

local styleChoice = 1       -- change from options gui

-- Available styles
local styleConfig = {
    [1] = {
        name = "White",
        baseTextOpacity = 1.0,
        wheelBaseColor = {0.05, 0.0, 0.0, 0.35},
        selOuterRadius = 0.94,
    },
    [2] = {
        name = "Black",
        wheelSelColor = {0.0, 0.0, 0.0, 0.7},
        wheelRingColor = {0.0, 0.0, 0.0, 0.7},
        baseTextOpacity = 1.0,
        selOuterRadius = 0.94,
    },
    [3] = {
        name = "Circle Light",
        bgTexture = "LuaUI/images/glow.dds",
        bgTextureSizeRatio = 1.2,
        bgTextureColor = { 0, 0, 0, 0.7 },
        textSize = 22,
        drawBase = false,
        drawDividers = true,
        baseOuterRadius = 0.8,
        closeHintSize = 0.85,
    },
    [4] = {
        name = "Ring Light",
        bgTexture = "LuaUI/images/enemyspotter.dds",
        dividerInnerRatio = 0.34,
        dividerOuterRatio = 0.68,
        textSize = 22,
        drawBase = false,
        drawDividers = true,
        baseOuterRadius = 0.8,
        closeHintSize = 0.85,
    },
}

-- Style defaults
local defaults = {
    drawBase = true,
    drawDividers = false,
    iconSize = 0.09,
    bgTextureColor = { 0, 0, 0, 0.5 },
    bgTextureSizeRatio = 1.15,
    dividerColor = { 1, 1, 1, 0.15 },
    dividerInnerRatio = 0.25,
    dividerOuterRatio = 0.62,
    textSize = 16,
    textAlignRadiusRatio = 0.62,
    wheelBaseColor = {0.0, 0.0, 0.0, 0.3},
    wheelSelColor = {1.0, 1.0, 1.0, 0.5},
    wheelRingColor = {1.0, 1.0, 1.0, 0.5},
    wheelAreaOutlineColor = {0.0, 0.0, 0.0, 0.7},
    selTextOpacity = 1.0,
    baseTextOpacity = 0.75,
    selOuterRadius = 0.9,
    baseOuterRadius = 0.9,
    -- next ones are not editable from style atm
    baseWheelSize = 0.355,            -- ~1/3 screen
    deadZoneBaseRatio = 0.12,         -- the center "no selection" area as a ratio of the ping wheel radius
    areaOutlineBaseWidth = 2.1,       -- width of the outer circle line
    dividerLineBaseWidth = 3.5,       -- width of the divider empty space between sections
    centerDotBaseSize = 15,           -- size of the center dot
    outerCircleBaseWidth = 2.5,       -- width of the outer circle line
    linesBaseWidth = 2.1,             -- thickness of the ping wheel line drawing
    soundDefaultSelect = "sounds/commands/cmd-default-select.wav",
    soundSetTarget = "sounds/commands/cmd-settarget.wav",
    rclickIcon = "icons/mouse/rclick_glow.png",
    closeHintSize = 1,
    outerCircleRatio = 0.92,          -- the outer circle radius ratio
    secondaryInnerRatio = 0.93,       -- secondary items inner limit
    secondaryOuterRatio = 1.4,        -- secondary items outer limit
    outerLimitRatio = 1.5,            -- the outer limit ratio where "no selection" is active
}

-- On/Off switches
local draw_line = false     -- set to true to draw a line from the center to the cursor during selection
local draw_deadzone = false -- set to true to draw a circle around the dead zone (for debugging purposes)
local do_blur = true        -- set to false to avoid doing blur

-- Fade and spam frames (set to 0 to disable)
-- NOTE: these are game frames, not display frames, so always 30 fps
local numFadeInFrames = 4   -- how many frames to fade in
local numFadeOutFrames = 4  -- how many frames to fade out
local numFlashFrames = 7    -- how many frames to flash when spamming
local spamControlFrames = 8 -- how many frames to wait before allowing another ping

-- Sizes and colors
local centerAreaRatio = 0.29
local deadZoneRatio = defaults.deadZoneBaseRatio

local pingWheelSelTextAlpha = defaults.selTextOpacity
local pingWheelBaseTextAlpha = defaults.selBaseTextOpacity

local pingWheelTextBaseSize = defaults.textSize
local pingWheelTextColor = { 1, 1, 1, 0.7 }
local pingWheelTextHighlightColor = { 1, 1, 1, 1 }
local pingWheelTextSpamColor = { 0.9, 0.9, 0.9, 0.4 }

local playerColor = { 0.9, 0.8, 0.5, 0.6 } -- will be overwritten with actual player color.

local pingWheelBaseColor = defaults.wheelBaseColor
local pingWheelSelColor = defaults.wheelSelColor
local pingWheelRingColor = defaults.wheelRingColor
local pingWheelAreaOutlineColor = defaults.wheelAreaOutlineColor
local pingWheelAreaInlineColor = {0.5, 0.5, 0.5, 0.4}
local pingWheelDrawBase = defaults.drawBase

local selectedScaleFactor = 1.3         -- how much bigger to draw selected item text

---------------------------------------------------------------
-- End of params
--

-- Load custom wheel options from commands.json and messages.json

local function loadPingWheelMessages(fileName, destArray)
    local fullPath = configDir .. fileName
    if not VFS.FileExists(fullPath) then return end
    local jsonData = VFS.LoadFile(fullPath)
    local final = {}
    -- filter out lines starting with #
    for _, line in ipairs(jsonData:lines()) do
        if string.sub(line:trim(), 1, 1) ~= '#' then
            final[#final+1] = line
        end
    end
    final = table.concat(final, "\n")

    local success, data = pcall(Json.decode, final)
    if not success then
        Spring.Log("Ping Wheel", LOG.ERROR, "Can't load " .. fullPath)
        return
    end

    if destArray == 'commands' then
        pingCommands = data
    else
        pingMessages = data
    end
end

loadPingWheelMessages('commands.json', 'commands')
loadPingWheelMessages('messages.json', 'messages')


-- Internal switches
local doDividers = true
local showLRHint = false

local pressReleaseMode = false
local doubleWheel = false
local useIcons = true
local hasCenterAction = true

-- Calculated sizes
local iconSize = defaults.iconSize

local wheelRadius
local pingWheelThickness
local centerDotSize
local dividerLineWidth
local pingWheelTextSize
local pingWheelRingWidth
local pingWheelBorderWidth
local selOuterRatio = defaults.selOuterRadius
local baseOuterRatio = defaults.baseOuterRadius
local closeHintSize = defaults.closeHintSize
local areaVertexNumber = 10
local secondaryOuterRatio = defaults.secondaryOuterRatio

-- Calculated sizes
local function updateSizes(vsx, vsy)
    if not vsx then
        vsx, vsy = Spring.GetViewGeometry()
    end
    local f = math.min(vsx, vsy) / 1080.0
    wheelRadius = (math.min(vsx, vsy)*defaults.baseWheelSize)/2
    pingWheelTextSize = pingWheelTextBaseSize * f
    centerDotSize = defaults.centerDotBaseSize * f
    dividerLineWidth = defaults.dividerLineBaseWidth * f
    pingWheelThickness = defaults.linesBaseWidth * f
    pingWheelRingWidth = defaults.outerCircleBaseWidth * f
    pingWheelBorderWidth = defaults.areaOutlineBaseWidth * f
end

updateSizes()

-- Squared variables
local deadZoneRadiusSq
local outerLimitRadiusSq
local baseOuterRadiusSq
local centerAreaRadiusSq

local function setSizedVariables()
    deadZoneRadiusSq = (deadZoneRatio*wheelRadius)^2
    outerLimitRadiusSq = (defaults['outerLimitRatio']*wheelRadius)^2
    baseOuterRadiusSq = (baseOuterRatio*wheelRadius)^2
    centerAreaRadiusSq = (centerAreaRatio*wheelRadius)^2
    secondaryOuterRadiusSq = (secondaryOuterRatio*wheelRadius)^2
end

--- Other file variables
local globalDim = 1     -- this controls global alpha for all wheel elements
local globalFadeIn = 0  -- how many frames left to fade in
local globalFadeOut = 0 -- how many frames left to fade out

local bgTexture = "LuaUI/images/glow.dds"
local bgTextureSizeRatio = defaults.bgTextureSizeRatio
local bgTextureColor = defaults.bgTextureColor
local dividerInnerRatio = defaults.dividerInnerRatio
local dividerOuterRatio = defaults.dividerOuterRatio
local textAlignRatio = defaults.textAlignRadiusRatio
local dividerColor = defaults.dividerColor

local pingWheel = pingCommands
local keyDown = false
local displayPingWheel = false

local pingWorldLocation
local screenLocation
local mainSelection = 0
local secondarySelection = 0
local centerSelected = false
local spamControl = 0
local flashFrame = 0
local flashing = false
local lineScale = 1

-- Speedups
local spGetMouseState = Spring.GetMouseState
local spGetModKeyState = Spring.GetModKeyState
local atan2 = math.atan2
local floor = math.floor
local pi = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

-- caches
local baseCircleArrays = {}
local cachedTexts = {}

-- Display lists
local itemsDlist
local baseDlist
local decorationsDlist
local blurDlist
local recreateBlurDlist

local function destroyItemsDlist()
    if not itemsDlist then return end
    gl.DeleteList(itemsDlist)
    itemsDlist = nil
end
local function destroyBaseDlist()
    if not baseDlist then return end
    gl.DeleteList(baseDlist)
    baseDlist = nil
end
local function destroyDecorationsDlist()
    if not decorationsDlist then return end
    gl.DeleteList(decorationsDlist)
    decorationsDlist = nil
end
local function destroyBlurDlist()
    if not blurDlist then return end
    WG['guishader'].RemoveDlist('pingwheel')
    gl.DeleteList(blurDlist)

    blurDlist = nil
end

-- Shader globals
local shader
local luaShaderDir = "LuaUI/Widgets/Include/"
local LuaShader = VFS.Include(luaShaderDir.."LuaShader.lua")

-- GL speedups
local glCallList             = gl.CallList
local glColor                = gl.Color
local glLineWidth            = gl.LineWidth
local glPopMatrix            = gl.PopMatrix
local glBlending             = gl.Blending
local glBeginEnd             = gl.BeginEnd
local glBeginText            = gl.BeginText
local glEndText              = gl.EndText
local glTexture              = gl.Texture
local glTexRect              = gl.TexRect
local glTranslate            = gl.Translate
local glText                 = gl.Text
local glVertex               = gl.Vertex
local glPointSize            = gl.PointSize
local GL_LINES               = GL.LINES
local GL_LINE_LOOP           = GL.LINE_LOOP
local GL_POINTS              = GL.POINTS
local GL_SRC_ALPHA           = GL.SRC_ALPHA
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local glPushMatrix           = gl.PushMatrix

local glColorMask           = gl.ColorMask
local glStencilFunc         = gl.StencilFunc
local glStencilOp           = gl.StencilOp
local glStencilTest         = gl.StencilTest
local glStencilMask         = gl.StencilMask
local GL_ALWAYS = GL.ALWAYS
local GL_NOTEQUAL = GL.NOTEQUAL
local GL_EQUAL = GL.EQUAL
local GL_KEEP = 0x1E00 --GL.KEEP
local GL_REPLACE = GL.REPLACE

------------------------
--- Translations and sending of messages
---

function widget:LanguageChanged()
    cachedTexts = {}
end

local function getTranslatedText(text)
    if string.sub(text, 1, 3) == 'ui.' then
        if cachedTexts[text] then return cachedTexts[text] end
        local newText = Spring.I18N(text)
        if text == newText then
            local splitText = string.split(text, ".")
            newText = splitText[#splitText]:gsub("^%l", string.upper)
        end
        cachedTexts[text] = newText
        return newText
    end
    return text
end

local function createMapPoint(playerID, text, x, y, z, color, icon)
    data = {text = text, x = x, y = y, z = z, r = r, g = g, b = b, icon = icon}
    if color then
        data.r = color[1]
        data.g = color[2]
        data.b = color[3]
    end
    msg = Json.encode(data)
    Spring.SendLuaUIMsg('mppnt:' .. msg)
end

------------------------
--- Configuration
---

function widget:GetConfigData()
    return {
        wheelStyle = styleChoice,
        interactionMode = pressReleaseMode and 2 or 1,
        useIcons = useIcons,
        doubleWheel = doubleWheel
    }
end

function widget:SetConfigData(data)
    if data.wheelStyle ~= nil then
        styleChoice = data.wheelStyle
    end
    if data.interactionMode ~= nil then
        pressReleaseMode = data.interactionMode == 2
    end
    if data.useIcons ~= nil then
        useIcons = data.useIcons
    end
    if data.doubleWheel ~= nil then
        doubleWheel = data.doubleWheel
    end
end

local function applyStyle()
    local style = styleConfig[styleChoice]
    bgTexture = style.bgTexture
    bgTextureSizeRatio = style.bgTextureSizeRatio or defaults.bgTextureSizeRatio
    bgTextureColor = style.bgTextureColor or defaults.bgTextureColor
    pingWheelIconSize = style.iconSize or defaults.iconSize
    dividerInnerRatio = style.dividerInnerRatio or defaults.dividerInnerRatio
    dividerOuterRatio = style.dividerOuterRatio or defaults.dividerOuterRatio
    textAlignRatio = style.textAlignRadiusRatio or defaults.textAlignRadiusRatio
    dividerColor = style.dividerColor or defaults.dividerColor
    pingWheelTextBaseSize = style.textSize or defaults.textSize
    pingWheelSelTextAlpha = style.selTextOpacity or defaults.selTextOpacity
    pingWheelBaseTextAlpha = style.baseTextOpacity or defaults.baseTextOpacity
    baseOuterRatio = style.baseOuterRadius or defaults.baseOuterRadius
    closeHintSize = style.closeHintSize or defaults.closeHintSize
    pingWheelDrawBase = style.drawBase
    if pingWheelDrawBase == nil then
        pingWheelDrawBase = defaults.drawBase
    end

    if pingWheelDrawBase then
        pingWheelSelColor = style.wheelSelColor or defaults.wheelSelColor
        pingWheelRingColor = style.wheelRingColor or defaults.wheelRingColor
        pingWheelAreaOutlineColor = style.wheelAreaOutlineColor or defaults.wheelAreaOutlineColor
        pingWheelBaseColor = style.wheelBaseColor or defaults.wheelBaseColor
        selOuterRatio = style.selOuterRadius or defaults.selOuterRadius
        doDividers = false
        deadZoneRatio = defaults.deadZoneBaseRatio
        hasCenterAction = true
    else
        doDividers = style.drawDividers
        deadZoneRatio = centerAreaRatio
        hasCenterAction = false
    end
    local vx, vy = Spring.GetViewGeometry()

    local sizeRatio = math.min(vx, vy)/1080.0
    pingWheelTextSize = pingWheelTextBaseSize * sizeRatio

    setSizedVariables()
    destroyItemsDlist()
    destroyDecorationsDlist()
    destroyBaseDlist()
end

------------------------
--- Shaders
---

local vsSrc = [[
	#version 150 compatibility
	#extension GL_ARB_shading_language_420pack: require // for engine defs
	#line 10000

	uniform float scale;
	uniform vec4 mousePosition;

	out vec2 texCoord;

	//__ENGINEUNIFORMBUFFERDEFS__

	#line 11000

	void main() {
		vec4 vertPos = gl_Vertex;

		float viewratio = viewGeometry.x / viewGeometry.y;

		vec2 stretched = vec2(vertPos.x , vertPos.y * viewratio);
		stretched.xy *= scale;

		vec4 screenPos = mousePosition;
		screenPos.y *= viewratio;
		screenPos.xy += stretched.xy;

		// outputs
		gl_Position = screenPos;
		gl_FrontColor = gl_Color;
		texCoord = gl_MultiTexCoord0.st;
	}
]]

local fsSrc = [[
	#version 150 compatibility
	#line 20000

	uniform sampler2D tex0;
	uniform float alpha;
	uniform float useTex;

	in vec2 texCoord;

	void main(void) {
		if (useTex > 0.5) {
			gl_FragColor = texture2D(tex0, texCoord);
			gl_FragColor *= gl_Color;
		} else {
			gl_FragColor = gl_Color;
		}
		gl_FragColor.a *= alpha;
	}
]]

local function loadShaders()
    local engineUniformBufferDefs = LuaShader.GetEngineUniformBufferDefs()
    vsSrc = vsSrc:gsub("//__ENGINEUNIFORMBUFFERDEFS__", engineUniformBufferDefs)

    shader = LuaShader({vertex=vsSrc, fragment=fsSrc}, "ping wheel")
    shaderCompiled = shader:Initialize()
    if not shaderCompiled then
        shader:ShowError(shader.shLog)
    end
end

local function destroyShaders()
    if shader then shader:Finalize() end
end

------------------------
--- Init/shutdown and maintenance
---

function widget:Initialize()
    loadShaders()
    WG['pingwheel_gui'] = {}
    WG['pingwheel_gui'].getWheelStyle = function()
        return styleChoice
    end
    WG['pingwheel_gui'].setWheelStyle = function(value)
        styleChoice = value
        applyStyle()
    end
    WG['pingwheel_gui'].getUseIcons = function()
        return useIcons
    end
    WG['pingwheel_gui'].setUseIcons = function(value)
        useIcons = value
        destroyItemsDlist()
    end
    WG['pingwheel_gui'].getInteractionMode = function()
        return pressReleaseMode and 2 or 1
    end
    WG['pingwheel_gui'].setInteractionMode = function(value)
        pressReleaseMode = value == 2
        destroyItemsDlist()
    end
    WG['pingwheel_gui'].getDoubleWheel = function()
        return doubleWheel
    end
    WG['pingwheel_gui'].setDoubleWheel = function(value)
        doubleWheel = value
        destroyItemsDlist()
        destroyDecorationsDlist()
        destroyBaseDlist()
    end

    -- add the action handler with argument for press and release using the same function call
    widgetHandler:AddAction("ping_wheel_on", PingWheelAction, { true }, "p") --pR do we actually want Repeat?
    -- widgetHandler.actionHandler:AddAction(self, "ping_wheel_on", PingWheelAction, { false }, "r") -- can't trust release event since releasing modified first makes it fail detection
    playerColor = { Spring.GetTeamColor(Spring.GetMyTeamID()) }

    -- set the style from config
    applyStyle()
end

function widget:Shutdown()
    destroyItemsDlist()
    destroyDecorationsDlist()
    destroyBaseDlist()
    destroyBlurDlist()
    destroyShaders()
end

function widget:ViewResize(vsx, vsy)
    updateSizes(vsx, vsy)
    setSizedVariables()
    destroyItemsDlist()
    destroyDecorationsDlist()
    destroyBaseDlist()
end

------------------------
--- Turning on and off
---

-- Store the ping location in pingWorldLocation
local function SetPingLocation()
    local mx, my = spGetMouseState()
    local _, pos = Spring.TraceScreenRay(mx, my, true)
    if pos then
        pingWorldLocation = { pos[1], pos[2], pos[3] }
        screenLocation = { x = mx, y = my }

        -- play a UI sound to indicate wheel is open
        Spring.PlaySoundFile(defaults.soundSetTarget, 0.1, 'ui')
    end
end

local function FadeIn()
    if numFadeInFrames == 0 or not displayPingWheel then return end
    globalFadeIn = numFadeInFrames
    globalFadeOut = 0
end

local function FadeOut()
    if flashing then return end
    if numFadeOutFrames == 0 then return end
    globalFadeIn = 0
    globalFadeOut = numFadeOutFrames
end

local function TurnOn(reason)
    -- set pingwheel to display
    displayPingWheel = true
    showLRHint = false
    if not pingWorldLocation then
        SetPingLocation()
    end
    --Spring.Echo("Turned on: " .. reason)
    FadeIn()
    return true
end

local function TurnOff(reason)
    if displayPingWheel then
        if mainSelection ~= 0 or centerSelected then
            destroyBaseDlist()
        end
        destroyItemsDlist()
        destroyBlurDlist()
        displayPingWheel = false
        pingWorldLocation = nil
        screenLocation = nil
        mainSelection = 0
        centerSelected = false
        --Spring.Echo("Turned off: " .. reason)
        return true
    end
end

-- sets flashing effect to true and turn off wheel display
local function FlashAndOff()
    flashing = true
    flashFrame = numFlashFrames
end

local function checkRelease()
    if displayPingWheel
        and pingWorldLocation
        and spamControl == 0
    then
        if (mainSelection > 0 or centerSelected) and not flashing then
            local pingText, color, icon
            local selWheel, sel
            if secondarySelection > 0 then
                selWheel = pingWheel[mainSelection].children
                sel = secondarySelection
            elseif mainSelection > 0 then
                selWheel = pingWheel
                sel = mainSelection
            end
            if selWheel then
                pingText = selWheel[sel].msg or selWheel[sel].name
                color = selWheel[sel].color or pingWheel[mainSelection].color or playerColor
                icon = selWheel[sel].icon or pingWheel[mainSelection].icon
            end
            createMapPoint(Spring.GetMyPlayerID(), pingText, pingWorldLocation[1], pingWorldLocation[2], pingWorldLocation[3],
                color, icon)

            -- Spam control is necessary!
            spamControl = spamControlFrames

            -- play a UI sound to indicate ping was issued
            --Spring.PlaySoundFile("sounds/ui/mappoint2.wav", 1, 'ui')
            FlashAndOff()
            return true
        else
            FadeOut()
        end
        -- make sure left/right hint is not shown
        showLRHint = false
    else
        FadeOut()
    end
end

------------------------
--- Key/Mouse Interaction

local function setSelection(selected, secondary, centersel)
    if selected ~= mainSelection or centersel ~= centerSelected or secondary ~= secondarySelection then
        destroyItemsDlist()
        destroyBaseDlist()
        if selected ~= mainSelection then
            -- avoid blur 'blinking' if we destroy the list here
            recreateBlurDlist = true
        end
        if selected ~=0 or centersel or secondary ~=0 then
            Spring.PlaySoundFile(defaults.soundDefaultSelect, 0.3, 'ui')
        end
    end
    mainSelection = selected
    secondarySelection = secondary
    centerSelected = centersel
end

local function setWheel(selected)
    if selected ~= pingWheel then
        destroyDecorationsDlist()
        destroyItemsDlist()
        destroyBaseDlist()
    end
    pingWheel = selected
end

function widget:KeyRelease(key)
    keyDown = false
    showLRHint = false
    if not pressReleaseMode and displayPingWheel and key == 27 then -- could include KEYSIMS but not sure it's worth it
        -- click mode: allow closing with esc.
        FadeOut()
    elseif pressReleaseMode and displayPingWheel then
        -- pressRelease mode: allow activating on key release.
        checkRelease()
    end
end

function PingWheelAction(_, _, _, args)
    if args[1] then
        keyDown = true
        if doubleWheel then
            showLRHint = true
        end
        if not displayPingWheel and doubleWheel and pressReleaseMode then
            SetPingLocation()
        end
        if not displayPingWheel and not doubleWheel then
            TurnOn("Single press")
        end
    else
        -- NOTE: can't trust release action since if modifier is released first it won't trigger
        --keyDown = false
        --if displayPingWheel and not doubleWheel then
        --    checkRelease()
        --end
    end
end

function widget:MousePress(mx, my, button)
    if displayPingWheel and not pressReleaseMode then
        -- click mode: allow activating option with left and close with right.
        if button == 1 then
            return checkRelease()
        else
            -- technically right click, but any button other than left seems more intuitive
            FadeOut()
            return true
        end
    elseif displayPingWheel and pressReleaseMode then
        -- release mode: allow click as well as release.
        if button == 1 then
            return checkRelease()
        elseif button == 3 then
            FadeOut()
            return true
        end
    elseif showLRHint or button == 4 or button == 5 then
        local alt, ctrl, meta, shift = spGetModKeyState()
        -- If any modifier is pressed we let other widgets handle this
        -- unless on our keydown event.
        if showLRHint or not (alt or ctrl or meta or shift) then
            local chosenWheel = false
            if button == 1 or button == 4 then
                chosenWheel = pingCommands
            elseif not doubleWheel and (button == 3 or button == 5) then
                chosenWheel = pingCommands
            elseif button == 3 or button == 5 then
                chosenWheel = pingMessages
            end
            if chosenWheel then
                setWheel(chosenWheel)
                TurnOn("mouse press")
                return true -- block all other mouse presses
            end
        end
    else
        -- set pingwheel to not display
        FadeOut()
    end
end


-- when mouse is pressed, issue the ping command
function widget:MouseRelease(mx, my, button)
    if pressReleaseMode then
        checkRelease()
    end
end

local sec, sec2 = 0, 0
function widget:Update(dt)
    sec = sec + dt
    -- we need smooth update of fade frames
    if (sec > 0.017) and (globalFadeIn > 0 or globalFadeOut > 0) then
        sec = 0
        if globalFadeIn > 0 then
            globalFadeIn = globalFadeIn - 1
            globalDim = 1 - globalFadeIn / numFadeInFrames
        else
            globalFadeOut = globalFadeOut - 1
            if globalFadeOut == 0 then
                TurnOff("globalFadeOut 0")
            end
            globalDim = globalFadeOut / numFadeOutFrames
            return
        end
    end

    if mainSelection ~= 0 or centerSelected or secondarySelection ~= 0 then
        Spring.SetMouseCursor("cursornormal")
    end

    sec2 = sec2 + dt
    if (sec2 > 0.03) and displayPingWheel then
        sec2 = 0
        if spamControl > 0 then
            spamControl = (spamControl == 0) and 0 or (spamControl - 1)
        end
        if not screenLocation then
            return
        end
        if flashing then
            if flashFrame > 0 then
                flashFrame = flashFrame - 1
            else
                flashing = false
                FadeOut()
            end
        else
            local mx, my = spGetMouseState()
            -- calculate where the mouse is relative to the screenLocation, remember top is the first selection
            local dx = mx - screenLocation.x
            local dy = my - screenLocation.y
            local dist = dx * dx + dy * dy

            -- deadzone is no selection
            if (dist < deadZoneRadiusSq)
                or (dist > outerLimitRadiusSq)
            then
                setSelection(0, 0, false)
                return
            end

            -- center area
            if hasCenterAction and dist < centerAreaRadiusSq then
                setSelection(0, 0, true)
                return
            end

            -- selection
            local angle = atan2(dx, dy)
            local areaHalf = pi/#pingWheel
            local twopi = 2*pi
            angle = angle < -areaHalf and (twopi+angle) or angle

            if mainSelection ~= 0 and pingWheel[mainSelection].children and (dist < secondaryOuterRadiusSq)
                and (dist > baseOuterRadiusSq) then
                local nelmts = #pingWheel[mainSelection].children
                local areaSize = nelmts*areaHalf   -- for now area size is hardcoded to area/2 slots
                local areaCenter = (mainSelection-1)*areaHalf*2
                local areaStart = areaCenter - areaSize/2
                local angleDiff = angle-areaStart

                if angleDiff < 0 then angleDiff = angleDiff + twopi
                elseif angleDiff > twopi then angleDiff = angleDiff - twopi end

                local selection = floor(angleDiff/(areaSize/nelmts))+1

                if selection > nelmts then selection = 0 end

                if secondarySelection ~= selection then
                    setSelection(mainSelection, selection, false)
                end
                return
            end

            local selection = floor((angle+areaHalf) / (2*areaHalf)) + 1

            if selection ~= mainSelection or secondarySelection ~= 0 then
                setSelection(selection, 0, false)
                return
            end
        end
    elseif (sec2 > 0.03) and keyDown and not displayPingWheel and doubleWheel and pressReleaseMode then
        -- gesture left or right to select primary or secondary wheel on pressRelaseMode
        local mx, my = spGetMouseState()
        local dx = mx - screenLocation.x
        local dy = my - screenLocation.y
        local chosenWheel = false
        if dx < -5 then
            chosenWheel = pingCommands
        elseif dx > 5 then
            chosenWheel = pingMessages
        end
        if chosenWheel then
            setWheel(chosenWheel)
            TurnOn("gesture")
        end
    end
end

------------------------
--- Drawing
---
local function circleArray(items, itemverts)
    local arr = {}
    local parts = items * (itemverts-1)
    local f = 2 * pi / parts
    for i = 1, parts+1 do
        local a = (i-1) * f - pi/items
        arr[i] = {sin(a), cos(a)}
    end
    return arr
end

-- Initialize circle vector arrays for both wheel's number of vectors
baseCircleArrays[#pingCommands] = circleArray(#pingCommands, areaVertexNumber)
baseCircleArrays[#pingCommands*2] = circleArray(#pingCommands*2, areaVertexNumber)
if #pingCommands ~= #pingMessages then
    baseCircleArrays[#pingMessages] = circleArray(#pingMessages, areaVertexNumber)
    baseCircleArrays[#pingMessages*2] = circleArray(#pingMessages*2, areaVertexNumber)
end

local function resetDrawState()
    -- restore gl state
    gl.Texture(0, false)
    glColor(1.0, 1.0, 1.0, 1.0)
    glLineWidth(1.0)
    if bgTexture and pingWheelDrawBase then
        glStencilTest(false)
        gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
        glStencilMask(255)
        glStencilFunc(GL_ALWAYS, 1, 1)
        --glStencilFunc(GL_NOTEQUAL, 1, 1)
    end
    glPointSize(1)
end

local function dVector(x1, x2, y1, y2, ff)
    -- normalized and scaled vector pointing from vector1 to vector2
    local dx = x2-x1
    local dy = y2-y1
    local z = ff/sqrt(dx*dx+dy*dy)
    return dx*z, dy*z
end

local function drawArea(vertices, n, i, r1, r2, spacing, arr)
    -- draw a donut portion with spacer space
    local function Area(n, i, p, r1, r2, arr)
        local o1, o2, o3, o4
        local startidx = (i-1)*(p-1)
        for j=startidx+1, startidx+p-1 do
            o1, o2, o3, o4 = 0, 0, 0, 0
            local sin1, cos1 = unpack(arr[j])
            local sin2, cos2 = unpack(arr[j+1])
            if j == (startidx+1) then
                o1, o2 = dVector(sin1, sin2, cos1, cos2, spacing)
            elseif j == startidx+p-1 then
                o3, o4 = dVector(sin1, sin2, cos1, cos2, -spacing)
            end
            glVertex(sin1*r1+o1, cos1*r1+o2)
            glVertex(sin1*r2+o1, cos1*r2+o2)
            glVertex(sin2*r2+o3, cos2*r2+o4)
            glVertex(sin2*r1+o3, cos2*r1+o4)
        end
    end
    glBeginEnd(GL.QUADS, Area, n, i, vertices, r1, r2, arr)
end

local function drawCircleOutline(r, arr, hole, holeEnd)
    local function Circle()
        local vn = areaVertexNumber-1
        holeStart = holeEnd and hole or (hole-1)*vn+1
        holeEnd = holeEnd and holeEnd or hole*vn
        for i=1+holeEnd, #arr do
            glVertex(arr[i][1]*r, arr[i][2]*r)
        end
        if hole ~=0 then
            for i=1, holeStart do
                glVertex(arr[i][1]*r, arr[i][2]*r)
            end
        end
    end
    glBeginEnd(GL.LINE_STRIP, Circle)
end

local function drawArc(r, arr, arcStart, arcEnd)
    local function Circle()
        local vn = areaVertexNumber-1
        local loopEnd = arcEnd <= #arr and arcEnd or #arr
        for i=arcStart, loopEnd do
            glVertex(arr[i][1]*r, arr[i][2]*r)
        end
        if loopEnd ~= arcEnd then
            for i=1, arcEnd-#arr+1 do
                glVertex(arr[i][1]*r, arr[i][2]*r)
            end
        end
    end
    glBeginEnd(GL.LINE_STRIP, Circle)
end

local function drawAreaOutline(n, i, r1, r2, spacing, arr)
    -- draw a triangle at the right angle for selection
    -- also push external vertex a bit to the inside so we leave
    -- some space between sections
    local function CirclePart(n, i, p, r, dir, arr)
        local o1, o2
        local startidx = (i-1)*(p-1)+1
        local endidx = startidx+p-1
        if dir == -1 then
            startidx, endidx = endidx, startidx
        end
        for j=startidx, endidx, dir do
            o1, o2 = 0, 0
            local sin1, cos1 = unpack(arr[j])
            if (j == startidx and dir == 1) or (j == endidx and dir == -1) then
                o1, o2 = dVector(sin1, arr[j+1][1], cos1, arr[j+1][2], spacing)
            elseif (j == endidx and dir == 1) or (j == startidx and dir == -1) then
                o1, o2 = dVector(sin1, arr[j-1][1], cos1, arr[j-1][2], spacing)
            end
            glVertex(sin1*r+o1, cos1*r+o2)
        end
    end
    local function AreaOutline(n, i, p, r1, r2, arr)
        CirclePart(n, i, p, r2, 1, arr)
        CirclePart(n, i, p, r1, -1, arr)
    end
    glLineWidth(dividerLineWidth * lineScale * 0.4)
    glBeginEnd(GL_LINE_LOOP, AreaOutline, n, i, areaVertexNumber, r1, r2, arr)
end

local function drawIcon(img, pos, size, offset)
    glColor(pingWheelTextHighlightColor)
    glTexture(img)
    if not size then size = 1.0 end

    if offset then pos = {pos[1]+offset[1], pos[2]+offset[2]} end
    local halfSize = wheelRadius * iconSize * size

    glTexRect(pos[1] - halfSize, pos[2] - halfSize,
        pos[1] + halfSize, pos[2] + halfSize)
    glTexture(false)
end

local function drawWheel()
    local r1, r2, spacing = 0.3, baseOuterRatio, 0.008 -- hardcoded for now
    local borderWidth = pingWheelBorderWidth * lineScale
    local borderMargin = borderWidth/(wheelRadius*2)
    local outerCircleRatio = defaults['outerCircleRatio']
    local secondaryInnerRatio = defaults['secondaryInnerRatio']

    if mainSelection ~= 0 and pingWheel[mainSelection].children then
        arr = baseCircleArrays[#pingWheel*2]
        for i=1, 3 do
            s = (mainSelection == 1 and i == 1) and #pingWheel*2 or (mainSelection*2+i-3)
            if i == secondarySelection then
                glColor(pingWheelSelColor)
            else
                glColor(pingWheelBaseColor)
            end
            drawArea(areaVertexNumber, #pingWheel*2, s, secondaryInnerRatio, secondaryOuterRatio, spacing, arr)
            glColor(pingWheelAreaOutlineColor)
            drawAreaOutline(#pingWheel*2, s, secondaryInnerRatio, secondaryOuterRatio, spacing, arr)
            glColor(pingWheelAreaInlineColor)
            drawAreaOutline(#pingWheel, s, secondaryInnerRatio+borderMargin, secondaryOuterRatio-borderMargin, spacing+borderMargin, arr)
        end
        glColor(pingWheelRingColor)
        glLineWidth(pingWheelRingWidth * lineScale)
        local vn = areaVertexNumber-1
        local start = (mainSelection-1)*2-1
        start = start > 0 and start or start+#pingWheel*2
        drawArc(secondaryOuterRatio+0.01, arr, start*vn+1, (start+3)*vn+1)
    end

    -- circle positions cache
    local arr = baseCircleArrays[#pingWheel]
    -- a ring around the wheel
    glColor(pingWheelRingColor)
    glLineWidth(pingWheelRingWidth * lineScale)
    local hole = (selOuterRatio>=outerCircleRatio) and mainSelection or 0
    drawCircleOutline(outerCircleRatio, arr, hole)

    -- setup stencil buffer to mask areas
    if bgTexture then
        gl.Clear(GL.STENCIL_BUFFER_BIT, 1)

        glStencilTest(true)
        glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)
        glStencilFunc(GL_ALWAYS, 0, 0)
        glStencilMask(0xff)
    end

    glLineWidth(borderWidth)
    -- item area backgrounds
    glColor(pingWheelBaseColor)
    for i=1, #pingWheel do
        if i~=mainSelection then
            glColor(pingWheelBaseColor)
            drawArea(areaVertexNumber, #pingWheel, i, r1, r2, spacing, arr)
            glColor(pingWheelAreaOutlineColor)
            drawAreaOutline(#pingWheel, i, r1, r2, spacing, arr)
            glColor(pingWheelAreaInlineColor)
            drawAreaOutline(#pingWheel, i, r1+borderMargin, r2-borderMargin, spacing+borderMargin, arr)
        end
    end
    -- selected part
    if mainSelection ~= 0 then
        r2 = selOuterRatio
        glColor(pingWheelSelColor)
        drawArea(areaVertexNumber, #pingWheel, mainSelection, r1, r2, spacing, arr)
        drawAreaOutline(#pingWheel, mainSelection, r1, r2, spacing, arr)
    end

    arr = baseCircleArrays[#pingWheel]
    --center hotzone
    if hasCenterAction then
        if centerSelected then
            glColor(pingWheelSelColor)
        else
            glColor(pingWheelBaseColor)
        end
        drawArea((areaVertexNumber-1)*#pingWheel+1, 1, 1, deadZoneRatio, centerAreaRatio, 0.0, arr)
        glColor(pingWheelAreaInlineColor)
        drawCircleOutline(deadZoneRatio, arr, 0)
    end

    -- from now on don't update stencil mask
    if bgTexture then
        glStencilMask(0)
    end
end

local function drawDottedLine()
    local function line(x1, y1, x2, y2)
        glVertex(x1, y1)
        glVertex(x2, y2)
    end
    -- draw a dotted line connecting from center of wheel to the mouse location
    if draw_line and (mainSelection > 0 or centerSelected) then
        glColor({1, 1, 1, 0.5})
        glLineWidth(pingWheelThickness / 4)
        local mx, my = spGetMouseState()
        glBeginEnd(GL_LINES, line, 0, 0, mx-screenLocation.x, my-screenLocation.y)
    end
end

local function drawCloseHint()
    if pressReleaseMode then return end

    local x = 0
    local y = -wheelRadius*(baseOuterRatio+0.05)
    local hintIconSize = 0.8*closeHintSize
    local hintTextSize = 0.9*closeHintSize
    local drawIconSize = wheelRadius * iconSize * hintIconSize
    local w = gl.GetTextWidth("Cancel")*pingWheelTextSize*hintTextSize
    x_offset = (w+drawIconSize)/2.0
    drawIcon(defaults.rclickIcon, {x-x_offset, y}, hintIconSize)
    glColor({1, 1, 1, 0.7})
    glBeginText()
    glText("Cancel", screenLocation.x+drawIconSize/2-x_offset+w/6,
            screenLocation.y+y,
            pingWheelTextSize*hintTextSize, "lovs")
    glEndText()
end

local function drawDividers()
    -- draw divider lines between slices
    if not doDividers then return end
    local function Lines()
        for i = 1, #pingWheel do
            local angle = (i - 1.5) * 2 * pi / #pingWheel
            glVertex(dividerInnerRatio * sin(angle),
                dividerInnerRatio * cos(angle))
            glVertex(dividerOuterRatio * sin(angle),
                dividerOuterRatio * cos(angle))
        end
    end

    glColor(dividerColor)
    glLineWidth(pingWheelThickness)
    glBeginEnd(GL_LINES, Lines)
end

local function drawItem(selItem, posRatio, angle, isSelected, useColors, flashBlack)
    local text = getTranslatedText(selItem.name)
    local color = (useColors and selItem.color) or (isSelected and pingWheelTextHighlightColor) or pingWheelTextColor
    if isSelected and flashBlack then
        color = { 0, 0, 0, 0 }
    elseif spamControl > 0 and not flashing then
        color = pingWheelTextSpamColor
    else
        -- TODO: this is modifying in place
        color[4] = isSelected and pingWheelSelTextAlpha or pingWheelBaseTextAlpha
    end
    local x = wheelRadius * posRatio * sin(angle)
    local y = wheelRadius * posRatio * cos(angle)
    local icon = selItem.icon
    local textScale = isSelected and selectedScaleFactor or 1.0
    if icon and useIcons then
        local halfSize = wheelRadius * iconSize
        local dist = pingWheelTextSize * 0.3
        local yOffset = pingWheelTextSize/2 + dist/2
        y = y + halfSize*0.3 -- account for icons being smaller than their bb
        drawIcon(icon, {x, y + yOffset}, selItem.icon_size, selItem.icon_offset)
        y = y - dist/2 - halfSize
    end
    glColor(color)
    glText(text, screenLocation.x+x,
        screenLocation.y+y,
        pingWheelTextSize*textScale, "cvos")
end

local function drawItems()
    -- draw the text for each slice and highlight the selected one
    -- also flash the text color to indicate ping was issued
    local useColors = WG['pingwheel'] and WG['pingwheel'].getUseColors()
    local flashBlack = false
    if flashing and (flashFrame % 2 == 0) then
        flashBlack = true
    end

    glBeginText()
    for i = 1, #pingWheel do
        local isSelected = mainSelection == i
        local selItem = pingWheel[i]
        local angle = (i - 1) * 2 * pi / #pingWheel
        drawItem(selItem, textAlignRatio, angle, isSelected, useColors, flashBlack and secondarySelection == 0)
    end
    if hasCenterAction then
        local v = (deadZoneRatio+centerAreaRatio)/2
        if centerSelected and flashBlack then
            glColor({ 0, 0, 0, 0 })
        else
            glColor(pingWheelTextColor)
        end
        local textScale = centerSelected and selectedScaleFactor or 1
        glText('Ping', screenLocation.x,
            screenLocation.y-v*wheelRadius,
            pingWheelTextSize*textScale*0.8, "cvos")
    end
    if mainSelection ~= 0 and pingWheel[mainSelection].children then
        for i = 1, 3 do
            local idx = mainSelection*2+i-3
            local isSelected = secondarySelection == i
            local selItem = pingWheel[mainSelection].children[i]
            local angle = (idx - 1) * pi / #pingWheel
            drawItem(selItem, 1.17, angle, isSelected, useColors, flashBlack)
        end
    end
    glEndText()

    -- Close hint at the bottom
    drawCloseHint()
end

local function drawWheelChoiceHelper()
    -- draw dot at mouse location
    local mx, my
    if pressReleaseMode and screenLocation then
        -- fixed position in pressrelease mode
        mx = screenLocation.x
        my = screenLocation.y
    else
        -- follows mouse in click mode
        mx, my = spGetMouseState()
    end
    glColor(playerColor)
    glPointSize(centerDotSize)
    glBeginEnd(GL_POINTS, glVertex, mx, my)

    -- draw two hints at the top left and right of the location
    glColor(1, 1, 1, 1)
    glText("R-click\nMsgs", mx + 15, my + 11, 12, "os")
    glText("L-click\nCmds", mx - 15, my + 11, 12, "ros")
end

local function drawBgTexture()
    if bgTexture then
        glStencilFunc(GL_NOTEQUAL, 1, 1)
        glColor(bgTextureColor)
        glTexture(bgTexture)
        local halfSize = bgTextureSizeRatio
        glTexRect(-halfSize, -halfSize,
            halfSize, halfSize)
        glTexture(false)
        glStencilFunc(GL_ALWAYS, 1, 1)
    end
end

local function drawDeadZone()
    -- draw a smooth circle with 64 vertices
    if not draw_deadzone then return end
    --glColor(playerColor)

    glColor({1, 1, 1, 0.25})
    glLineWidth(pingWheelThickness)

    local function Circle(r)
        for i = 1, 64 do
            local angle = (i - 1) * 2 * pi / 64
            glVertex(r * sin(angle), r * cos(angle))
        end
    end

    -- draw the dead zone circle
    glBeginEnd(GL_LINE_LOOP, Circle, deadZoneRatio)
end

local function drawCenterDot()
    if flashing then return end
    -- draw the center dot
    glColor({0,0,0,0.8})
    glPointSize(centerDotSize)
    glBeginEnd(GL_POINTS, glVertex, 0, 0)
    glColor(playerColor)
    glPointSize(centerDotSize*0.8)
    glBeginEnd(GL_POINTS, glVertex, 0, 0)
end

local function drawDecorations()
    -- deadzone radius
    drawDeadZone()

    -- if keyDown then draw a dot at where mouse is
    drawCenterDot()

    -- draw dividers between zones for styles with no base
    drawDividers()
end

local function prepareBlur()
    if recreateBlurDlist then
        destroyBlurDlist()
        recreateBlurDlist = false
    end
    if not blurDlist and do_blur and WG['guishader'] then
        local outerCircleRatio = defaults['outerCircleRatio']
        local secondaryInnerRatio = defaults['secondaryInnerRatio']
        blurDlist = gl.CreateList(function()
            glPushMatrix()
            gl.Translate(screenLocation.x, screenLocation.y, 0)
            gl.Scale(wheelRadius, wheelRadius, wheelRadius)
            local arr = baseCircleArrays[#pingWheel]
            local spacing = 0.003
            drawArea((areaVertexNumber-1)*#pingWheel+1, 1, 1, deadZoneRatio, outerCircleRatio, 0.0, arr)
            if mainSelection ~= 0 and selOuterRatio > outerCircleRatio then
                drawArea(areaVertexNumber, #pingWheel, mainSelection, outerCircleRatio, selOuterRatio, spacing, arr)
            end
            if mainSelection ~= 0 and pingWheel[mainSelection].children then
                arr = baseCircleArrays[#pingWheel*2]
                for i=1, 3 do
                    s = (mainSelection == 1 and i == 1) and #pingWheel*2 or (mainSelection*2+i-3)
                    drawArea(areaVertexNumber, #pingWheel*2, s, secondaryInnerRatio, secondaryOuterRatio, 0, arr)
                end
            end
            glPopMatrix()
        end)
        WG['guishader'].InsertDlist(blurDlist, 'pingwheel')
    end
end

local function drawWheelBase()
    if not baseDlist then
        baseDlist = gl.CreateList(drawWheel)
    end

    glCallList(baseDlist)
end

local function drawWheelForeground()
    drawDottedLine() -- Dotted line to mouse needs to be updated all the time so no cooking

    shader:SetUniform("useTex", 1)
    if flashing then
        drawItems()
    else
        if not itemsDlist then
            itemsDlist = gl.CreateList(drawItems)
        end
        glCallList(itemsDlist)
    end
end

function widget:DrawScreen()
    -- Screen hint for double wheel selection
    if showLRHint and doubleWheel then
        drawWheelChoiceHelper()
    end

    -- Main wheel
    if displayPingWheel and screenLocation then
        local vsx, vsy, vpx, vpy = Spring.GetViewGeometry()
        local mmx = screenLocation.x*2 - vsx
        local mmy = screenLocation.y*2 - vsy

        local scale1 = (vsy/vsx)*defaults.baseWheelSize -- for items in -1, 1
        local scale2 = 2/vsx           -- for items in screen space

        shader:Activate()
        shader:SetUniform("scale", scale1)
        shader:SetUniform("useTex", 0)
        shader:SetUniform("alpha", globalDim)
        shader:SetUniform("mousePosition", mmx/vsx, mmy/vsx, 1.0, 1.0)

        glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        -- The new style base
        if pingWheelDrawBase then
            prepareBlur()
            drawWheelBase()
        end

        -- background texture, can be overlayed over the new base
        shader:SetUniform("useTex", 1)
        drawBgTexture()
        shader:SetUniform("useTex", 0)

        -- Other details
        if flashing then
            drawDecorations()
        else
            if not decorationsDlist then
                decorationsDlist = gl.CreateList(drawDecorations)
            end
            glCallList(decorationsDlist)
        end

        shader:SetUniform("scale", scale2)
        drawWheelForeground()

        -- Reset state
        shader:Deactivate()
        resetDrawState()
    end
end
