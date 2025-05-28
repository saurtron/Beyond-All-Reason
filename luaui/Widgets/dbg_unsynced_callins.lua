function widget:GetInfo()
    return {
        name      = 'Unsynced Callins Debug',
        desc      = "Unsynced Callins Debug",
        layer     = 999999,
        enabled   = true,
    }
end

function widget:UnitScriptLight(lights)
	Spring.Echo("Unsynced Widget UnitScriptLight", lights)
end

function widget:Explosion()
	Spring.Echo("Widget explosion!")
end

function widget:Initialize()
        for wdid, wd in pairs(WeaponDefs) do
		Script.SetWatchExplosion(wdid, true)
        end
end


