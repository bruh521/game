local module = {}
local Players = game:WaitForChild("Players")
local Lighting = game:WaitForChild("Lighting")
local ReplicatedFirst = game:WaitForChild("ReplicatedFirst")
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local ClientScripts = require(ReplicatedStorage:WaitForChild("ClientScripts"):WaitForChild("ClientMain"))
local Remotes = ReplicatedStorage:WaitForChild("Remote")
local RemoteEvent = Remotes:WaitForChild("RemoteEvent")
local ServerStorage = game:WaitForChild("ServerStorage")
local ServerScriptService = game:WaitForChild("ServerScriptService")
local ServerScripts = ServerScriptService:WaitForChild("ServerScripts")
local ServerMain = require(ServerScripts:WaitForChild("ServerMain"))
local StarterChar = ReplicatedStorage:WaitForChild("StarterChar")
local Settings = require(ServerScripts:WaitForChild("Settings"))
local Alive = workspace:WaitForChild("Alive")
local ClientScripts = require(ReplicatedStorage.ClientScripts.ClientMain)
local NPCs = workspace:FindFirstChild("NPCs")
local ClientRemotes = require(ServerScripts:WaitForChild("ClientRemotes"))
local Locations = workspace:WaitForChild("Locations")
local LP = game.Players.LocalPlayer

module.DevFunctions = {

}
--[[
function module.RequestTick(plr, ...)
	local info = ... or {}
	return startTick
end
]]





return module
