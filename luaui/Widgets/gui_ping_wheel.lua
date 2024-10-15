function widget:GetInfo()
    return {
        name    = "Ping Wheel",
        desc    =
        "Displays a ping wheel when a keybind is held down. Default keybind is 'alt-w', rebindable. Left click (or mouse 4) to bring up commands wheel, right click (or mouse 5) for messages wheel. \nNow with two wheel styles! (edit file param to change style)",
        author  = "Errrrrrr",
        date    = "June 27, 2023",
        license = "GNU GPL, v2 or later",
        version = "2.5",
        layer   = -1,
        enabled = true,
        handler = true,
    }
end

-----------------------------------------------------------------------------------------------
-- The wheel is opened by holding the keybind (default: alt-w), left click to select an option.
--
-- Bindable action name: ping_wheel_on
--
-- You can add or change the options in the pingWheel tables.
-- the two tables pingCommands and pingMessages are left and right click options respectively.
--
-- NEW: styleChoice determines the style of the wheel. 1 = circle, 2 = ring, 3 = custom
-- NEW: added fade in/out animation (can be turned off by setting both frames numbers to 0)
-- NEW: you can now use mouse 4 and 5 directly for the two wheels!
-- NEW: LOTS OF PRETTY COLORS!
-----------------------------------------------------------------------------------------------
local iconDir = 'anims/icexuick_75/'
local configDir = 'luaui/configs/pingwheel/'
local pingCommands = {                             -- the options in the ping wheel, displayed clockwise from 12 o'clock
    { name = "ui.wheel.attack",  color = { 1, 0.3, 0.3, 1 }, icon = iconDir..'cursorattack_2.png' }, -- color is optional, if no color is chosen it will be white
    { name = "Rally",   color = { 0.4, 0.8, 0.4, 1 }, icon = iconDir..'cursorfight_11.png', icon_offset={7, -8} },
    { name = "Defend",  color = { 0.7, 0.9, 1, 1 }, icon = iconDir..'cursordefend_59.png', size=0.8 },
    { name = "ui.wheel.retreat", color = { 0.9, 0.7, 1, 1 } },
    { name = "Alert",   color = { 1, 1, 0.5, 1 } },
    { name = "Reclaim", color = { 0.7, 1, 0.7, 1 }, icon = iconDir..'cursorreclamate_55.png' },
    { name = "Stop",    color = { 1, 0.2, 0.2, 1 } },
    { name = "Wait",    color = { 0.7, 0.6, 0.3, 1 }, icon = iconDir..'cursorwait_31.png' },
}

local pingMessages = {
    -- let's give these commands rainbow colors!
    { name = "TY!",      color = { 1, 1, 1, 1 } },
    { name = "GJ!",      color = { 1, 0.5, 0, 1 } },
    { name = "DANGER!",  color = { 1, 1, 0, 1 } },
    { name = "Sorry!",   color = { 0, 1, 0, 1 } },
    { name = "LOL",      color = { 0, 1, 1, 1 } },
    { name = "No",       color = { 0, 0, 1, 1 } },
    { name = "ui.wheel.omw",  color = { 0.5, 0, 1, 1 }, icon = iconDir..'cursormove_24.png', icon_offset={7, -8} },
    { name = "ui.wheel.paid", color = { 1, 0, 1, 1 } },
    -- add (possibly longer) msg attribute to have separate text on the wheel (name) and ping/chat (msg). as follows:
    -- { name = "Shop Open", msg = "shop open; 440m per each (paying is mandatory)", color = { 0.5, 0, 1, 1 } },
}

local styleChoice = 1 -- 1 = circle, 2 = ring, 3 = custom

-- Available styles
local styleConfig = {
    [1] = {
        name = "White",
        gl4 = true,
        baseTextOpacity = 1.0,
    },
    [2] = {
        name = "Black",
        gl4 = true,
        pingWheelSelColor = {0.0, 0.0, 0.0, 0.7},
        pingWheelRingColor = {0.0, 0.0, 0.0, 0.7},
        baseTextOpacity = 1.0,
    },
    [3] = {
        name = "Circle Light",
        bgTexture = "LuaUI/images/glow.dds",
        bgTextureSizeRatio = 2.2,
        bgTextureColor = { 0, 0, 0, 0.9 },
        textSize = 24,
        gl4 = false,
    },
    [4] = {
        name = "Ring Light",
        bgTexture = "LuaUI/images/enemyspotter.dds",
        dividerInnerRatio = 0.6,
        dividerOuterRatio = 1.2,
        textSize = 24,
        gl4 = false,
    },
}

