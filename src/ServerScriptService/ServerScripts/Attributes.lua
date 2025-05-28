local module = {}


function module.AddWalkSpeed(plr,stuff)
	local info = stuff or {}

	if plr.Character:FindFirstChild('Humanoid') then
		local info = stuff or {}
		local curSpeed = plr.Character.WalkSpeed.Value
		local Modifier = tonumber(info.Speed)
		local Duration = tonumber(info.Duration)
		plr.Character.WalkSpeed.Value = curSpeed+Modifier
		local NEG = curSpeed+Modifier
		if Duration == nil then return end 
		task.wait(Duration)
		local afterSpeed = NEG-Modifier
		plr.Character.WalkSpeed.Value = afterSpeed

	end
end



function module.AddJumpPower(plr,stuff)
	local info = stuff or {}

	if plr.Character:FindFirstChild('Humanoid') then
		local info = stuff or {}
		local curSpeed = plr.Character.JumpPower.Value
		local Modifier = tonumber(info.JumpPower)
		local Duration = tonumber(info.Duration)
		plr.Character.JumpPower.Value = curSpeed+Modifier
		local NEG = curSpeed+Modifier
		if Duration == nil then return end 
		task.wait(Duration)
		local afterSpeed = NEG-Modifier
		plr.Character.JumpPower.Value = afterSpeed
	end
end



























return module
