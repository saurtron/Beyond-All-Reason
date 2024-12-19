local maxErrors = 10

local function getError(text)
	-- [t=00:00:19.471167][f=-000001] XXXX
	local errorIndex = text:match'^%[t=[%d%.:]*%]%[f=[%-%d]*%] ().*'
	if errorIndex and errorIndex > 0 then
		text = text:sub(errorIndex)
	end
	return text
end

local function infologTest()
	local errors = {}
	local infolog = VFS.LoadFile("infolog.txt")
	if infolog then
		local fileLines = string.lines(infolog)
		for i, line in ipairs(fileLines) do
			if string.find(line, 'Error:', nil, true) then
				errors[#errors+1] = getError(line)
				if #errors > maxErrors then
					return errors
				end
			end
		end
	end
	return errors
end


function test()
	local errors = infologTest()
	if #errors > 0 then
		error(table.concat(errors, "\n"), 0)
	end
end
