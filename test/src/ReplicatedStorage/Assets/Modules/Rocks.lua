local Rocks = {}

local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local Modules = RS:WaitForChild"Assets":WaitForChild"Modules"
local partCacheMod = require(Modules:WaitForChild"PartCache")

local cacheFolder
if not workspace:FindFirstChild("Ignore") then
	cacheFolder = Instance.new("Folder")
	cacheFolder.Name = "Ignore"
	cacheFolder.Parent = workspace
else
	cacheFolder = workspace.Ignore
end

local partCache = partCacheMod.new(Instance.new("Part"), 1000, cacheFolder)

function Rocks.Ground(Pos, Distance, Size, filter, MaxRocks, Ice, despawnTime)
	local random = Random.new()
	
	local angle = 30
	local otherAngle = 360/MaxRocks
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Whitelist
	params.FilterDescendantsInstances = {workspace.Map}
	local size
	size = Size or Vector3.new(2, 2, 2)
	local pos = Pos
	despawnTime = despawnTime or 3

	local function OuterRocksLoop ()
		for i = 1, MaxRocks do
			local cf = CFrame.new(Pos)
			local newCF = cf * CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0) * CFrame.new(Distance/2 + Distance/2.7, 10, 0)
			local ray = workspace:Raycast(newCF.Position, Vector3.new(0, -20, 0), params)
			angle += otherAngle
			if ray then
				local part = partCache:GetPart()
				local hoof = partCache:GetPart()
				
				part.CFrame = CFrame.new(ray.Position - Vector3.new(0, 0.5, 0), Pos) * CFrame.fromEulerAnglesXYZ(random:NextNumber(-.25, .5), random:NextNumber(-.25, .25), random:NextNumber(-.25, .25))
				part.Size = Vector3.new(size.X * 1.3, size.Y/1.4, size.Z * 1.3) * random:NextNumber(1, 1.5)
				
				hoof.Size = Vector3.new(part.Size.X * 1.01, part.Size.Y * 0.25, part.Size.Z * 1.01)
				hoof.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 - hoof.Size.Y / 2.1, 0)
				
				part.Parent = cacheFolder
				hoof.Parent = cacheFolder
				
				if ray.Instance.Material == Enum.Material.Concrete or ray.Instance.Material == Enum.Material.Air or ray.Instance.Material == Enum.Material.Wood or ray.Instance.Material == Enum.Material.Neon or ray.Instance.Material == Enum.Material.WoodPlanks then
					part.Material = ray.Instance.Material	
					hoof.Material = ray.Instance.Material	
				else
					part.Material = ray.Instance.Material	
					hoof.Material = ray.Instance.Material	
				end

				part.BrickColor = ray.Instance.BrickColor
				part.Anchored = true
				part.CanTouch = false
				part.CanCollide = false

				hoof.BrickColor = ray.Instance.BrickColor
				hoof.Anchored = true
				hoof.CanTouch = false
				hoof.CanCollide = false
				
				task.delay(despawnTime, function()
					TS:Create(part,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01)}):Play()
					TS:Create(hoof,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01), CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 - part.Size.Y / 2.1, 0)}):Play()
					
					task.delay(0.6, function()
						partCache:ReturnPart(part)
						partCache:ReturnPart(hoof)
					end)
				end)
			end		
		end
	end

	local function InnerRocksLoop ()
		for i = 1, MaxRocks do
			local cf = CFrame.new(Pos)
			local newCF = cf * CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0) * CFrame.new(Distance/2 + Distance/10, 10, 0)
			local ray = game.Workspace:Raycast(newCF.Position, Vector3.new(0, -20, 0), params)
			angle += otherAngle
			if ray then
				local part = partCache:GetPart()
				local hoof = partCache:GetPart()

				part.CFrame = CFrame.new(ray.Position - Vector3.new(0, size.Y * 0.4, 0), Pos) * CFrame.fromEulerAnglesXYZ(random:NextNumber(-1,-0.3),random:NextNumber(-0.15,0.15),random:NextNumber(-.15,.15))
				part.Size = Vector3.new(size.X * 1.3, size.Y * 0.7, size.Z * 1.3) * random:NextNumber(1, 1.5)

				hoof.Size = Vector3.new(part.Size.X * 1.01, part.Size.Y * 0.25, part.Size.Z * 1.01)
				hoof.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 - hoof.Size.Y / 2.1, 0)

				part.Parent = cacheFolder
				hoof.Parent = cacheFolder

				if ray.Instance.Material == Enum.Material.Concrete or ray.Instance.Material == Enum.Material.Air or ray.Instance.Material == Enum.Material.Wood or ray.Instance.Material == Enum.Material.Neon or ray.Instance.Material == Enum.Material.WoodPlanks then
					part.Material = ray.Instance.Material	
					hoof.Material = ray.Instance.Material	
				else
					part.Material = ray.Instance.Material --ray.Instance.Material	
					hoof.Material = ray.Instance.Material	
				end

				part.BrickColor = ray.Instance.BrickColor
				part.Anchored = true
				part.CanTouch = false
				part.CanCollide = false

				hoof.BrickColor = ray.Instance.BrickColor
				hoof.Anchored = true
				hoof.CanTouch = false
				hoof.CanCollide = false


				task.delay(despawnTime, function()
					TS:Create(part,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01)}):Play()
					TS:Create(hoof,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01), CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 - part.Size.Y / 2.1, 0)}):Play()

					task.delay(0.6, function()
						partCache:ReturnPart(part)
						partCache:ReturnPart(hoof)
					end)
				end)
			end		
		end
	end
	InnerRocksLoop()
	OuterRocksLoop()
end

return Rocks
