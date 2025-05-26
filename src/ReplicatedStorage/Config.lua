local module = {}

module.CharAttributes = {
	["WalkSpeed"] = {
		Default = 18,
	},
	["JumpHeight"] = {
		Default = 7.2,
	},
	["Health"] = {
		Default = 100,
	},
	["RespawnTime"] = {
		Default = 0,
	},
}
module.DefaultSettings = {
	["BGMVol"] = {
		Default = 50,
	},
}

module.Admins = {
	152124807, -- my one and only
	265301504, -- me
}
module.BGMVals = {
	["TweenTime"] = 4,
	["WeatherTweenTime"] = 3,
	
}
-- fix 
module.DefaultSize = {
	["BodyTypeScale"] = 0,
	["DepthScale"] = 1,
	["HeadScale"] = .95,
	["HeightScale"] = .95,
	["ProportionScale"] = 0,
	["WidthScale"] = .75,
	--["Face"] = 0,
	--	["RightLeg"] = 0,
	--	["LeftArm"] = 0,
	--	["LeftLeg"] = 0,
	--["Torso"] = 0,
	--	["RightArm"] = 0,
}


module.BannedThings = {
	["RightFoot"] = "RightLeg",
	["RightLowerLeg"] = "RightLeg",
	["RightUpperLeg"] = "RightLeg",
	["LeftFoot"] = "LeftLeg",
	["LeftLowerLeg"] = "LeftLeg",
	["LeftUpperLeg"] = "LeftLeg",
	["UpperTorso"] = "Torso",
	["LowerTorso"] = "Torso", -- test file line
	
}


module.BannedThingsNum = 5637151279

return module


--[[module.DefaultSize = {
	["BodyTypeScale"] = 0,
	["DepthScale"] = 1,
	["HeadScale"] = 1,
	["HeightScale"] = 1,
	["ProportionScale"] = 0,
	["WidthScale"] = 1,
	["Face"] = 0,
	["LeftArm"] = 0,
	["LeftLeg"] = 0,
	["RightLeg"] = 0,
	["Torso"] = 0,
	["RightArm"] = 0,
}

]]
