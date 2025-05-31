local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Rodux = require(script.Parent.Parent.Parent.Packages.Rodux)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)

local App = {}

local app
local store
local rootTree

function App:Get()
	return app
end

function App:GetStore()
	return store
end

function App:Mount()
	rootTree = Roact.mount(app, self.Modules.PluginWidget:GetWidget())
end

function App:Unmount()
	if rootTree then
		Roact.unmount(rootTree)
		rootTree = nil
	end
	store:dispatch({ type = "ResetAll" })
end

function App:Start() end

function App:Init()
	store = Rodux.Store.new(self.Modules.State.Reducer)
	app = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		Main = Roact.createElement(self.UI.Main),
	})
end

return App