local CS = game:GetService("CollectionService")

local module = {}
local ranNum = math.random
function module.getRandomItem(list) -- total can be above 100
	local Sum = 0
	for i,v in pairs(list) do
		Sum += v
	end
	local Chance = ranNum(Sum)
	local Count = 0
	for i,v in pairs(list) do
		Count += v
		if Chance <= Count then
			return i, v
		end
	end
end
function module.getLargestValue(leTable)
	local currentLargestVal = 0
	local currentLargest
	
	for i,v in pairs(leTable) do
		if v >= currentLargestVal then
			currentLargestVal = v
			currentLargest = i
		end
	end
	
	return currentLargest, currentLargestVal
end
function module.createCircle(position,points,distance)
	local posTable = {}
	for point = 1, points do
		local gapDegree = 360/points * point
		local x = math.cos(math.rad(gapDegree)) * distance + position.X
		local z = math.sin(math.rad(gapDegree)) * distance + position.Z

		table.insert(posTable,Vector3.new(x,position.Y,z))
	end
	return posTable
end

function module.RayCastOnMap(origin,direction,returnAll)
	local raycastSettings = RaycastParams.new()
	raycastSettings.FilterDescendantsInstances = {workspace.Map}
	raycastSettings.FilterType = Enum.RaycastFilterType.Include
	local ray = workspace:Raycast(origin, direction, raycastSettings)

	if returnAll then return ray end
	if ray then
		return ray.Position
	else
		return origin
	end
end
function module.createTween(length,style,direction,repeats,revert,delaytime)
	local tween = TweenInfo.new(
		length,
		Enum.EasingStyle[style],
		Enum.EasingDirection[direction],
		repeats,
		revert,
		delaytime
	)
	return tween
end
function module.spawnVFX(object,info,properties,keepBool)
	local tween = game:GetService("TweenService"):Create(object,info,properties)
	tween:Play()
	if not keepBool or keepBool == nil then
		coroutine.resume(coroutine.create(function()
			tween.Completed:Connect(function()
				if not object or not object.Parent then return end
				if object.Parent ~= workspace.Ignore then
					object.Parent:Destroy()
				else
					object:Destroy()
				end
			end)
		end))
	end
end
function module.spawnRubble(Object,ObjPosition,Settings)
	local _Settings = Settings or {}
	local origPos = _Settings.origPos
	local travelDistance = _Settings.Range or 1
	local Duration = _Settings.Duration or 1
	local Speed = _Settings.Speed or 0.5
	local Size = _Settings.Size or Vector3.new(1,1,1)
	local newSize = _Settings.newSize or _Settings.Size or Vector3.new(1,1,1)
	
	local Debris = Instance.new("Part")
	Debris.Size = Size
	Debris.Anchored = true
	Debris.CanCollide = false
	Debris.Position = ObjPosition
	Debris.Material = Object.Material
	Debris.Color = Object.Color
	Debris.Parent = workspace.Ignore
	local dir = (ObjPosition-origPos).Unit
	local newPos = Debris.Position + dir*travelDistance*Vector3.new(1,0,1)
	coroutine.resume(coroutine.create(function()
		module.spawnVFX(Debris,module.createTween(Speed,"Exponential","Out",0,false,0),{Size = newSize, Position = newPos, Orientation = Vector3.new(ranNum(0,255),ranNum(0,255),ranNum(0,255))},true)
		--local CT = os.clock()
		--repeat 
		--	wait(0.25)
		--	local _,newPart = module.RayCastOnMap(Debris.Position + Vector3.new(0,Debris.Size.Y/2,0),Vector3.new(0,-(Debris.Size.Y/2 + 2),0))
		--	if newPart then
		--		Debris.Material = newPart.Material
		--		Debris.Color = newPart.Color
		--	end
		--until (os.clock()-CT >= Duration)
		wait(Duration) -- remove if use above
		module.spawnVFX(Debris,module.createTween(Speed,"Exponential","In",0,false,0),{Size = Debris.Size/15},false)
	end))
end
function module.lerpPosition(pos1,pos2,fraction)
	local X = pos1.X + (pos2.X-pos1.X) * fraction
	local Y = pos1.Y + (pos2.Y-pos1.Y) * fraction
	local Z = pos1.Z + (pos2.Z-pos1.Z) * fraction
	return Vector3.new(X,Y,Z)
end

function module.CheckStunned(Character)
	if CS:HasTag(Character,"Stunned") or CS:HasTag(Character,"Disabled") then
		return true
	end
end

function module:FastCastRay(Origin, Direction)
	local _debug = false

	local Settings = RaycastParams.new()
	Settings.FilterDescendantsInstances = {workspace.Map}
	Settings.FilterType = Enum.RaycastFilterType.Include

	local Ray = workspace:Raycast(Origin, Direction, Settings)

	if Ray then
		return Ray.Position
	else
		return Origin + Direction
	end
end

return module