-- Style defaults
local defaults = {
    iconSize = 0.16,
    bgTextureColor = { 0, 0, 0, 0.66 },
    bgTextureSizeRatio = 1.9,
    dividerColor = { 1, 1, 1, 0.15 },
    dividerInnerRatio = 0.45,
    dividerOuterRatio = 1.1,
    textSize = 16,
    textAlignRadiusRatio = 1.1,
    wheelSelColor = {1.0, 1.0, 1.0, 0.5},
    wheelRingColor = {1.0, 1.0, 1.0, 0.5},
    selTextOpacity = 1.0,
    baseTextOpacity = 0.75,
    fallback = 3, -- should automatically set this to first non-gl4 style
}

-- On/Off switches
local use_gl4 = true        -- set to false to not use the new gl4 wheel style
local draw_dividers = true  -- set to false to disable the dividers between options (the colored ones in non gl4 mode)
local draw_line = false     -- set to true to draw a line from the center to the cursor during selection
local draw_circle = false   -- set to false to disable the circle around the ping wheel

-- Fade and spam frames (set to 0 to disable)
-- NOTE: these are now game frames, not display frames, so always 30 fps
local numFadeInFrames = 4   -- how many frames to fade in
local numFadeOutFrames = 4  -- how many frames to fade out
local numFlashFrames = 7    -- how many frames to flash when spamming
local spamControlFrames = 8 -- how many frames to wait before allowing another ping

-- Sizes and colors
local pingWheelBaseRadius = 0.1         -- base radius for whole wheel size (10% of the screen size)
local dividerLineBaseWidth = 3.5        -- width of the divider empty space between sections
local outerCircleBaseWidth = 2          -- width of the outer circle line
local centerDotBaseSize = 20            -- size of the center dot
local linesBaseWidth = 2		-- thickness of the ping wheel line drawing
local deadZoneRadiusRatio = 0.3         -- the center "no selection" area as a ratio of the ping wheel radius
local outerLimitRadiusRatio = 5         -- the outer limit ratio where "no selection" is active

pingWheelSelTextAlpha = defaults.selSelTextOpacity
pingWheelBaseTextAlpha = defaults.selBaseTextOpacity

local pingWheelTextBaseSize = defaults.textSize
local pingWheelTextColor = { 1, 1, 1, 0.7 }
local pingWheelTextHighlightColor = { 1, 1, 1, 1 }
local pingWheelTextSpamColor = { 0.9, 0.9, 0.9, 0.4 }
local pingWheelPlayerColor = { 0.9, 0.8, 0.5, 0.8 }

local pingWheelColor = { 0.9, 0.8, 0.5, 0.6 }
local pingWheelBaseColor = {0.0, 0.0, 0.0, 0.3}
local pingWheelSelColor = defaults.wheelSelColor
local pingWheelRingColor = defaults.wheelRingColor

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

-- Calculated sizes
local iconSize = defaults.iconSize
local viewSizeX, viewSizeY = Spring.GetViewGeometry()

local pingWheelRadius = pingWheelBaseRadius * math.min(viewSizeX, viewSizeY)
local pingWheelGl4Radius = pingWheelBaseRadius*(viewSizeY/viewSizeX)*3.55    -- 3.55 is 2/(viewSizeY/viewSizeX)
local sizeRatio = math.min(viewSizeX, viewSizeY)/1080.0
local pingWheelThickness = linesBaseWidth * sizeRatio
local centerDotSize = centerDotBaseSize * sizeRatio
local dividerLineWidth = dividerLineBaseWidth * sizeRatio
local pingWheelTextSize = pingWheelTextBaseSize * sizeRatio
local pingWheelRingWidth = outerCircleBaseWidth * sizeRatio

--- Other file variables
local gl4Available = false     -- will automatically be set to true on vbo/shader initialization
local gl4Style = true

local globalDim = 1     -- this controls global alpha of all gl.Color calls
local globalFadeIn = 0  -- how many frames left to fade in
local globalFadeOut = 0 -- how many frames left to fade out

local bgTexture = "LuaUI/images/glow.dds"
local bgTextureSizeRatio = defaults.bgTextureSizeRatio
local bgTextureColor = defaults.bgTextureColor
local dividerInnerRatio = defaults.dividerInnerRatio
local dividerOuterRatio = defaults.dividerOuterRatio
local textAlignRadiusRatio = defaults.textAlignRadiusRatio
local dividerColor = defaults.dividerColor

local pingWheel = pingCommands
local keyDown = false
local displayPingWheel = false

local pingWorldLocation
local pingWheelScreenLocation
local pingWheelSelection = 0
local spamControl = 0
--local gameFrame = 0
local flashFrame = 0
local flashing = false
local gameFrame = 0

