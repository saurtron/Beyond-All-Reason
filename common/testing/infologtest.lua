local maxErrors = 10

local function infologTest()
	local errors = {}
	local infolog = VFS.LoadFile("infolog.txt")
	if infolog then
		local fileLines = string.lines(infolog)
		for i, line in ipairs(fileLines) do
			if string.find(line, 'Error:', nil, true) then
				errors[#errors+1] = line
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
		error(table.concat(errors, "\n"))
	end
end
