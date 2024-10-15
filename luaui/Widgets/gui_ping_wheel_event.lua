function widget:GetInfo()
    return {
        name    = "Ping Wheel Event",
        desc    =
        "Displays local map markers in response to sendMapPing sent from gadgets/game_map_ping.lua",
        author  = "saurtron",
        date    = "Oct 9, 2024",
        license = "GNU GPL, v2 or later",
        version = "2.5",
        layer   = -1,
        enabled = true
    }
end

-- On/Off switches
local use_colors = false -- set to false to use player color instead of custom ping color (controlled from options ui)

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
        text = Spring.I18N(text)
    end
    return text
end

function MapPointEvent(playerID, str)
    local data = Json.decode(str)
    local text = getTranslatedText(data['text'])
    -- Send a local ping since each user will see it in their own language
    if use_colors and data['r'] and data['g'] and data['b'] then
        text = colourNames(data['r'], data['g'], data['b']) .. text
    end
    Spring.MarkerAddPoint(data['x'], data['y'], data['z'],
        text, true, playerID)
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


function widget:Initialize()
    WG['pingwheel'] = {}
    WG['pingwheel'].getUseColors = function()
        return use_colors
    end
    WG['pingwheel'].setUseColors = function(value)
        use_colors = value
    end
    widgetHandler:RegisterGlobal('MapPointEvent', MapPointEvent)
end

function widget:Shutdown()
    widgetHandler:DeregisterGlobal('MapPointEvent')
end