-- Speedups
local spGetMouseState = Spring.GetMouseState
local spGetModKeyState = Spring.GetModKeyState
local spTraceScreenRay = Spring.TraceScreenRay
local atan2 = math.atan2
local floor = math.floor
local pi = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local soundDefaultSelect = "sounds/commands/cmd-default-select.wav"
local soundSetTarget = "sounds/commands/cmd-settarget.wav"

local function dimmed(color)
    local r, g, b, a = unpack(color)

    -- new alpha is globalDim * a, clamped between 0 and 1
    a = a * globalDim
    if a > 1 then a = 1 end
    if a < 0 then a = 0 end

    return {r, g, b, a}
end

-- GL speedups
local glColor                = gl.Color
local glLineWidth            = gl.LineWidth
local glPopMatrix            = gl.PopMatrix
local glBlending             = gl.Blending
local glDepthTest            = gl.DepthTest
local glBeginEnd             = gl.BeginEnd
local glBeginText            = gl.BeginText
local glEndText              = gl.EndText
local glTexture              = gl.Texture
local glTexRect              = gl.TexRect
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
local glStencilMask = gl.StencilMask
local GL_ALWAYS = GL.ALWAYS
local GL_NOTEQUAL = GL.NOTEQUAL
local GL_EQUAL = GL.EQUAL
local GL_KEEP = 0x1E00 --GL.KEEP
local GL_REPLACE = GL.REPLACE
local GL_TRIANGLE_FAN = GL.TRIANGLE_FAN
local GL_TRIANGLES = GL.TRIANGLES

local function MyGLColor(color)
    glColor(dimmed(color))
end
local glColorDimmed          = MyGLColor

-------   Shaders: -------------------
local circleSegments = 64

local luaShaderDir = "LuaUI/Widgets/Include/"
local LuaShader = VFS.Include(luaShaderDir.."LuaShader.lua")
VFS.Include(luaShaderDir.."instancevbotable.lua")

local circleShader = nil
local circleInstanceVBO = nil


local vsSrc = [[
#version 420

#line 10000

layout (location = 0) in vec4 circlepointposition;

uniform float circleradius;
uniform vec4 mouseposition;
uniform vec4 color;

//__ENGINEUNIFORMBUFFERDEFS__

#line 11000

void main() {
	vec4 circleWorldPos = circlepointposition;

	float viewratio = viewGeometry.x / viewGeometry.y;

	vec2 stretched = vec2(circleWorldPos.x , circleWorldPos.y * viewratio);
	float x = (stretched.x+1.0)/2.0;
	float y = (stretched.y+1.0)/2.0;
	stretched.x*=circleradius;
	stretched.y*=circleradius;

	vec4 worldPosInCamSpace = mouseposition;
	worldPosInCamSpace.y *= viewratio;

	worldPosInCamSpace.xy += stretched.xy * worldPosInCamSpace.w;

	gl_Position = worldPosInCamSpace;
}
]]

local fsSrc =  [[
#version 420

#line 20000

uniform vec4 color;

//__ENGINEUNIFORMBUFFERDEFS__

out vec4 fragColor;


void main() {
	fragColor = color;
}

]]

local function initgl4()
    local engineUniformBufferDefs = LuaShader.GetEngineUniformBufferDefs()
    vsSrc = vsSrc:gsub("//__ENGINEUNIFORMBUFFERDEFS__", engineUniformBufferDefs)
    fsSrc = fsSrc:gsub("//__ENGINEUNIFORMBUFFERDEFS__", engineUniformBufferDefs)
    circleShader =  LuaShader(
        { vertex = vsSrc, fragment = fsSrc },
        "ping wheel shader"
    )
    shaderCompiled = circleShader:Initialize()
    if not shaderCompiled then return end

    local circleVBO,numVertices = makeCircleVBO(circleSegments)
    local circleInstanceVBOLayout = {
        {id = 1, name = 'optional', size = 4},
    }
    circleInstanceVBO = makeInstanceVBOTable(circleInstanceVBOLayout, 32, "pingwheelVBO")
    if not circleInstanceVBO then return end
    circleInstanceVBO.numVertices = numVertices
    circleInstanceVBO.vertexVBO = circleVBO
    circleInstanceVBO.VAO = makeVAOandAttach(circleInstanceVBO.vertexVBO, circleInstanceVBO.instanceVBO)
    if not circleInstanceVBO.VAO then return end
    pushElementInstance(circleInstanceVBO, {0,0,0,0}, nil, true, false)
    gl4Available = true
end

-- Globals
local lineScale = 1

