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
	autolevel = true,
	autolevelText = "off",
	fullLogs = "logs go here",
}

local main_model_name = "testrunner_model"
local rmlmain = "luaui/rmlwidgets/gui_testrunner/view.rml"

local logArea
local fullLogs = ""

local isScenario = true
local testFinished = false

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
		RmlUi.SetDebugContext('shared')
	end
end

function widget:TestClicked(element)
	testFinished = false
	local name = element.child_nodes[1].inner_rml
	local label = element.child_nodes[2].inner_rml
	local filename = element.child_nodes[3].inner_rml
	local text = label:split(".")[1]
	local command = isScenario and 'runscenario' or 'runtests'
	logArea.inner_rml = fullLogs
	fullLogs = ""
	dm_handle.running = text .. "..."
	spSendCommands(command .. " " .. text)
end

function widget:RunTest(element)
	isScenario = false
	widget:TestClicked(element, false)
end

function widget:RunScenario(element)
	isScenario = true
	widget:TestClicked(element, true)
end

function widget:AutolevelClicked(element, b)
	local state = element.attributes.checked and 'on' or 'off'
	dm_handle.autolevelText = state
	spSendCommands("testsautoheightmap " .. state)
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
	widget:Shutdown()
	widget:Initialize()
end

