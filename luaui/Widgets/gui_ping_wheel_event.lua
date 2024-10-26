function widget:GetInfo()
    return {
        name    = "Ping Wheel Event",
        desc    =
        "Displays local map markers in response to sendMapPoint sent from gadgets/game_map_point.lua",
        author  = "saurtron",
        date    = "Oct 9, 2024",
        license = "GNU GPL, v2 or later",
        version = "2.5",
        layer   = 0,
        enabled = true
    }
end

local PACKET_HEADER = "mppnt:"
local PACKET_HEADER_LENGTH = string.len(PACKET_HEADER)

local commands = {}
local iconBaseDlist
local iconQuadDlist

-- On/Off switches
local use_colors = false -- set to false to use player color instead of custom ping color (controlled from options ui)
local getMiniMapFlipped = VFS.Include("luaui/Widgets/Include/minimap_utils.lua").getMiniMapFlipped
local defaultIcon = "anims/icexuick_75/cursorattack_2.png"
local maxIconDuration = 300
local minIconHeight = 4160

-- method speedups
local glBeginEnd = gl.BeginEnd
local glCallList = gl.CallList
local glColor = gl.Color
local glPopMatrix = gl.PopMatrix
local glPushMatrix = gl.PushMatrix
local glRotate = gl.Rotate
local glScale = gl.Scale
local glTexture = gl.Texture
local glTranslate = gl.Translate

local function colourNames(R, G, B)
    local R255 = math.floor(R * 255) --the first \255 is just a tag (not colour setting) no part can end with a zero due to engine limitation (C)
    local G255 = math.floor(G * 255)
    local B255 = math.floor(B * 255)
    if R255 % 10 == 0 then
        R255 = R255 + 1
    end
    if G255 % 10 == 0 then
        G255 = G255 + 1
    end
    if B255 % 10 == 0 then
        B255 = B255 + 1
    end
    return "\255" .. string.char(R255) .. string.char(G255) .. string.char(B255) --works thanks to zwzsg
end

