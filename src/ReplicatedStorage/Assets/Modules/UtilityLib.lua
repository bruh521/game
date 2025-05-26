local utilityLib = {}

--[[
function tween.obj(obj,style,direction,t,goal,reverse,repeatCount)
    local tweenInfo = TweenInfo.new(t,Enum.EasingStyle[style],Enum.EasingDirection[direction],reverse and repeatCount or 0,reverse or false)
    local tween = game:GetService"TweenService":Create(obj,tweenInfo,goal)
    tween:Play()
    return tween
end
]]

local Players = game:GetService"Players"
local runService = game:GetService"RunService"
local UIS = game:GetService"UserInputService"
local repStorage = game:GetService"ReplicatedStorage"
local Assets = repStorage.Assets
local Modules = Assets.Modules
--[[

local Effects = Assets.Effects
local Objects = Assets.Objects

]]
local Lighting = game:GetService"Lighting"

local boatTween = require(Modules:WaitForChild"BoatTween")

function utilityLib.Tween(...)
	local info = ...;
	
	local tweenInfo = TweenInfo.new(info.Time,Enum.EasingStyle[info.Style],Enum.EasingDirection[info.Direction],info.Reverse and info.RepeatCount or 0,info.Reverse or false)
	local tween = game:GetService"TweenService":Create(info.Obj,tweenInfo,info.Goal)
	tween:Play()
	return tween
end

function utilityLib.Tween2(...)
	local Info = ...;

	local Tween = boatTween:Create(Info.Obj,{
		Time = Info.Time;
		EasingStyle = Info.Style;
		EasingDirection = Info.Direction;

		Reverses = Info.Reverse;
		DelayTime = Info.DelayTime or 0;
		RepeatCount = Info.RepeatCount or 0;

		StepType = Info.StepType or "Heartbeat";
		Goal = Info.Goal
	})
	Tween:Play()
	Tween.Completed:Connect(function()
		utilityLib.pcall(function()
			Tween:Destroy()
		end)
		Tween = nil
	end)

	return Tween
end

function utilityLib.Tween3(Obj,Info,Goal)
	local Tween = boatTween:Create(Obj,{
		Time = Info[1],
		EasingStyle = Info[2],
		EasingDirection = Info[3],

		Reverses = Info[4],
		DelayTime = Info[5],
		RepeatCount = Info[6],

		StepType = Info[7] or "Heartbeat",
		Goal = Goal
	})
	Tween:Play()
	Tween.Completed:Connect(function()
		pcall(function()
			Tween:Destroy()
		end)
		Tween = nil
	end)

	return Tween
end

function utilityLib.Spawn(func)
	coroutine.resume(coroutine.create(function()
		local success,err = pcall(function()
			func()
		end)
		if not success then print(err) end
	end))
end

function utilityLib.Delay(n,func)
	coroutine.resume(coroutine.create(function()
		local success,err = pcall(function()
			wait(n)
			func()
		end)
		if not success then print(err) end
	end))
end

local AcceptedTypes = {
	["Instance"] = "Destroy",
	["RBXScriptConnection"] = "Disconnect",
	["table"] = true
}

function utilityLib.DelayDestroy(obj,n)
	local typeOf = AcceptedTypes[typeof(obj)]
	assert(typeOf)
	
	task.delay(n,function()
		local Suc,Err = pcall(function()
			if typeOf == "Destroy" then
				obj:Destroy()
			elseif typeOf == "Disconnect" then
				obj:Disconnect()
			else
				for _,v in pairs(obj) do
					v:Destroy()
				end
				obj = nil
			end
		end)
		if not Suc then
			print(Err)
		end
	end)
end

function utilityLib.pcall(func)
	local success,err = pcall(function()
		func()
	end)
	if not success then 
		print(err) 
	end
	return success,err
end

function utilityLib.Weld(p0,p1,cframe,name)
	local weld = Instance.new("ManualWeld")
	weld.Name = name or p0.Name .. "_Weld"
	weld.Part0,weld.Part1 = p0,p1
	weld.C0 = cframe
	weld.Parent = p1

	return weld
end

