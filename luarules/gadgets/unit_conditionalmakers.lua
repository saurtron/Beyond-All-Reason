
function gadget:GetInfo()
	return {
		name      = "Conditional energy makers",
		desc      = "makes energy production on/off dependent based on conditionalenergymake unitdef customParam",
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
local conditionalEnergyMakers = {}
for id, def in pairs(UnitDefs) do
	if def.customParams and def.customParams.conditionalenergymake then
		conditionalEnergyMakers[id] = def.energyMake
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local energyProd = conditionalEnergyMakers[unitDefID]
	if energyProd then
		-- change production from unconditional to conditional
		spSetUnitResourcing(unitID, "cme", energyProd)
		spSetUnitResourcing(unitID, "ume", -energyProd)
	end
end
