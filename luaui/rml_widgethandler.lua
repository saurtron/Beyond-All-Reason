
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
	function widget:InitializeRml(model_name, model, rmlmain)
	    local dm_handle = widget.rmlContext:OpenDataModel(model_name, model)
	    if not dm_handle then
		Spring.Echo("RmlUi: Failed to open data model ", model_name)
		return false
	    end

	    local document = widget.rmlContext:LoadDocument(rmlmain, widget)
	    if not document then
		Spring.Echo("Failed to load document")
		return false
	    end

	    -- uncomment the line below to enable debugger
	    -- RmlUi.SetDebugContext('shared')

	    document:ReloadStyleSheet()
	    document:Show()
	    widget.dm_handle = dm_handle
	    widget.document = document
	    return true
	end
	return true
end

return {WrapWidget = WrapWidget}