local function drawPortion(r, n, i)
    -- draw a triangle at the right angle for selection
    local function Triangles(a1, a2)
        glVertex(0.0, 0.0)
        glVertex(sin(a1), cos(a1))
        glVertex(sin(a2), cos(a2))
    end
    local angle1 = (i - 1.5) * 2 * pi / n
    local angle2 = (i - 0.5) * 2 * pi / n
    circleShader:SetUniform("circleradius", r*pingWheelGl4Radius)
    glBeginEnd(GL_TRIANGLES, Triangles, angle1, angle2)
end

local function drawSquare(r)
    local function Square(r)
        glVertex(1.0, 1.0)
        glVertex(1.0, -1.0)
        glVertex(-1.0, -1.0)
        glVertex(-1.0, 1.0)
    end
    circleShader:SetUniform("circleradius", r*pingWheelGl4Radius)
    glBeginEnd(GL_TRIANGLE_FAN, Square, r)

end

local function drawIcon(img, pos, size, offset)
    glColorDimmed(pingWheelTextHighlightColor)
    glTexture(img)
    if not size then size = 1.0 end

    if offset then pos = {pos[1]+offset[1], pos[2]+offset[2]} end
    local halfSize = pingWheelRadius * iconSize * size

    glTexRect(pos[1] - halfSize, pos[2] - halfSize,
        pos[1] + halfSize, pos[2] + halfSize)
    glTexture(false)
end

local function drawGl4Dividers(r, width)
    if not width then width = 1.0 end
    glLineWidth(dividerLineWidth * lineScale * width)
    circleShader:SetUniform("circleradius", r*pingWheelGl4Radius)
    local function Lines()
        for i = 1, #pingWheel do
            local angle2 = (i - 1.5) * 2 * pi / #pingWheel
            glVertex(0.0, 0.0, 1.0, 1.0)
            glVertex(sin(angle2), cos(angle2), 1.0, 1.0)
        end
    end

    glBeginEnd(GL_LINES, Lines)
end

local function resetDrawState()
    -- restore gl state
    glStencilMask(255)
    glStencilFunc(GL_ALWAYS, 1, 1)

    --glStencilFunc(GL_NOTEQUAL, 1, 1)
    glBlending(false)

    gl.Texture(0, false)
    glStencilTest(false)
    glDepthTest(false)
    glColor(1.0, 1.0, 1.0, 1.0)
    glLineWidth(1.0)
    gl.Clear(GL.STENCIL_BUFFER_BIT, 0)
    glPointSize(1)
end

local function drawMask()
    -- draw a mask consisting of a circle with a hole in the middle and some cut lines between areas
    glStencilFunc(GL_ALWAYS, 0, 0)
    circleShader:SetUniform("circleradius", 0.9*pingWheelGl4Radius)
    circleInstanceVBO.VAO:DrawArrays(GL_TRIANGLE_FAN, circleInstanceVBO.numVertices, 0, circleInstanceVBO.usedElements, 0)

    glStencilFunc(GL_ALWAYS, 1, 1)
    circleShader:SetUniform("circleradius", 0.3*pingWheelGl4Radius)
    circleInstanceVBO.VAO:DrawArrays(GL_TRIANGLE_FAN, circleInstanceVBO.numVertices, 0, circleInstanceVBO.usedElements, 0)

    drawGl4Dividers(0.9)
end

