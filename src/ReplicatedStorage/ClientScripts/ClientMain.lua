local module = {}
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
local Targetshadow = Stuff:WaitForChild("TargetShadow")
local Junk = workspace:WaitForChild("Junk")
local posPlusOne = Vector3.new(1,1,1)
local Yourself = {}
local Locations = workspace:WaitForChild("Locations")
local LocationList = {}
local LP = game.Players.LocalPlayer

local curLocation = nil
-- remove out of char, fix shadow on meshes and rotation

function module.TargetedShadow(HumRootPart)
--[[Targetshadow = Targetshadow:Clone()
Targetshadow.Parent = HumRootPart.Parent
local lc = game.Players.LocalPlayer.Character
local rayParamsTargetShadow = RaycastParams.new()
rayParamsTargetShadow.FilterType = Enum.RaycastFilterType.Exclude
rayParamsTargetShadow.FilterDescendantsInstances = Yourself	

while game["Run Service"].Heartbeat:Wait() do
	if HumRootPart then
			local ray = Ray.new(HumRootPart.Position, Vector3.new(0, -5000, 0))
			local hit,pos,normal = game.Workspace:FindPartOnRayWithIgnoreList(ray, {workspace.NPCs, Targetshadow,lc})
			local newPos = pos + Vector3.new(0,.05,0)
	if hit then
				Targetshadow.CFrame = CFrame.new(newPos,newPos+normal)*CFrame.Angles(0, 1.570796326794896619231321691639751442098584699687552910487472296153908203143104499314017412671058533991074043256641153323546922304775291115862679704064240558725142051350969260552779822311474477465191, 0)
	else
				local newPos = pos + Vector3.new(0,-1000,0)
				Targetshadow.CFrame = CFrame.new(newPos,newPos+normal)*CFrame.Angles(0, 1.570796326794896619231321691639751442098584699687552910487472296153908203143104499314017412671058533991074043256641153323546922304775291115862679704064240558725142051350969260552779822311474477465191, 0)
	end
	end
	end
	]]
end


local CurLocation = nil
local LocationParams = RaycastParams.new()
LocationParams.FilterDescendantsInstances = {}
LocationParams.FilterType = Enum.RaycastFilterType.Include
LocationParams.IgnoreWater = true

local function SetLocations()
	local list = {}
	for i, v in pairs(workspace:GetChildren()) do
	table.insert(list,v)
	end
	LocationList = list
	LocationParams.FilterDescendantsInstances = LocationList
end

local function MainLocationThread()
	while task.wait(.43) do
		if LP.Character ~= nil and LP.Character:FindFirstChild("Head") then
		if game.Players.LocalPlayer.Character:FindFirstChild("Head") then
			local result = workspace:Raycast(LP.Character:FindFirstChild("Head").Position,Vector3.new(0,10000,0),LocationParams)
			if result then
				local hitPart = result.Instance
				if curLocation ~= hitPart.Name then
					curLocation = hitPart.Name
					-- add MUsic player
				end
			end
		end
		end
	end
end
function module.StartLocation()
	SetLocations()
coroutine.spawn(MainLocationThread())
	
end
return module
