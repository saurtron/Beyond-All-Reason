local gadget = gadget ---@type Gadget

function gadget:GetInfo()
	return {
		name = "Test base64",
		description = "Test base64 and interaction with startscript",
		layer = 0,
		enabled = true,
	}
end


local baseScript = [[
[GAME]
{
	[allyteam0]
        {
                numallies=0;
        }
        [allyteam1]
        {
                numallies=0;
        }
        [team0]
        {
                teamleader=0;
                allyteam=0;
        }
        [team1]
        {
                teamleader=1;
                allyteam=1;
        }
        [player0]
        {
                team=0;
                name=Player;
        }
        [player1]
        {
                team=1;
                name=Player2;
        }
	myplayername=Player;
        gametype=Beyond All Reason $VERSION;
        mapname=All That Glitters v2.2;
        ishost=1;
        startpostype=2;
        maphash=1;
        startpostype=0;
        modhash=1;
        showservername=A Battle;

	[MODOPTIONS]
	{
		verify_encoding=1;

]]


if gadgetHandler:IsSyncedCode() then
	function gadget:Initialize()
		local strings = {}
		math.randomseed(123) -- for reproducibility
		for L = 1, 20 do
			for i = 1, 10 do
				local str = "pref"
				for j = 1, L do
					str = str .. string.char(math.random(0, 255))
				end
				strings[#strings+1] = str
			end
		end
		-- a bunch of manual tests too
		--strings[#strings+1] = "return { foo = bar }"
		--strings[#strings+1] = "x = 1.e-6 + 0.123"
		strings[#strings+1] = "works??!??!///+"
		--strings[#strings+1] = "x=1"
		--strings[#strings+1] = "x=1;"
		--strings[#strings+1] = "x=1;\n"
		--strings[#strings+1] = "x\n=1;\n"
		--strings[#strings+1] = ";"
		--strings[#strings+1] = "\n"
		--strings[#strings+1] = ""
		--
		local broken = "QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWV  phYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk"
		local ok =     "QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk"

		if Spring.GetModOption("verify_encoding") then
			if Encoding.DecodeBase64(broken) == Encoding.DecodeBase64(ok) then
				Spring.Echo("contaminated base64 decodes the same", Encoding.DecodeBase64(broken), Encoding.DecodeBase64(ok))
			end
			for i = 1, #strings do
				if Encoding.DecodeBase64(Spring.GetModOption("encoded" .. i)) ~= strings[i] then
					Spring.Echo("bad encode", i, strings[i], Spring.GetModOption("encoded" .. i))
				end
				if Encoding.DecodeBase64Url(Spring.GetModOption("encodedu" .. i)) ~= strings[i] then
					Spring.Echo("bad url encode", i, strings[i], Spring.GetModOption("encodedu" .. i))
				end
			end
		else
			local startscript = baseScript
			for i = 1, #strings do
				startscript = startscript .. "encoded" .. i .. "=" .. Encoding.EncodeBase64(strings[i]) .. ";\n"
				startscript = startscript .. "encodedu" .. i .. "=" .. Encoding.EncodeBase64Url(strings[i]) .. ";\n"
			end
			startscript = startscript .. "\n}\n}"
			Spring.Reload(startscript)
		end

	end
end
