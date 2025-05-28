local module = {}

local  module2 = {} 
	

--[[
local function module.WalkSpeed(c)
	if c:FindFirstChild("Humanoid") then
		local hum = c.Humanoid
		hum.AttributeChanged:Connect(function(a)
			hum.WalkSpeed = hum:GetAttribute("WalkSpeed") 
		end)
	end
end
-- TODO dont make them all seperate events, combine into one
local function JumpHeight(c)
	if c:FindFirstChild("Humanoid") then
		local hum = c.Humanoid
		hum.AttributeChanged:Connect(function(a)
			hum.JumpPower = hum:GetAttribute("JumpHeight") 
		end)
	end
end
local function Health(c)
	if c:FindFirstChild("Humanoid") then
		local hum = c.Humanoid
		hum.AttributeChanged:Connect(function(a)
			hum.Health = hum:GetAttribute("Health") 
		end)
	end
end
]]


function module2.Health(c)
	c.Humanoid.Health = c.Humanoid:GetAttribute("Health") 
end
function module2.WalkSpeed(c)
	c.Humanoid.WalkSpeed = c.Humanoid:GetAttribute("WalkSpeed") 
end
function module2.JumpHeight(c)
	c.Humanoid.JumpHeight = c.Humanoid:GetAttribute("JumpHeight") 
end


function module.WatchAttributes(char)
	if char:FindFirstChild("Humanoid") then
	char.Humanoid.AttributeChanged:Connect(function(erm)
		if module2[erm](char) then 	
			module2[erm](char) end -- test
	end)
	end
end

return module
