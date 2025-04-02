
function gadget:GetInfo()
	return {
		name = "Prevent outside-of-map hax",
		desc = "Prevent mobile unit outside-of-map hax (unless its gaia)",
		author = "Beherith",
		date = "3 27 2011",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end

if not gadgetHandler:IsSyncedCode() then
	return false
end

local rangeLimit = 1800
local rangeLimitGaia = 20000

local gaiaTeamID = Spring.GetGaiaTeamID()
local mapX = Game.mapSizeX
local mapZ = Game.mapSizeZ
local allMobileUnits = {}
local spGetUnitCurrentCommand = Spring.GetUnitCurrentCommand
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitDefID = Spring.GetUnitDefID
local spValidUnitID = Spring.ValidUnitID
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spIsPosInMap = Spring.IsPosInMap
local CMD_STOP = CMD.STOP
local CMD_GUARD = CMD.GUARD
local CMD_INSERT = CMD.INSERT
local CMD_INTERNAL = CMD.OPT_INTERNAL
local math_bit_and = math.bit_and

local MAX_OUT_OF_MAP = Game.gameSpeed*5

local isMobileUnit = {}
local isBuilder = {}
for unitDefID, udef in pairs(UnitDefs) do
	if not (udef.isBuilding or udef.speed == 0) then
		isMobileUnit[unitDefID] = true
	end
	if udef.isBuilder and (udef.buildSpeed and udef.buildSpeed > 0) and (udef.buildDistance and udef.buildDistance > 0) then
		isBuilder[unitDefID] = true
	end
end

local guardingUnits = {}

function gadget:Initialize()
	gadgetHandler:RegisterAllowCommand(CMD_STOP)
	gadgetHandler:RegisterAllowCommand(CMD_GUARD)
	gadgetHandler:RegisterAllowCommand(CMD_INSERT)
	for _, unitID in pairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID), spGetUnitTeam(unitID))
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if isMobileUnit[unitDefID] then
		allMobileUnits[unitID] = true
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam, weaponDefID)
	allMobileUnits[unitID] = nil
	guardingUnits[unitID] = nil
end
local function isInsideMap(unitID)
	local x,_,z = spGetUnitPosition(unitID)
	return spIsPosInMap(x, z)
end
local function maybeCancelGuard(unitID, cmdTag, guardeeID, frame)
	if guardeeID and spValidUnitID(guardeeID) then
		if isInsideMap(guardeeID) then
			guardingUnits[unitID] = frame
		else
			if frame - guardingUnits[unitID] > MAX_OUT_OF_MAP then
				spGiveOrderToUnit(unitID, CMD.REMOVE, cmdTag)
			end
		end
	else
		guardingUnits[unitID] = nil
	end
end



function gadget:GameFrame(f)
	if f % 69 == 0 then
		local minMap = -rangeLimit
		local maxMapX = mapX + rangeLimit
		local maxMapZ = mapZ + rangeLimit
		local minMapGaia = -rangeLimitGaia
		local maxMapXGaia = mapX + rangeLimitGaia
		local maxMapZGaia = mapZ + rangeLimitGaia
		for unitID, _ in pairs(allMobileUnits) do
			local x, y, z = spGetUnitPosition(unitID)
			if z then
				local unitTeam = spGetUnitTeam(unitID)
				if unitTeam == gaiaTeamID then
					if z < minMapGaia or x < minMapGaia or z > maxMapZGaia or x > maxMapXGaia then
						Spring.DestroyUnit(unitID, false, true)
					end
				else
					if z < minMap or x < minMap or z > maxMapZ or x > maxMapX then
						Spring.DestroyUnit(unitID, false, true)
					end
				end
			end
			if guardingUnits[unitID] then
				local cmdID, cmdOptions, cmdTag, cmdParam1  = spGetUnitCurrentCommand(unitID)
				if cmdID and math_bit_and(cmdOptions, CMD_INTERNAL) == CMD_INTERNAL then
					cmdID, cmdOptions, cmdTag, cmdParam1  = spGetUnitCurrentCommand(unitID, 2)
				end
				if cmdID == CMD_GUARD then
					maybeCancelGuard(unitID, cmdTag, cmdParam1, f)
				elseif not cmdID then
					guardingUnits[unitID] = nil
				end
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions, cmdTag, fromSynced, fromLua)
	if not isMobileUnit[unitDefID] then
		return true
	end
	if cmdID == CMD_STOP then
		return isInsideMap(unitID)
	elseif cmdID == CMD_GUARD or cmdID == CMD_INSERT then
		guardeeID = cmdParams[1]
		if cmdID == CMD_INSERT then
			cmdID = cmdParams[2]
			if not cmdID == CMD_GUARD then return true end
			guardeeID = cmdParams[4]
		else
			guardeeID = cmdParams[1]
		end
		-- To guard out of map both units must be builders
		if guardeeID and spValidUnitID(guardeeID) then
			local guardeeUnitDefID = spGetUnitDefID(guardeeID)
			if not (isBuilder[unitDefID] and isBuilder[guardeeUnitDefID]) then
				if isInsideMap(guardeeID) then
					-- storing frame number, but will be updated later
					guardingUnits[unitID] = 0
				else
					return false
				end
			end
		end
	end
	return true
end
