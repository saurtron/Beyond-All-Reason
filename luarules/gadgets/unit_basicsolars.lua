
function gadget:GetInfo()
	return {
		name      = "Basic Solars",
		desc      = "makes energy production on/off dependent",
		author    = "saurtron",
		date      = "Nov 20, 2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if not gadgetHandler:IsSyncedCode() then
	return false
end

local spSetUnitResourcing = Spring.SetUnitResourcing
local solarNames = {'corsolar', 'armsolar', 'legsolar'}
local solars = {}
for id, def in pairs(UnitDefs) do
	if table.contains(solarNames, def.name) then
		solars[id] = def.energyMake
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local energyProd = solars[unitDefID]
	if energyProd then
		-- change production from unconditional to conditional
		spSetUnitResourcing(unitID, "cme", energyProd)
		spSetUnitResourcing(unitID, "ume", -energyProd)
	end
end
