<<<<<<< HEAD
=======
function skip()
	return Spring.GetGameFrame() > 0
end

>>>>>>> master
-- Test whether mexes are able to clear queued buildings by shift-clicking
function setup()
	Test.clearMap()

<<<<<<< HEAD
	widget_cmd_extractor_snap = widgetHandler:FindWidget("Extractor Snap (mex/geo)")
	assert(widget_cmd_extractor_snap)

	widget_gui_pregame_build = widgetHandler:FindWidget("Pregame Queue")
=======
	local widget_cmd_extractor_snap = widgetHandler:FindWidget("Extractor Snap (mex/geo)")
	assert(widget_cmd_extractor_snap)

	local widget_gui_pregame_build = widgetHandler:FindWidget("Pregame Queue")
>>>>>>> master
	assert(widget_gui_pregame_build)

	WG['pregame-build'].setBuildQueue({})
	WG["pregame-build"].setPreGamestartDefID(nil)

	initialCameraState = Spring.GetCameraState()

	Spring.SetCameraState({
		mode = 5,
	})

	-- wait for camera to move
	Test.waitTime(10)
end

function cleanup()
	Test.clearMap()

	WG['pregame-build'].setBuildQueue({})
	WG["pregame-build"].setPreGamestartDefID(nil)

	Spring.SetCameraState(initialCameraState)
end

<<<<<<< HEAD
function test()
	mexUnitDefId = UnitDefNames["armmex"].id
	metalSpots = WG['resource_spot_finder'].metalSpotsList

	midX, midZ = Game.mapSizeX / 2, Game.mapSizeZ / 2
	targetMex = nil
	targetMexDistance = 1e20
=======
-- tests both pregame mex snap behavior, as well as basic queue and blueprint handling
function test()
	local mexUnitDefId = UnitDefNames["armmex"].id
	local metalSpots = WG['resource_spot_finder'].metalSpotsList

	local midX, midZ = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local targetMex = nil
	local targetMexDistance = 1e20
>>>>>>> master
	for i = 1, #metalSpots do
		local distance2 = math.distance2dSquared(midX, midZ, metalSpots[i].x, metalSpots[i].z)
		if distance2 < targetMexDistance then
			targetMexDistance = distance2
			targetMex = metalSpots[i]
		end
	end

	-- Place a mex off of a mex spot - expect mex snap to position it on the spot, as close as possible to cursor position
	WG["pregame-build"].setPreGamestartDefID(mexUnitDefId)
<<<<<<< HEAD
	sx, sy, sz = Spring.WorldToScreenCoords(targetMex.x - 200, targetMex.y, targetMex.z - 200)
=======
	local activeBlueprint = WG["pregame-build"].getPreGameDefID()
	assert(activeBlueprint == mexUnitDefId, "Active blueprint should be armmex")
	local sx, sy, sz = Spring.WorldToScreenCoords(targetMex.x - 200, targetMex.y, targetMex.z - 200)
>>>>>>> master
	Spring.WarpMouse(sx, sy)

	-- wait for widgets to respond
	Test.waitTime(10)

	-- did it snap?
	assert(WG.ExtractorSnap.position ~= nil)

	-- did it snap to the closest mex?
	assert(math.distance2d(
		WG.ExtractorSnap.position.x,
		WG.ExtractorSnap.position.z,
		targetMex.x,
		targetMex.z
	) < 100)

<<<<<<< HEAD
	snappedPosition = table.copy(WG.ExtractorSnap.position)
=======
	local snappedPosition = table.copy(WG.ExtractorSnap.position)
>>>>>>> master

	-- queue the mex build
	Script.LuaUI.MousePress(sx, sy, 1)

	-- wait for widgets to respond
	Test.waitTime(10)

	-- move mouse to snapped position
	sx, sy, sz = Spring.WorldToScreenCoords(snappedPosition.x, snappedPosition.y, snappedPosition.z)
	Spring.WarpMouse(sx, sy)

	-- select mex again
	WG["pregame-build"].setPreGamestartDefID(mexUnitDefId)

	-- wait for widgets to respond
	Test.waitTime(10)

	-- mock shift, and mouse press on top of the snapped position
	-- this should clear the queued mex, and not try to snap it to another position
	Test.mock(Spring, "GetModKeyState", function()
		return false, false, false, true
	end)
	Script.LuaUI.MousePress(sx, sy, 1)

	-- wait for widgets to respond
	Test.waitTime(10)

	-- clear blueprint
	WG["pregame-build"].setPreGamestartDefID(nil)
<<<<<<< HEAD

	-- Did the mex get de-queued?
	buildQueue = WG['pregame-build'].getBuildQueue()
=======
	activeBlueprint = WG["pregame-build"].getPreGameDefID()
	assert(activeBlueprint == nil, "Active blueprint should be nil")

	-- Did the mex get de-queued?
	local buildQueue = WG['pregame-build'].getBuildQueue()
>>>>>>> master
	assert(#buildQueue == 0, "Build queue should be empty")
end
