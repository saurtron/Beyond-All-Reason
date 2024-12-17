local widgetName = "Attack Range GL4"

local helpers = VFS.Include('common/testing/helpers.lua')

local createUnitAt = helpers.createUnitAt
local getAllyTeams = helpers.getAllyTeams
local radiusCommandParams = helpers.radiusCommandParams
local getWorldPosition = helpers.getWorldPosition

function skip()
	return Spring.GetGameFrame() <= 0
end

function setup()
	-- test on quicksilver remake 1.24
	if Test.expectCallin then
		Test.expectCallin("Update")
	end
	Test.clearMap()
	initialCameraState = Spring.GetCameraState()
	widget = Test.prepareWidget(widgetName)
	--Spring.SetCameraState({
	--	mode = 5,
	--})
end

function cleanup()
	--Test.clearMap()

	Spring.SetCameraState(initialCameraState)
end

local delay = 5

function checkZombies()
	for _, vao in pairs(widget.attackRangeVAOs) do
		if vao.numZombies and vao.numZombies > 0 then
			assert(vao.numZombies == 0)
		end
	end

end

function waitUntilRemainder(n, modulo)
	while (Spring.GetGameFrame() % modulo) ~= n do
		Test.waitFrames(1)
	end
end

function run(team1, team2, radarTeam, distance, attacker, target, remainder, modulo)
	if not radarTeam then
		radarTeam = team2
	end
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2

	local giveOrder = Spring.GiveOrderToUnit
	local validUnit = SyncedProxy.Spring.ValidUnitID

	local unit5 = createUnitAt(attacker, x+700, z, team1)
	local unit6 = createUnitAt(attacker, x+800, z, team1)
	local unit7 = createUnitAt(attacker, x+900, z, team1)
	local unit8 = createUnitAt(attacker, x+1000, z, team1)
	local unit9 = createUnitAt(attacker, x+1100, z, team1)

	assert(validUnit(unit5), "Invalid unit")
	assert(validUnit(unit6), "Invalid unit")
	assert(validUnit(unit7), "Invalid unit")


	--Spring.Echo(widget.attackRangeVAOs)
	waitUntilRemainder(remainder, modulo)

	Spring.SelectUnitArray({unit5, unit6, unit7})
	--checkZombies()

	SyncedProxy.Spring.DestroyUnit(unit5)
	--checkZombies()

	SyncedProxy.Spring.DestroyUnit(unit6)
	--checkZombies() -- here

	Spring.SelectUnit(unit8, true)
	--checkZombies()

	Test.waitFrames(1)

	Spring.SelectUnit(unit9, true)
	--checkZombies()

	--Spring.Echo("DESTROY", unit7, unit5, unit6)
	SyncedProxy.Spring.DestroyUnit(unit7)
	Test.waitUntilCallin('Update', function() return true end)
	checkZombies() -- here on 2

	Test.waitFrames(1) -- dont crash when cleaning map :P
	--checkZombies()

end

function test()
	local random = math.random

	local maxtests = 6

	for i=1, maxtests do
		local offset = 400
		local distance = random(400+offset, 840+offset)

		local attacker = "armsnipe"
		local target = "armsolar"

		run(0, 1, 0, distance, attacker, target, maxtests-i, maxtests)
		Test.clearMap()
	end
end

