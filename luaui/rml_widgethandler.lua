
local function WrapWidget(wh, widget)
	if not widget.GetInfo then
		return true
	end
	local whInfo = widget.GetInfo()
	if not whInfo.rmlwidget then
		return true
	end
	if not RmlUi then
		return false
	end
	if whInfo.rmlwidget and not whInfo.rmlcontext then
		whInfo.rmlcontext = 'shared'
	end
	widget.rmlContext = RmlUi.GetContext(whInfo.rmlcontext)

	local name = whInfo.name
	local filename = wh.knownWidgets[name].filename
	--local base, path = Basename(filename)
	local _,_,base = string.find(filename, "([^\\/:]*)$")
	local _,_,path = string.find(filename, "(.*[\\/:])[^\\/:]*$")
	local widgetData = {}
	function widget:InitializeRml(model, model_name, rmlmain)
		Spring.Echo("RML", widget.whInfo, filename, base, path)
		Spring.Echo("Filename", whInfo.filename, whInfo.name)
		if not model_name then
			model_name = whInfo.name
		end
		local dm_handle = widget.rmlContext:OpenDataModel(model_name, model)
		if not dm_handle then
			Spring.Echo("RmlUi: Failed to open data model ", model_name)
			return false
		end
		widgetData.model_name = model_name

		local document = widget.rmlContext:LoadDocument(rmlmain, widget)
		if not document then
			Spring.Echo("Failed to load document")
			return false
		end
		widgetData.document = document

		-- uncomment the line below to enable debugger
		-- RmlUi.SetDebugContext('shared')

		document:ReloadStyleSheet()
		document:Show()
		widget.dm_handle = dm_handle
		widget.document = document
		return true
	end
	function widget:ShutdownRml()
		if not widgetData.model_name then return end

		widget.rmlContext:RemoveDataModel(widgetData.model_name)
		if widgetData.document then
			widgetData.document:Close()
		end
	end
	return true
end

return {WrapWidget = WrapWidget}