local function drawWheelGl4()
    if not gl4Available then return end
    if not pingWheelScreenLocation then return end
    if Spring.IsGUIHidden() or (WG['topbar'] and WG['topbar'].showingQuit()) then return end
    if circleInstanceVBO.usedElements == 0 then return end

    -- clear stencil buffer to 1 so we won't draw anywhere
    -- we will set the wheel donut as allowed later
    glStencilMask(1)
    gl.Clear(GL.STENCIL_BUFFER_BIT, 1)

    -- other setup
    glStencilTest(true)
    glDepthTest(false)
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)

    circleShader:Activate()

    -- draw mask
    glColorMask(false, false, false, false) -- disable color drawing for mask
    drawMask()

    local vsx, vsy, vpx, vpy = Spring.GetViewGeometry()
    local mmx = pingWheelScreenLocation.x*2 - vsx
    local mmy = pingWheelScreenLocation.y*2 - vsy

    circleShader:SetUniform("mouseposition", mmx, mmy, 1.0, vsx)

    -- draw colored wheel base areas
    glColorMask(true, true, true, true)	-- re-enable color drawing

    -- a ring around the wheel
    glStencilMask(0)
    glLineWidth(pingWheelRingWidth * lineScale * 1.0)
    glStencilFunc(GL_ALWAYS, 1, 1)
    circleShader:SetUniform("circleradius", 0.92*pingWheelGl4Radius)
    circleShader:SetUniform("color", unpack(dimmed(pingWheelRingColor)))
    circleInstanceVBO.VAO:DrawArrays(GL_LINE_LOOP, circleInstanceVBO.numVertices, 0, circleInstanceVBO.usedElements, 0)

    glStencilFunc(GL_NOTEQUAL, 1, 1)
    -- subtle border around sections
    circleShader:SetUniform("color", unpack(dimmed(pingWheelBaseColor)))
    circleShader:SetUniform("circleradius", 0.9*pingWheelGl4Radius)
    circleInstanceVBO.VAO:DrawArrays(GL_LINE_LOOP, circleInstanceVBO.numVertices, 0, circleInstanceVBO.usedElements, 0)
    circleShader:SetUniform("circleradius", 0.3*pingWheelGl4Radius)
    circleInstanceVBO.VAO:DrawArrays(GL_LINE_LOOP, circleInstanceVBO.numVertices, 0, circleInstanceVBO.usedElements, 0)
    drawGl4Dividers(0.9, 1.5)

    -- selected part
    if pingWheelSelection ~= 0 then
        circleShader:SetUniform("circleradius", 0.9*pingWheelGl4Radius)
        circleShader:SetUniform("color", unpack(dimmed(pingWheelSelColor)))
        glStencilMask(1)
        drawPortion(1.5, #pingWheel, pingWheelSelection)
        glStencilMask(0)
    end

    -- rest of the circle
    circleShader:SetUniform("color", unpack(dimmed(pingWheelBaseColor)))
    drawSquare(0.9)

    -- done using shader
    circleShader:Deactivate()
end

local cachedTexts = {}

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

local function createMapPoint(playerID, text, x, y, z, r, g, b, icon)
    data = {text = text, x = x, y = y, z = z, r = r, g = g, b = b, icon = icon}
    msg = Json.encode(data)
    Spring.SendLuaRulesMsg('mppnt:' .. msg)
end

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
    textAlignRadiusRatio = style.textAlignRadiusRatio or defaults.textAlignRadiusRatio
    dividerColor = style.dividerColor or defaults.dividerColor
    pingWheelTextBaseSize = style.textSize or defaults.textSize
    pingWheelSelTextAlpha = style.selTextOpacity or defaults.selTextOpacity
    pingWheelBaseTextAlpha = style.baseTextOpacity or defaults.baseTextOpacity

    gl4Style = style.gl4
    if gl4Style and not gl4Available then
        styleChoice = style.fallback or defaults.fallback
        applyStyle()
        return
    end
    local vx, vy = Spring.GetViewGeometry()

    local sizeRatio = math.min(vx, vy)/1080.0
    pingWheelTextSize = pingWheelTextBaseSize * sizeRatio

    if style.gl4 then
        pingWheelSelColor = style.pingWheelSelColor or defaults.wheelSelColor
        pingWheelRingColor = style.pingWheelRingColor or defaults.wheelRingColor
        draw_dividers = false
    else
        draw_dividers = doDividers
    end
end

function widget:Initialize()
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
    end
    WG['pingwheel_gui'].getInteractionMode = function()
        return pressReleaseMode and 2 or 1
    end
    WG['pingwheel_gui'].setInteractionMode = function(value)
        pressReleaseMode = value == 2
    end
    WG['pingwheel_gui'].getDoubleWheel = function()
        return doubleWheel
    end
    WG['pingwheel_gui'].setDoubleWheel = function(value)
        doubleWheel = value
    end



    -- add the action handler with argument for press and release using the same function call
    widgetHandler.actionHandler:AddAction(self, "ping_wheel_on", PingWheelAction, { true }, "p") --pR do we actually want Repeat?
    -- widgetHandler.actionHandler:AddAction(self, "ping_wheel_on", PingWheelAction, { false }, "r") -- can't trust release event since releasing modified first makes it fail detection
    pingWheelPlayerColor = { Spring.GetTeamColor(Spring.GetMyTeamID()) }
    pingWheelColor = pingWheelPlayerColor

    if use_gl4 then
        initgl4()
    end
    -- set the style from config
    applyStyle()
end

function widget:Shutdown()
end

function widget:ViewResize(vsx, vsy)
    pingWheelRadius = pingWheelBaseRadius * math.min(vsx, vsy)
    pingWheelGl4Radius = pingWheelBaseRadius*(vsy/vsx)*3.55
    local f = math.min(vsx, vsy) / 1080.0
    pingWheelTextSize = pingWheelTextBaseSize * f
    centerDotSize = centerDotBaseSize * f
    dividerLineWidth = dividerLineBaseWidth * f
    pingWheelThickness = linesBaseWidth * f
    pingWheelRingWidth = outerCircleBaseWidth * f
end

-- Store the ping location in pingWorldLocation
local function SetPingLocation()
    local mx, my = spGetMouseState()
    local _, pos = spTraceScreenRay(mx, my, true)
    if pos then
        pingWorldLocation = { pos[1], pos[2], pos[3] }
        pingWheelScreenLocation = { x = mx, y = my }

        -- play a UI sound to indicate wheel is open
        Spring.PlaySoundFile(soundSetTarget, 0.1, 'ui')
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
    -- turn on fade in
    FadeIn()
    return true
end

local function TurnOff(reason)
    if displayPingWheel then
        displayPingWheel = false
        pingWorldLocation = nil
        pingWheelScreenLocation = nil
        pingWheelSelection = 0
        --Spring.Echo("Turned off: " .. reason)
        return true
    end
end

-- sets flashing effect to true and turn off wheel display
local function FlashAndOff()
    flashing = true
    flashFrame = numFlashFrames
    --FadeOut()
    --Spring.Echo("Flashing off: " .. tostring(flashFrame))
end

local function checkRelease()
    if displayPingWheel
        and pingWorldLocation
        and spamControl == 0
    then
        if pingWheelSelection > 0 and not flashing then
            local pingText = pingWheel[pingWheelSelection].msg or pingWheel[pingWheelSelection].name
            local color = pingWheel[pingWheelSelection].color or pingWheelColor

            createMapPoint(Spring.GetMyPlayerID(), pingWheel[pingWheelSelection].name, pingWorldLocation[1], pingWorldLocation[2], pingWorldLocation[3],
                color[1], color[2], color[3], pingWheel[pingWheelSelection].icon)

            -- Spam control is necessary!
            spamControl = spamControlFrames

            -- play a UI sound to indicate ping was issued
            --Spring.PlaySoundFile("sounds/ui/mappoint2.wav", 1, 'ui')
            FlashAndOff()
        else
            --TurnOff("Selection 0")
            FadeOut()
        end
        -- make sure left/right hint is not shown
        showLRHint = false
    else
        --TurnOff("mouse release")
        FadeOut()
    end
end

function widget:KeyRelease(key)
    keyDown = false
    showLRHint = false
    if not pressReleaseMode and displayPingWheel and key == 27 then -- could include KEYSIMS but not sure it's worth it
        -- click mode: allow closing with esc.
        FadeOut()
    elseif pressReleaseMode and displayPingWheel then
        -- release mode, single wheel: allow activating on key release.
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
        --Spring.Echo("keyDown: " .. tostring(keyDown))
    end
end

function widget:MousePress(mx, my, button)
    if displayPingWheel and not pressReleaseMode then
        -- click mode: allow activating option with left and close with right.
        if button == 1 then
            checkRelease()
        else
            -- should be right click, but any button other than left seems more intuitive
            FadeOut()
        end
    elseif displayPingWheel and pressReleaseMode then
        -- release mode: allow click as well as release.
         if button == 1 then
            checkRelease()
        elseif button == 3 then
            FadeOut()
        end
    elseif showLRHint or button == 4 or button == 5 then
        -- release mode.
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
                pingWheel = chosenWheel
                TurnOn("mouse press")
                return true -- block all other mouse presses
            end
        end
    else
        -- set pingwheel to not display
        --TurnOff("mouse press")
        FadeOut()
    end
end


-- when mouse is pressed, issue the ping command
function widget:MouseRelease(mx, my, button)
    if pressReleaseMode then
        checkRelease()
    end
end

--[[ function widget:GameFrame(gf)
    gameFrame = gf
end ]]

local sec, sec2 = 0, 0
function widget:Update(dt)
    sec = sec + dt
    -- we need smooth update of fade frames
    if (sec > 0.017) and globalFadeIn > 0 or globalFadeOut > 0 then
        sec = 0
        if globalFadeIn > 0 then
            globalFadeIn = globalFadeIn - 1
            if globalFadeIn < 0 then globalFadeIn = 0 end
            globalDim = 1 - globalFadeIn / numFadeInFrames
        end
        if globalFadeOut > 0 then
            globalFadeOut = globalFadeOut - 1
            if globalFadeOut <= 0 then
                globalFadeOut = 0
                TurnOff("globalFadeOut 0")
            end
            globalDim = globalFadeOut / numFadeOutFrames
        end
        -- directly use gl.Color when globalDim is 1
        if globalDim == 1 then
            glColorDimmed = gl.Color
        else
            glColorDimmed = MyGLColor
        end
    end

    sec2 = sec2 + dt
    if (sec2 > 0.03) and displayPingWheel then
        sec2 = 0
        if globalFadeOut == 0 and not flashing then -- if not flashing and not fading out
            local mx, my = spGetMouseState()
            if not pingWheelScreenLocation then
                return
            end
            -- calculate where the mouse is relative to the pingWheelScreenLocation, remember top is the first selection
            local dx = mx - pingWheelScreenLocation.x
            local dy = my - pingWheelScreenLocation.y
            local angle = atan2(dx, dy)
            local angleDeg = floor(angle * 180 / pi + 0.5)
            if angleDeg < 0 then
                angleDeg = angleDeg + 360
            end
            local offset = 360 / #pingWheel / 2
            local selection = (floor((360 + angleDeg + offset) / 360 * #pingWheel)) % #pingWheel + 1
            -- deadzone is no selection
            local dist = sqrt(dx * dx + dy * dy)
            if (dist < deadZoneRadiusRatio * pingWheelRadius)
                or (dist > outerLimitRadiusRatio * pingWheelRadius)
            then
                pingWheelSelection = 0
                --Spring.SetMouseCursor("cursornormal")
            elseif selection ~= pingWheelSelection then
                pingWheelSelection = selection
                Spring.PlaySoundFile(soundDefaultSelect, 0.3, 'ui')
                --Spring.SetMouseCursor("cursorjump")
            end

            --Spring.Echo("pingWheelSelection: " .. pingWheel[pingWheelSelection].name)
        end
        if flashing and displayPingWheel then
            if flashFrame > 0 then
                flashFrame = flashFrame - 1
            else
                flashing = false
                FadeOut()
            end
        end
        if spamControl > 0 then
            spamControl = (spamControl == 0) and 0 or (spamControl - 1)
        end
    elseif (sec2 > 0.03) and keyDown and not displayPingWheel and doubleWheel and pressReleaseMode then
        -- gesture left or right to select primary or secondary wheel on pressRelaseMode
        if not pingWheelScreenLocation then
            return
        end
        local mx, my = spGetMouseState()
        local dx = mx - pingWheelScreenLocation.x
        local dy = my - pingWheelScreenLocation.y
        local chosenWheel = false
        if dx < -5 then
            chosenWheel = pingCommands
        elseif dx > 5 then
            chosenWheel = pingMessages
        end
        if chosenWheel then
            pingWheel = chosenWheel
            TurnOn("gesture")
        end
    end
end

local function drawDottedLine()
    local function line(x1, y1, x2, y2)
        glVertex(x1, y1)
        glVertex(x2, y2)
    end
    -- draw a dotted line connecting from center of wheel to the mouse location
    if draw_line and pingWheelSelection > 0 then
        glColorDimmed({1, 1, 1, 0.5})
        glLineWidth(pingWheelThickness / 4)
        local mx, my = spGetMouseState()
        glBeginEnd(GL_LINES, line, pingWheelScreenLocation.x, pingWheelScreenLocation.y, mx, my)
    end
end

local function drawLabels()
    -- draw the text for each slice and highlight the selected one
    -- also flash the text color to indicate ping was issued
    local flashBlack = false
    if flashing and (flashFrame % 2 == 0) then
        flashBlack = true
    end

    glBeginText()

    for i = 1, #pingWheel do
        local isSelected = pingWheelSelection == i
        local selItem = pingWheel[i]
        local angle = (i - 1) * 2 * pi / #pingWheel
        local text = getTranslatedText(selItem.name)
        local color = (WG['pingwheel'].getUseColors() and selItem.color) or (isSelected and pingWheelTextHighlightColor) or pingWheelTextColor
        if isSelected and flashBlack then
            color = { 0, 0, 0, 0 }
        elseif spamControl > 0 and not flashing then
            color = pingWheelTextSpamColor
        else
            -- TODO: this is modifying in place
            color[4] = isSelected and pingWheelSelTextAlpha or pingWheelBaseTextAlpha
        end
        local x = pingWheelScreenLocation.x + pingWheelRadius * textAlignRadiusRatio * sin(angle)
        local y = pingWheelScreenLocation.y + pingWheelRadius * textAlignRadiusRatio * cos(angle)
        local icon = selItem.icon
        local textScale = isSelected and selectedScaleFactor or 1.0
        if icon and useIcons then
            drawIcon(icon, {x, y+0.2*pingWheelRadius}, selItem.size, selItem.icon_offset)
            y = y-0.05*pingWheelRadius
        end
        glColorDimmed(color)
        glText(text, x,
            y,
            pingWheelTextSize*textScale, "cvos")
    end
    glEndText()
end

local function drawWheelChoiceHelper()
    -- draw dot at mouse location
    local mx, my
    if pressReleaseMode and pingWheelScreenLocation then
        mx = pingWheelScreenLocation.x
        my = pingWheelScreenLocation.y
    else
        mx, my = spGetMouseState()
    end
    glColor(pingWheelColor)
    glPointSize(centerDotSize)
    glBeginEnd(GL_POINTS, glVertex, mx, my)

    -- draw two hints at the top left and right of the location
    glColor(1, 1, 1, 1)
    glText("R-click\nMsgs", mx + 15, my + 11, 12, "os")
    glText("L-click\nCmds", mx - 15, my + 11, 12, "ros")
end

local function drawBgTexture()
    if bgTexture then
        glColorDimmed(bgTextureColor)
        glTexture(bgTexture)
        -- use pingWheelRadius as the size of the background texture
        local halfSize = pingWheelRadius * bgTextureSizeRatio
        glTexRect(pingWheelScreenLocation.x - halfSize, pingWheelScreenLocation.y - halfSize,
            pingWheelScreenLocation.x + halfSize, pingWheelScreenLocation.y + halfSize)
        glTexture(false)
    end
end

local function drawDividers()
    -- draw divider lines between slices
    if not draw_dividers then return end
    local function Lines()
        for i = 1, #pingWheel do
            local angle = (i - 1.5) * 2 * pi / #pingWheel
            glVertex(pingWheelScreenLocation.x + pingWheelRadius * dividerInnerRatio * sin(angle),
                pingWheelScreenLocation.y + pingWheelRadius * dividerInnerRatio * cos(angle))
            glVertex(pingWheelScreenLocation.x + pingWheelRadius * dividerOuterRatio * sin(angle),
                pingWheelScreenLocation.y + pingWheelRadius * dividerOuterRatio * cos(angle))
        end
    end

    glColorDimmed(dividerColor)
    glLineWidth(pingWheelThickness)
    glBeginEnd(GL_LINES, Lines)
end

local function drawDeadZone()
    -- draw a smooth circle at the pingWheelScreenLocation with 64 vertices
    if not draw_circle then return end
    --glColor(pingWheelColor)
    glColorDimmed({1, 1, 1, 0.25})
    glLineWidth(pingWheelThickness)

    local function Circle(r)
        for i = 1, 64 do
            local angle = (i - 1) * 2 * pi / 64
            glVertex(pingWheelScreenLocation.x + r * sin(angle), pingWheelScreenLocation.y + r * cos(angle))
        end
    end

    -- draw the dead zone circle
    glBeginEnd(GL_LINE_LOOP, Circle, pingWheelRadius * deadZoneRadiusRatio)
end

local function drawCenterDot()
    if flashing then return end
    -- draw the center dot
    glColorDimmed(pingWheelColor)
    glPointSize(centerDotSize)
    glBeginEnd(GL_POINTS, glVertex, pingWheelScreenLocation.x, pingWheelScreenLocation.y)
end

local function drawCloseHint()
    if pressReleaseMode then return end

    local x = pingWheelScreenLocation.x
    local y = pingWheelScreenLocation.y-pingWheelRadius*1.7
    local hintIconSize = 0.8
    local hintTextSize = 0.9
    local drawIconSize = pingWheelRadius * iconSize * hintIconSize
    local w = gl.GetTextWidth("Cancel")*pingWheelTextSize*hintTextSize
    x_offset = (w+drawIconSize)/2.0
    drawIcon("icons/mouse/rclick_glow.png", {x-x_offset, y}, hintIconSize)
    glColorDimmed({1, 1, 1, 0.7})
    glBeginText()
    glText("Cancel", x+drawIconSize/2-x_offset+w/6,
            y,
            pingWheelTextSize*hintTextSize, "lovs")
    glEndText()

end

function widget:DrawScreen()
    if displayPingWheel and pingWheelScreenLocation and gl4Style then
        drawWheelGl4()
    end
    glPushMatrix()
    -- if keyDown then draw a dot at where mouse is
    if showLRHint and doubleWheel then
        drawWheelChoiceHelper()
    end
    -- we draw a wheel at the pingWheelScreenLocation divided into #pingWheel slices, with the first slice starting at the top
    if displayPingWheel and pingWheelScreenLocation then
        glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        drawBgTexture()

        glStencilFunc(GL_ALWAYS, 1, 1)

        drawDeadZone()
        drawCenterDot()
        drawDottedLine()
        drawDividers()

        drawLabels()
        drawCloseHint()
    end

    glPopMatrix()
    if displayPingWheel and pingWheelScreenLocation then
        resetDrawState()
    end
end
