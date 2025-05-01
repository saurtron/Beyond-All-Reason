local widget = widget ---@type Widget

function widget:GetInfo()
    return {
        name = "Rml Starter",
        desc = "This widget is a starter example for RmlUi widgets.",
        author = "Mupersega",
        date = "2025",
        license = "GNU GPL, v2 or later",
        layer = -1000000,
        enabled = true,
        rmlwidget = true,
    }
end

local init_model = {
    expanded = false,
    message = "Hello, find my text in the data model!",
    testArray = {
        { name = "Item 1", value = 1 },
        { name = "Item 2", value = 2 },
        { name = "Item 3", value = 3 },
    },
}

local main_model_name = "starter_model"
local rmlfile = "luaui/rmlwidgets/gui_rml_starter/gui_rml_starter.rml"

function widget:Initialize()
    if not widget:InitializeRml(main_model_name, init_model, rmlfile) then
	    return
    end

    -- uncomment the line below to enable debugger
    -- RmlUi.SetDebugContext('shared')
end

function widget:Shutdown()
    widget.rmlContext:RemoveDataModel(main_model_name)
    if document then
        document:Close()
    end
end

-- This function is only for dev experience, ideally it would be a hot reload, and not required at all in a completed widget.
function widget:Reload(event)
    Spring.Echo("Reloading")
    Spring.Echo(event)
    widget:Shutdown()
    widget:Initialize()
end
