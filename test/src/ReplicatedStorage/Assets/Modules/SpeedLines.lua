local SpeedLines = {}

local Modules = game:GetService"ReplicatedStorage":WaitForChild"Assets":WaitForChild"Modules"
local utilityLib = require(Modules:WaitForChild"UtilityLib")
local CS = game:GetService"CollectionService"

function SpeedLines.Start(Obj)
	if not CS:HasTag(Obj,"SpeedLines") then
		CS:AddTag(Obj,"SpeedLines")
		
		local Lines = game:GetService"ReplicatedStorage".Assets.Objects.Misc.speed_lines:Clone()
		Lines.Name = "SpeedLines" .. Obj.Name
		Lines.Parent = workspace.Ignore
		
		local objVal = Instance.new("ObjectValue")
		objVal.Name = "SpeedLines"
		objVal.Value = Lines
		objVal.Parent = Obj
		
		local Weld = utilityLib.Weld(Obj.HumanoidRootPart,Lines,CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
		Weld.Name = "Weld"
		Weld.Parent = Lines
	end
end

function SpeedLines.End(Obj)
	CS:RemoveTag(Obj,"SpeedLines")
	
	for _,v in ipairs(Obj:GetChildren()) do
		if v.Name == "SpeedLines" then
			local Val = v.Value
			Val.Speed.Enabled = false
			Val.Speed2.Enabled = false
			utilityLib.DelayDestroy(Val,3)
			v:Destroy()
			Val.Weld:Destroy()
			Val.Anchored = true
		end
	end
end

return SpeedLines