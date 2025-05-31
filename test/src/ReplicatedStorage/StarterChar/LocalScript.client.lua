local Players = game:WaitForChild("Players")
local Lighting = game:WaitForChild("Lighting")
local ReplicatedFirst = game:WaitForChild("ReplicatedFirst")
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local ClientScripts = require(ReplicatedStorage:WaitForChild("ClientScripts"):WaitForChild("ClientMain"))
local Remotes = ReplicatedStorage:WaitForChild("Remote")
local RemoteEvent = Remotes:WaitForChild("RemoteEvent")
local StarterChar = ReplicatedStorage:WaitForChild("StarterChar")
local Alive = workspace:WaitForChild("Alive")
local DefaultSizeRig = ReplicatedStorage:FindFirstChild("Stuff"):FindFirstChild("DefaultSizeRig")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Stuff = ReplicatedStorage:WaitForChild("Stuff")
local DefaultRig = Stuff:WaitForChild("DefaultSizeRig")
local ClientScripts = ReplicatedStorage:WaitForChild("ClientScripts")
local ClientMain = require(ClientScripts:WaitForChild("ClientMain"))
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")
local baseTick

local Targetshadow = Stuff:WaitForChild("TargetShadow")
local Junk = workspace:WaitForChild("Junk")
local Hum = script.Parent:WaitForChild"Humanoid"
local HumRootPart = script.Parent:WaitForChild("HumanoidRootPart")
Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)


-- Somehow optimize this shit idk lol

-- targeted shadow using rays 
-- TODO fix for Playerscripts for settings for toggle
--[[local TargetShadowLoop = ClientMain.TargetedShadow(HumRootPart)

task.spawn(ClientMain)

local TargetShadowLoop = ClientMain.TargetedShadow(HumRootPart)
task.spawn(ClientMain)
]]

-- no ragdoll 



