function widget:GetInfo()
	return {
		name      = "TestRays",
		desc      = "Test Rays .",
		author    = "Saurtron",
		version   = "v1.0",
		date      = "Jan 2024",
		license   = "GNU GPL, v2 or later",
		layer     = -99990,
		enabled   = false,
	}
end

local spGetCameraPosition   = Spring.GetCameraPosition
local spGetCameraDirection = Spring.GetCameraDirection
local spTraceRayGround = Spring.TraceRayGround
local spTraceRayUnits = Spring.TraceRayUnits
local spTraceRayFeatures = Spring.TraceRayFeatures
local spGetUnitDefID = Spring.GetUnitDefID
local spGetFeatureDefID = Spring.GetFeatureDefID
local UnitDefs = UnitDefs
local FeatureDefs = FeatureDefs

local elapsed = 0.0

local function getDefNames(arr, defs, defFn)
	local names = {}
	local allNames = {}
	for _, unitData in pairs(arr) do
		local id = unitData[2]
		if not names[id] then
			local defID = defFn(id)
			local name = defs[defID].name
			names[id] = name
			allNames[#allNames+1] = name
		end
	end
	return allNames
end

function widget:MousePress(x, y, button)
	local x, y, cx, cy, cz, dx, dy, dz = Spring.GetMouseStartPosition(button)
	local cpx, cpy, cpz = spGetCameraPosition()
	local dist = spTraceRayGround(cpx, cpy, cpz, dx, dy, dz, 15000, true)
	local units = spTraceRayUnits(cpx, cpy, cpz, dx, dy, dz, dist+100)
	if #units > 0 then
		local allNames = getDefNames(units, UnitDefs, spGetUnitDefID)
		Spring.Echo("Units:", Json.encode(allNames))
		return
	end
	local feats = spTraceRayFeatures(cpx, cpy, cpz, dx, dy, dz, dist+100)
	if #feats > 0 then
		local allNames = getDefNames(feats, FeatureDefs, spGetFeatureDefID)
		Spring.Echo("Features:", Json.encode(allNames))
		return
	end

	local dist, x, y, z = spTraceRayGround(cpx, cpy, cpz, dx, dy, dz, 15000, false)
	Spring.Echo("Ground: x:" .. x .. " y:" .. y .. " z:" .. z .. " dist:" .. dist)
end

