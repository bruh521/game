local pluginFolder = script.Parent

local localDevVersion = pluginFolder:IsDescendantOf(game:GetService("PluginDebugService"))

local toolbar = plugin:CreateToolbar(if localDevVersion then "DataStore Editor - DEV" else "DataStore Editor")
local button = toolbar:CreateButton("DataStoreEditor", "DataStoreEditor", "rbxassetid://5523059345", "DataStore Editor")
local isOn = false
local isOnId = 0
local initialized = false
local modulesLoaded = false

type Env = {
	Plugin: Plugin,
	Modules: { [any]: any },
	UI: { [any]: any },
}

local env: Env = {
	Plugin = plugin,
	Modules = {},
	UI = {},
}

local function LoadModules(parent, tbl)
	for _, v in parent:GetChildren() do
		if v:IsA("ModuleScript") then
			tbl[v.Name] = require(v)
		elseif v:IsA("Folder") and v:FindFirstChildOfClass("ModuleScript") then
			local t = {}
			tbl[v.Name] = t
			LoadModules(v, t)
		end
	end
end

local function LoadPluginModules()
	for _, v in pluginFolder.Plugin:GetChildren() do
		if v:IsA("ModuleScript") then
			local m = require(v)
			env.Modules[v.Name] = m
			setmetatable(m, { __index = env })
		end
	end

	local numInit = 0
	local doneInit = 0
	local thread = coroutine.running()

	for name, module in env.Modules do
		if type(module.Init) == "function" then
			numInit += 1
			task.defer(function()
				debug.setmemorycategory(name)
				module:Init()
				debug.resetmemorycategory()
				doneInit += 1
				if doneInit >= numInit and coroutine.status(thread) == "suspended" then
					task.spawn(thread)
				end
			end)
		end
	end

	if doneInit < numInit then
		coroutine.yield()
	end

	for _, module in env.Modules do
		if type(module.Start) == "function" then
			task.spawn(module.Start, module)
		end
	end
end

local function ButtonClicked()
	isOn = not isOn
	isOnId += 1
	local id = isOnId

	button:SetActive(isOn)

	if isOn and not initialized then
		initialized = true
		LoadModules(pluginFolder.UI, env.UI)
		LoadPluginModules()
		env.Modules.PluginWidget.Disabled:Connect(function()
			if isOn then
				ButtonClicked()
			end
		end)
		modulesLoaded = true
	end

	if modulesLoaded and id == isOnId then
		if isOn then
			env.Modules.App:Mount()
		else
			env.Modules.App:Unmount()
		end

		env.Modules.PluginWidget:SetEnabled(isOn)
	end
end

button.Click:Connect(ButtonClicked)
plugin.Unloading:Connect(function()
	if isOn then
		ButtonClicked()
	end
end)