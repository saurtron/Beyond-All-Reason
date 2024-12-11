function skip()
	return Spring.GetGameFrame() <= 0
end

function setup()
	Test.clearMap()
end

function cleanup()
	Test.clearMap()
end

function crashGame()
	-- test waitUntilCallinArgs with and without expectCallin preregister
	local myTeamID = Spring.GetMyTeamID()

	local unitID = SyncedRun(function(locals)
		local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
		local y = Spring.GetGroundHeight(x, z)
		return Spring.CreateUnit("armpw", x, y, z, 0, locals.myTeamID)
	end)

	-- issue selfd
	Spring.GiveOrderToUnit(unitID, CMD.SELFD, {}, 0)

	Test.waitFrames(1)

	Test.waitUntilCallinArgs("UnitCommand", { nil, nil, nil, 500, nil, nil, nil })

	assert(Spring.GetUnitSelfDTime(unitID) > 0)
	Test.waitFrames(180)
end

function test()
	while true do
		crashGame()
	end
end
