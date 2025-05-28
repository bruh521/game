local module = {}

module.DevMode = false -- IGNORE DO NOT CHANGE
module.StartTick = tick()
module.ServerSettings = {
	['AllowStudioInGame'] = false,
	["ForceGameSettingsInStudio"] = false,
}
return module
