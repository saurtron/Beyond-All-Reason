
function gadget:GetInfo()
	return {
		name    = "Game Map Ping",
		desc	= 'allow sending map pings using the i18n library so everyone can see them in their own language',
		author	= 'Saurtron',
		date	= 'Oct 2024',
		license	= 'GNU GPL, v2 or later',
		layer	= 1,
		enabled	= true
	}
end

-- for example usecase see the ping_wheel widget createMapPing and MapPingEvent methods

local PACKET_HEADER = "ping:"
local PACKET_HEADER_LENGTH = string.len(PACKET_HEADER)

if gadgetHandler:IsSyncedCode() then

	function gadget:RecvLuaMsg(msg, playerID)
		if string.sub(msg, 1, PACKET_HEADER_LENGTH) ~= PACKET_HEADER then
			return
		end
		SendToUnsynced("sendMapPing", playerID, string.sub(msg, PACKET_HEADER_LENGTH+1))
		return true
	end

else	-- UNSYNCED

	local function sendMapPing(_, playerID, msg)
		local name,_,spec,_,playerAllyTeamID = Spring.GetPlayerInfo(playerID)
		local mySpec = Spring.GetSpectatingState()
		if not spec and (playerAllyTeamID == Spring.GetMyAllyTeamID() or mySpec) then
			if Script.LuaUI("MapPingEvent") then
				Script.LuaUI.MapPingEvent(playerID, msg)
			end
		end
	end

	function gadget:Initialize()
		gadgetHandler:AddSyncAction("sendMapPing", sendMapPing)
	end
	function gadget:Shutdown()
		gadgetHandler:AddSyncAction("sendMapPing")
	end
end