local function getTranslatedText(text)
    if string.sub(text, 1, 3) == 'ui.' then
        local newText = Spring.I18N(text)
        if text == newText then
            local splitText = string.split(text, ".")
            newText = splitText[#splitText]:gsub("^%l", string.upper)
        end
        return newText
    end
    return text
end

function widget:MapDrawCmd(playerID, cmdType, x, y, z, a, b, c)
    local osClock = os.clock()
    if cmdType == 'erase' then
        -- a is radius (currently hardcoded to 100 in engine), b and c unused
        local margin = a*a
        for cmdKey, cmdValue in pairs(commands) do
            -- maybe check playerID??
            if cmdValue.x and cmdValue.z and cmdValue.y then
                Spring.Echo("ERASE "..tostring(playerID).." "..tostring(x).." "..tostring(y).." "..tostring(z).." "..tostring(cmdValue.x).." "..tostring(cmdValue.y).." "..tostring(cmdValue.z))
            end
            if not cmdValue.x or not cmdValue.z or not cmdValue.y then
                Spring.Echo("NO COORDS!")
            elseif math.distance3dSquared(cmdValue.x, cmdValue.y, cmdValue.z, x, y, z) < margin then
                commands[cmdKey] = nil
            end
        end
    end
end

local function mapPointEvent(playerID, str)
    local data = Json.decode(str)
    local text
    if data['text'] then
        text = getTranslatedText(data['text'])
        if use_colors and data['r'] and data['g'] and data['b'] then
            text = colourNames(data['r'], data['g'], data['b']) .. text
        end
    end
    -- Send a local ping since each user will see it in their own language
    Spring.MarkerAddPoint(data['x'], data['y'], data['z'],
        text, true, playerID)
    data.osClock = os.clock()
    data.color = {data.r, data.g, data.b, data.a}
    commands[#commands+1] = data
end

function widget:RecvLuaMsg(msg, playerID)
    if string.sub(msg, 1, PACKET_HEADER_LENGTH) == PACKET_HEADER then
        mapPointEvent(playerID, string.sub(msg, PACKET_HEADER_LENGTH+1))
    end
end

local function drawGroundquad(x,y,z,size)
    gl.TexCoord(0,1)
    gl.Vertex(x-size,z-size, y)
    gl.TexCoord(0,0)
    gl.Vertex(x-size,z+size, y)
    gl.TexCoord(1,0)
    gl.Vertex(x+size,z+size, y)
    gl.TexCoord(1,1)
    gl.Vertex(x+size,z-size, y)
end

local function drawCircle(r, style)
    if not style then style = GL.TRIANGLE_FAN end
    local function Circle(r)
        for i = 1, 32 do
            local angle = (i - 1) * 2 * math.pi / 32
            gl.Vertex(r * math.sin(angle), r * math.cos(angle), 0)
        end
    end

    gl.BeginEnd(style, Circle, r)
end

local function drawIcon(img, color)
    local iconSize = 10
    if not img then img=defaultIcon end
    if not img then return end
    glCallList(iconBaseDlist)
    glColor(color)
    glCallList(iconRingDlist)
    glColor(1, 1, 1, 1)
    glTexture(img)
    glCallList(iconQuadDlist)
    glTexture(false)
end

function widget:DrawInMiniMap(sx, sy)
    local mapX = Game.mapX * 512
    local mapY = Game.mapY * 512

    local ratioX = sx / mapX
    local ratioY = sy / mapY

    local flipped = getMiniMapFlipped()
    for cmdKey, cmdValue in pairs(commands) do
       local x, y

        if flipped then
            x = (mapX - cmdValue.x) * ratioX
            y = sy - (mapY - cmdValue.z) * ratioY
        else
            x = cmdValue.x * ratioX
            y = sy - cmdValue.z * ratioY
        end
        glPushMatrix()
        glTranslate(x, y, 0.01)
        --glRotate(90,1,0,0)
        glScale(0.5,0.5,0.5)
        drawIcon(cmdValue.icon, cmdValue.color)
        glPopMatrix()
    end
end

function widget:ClearMapMarks()
    commands = {}
end

function widget:DrawWorldPreUnit()
    local osClock = os.clock()
    local camX, camY, camZ = Spring.GetCameraPosition()
    if camY >= minIconHeight then return end
    gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
    gl.DepthTest(false)
    gl.LineWidth(2)
    for cmdKey, cmdValue in pairs(commands) do
        glPushMatrix()
        glTranslate(cmdValue.x, cmdValue.y+2, cmdValue.z)
        glRotate(-90,1,0,0)
        glScale(2.0, 2.0, 2.0)
        drawIcon(cmdValue.icon, cmdValue.color)
        glPopMatrix()
    end

    gl.Color(1,1,1,1)
    gl.DepthTest(false)
    gl.LineWidth(1)
end

function widget:DrawScreen()
    local duration = 55
    local camX, camY, camZ = Spring.GetCameraPosition()
    if camY < minIconHeight then return end
    local vx, vy = Spring.GetViewGeometry()
    gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
    gl.DepthTest(false)
    gl.LineWidth(1)
    for cmdKey, cmdValue in pairs(commands) do
        local mx, my, mz = Spring.WorldToScreenCoords(cmdValue.x, cmdValue.y+2, cmdValue.z)
        glPushMatrix()
        glTranslate(mx, my, mz)
        --glRotate(90,1,0,0)
        drawIcon(cmdValue.icon, cmdValue.color)
        glPopMatrix()
    end

    gl.Color(1,1,1,1)
    gl.DepthTest(false)
    gl.LineWidth(1)
end


function widget:GameFrame()
    local duration = maxIconDuration
    local osClock = os.clock()
    for cmdKey, cmdValue in pairs(commands) do
	if osClock - cmdValue.osClock > duration  then
            commands[cmdKey] = nil
        end
    end
end

function widget:GetConfigData()
    return {
        useColors = use_colors
    }
end

function widget:SetConfigData(data)
    if data.useColors ~= nil then
        use_colors = data.useColors
    end
end

function createLists()
    local iconSize = 10
    iconBaseDlist = gl.CreateList(function()
        glColor(0, 0, 0, 0.5)
        drawCircle(iconSize)
    end)
    iconRingDlist = gl.CreateList(function()
        drawCircle(iconSize+2, GL.LINE_LOOP)
    end)
    iconQuadDlist = gl.CreateList(function()
        glBeginEnd(GL.QUADS, drawGroundquad, 0, 0, 0, iconSize*0.9)
    end)

end

function widget:Initialize()
    createLists()
 
    WG['pingwheel'] = {}
    WG['pingwheel'].getUseColors = function()
        return use_colors
    end
    WG['pingwheel'].setUseColors = function(value)
        use_colors = value
    end
end

function widget:Shutdown()
    gl.DeleteList(iconBaseDlist)
    gl.DeleteList(iconRingDlist)
    gl.DeleteList(iconQuadDlist)
end
