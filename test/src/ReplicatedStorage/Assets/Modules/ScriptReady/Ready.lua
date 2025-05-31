return {
	Ready = function()
		local LP = game:GetService"Players".LocalPlayer
		while true do
			if LP:GetAttribute"Loaded" then
				break
			end
			wait()
		end
		local Char = LP.Character or LP.CharacterAdded:Wait()
		while true do
			if Char:FindFirstChildWhichIsA"Humanoid" then
				break
			end
			if Char.Parent then
				break
			end
			wait()
		end

		while not Char.Parent do
			LP.Character.AncestryChanged:Wait()
		end
		while true do
			if Char.Parent == workspace.Alive and game:GetService"ReplicatedStorage":FindFirstChild"Assets" and game:GetService"ReplicatedStorage".Assets:FindFirstChild"Objects" then
				break
			end
			wait()
		end

		Char:WaitForChild"Humanoid":WaitForChild"Animator"

		return LP,Char,Char:WaitForChild"Humanoid",Char:WaitForChild"HumanoidRootPart"
	end,
}