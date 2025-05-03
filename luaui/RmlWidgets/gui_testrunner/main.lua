local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name = "Testrunner Gui",
		desc = "Gui for the testrunner",
		layer = -500,
		enabled = true,
		handler = true,
		rmlwidget = true,
	}
end

local model = {
	running = 'select one',
	autolevel = false,
	godmode = false,
	debugquadfield = false,
	debugcolvol = false,
	debugvis = false,
	debugpath = false,
	nocost = false,
	globallos = false,
	fullLogs = "logs go here",
}

local main_model_name = "testrunner_model"
local rmlmain = "luaui/rmlwidgets/gui_testrunner/view.rml"

local logArea
local fullLogs = ""

local isScenario = true
local testFinished = false
local currentScenario = nil
local scenarioArguments = {}

local testListener = {}

local spSendCommands = Spring.SendCommands


function testListener:TestResults(data)
	testFinished = true
	local item = data[1]
	local ms = item.milliseconds
	widget:Feedback(item.result .. " " .. tostring(ms/1000.0) .. 's')

end
function testListener:TestLog(level, text)
	if level < 30 then
		return
	end
	fullLogs = fullLogs .. "<br/>" .. tostring(text)
	logArea.inner_rml = fullLogs
end

function testListener:FinishTests(duration)
	if not testFinished then
		testFinished = true
		widget:Feedback("Finished with no feedback")
		dm_handle.running = "Finished with no feedback"
	end
end

local function findTestFiles(w, forScenarios)
	local res = w:findAllTestFiles({''}, forScenarios)
	for i, t in ipairs(res) do
		local splitLabel = t.label:split("/")
		t.name = splitLabel[#splitLabel]:split(".")[1]
	end
	return res
end

function widget:InitializeData()
	local w = widgetHandler:FindWidget("Test Runner")
	if w then
		model.tests = findTestFiles(w, false)
		model.scenarios = findTestFiles(w, true)
		model.onCommandToggle = function(evt, cmd, value) widget:CommandChange(cmd, value) end
		model.onGloballos = function(evt, value) widget:GloballosChange(value) end
		w:registerListener(testListener)
		widgetHandler:RemoveWidgetCallIn("Update", widget)
	else
		return false
	end
	return true
end

function widget:Initialize()
	widget:InitializeAll()
end

function widget:Update()
	widget:InitializeAll()
end

function widget:InitializeAll()
	local res = widget:InitializeData()
	if res and widget:InitializeRml(main_model_name, model, rmlmain) then
		logArea = document:GetElementById("log-area")
		--RmlUi.SetDebugContext('shared')
	else
		Spring.Echo("Could not initialize")
	end
end

local function GetScenarioArguments(filename)
	local w = widgetHandler:FindWidget("Test Runner")
	local res, env = w:loadTestFromFile(filename)

	if err then
		widget:Feedback(tostring(err))
		return {}
	else
		return env.scenario_arguments()
	end

end

local function createElement(idx, name, value)
	local elmt_type
	if type(value) == 'string' then
		elmt_type = 'text'
	else
		elmt_type = 'number'
	end
	local container = document:GetElementById("scenario-controls")
	local input_element = document:CreateElement('input')
	input_element = container:AppendChild(input_element)
	input_element:SetAttribute('type', elmt_type)
	input_element:SetAttribute('name', name)
	--input_element:SetAttribute('class', 'testrunner-items')
	input_element:SetAttribute('value', tostring(value))
	scenarioArguments[idx] = {name, input_element}
end

local function clearElements()
	for idx, argData in pairs(scenarioArguments) do
		container:RemoveChild(argData[2])
	end
	scenarioArguments = {}
end

local function runTest(label, args)
	local text = label:split(".")[1]
	local command = isScenario and 'runscenario' or 'runtests'
	logArea.inner_rml = fullLogs
	fullLogs = ""
	dm_handle.running = text .. "..."
	if args then
		Spring.Echo("Run", command, text, args)
		spSendCommands(command .. " " .. text .. args)
	else
		spSendCommands(command .. " " .. text)
	end
end

function widget:TestClicked(element)
	testFinished = false
	local name = element.child_nodes[1].inner_rml
	local label = element.child_nodes[2].inner_rml
	local filename = element.child_nodes[3].inner_rml

	if isScenario then
		clearElements()
		args = GetScenarioArguments(filename)
		Spring.Echo(args)
		for i,k in ipairs(args) do
			for name, value in pairs(k) do
				createElement(i, name, value)
			end
		end
		Spring.Echo("Set scenario")
		currentScenario = element
		return
	end
	currentScenario = false
	runTest(label)
end

function widget:RunTest(element)
	isScenario = false
	widget:TestClicked(element, false)
end

function widget:RunCurrent()
	if not currentScenario then
		return
	end
	local element = currentScenario
	local label = element.child_nodes[2].inner_rml
	local args = ""
	for idx, argData in pairs(scenarioArguments) do
		local name = argData[1]
		local elmt = argData[2]
		args = args .. " " .. tostring(elmt.attributes.value)
	end
	runTest(label, args)
end

function widget:RunScenario(element)
	isScenario = true
	widget:TestClicked(element, true)
end

function widget:CommandChange(cmd, value)
	--local state = element.attributes.checked and 'on' or 'off'
	local state = value and '1' or '0'
	spSendCommands(cmd .. " " .. state)
	return false
end

function widget:GloballosChange(value)
	-- just a toggle :(
	spSendCommands("globallos 0") -- 0 is team
	return false
end

function widget:Feedback(text)
	dm_handle.running = text
end

function widget:Shutdown()
	widget.rmlContext:RemoveDataModel(main_model_name)
	if document then
		document:Close()
	end
end

function widget:Reload(event)
	Spring.Echo("Reloading")
	Spring.Echo(event)
	widgetHandler:DisableWidget("Testrunner Gui")
	widgetHandler:EnableWidget("Testrunner Gui")
end