function utilityLib.shuffleTable(array)
	-- A buffer that is a direct clone of the array for temporary use
	local buffer = {}
	for i = 1, #array do
		buffer[i] = array[i]
	end

	-- The new array that represents a random configuration of the buffer array
	local newArray = {}
	while (#buffer > 0) do
		-- Remove the randomly chosen index from the buffer to ensure original values each iteration
		newArray[#newArray+1] = table.remove(buffer, math.random(#buffer))
	end

	-- Return the random configuration
	return newArray
end

function utilityLib.getTableLength(t)
	local count = 0
	for _,v in pairs(t) do
		count += 1
	end

	return count
end

function utilityLib.reverseTable(array)
	local reversed = {}

	for i = #array, 1, -1 do
		local val = array[#array]
		table.insert(reversed, val)
	end
	
	return reversed
end

function utilityLib.ReverseArray(t)
	for i = 1, math.floor(#t/2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
	
	return t
end

function utilityLib.getNumInObj(obj,name)
	local i = 0
	for _,v in pairs(obj:GetChildren()) do
		if v.Name:find(name) then
			i += 1
		end
	end

	return i
end

function utilityLib.getModelMass(Obj)
	local Mass = 0
	for _,v in ipairs(Obj:GetChildren()) do
		if v:IsA"BasePart" and not v.Massless then
			Mass += v:GetMass()
		end
	end
	
	return Mass
end

function utilityLib.lookForAttribute(Folder,Attribute)
	for _,v in pairs(Folder:GetChildren()) do
		if v:GetAttribute(Attribute) then
			return v
		end
	end
	
	return false
end

function utilityLib.makeRayFromPos(...)
	local Info = ...;
	local Obj = Info.Obj

	local ray = RaycastParams.new()
	ray.FilterDescendantsInstances = Info.Filter
	ray.FilterType = Enum.RaycastFilterType[Info.FilterType]

	local originPos = typeof(Obj) == "Vector3" and Obj or Obj.Position

	local castRay = workspace:Raycast(originPos,Info.WhereTo,ray)
	
	local rayInstance,rayPos,rayNorm = nil,nil,nil
	if castRay then
		if castRay.Instance then
			rayInstance = castRay.Instance
		end
		if castRay.Position then
			rayPos = castRay.Position
		end
		if castRay.Normal then
			rayNorm = castRay.Normal
		end
	end

	return rayInstance,rayPos,rayNorm
end

function utilityLib.Raycast(...)
	local v88 = ...;
	local v89 = { workspace.CurrentCamera, workspace.Ignore, workspace:FindFirstChild("Mob_Spawns"), workspace:FindFirstChild("Mob_Spawns2") };
	if v88.Ignore then
		for v90, v91 in pairs(v88.Ignore) do
			table.insert(v89, v91);
		end;
	end;
	local v92 = v88.RaycastParams or RaycastParams.new();
	v92.FilterType = v88.FilterType or Enum.RaycastFilterType.Blacklist;
	v92.FilterDescendantsInstances = v89;
	local v93 = workspace:Raycast(v88.Origin, v88.Ray, v92);
	local v94 = v93 and v93.Instance;
	if v88.IgnoreNonCollisionMap and v94 and not v94.CanCollide and v94.Anchored and (not v88.RecursiveCount or v88.RecursiveCount < 10) and (not v94.Parent:FindFirstChild("Health") and not v94.Parent.Parent:FindFirstChild("Health")) then
		table.insert(v89, v94);
		v88.Ignore = v89;
		v88.RecursiveCount = v88.RecursiveCount and v88.RecursiveCount + 1 or 1;
		v88.RaycastParams = v92;
		return utilityLib.Raycast(v88);
	end;
	return v94, v93 and v93.Position, v93 and v93.Normal, v93 and v93.Distance;
end;

function utilityLib.isDecimal(num)
	return num % 1 > 0
end

function utilityLib.Round(num)
	return math.floor(num * 10) / 10
end

local rand = Random.new()
function utilityLib.Random(min,max,int)
	return ((min % 1 > 0 or int) and rand:NextNumber(min,max) or rand:NextInteger(min,max))
	--return (int and rand:NextInteger(min,max) or rand:NextNumber(min,max))
	--return min + math.random() * (max - min)   
end

function utilityLib.findInFolder(folder,name,bool)
	for _,v in pairs(folder:GetChildren()) do
		if (not bool and v.Name:lower():find(name) or v.Name:lower() == name:lower()) then
			return v
		end
	end
end

function utilityLib.findPlayer(Name)
	for _,v in pairs(game:GetService"Players":GetPlayers()) do
		if v.Name:lower():sub(1,#Name) == Name:lower() then--if v.Name:lower():find(Name:lower()) then
			return v
		end
	end
	
	return nil
end

function utilityLib.LookForValue(Folder,Val)
	for _,v in ipairs(Folder:GetChildren()) do
		if v.Value == Val then
			return v
		end
	end
	
	return nil
end

function utilityLib.EmitParticle(...)
	local Info = ...;
	local Obj = Info.Obj
	
	if Info.CFrame then
		Obj = Instance.new("Part")
		Obj.Name = "ParticlePart"
		Obj.Anchored = true
		Obj.Size = Vector3.new()
		Obj.CFrame = Info.CFrame
		Obj.CanCollide = false
		Obj.Transparency = 1
		Obj.Parent = workspace.Ignore
		--utilityLib.DelayDestroy(Obj,(Info.Lifetime or Info.Particle.Lifetime.Max)+1)
	end
	
	local Particle = Info.Particle:Clone()
	Particle.Color = Info.Color or Particle.Color
	Particle.Size = Info.Size or Particle.Size
	Particle.Transparency = Info.Transparency or Particle.Transparency
	Particle.Parent = Obj
	Particle:Emit(Info.Amount)
	
	utilityLib.DelayDestroy(Obj.Name == "ParticlePart" and Obj or Particle,Info.Lifetime or Particle.Lifetime.Max)
end

function utilityLib.Lerp(a,b,t)
	return a + (b - a) * t
end

function utilityLib.getYaw(vec)
	return -math.atan2(vec.Z, vec.X) - math.pi/2
end

function utilityLib.Invis(Obj,Invis)
	for _,v in pairs(Obj:GetDescendants()) do
		if (v:IsA"BasePart" or v:IsA"UnionOperation" or v:IsA"Decal") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = Invis and 1 or 0
		end
	end
end

function utilityLib.humanoidChecks(Char)
	if not Char then
		return false
	end
	local Hum = Char:FindFirstChildWhichIsA"Humanoid"
	if not Hum then
		return false
	end
	if Hum and (Hum.Health <= 0 or (Hum.SeatPart and Hum.Health ~= Hum.Health)) then
		return false
	end
	if game:GetService"CollectionService":HasTag(Char,"Stunned") then
		return false
	end
	if not Char:FindFirstChild"Head" then
		return false
	end
	
	return true
end

function utilityLib.getTargets(Char)
	local Table = {}
	
	local Plr = game:GetService"Players":GetPlayerFromCharacter(Char)
	if Char then
		local Children = workspace.Alive:GetChildren()
		for i=1,#Children do
			local Child = Children[i]
			if Child and Child:FindFirstChild"HumanoidRootPart" and Child:FindFirstChildWhichIsA"Humanoid" and Child.Humanoid.Health > 0 and not Child:FindFirstChildWhichIsA"ForceField" then
				table.insert(Table,Children[i].HumanoidRootPart)
			end
		end
	end
	
	return Table
end

function utilityLib.stringToCF(str)
	return CFrame.new(table.unpack(str:gsub(" ",""):split(",")))
end

function utilityLib.getInTable(Table,Name)
	for _,v in pairs(Table) do
		if _:lower() == Name then
			return v
		end
	end
end

function utilityLib.collisionGroupExists(Name)
	local Success = pcall(function()
		game:GetService"PhysicsService":IsCollisionGroupRegistered(Name)
	end)

	return Success
end

function utilityLib.ArraySelectRandom(array)
	if #array == 1 then
		return array[1]
	end

	local position = Random.new():NextInteger(1, #array)

	return array[position]
end

function utilityLib.DictionarySelectRandom(dictionary)
	local keys = {}

	for key, _ in pairs(dictionary) do
		table.insert(keys, key)
	end

	if #keys == 1 then
		local onlyKey = keys[1]
		return dictionary[onlyKey]
	end

	local position = Random.new():NextInteger(1, #keys)
	local key = keys[position]

	return dictionary[key]
end

function utilityLib.findInTable(tab,val,bool)
	for _,v in pairs(tab) do
		if (bool and v:lower():find(val:lower()) or v:lower() == val:lower()) then
		--if v:lower() == val then
			return v
		end
	end
end

function utilityLib.getCountTable(Tab,Name)
	local Amount = 0
	for _,v in pairs(Tab) do
		if v == Name then
			Amount += 1
		end
	end

	return Amount
end

function utilityLib.getCountFolder(Folder,Name)
	local Amount = 0
	for _,v in pairs(Folder:GetChildren()) do
		if v.Name == Name then
			Amount += 1
		end
	end

	return Amount
end

function utilityLib.getRandomPlr(ignorePlr)
	local plrList = Players:GetPlayers()
	if ignorePlr then
		table.remove(plrList,table.find(plrList,ignorePlr))
	end
	
	return plrList[math.random(#plrList)]
end

function utilityLib.ReturnWithUserId(userId)
	for _,v in ipairs(Players:GetPlayers()) do
		if v.UserId == tonumber(userId) then
			return v
		end
	end
	
	return nil
end

function utilityLib.removeSpaces(Str)
	return Str:gsub(" ","")
end

function utilityLib.roundNumber(Num,decimalPlaces)
	return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", Num))
end

function utilityLib.CheckTableEqual(t1,t2)
	if #t1~=#t2 then return false end
	for i=1,#t1 do if t1[i]~=t2[i] then return false end end
	return true
end

function utilityLib.CheckArrayEqual(arr1,arr2)
	for i, v in pairs(arr1) do
		if (typeof(v) == "table") then
			if (utilityLib.CheckArrayEqual(arr2[i], v) == false) then
				return false
			end
		else
			if (v ~= arr2[i]) then
				return false
			end
		end
	end
	return true
end

return utilityLib