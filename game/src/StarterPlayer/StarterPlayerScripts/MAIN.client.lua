local Players = game:WaitForChild("Players")
local Lighting = game:WaitForChild("Lighting")
local ReplicatedFirst = game:WaitForChild("ReplicatedFirst")
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
--local ClientScripts = require(ReplicatedStorage:WaitForChild("ClientScripts"):WaitForChild("ClientMain"))
local Remotes = ReplicatedStorage:WaitForChild("Remote")
local RemoteEvent = Remotes:WaitForChild("RemoteEvent")
local StarterChar = ReplicatedStorage:WaitForChild("StarterChar")
local Alive = workspace:WaitForChild("Alive")
local DefaultSizeRig = ReplicatedStorage:FindFirstChild("Stuff"):FindFirstChild("DefaultSizeRig")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Stuff = ReplicatedStorage:WaitForChild("Stuff")
local DefaultRig = Stuff:WaitForChild("DefaultSizeRig")
local ClientScripts = ReplicatedStorage:WaitForChild("ClientScripts")
local ClientMain = ClientScripts:WaitForChild("ClientMain")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")
local baseTick
local RunService = game:GetService("RunService")
--local v1 = ClientMain.InitiateLocatonDetermination()

--local v2 = coroutine.create(v1)
--v2()

--[[
local Test = RemoteFunction:InvokeServer({
	Type = 'LatencyTest',
	ClientTick = tick(),
})

workspace:WaitForChild("LatencyButton").ClickDetector.MouseClick:Connect(function()
	local Test2 = RemoteFunction:InvokeServer({
		Type = 'LatencyTest',
		ClientTick = tick(),
	})
end)
]]

