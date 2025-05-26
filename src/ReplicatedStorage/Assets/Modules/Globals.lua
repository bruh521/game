local module = {}
	

function module.FocusCam(...)
	local Info = ...;
	local Obj = Info.Object
	local Tween = Info.Tween

	local focusCam = typeof(Obj) == "Instance" and Instance.new("ObjectValue") or typeof(Obj) == "CFrame" and Instance.new("CFrameValue") or nil
	focusCam.Name = "FocusCam"
	focusCam.Value = Obj

	if Tween then
		focusCam:SetAttribute("Tween",Tween)

		if Info.Destroy then
			focusCam:SetAttribute("Destroy",Info.Destroy)
		end
	end

	return focusCam
end



return module