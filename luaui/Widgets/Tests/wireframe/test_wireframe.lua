function setup()
	Test.clearMap()

	--Test.levelHeightMap()

	--Spring.SendCommands("globallos")
	Spring.SendCommands("setspeed 5")
end

function cleanup()
	--Spring.SendCommands("globallos")
	Spring.SendCommands("setspeed 1")

	--Test.clearMap()
end

function runWireframeTest()
	local WAIT_FRAMES = 204 -- enough to trigger critter cleanup/restoring by gaia_critters
	local unitName = 'armsolar'

	local midX, midZ = Game.mapSizeX / 2, Game.mapSizeZ / 2

	SyncedRun(function(locals)
		local GaiaTeamID  = Spring.GetGaiaTeamID()
		local midX, midZ = locals.midX, locals.midZ
		local spCreateUnit = Spring.CreateUnit
		local unitName = locals.unitName
		local function createUnit(def, x, z, teamID)
			local y = Spring.GetGroundHeight(x, z)
			local x = midX + x
			local z = midZ + z
			spCreateUnit(def, x, y, z, "south", teamID)
		end
		for i=1, 10 do
			for j=1, 10 do
				createUnit(unitName, -2000+i*80, -1500+j*80, 0)
			end
		end
	end, 500)
	Test.waitFrames(4)
	SyncedRun(function(locals)
		local h = {}
		h["build"] = 0.9
		local allUnits = Spring.GetAllUnits()
		for _, unitID in pairs(allUnits) do
			Spring.SetUnitHealth(unitID, h)
		end
		--[[local h = {}
		h["health"] = 340*0.9
		local allUnits = Spring.GetAllUnits()
		for _, unitID in pairs(allUnits) do
			Spring.SetUnitHealth(unitID, h)
		end]]--
	end)
	Test.waitFrames(1)

	Test.waitFrames(WAIT_FRAMES - (Spring.GetGameFrame() % WAIT_FRAMES))

	Test.waitFrames(2000)
end

function test()
	runWireframeTest()
end
