function widget:GetInfo()
	return {
		name      = "TestRays Ground",
		desc      = "Test Rays Ground",
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
local spTraceRayGroundInDirection = Spring.TraceRayGroundInDirection
local spTraceRayGroundBetweenPositions = Spring.TraceRayGroundBetweenPositions


function widget:MousePress(x, y, button)
	local fx, fy, fz
	local x, y, cx, cy, cz, dx, dy, dz = Spring.GetMouseStartPosition(button)
	local cpx, cpy, cpz = spGetCameraPosition()
	local dist, x, y, z = spTraceRayGroundInDirection(cpx, cpy, cpz, dx, dy, dz, nil, false)
	local wdist, wx, wy, wz = spTraceRayGroundInDirection(cpx, cpy, cpz, dx, dy, dz, nil, true)
	local units = Spring.GetSelectedUnits()
	if #units == 2 then
		fx, fy, fz = Spring.GetUnitPosition(units[2])
	else
		fx, fy, fz = x, y, z
	end
	if #units == 0 then
		units = Spring.GetAllUnits()
		Spring.Echo(Json.encode(units))
	end
	local ux, uy, uz = 0,0,0
	if #units > 0 then
		ux, uy, uz = Spring.GetUnitPosition(units[1])
	end
	local dist3, x3, y3, z3 = spTraceRayGroundBetweenPositions(cpx, cpy, cpz, cpx+dx*10000, cpy+dy*10000, cpz+dz*10000, false)
	Spring.Echo(string.format("ground1: %.1f %.1f %.1f %.1f water: %.1f %.1f %.1f %.1f", x, y, z, dist, wx, wy, wz, wdist))
	Spring.Echo(string.format("ground2: %.1f %.1f %.1f %.1f depth: %.1f", x3, y3, z3, dist3, dist-wdist))
	if #units > 0 then
		local dist2, x2, y2, z2 = spTraceRayGroundBetweenPositions(fx, fy+10, fz, ux, uy-10, uz, false)
		Spring.GiveOrderToUnit(units[1], CMD.ATTACK, {x2, y2, z2}, 0)
	end
end

