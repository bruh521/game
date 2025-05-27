local module = {}
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
local Debris = game:GetService("Debris")
local function SetSizeConstraintsNew(char,tables)
		local charHum = char:WaitForChild("Humanoid") 
		local NewCharDesc = Instance.new("HumanoidDescription")
		NewCharDesc = char.Humanoid:GetAppliedDescription()
		-- banned char parts 
		--[[
		for i, v in pairs(Config.BannedThings) do
			if NewCharDesc[v] then
			if tonumber(NewCharDesc[v]) > bannedthingnum then
					NewCharDesc[v] = 0
				end
			end
		end	
		]]
		if not tables then
			-- sets size
	for TypeName, val in pairs(Config.DefaultSize) do
			if NewCharDesc[TypeName] then 
			NewCharDesc[TypeName] = val
			end
	end
		else
			if tables then
			for TypeName, val in pairs(tables) do
				if NewCharDesc[TypeName] then 
					NewCharDesc[TypeName] = val
				end	
			end
			end 
		
		end
		task.wait()
	for HumParts, DescParts in pairs(Config.BannedThings) do
		--print('_, is '.. _, ' and Parts is ' .. Parts)
		if char:FindFirstChild(HumParts) then
			if DefaultSizeRig:FindFirstChild(HumParts) then
				local targetPart = char:FindFirstChild(HumParts) 
				if targetPart.Size.X > DefaultSizeRig[HumParts].Size.X + CVars.SizeConstraintsPlusOrMinus.Value or 
					targetPart.Size.Y > DefaultSizeRig[HumParts].Size.Y + CVars.SizeConstraintsPlusOrMinus.Value or
					targetPart.Size.Z > DefaultSizeRig[HumParts].Size.Z + CVars.SizeConstraintsPlusOrMinus.Value or 
					targetPart.Size.X < DefaultSizeRig[HumParts].Size.X - CVars.SizeConstraintsPlusOrMinus.Value or 
					targetPart.Size.Y < DefaultSizeRig[HumParts].Size.Y - CVars.SizeConstraintsPlusOrMinus.Value or
					targetPart.Size.Z < DefaultSizeRig[HumParts].Size.Z - CVars.SizeConstraintsPlusOrMinus.Value then
					NewCharDesc[DescParts] = 0
					-- player alert ig	
					
				end
			end
		end
		end
charHum:ApplyDescription(NewCharDesc)
	
	
	
	
end



function getTableLength(t)
	local c = 0
	for i, v in pairs(t) do
		c=c+1
	end
	return c
end
--[[
local function WatchAttributes(char)
	for i, v in pairs(char.Humanoid:GetAttributes()) do
	--	if AttributeHandler[i] then	AttributeHandler[i](char) else warn('ATTRIBUTE ' .. i .. " DOESN'T EXIST") 
		end
	end
end
]]
local function ApplyAttributes(char)
	local hum = char:WaitForChild("Humanoid")
	for Attribute, Vals in pairs(Config.CharAttributes) do
		local val = Vals['Default'] or 0
		hum:SetAttribute(Attribute,val)
	end
	-- Watch Attributes until death or leave
	AttributeHandler.WatchAttributes(char)

	-- set defaults (again)
for Attribute2, Vals2 in pairs(Config.DefaultAttributes) do
		local val3 = Vals2['Default'] or 0
		hum:SetAttribute(Attribute2,val3)
	end
	
end

local function checkAdmin(userid)
	local v2 = false
	for i, v in pairs(Config.Admins) do
		if v == userid then
			v2 = true
		end
		
	end
	return v2
end
function module.SetupCharacter(...)
	local info = ... or {}
	local Character = info.Character
	Character.Parent = workspace.Alive
	for i, v in pairs(StarterChar:GetChildren()) do
		v:Clone().Parent = info.Character
	end
	if Config.RestrainCharacters == true then
		SetSizeConstraintsNew(Character)
	end
	ApplyAttributes(Character)
	Character.Humanoid.Died:Connect(function(c)
		task.wait(Character.Humanoid:GetAttribute("RespawnTime"))
		game.Players[Character.Name]:LoadCharacter()
	end)
	-- when done
	local bv = Instance.new("BoolValue")
	bv.Name = 'Loaded' 
	bv.Value = true
	bv.Parent = Character
	
end

function module.ActivateDialogue()
	-- i need GUI to make dialogue 
end

function module.setBouncers() -- should probably make one function 
	-- that checks --> set bouncers
	-- so it only checks every part once
-- @CloneTrooper1019, 2017
-- OBJ Trampoline Folder --> group "bouncer" --> script parent
local function onTouched(hit)
	local char = hit.Parent
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			local rootPart = humanoid.RootPart
			if rootPart and rootPart.Velocity.Y < 200 then
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(0,10e6,0)
				bv.Velocity = Vector3.new(0,200,0)
				bv.Parent = rootPart
				Debris:AddItem(bv,.25)
			end
		end
	end
end






	for i, v in pairs(Map:GetDescendants()) do
		if v.Name == "Bouncer" and v:IsA("BasePart") then
			v.Touched:Connect(function(hit)
				onTouched(hit)
			end)
		end
		end
end

return module

