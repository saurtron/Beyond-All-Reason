
function gadget:GetInfo()
    return {
        name      = "Nano Radar Pos",
        desc      = "Removes radar icon wobble for nanos since these units are technically not buildings (no yardmap)",
        author    = "Floris",
        date      = "November 2019",
        license   = "GNU GPL, v2 or later",
        layer     = 0,
        enabled   = true
    }
end


if (gadgetHandler:IsSyncedCode()) then

    local isTransportable = {}
    for unitDefID, defs in pairs(UnitDefs) do
        if string.find(defs.name, "nanotc") then
            isTransportable[unitDefID] = true
        elseif not (defs.cantBeTransported and defs.cantBeTransported or false) and defs.leavesGhost then
            isTransportable[unitDefID] = true
	end
    end

    function gadget:UnitLoaded(unitId, unitDefId, unitTeam, transportId, transportTeam)
        if isTransportable[unitDefId] then
		Spring.Echo("Pick up", unitId)
		Spring.SetUnitLeavesGhost(unitId, false, true)
        end
    end
    function gadget:UnitUnloaded(unitId, unitDefId, unitTeam, transportId, transportTeam)
        if isTransportable[unitDefId] then
		Spring.Echo("Drop", unitId)
		Spring.SetUnitLeavesGhost(unitId, true)
        end
    end

end
