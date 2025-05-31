-- Test code
-- put random stuff here
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")
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
local StarterChar = ReplicatedStorage:WaitForChild("StarterChar")
local Settings = require(ServerScripts:WaitForChild("Settings"))
local Alive = workspace:WaitForChild("Alive")
local DefaultSizeRig = ReplicatedStorage:FindFirstChild("Stuff"):FindFirstChild("DefaultSizeRig")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local AttributeHandler = require(ServerScripts:WaitForChild("AttributeHandler"))
local Stuff = ReplicatedStorage:WaitForChild("Stuff")
local DefaultRig = Stuff:WaitForChild("DefaultSizeRig")
local constraint = Config.SizeConstraintsPlusOrMinus
local CVars = game.ReplicatedStorage:WaitForChild("CVars")
local Map = workspace:WaitForChild("Map")
local Attributes = require(ServerScripts.Attributes)
task.wait()

if Settings.DevMode == true then
else
	script.Disabled = true
end

local randompart = workspace:WaitForChild("randomPart")
randompart.ClickDetector.MouseClick:Connect(function(plr)
	local char = plr.Character
	Attributes.AddWalkSpeed(plr,{
		['Speed'] = 300,
		['Duration'] = 10,
	})
end)