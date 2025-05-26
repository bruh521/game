local _g = _G.MoonGlobal
local Themer = {}

------------------------------------------------------------
	local tween = game:GetService("TweenService")

	Themer._PaintMap = {}
	Themer._PaintedItemMap  = {}

	Themer._BuiltInThemes = {
		Default 	= {main = {246,142,31},  second = {172,99,21},   third = {123,71,15},  highlight = {52,144,174}, bg = {18,22,28}, text = {245,245,245}, _bgOuter = {"","Crop",1,"Default"}},
		Dark 	   	= {main = {178,187,193}, second = {108,113,117}, third = {70,74,76},   highlight = {174,102,66}, bg = {33,33,33}, text = {240,240,240}},
		Lunar 		= {main = {52,161,218},  second = {52,144,174},  third = {33,76,111},  highlight = {174,115,52}, bg = {18,22,61}, text = {245,245,245}, _bgOuter = {"rbxassetid://11869805803","Fit",1,"Pixelated"}},
		Subspace	= {main = {193,135,255}, second = {115,44,191},  third = {76,30,127},  highlight = {159,160,0},  bg = {12,0,36},  text = {225,219,244}},
	
		Taiga 	    = {main = {139,199,194}, second = {20,118,109},  third = {0,72,67},    highlight = {107,68,35},  bg = {0,19,15},  text = {232,247,250}},
		Blush 	    = {main = {255,122,146}, second = {169,80,95},   third = {118,56,66},  highlight = {213,36,107}, bg = {28,18,21}, text = {252,235,241}},
		Blonde 	    = {main = {255,144,95},  second = {184,103,68},  third = {127,72,47},  highlight = {29,109,157}, bg = {28,22,18}, text = {255,241,235}},	
		Wheat 	    = {main = {255,194,95},  second = {184,139,68},  third = {127,96,47},  highlight = {98,143,64},  bg = {28,24,18}, text = {255,247,235}},
		Gaia  		= {main = {128,184,129}, second = {62,111,63},   third = {29,77,30},   highlight = {0,131,139},  bg = {26,21,17}, text = {209,229,210}},
		Ares 	    = {main = {196,78,78},   second = {161,54,54},   third = {102,34,34},  highlight = {200,143,0},  bg = {28,18,18}, text = {227,226,225}},
		Aqua  = {main = {128,168,184}, second = {62,96,111},   third = {29,61,77},   highlight = {0,150,123},  bg = {18,19,28}, text = {209,226,229}},
		Energy 	    = {main = {227,227,0},   second = {191,169,0},   third = {127,113,0},  highlight = {27,170,0},   bg = {37,37,37}, text = {246,245,230}},
		Digital     = {main = {88,204,88},   second = {49,146,49},   third = {31,93,31},   highlight = {170,130,0},  bg = {32,32,32}, text = {218,243,218}},
		Fuchsia 	= {main = {255,135,251}, second = {191,44,187},  third = {127,30,124}, highlight = {0,124,127},  bg = {36,0,35},  text = {244,219,243}},
	}

	Themer.ThemeList = {
		"Taiga", "Blush", "Blonde", "Wheat", "Gaia", "Ares", "Aqua", "Energy", "Digital", "Fuchsia",
		"~",
		"Default", "Dark", "Lunar", "Subspace",
	}

	Themer.ColorList = {{"main", "main"}, {"second", "second"}, {"third", "third"}, {"highlight", "highlight"}, {"bg", "bg"}, {"text", "text"}}

	Themer._Theme = {}
	for paintName, paint in pairs(Themer._BuiltInThemes.Default) do
		if string.sub(paintName, 1, 1) == "_" then
			Themer._Theme[paintName] = {paint[1], paint[2], paint[3]}
		else
			Themer._Theme[paintName] = Color3.fromRGB(paint[1], paint[2], paint[3])
		end
	end

	Themer._TweenMap = {}
	Themer.QUICK_TWEEN = 0.06

	Themer.theme_changed = {}
	Themer.theme_buttons = {}

	local themes = {Default = true, Dark = true, Lunar = true, Subspace = true}
	local saved
------------------------------------------------------------
do
	function Themer:QuickTween(obj, tweenTime, propMap, slow_start)
		local getId = obj:GetDebugId(8)
		
		if obj:IsDescendantOf(game) and tweenTime and tweenTime > 0 then
			self._TweenMap[getId] = {tween:Create(obj, TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, slow_start == nil and Enum.EasingDirection.Out or Enum.EasingDirection.In), propMap), propMap}
			self._TweenMap[getId][1]:Play()
		else
			if self._TweenMap[getId] and self._TweenMap[getId][1].PlaybackState == Enum.PlaybackState.Playing then
				self._TweenMap[getId][1]:Cancel()
			end
			for prop, val in pairs(propMap) do
				obj[prop] = val
			end
		end
	end

	local uiGetT = {
		Frame = function(...) end,
		TextBox = function(map, ui, givenValue)
			map["TextTransparency"] = givenValue and givenValue or ui.TextTransparency
			map["TextStrokeTransparency"] = givenValue and givenValue or ui.TextStrokeTransparency
		end,
		ImageButton = function(map, ui, givenValue)
			map["ImageTransparency"] = givenValue and givenValue or ui.ImageTransparency
		end,
		SelectionBox = function(map, ui, givenValue)
			map["SurfaceTransparency"] = givenValue and givenValue or ui.SurfaceTransparency
		end,
		ScrollingFrame = function(map, ui, givenValue)
			map["ScrollBarImageTransparency"] = givenValue and givenValue or ui.ScrollBarImageTransparency
		end,
	}
	uiGetT.TextButton = uiGetT.TextBox
	uiGetT.TextLabel = uiGetT.TextBox
	uiGetT.ImageLabel = uiGetT.ImageButton
	uiGetT.ViewportFrame = uiGetT.ImageButton
	uiGetT.SelectionSphere = uiGetT.SelectionBox

	function Themer.GetTransparencyPropertyMap(ui, givenValue)
		local map = {BackgroundTransparency = givenValue and givenValue or ui.BackgroundTransparency}
		uiGetT[ui.ClassName](map, ui, givenValue)
		return map
	end

	local uiSetT = {
		Frame = function(...) end,
		TextBox = function(ui, value)
			ui.TextTransparency = value
			ui.TextStrokeTransparency = value
		end,
		ImageButton = function(ui, value)
			ui.ImageTransparency = value
		end,
		SelectionBox = function(ui, value)
			ui.SurfaceTransparency = value
		end,
		ScrollingFrame = function(ui, value)
			ui.ScrollBarImageTransparency = value
		end,
	}
	uiSetT.TextButton = uiSetT.TextBox
	uiSetT.TextLabel = uiSetT.TextBox
	uiSetT.ImageLabel = uiSetT.ImageButton
	uiSetT.ViewportFrame = uiSetT.ImageButton
	uiSetT.SelectionSphere = uiSetT.SelectionBox

	function Themer.SetUITransparency(ui, value)
		ui.BackgroundTransparency = value
		uiSetT[ui.ClassName](ui, value)
	end
end
------------------------------------------------------------
do
	function Themer:_paint(obj, paintData, tweenTime)
		if tweenTime == 0 then
			tweenTime = nil
		end
		for prop, paintName in pairs(paintData) do
			self:QuickTween(obj, tweenTime, {[prop] = self._Theme[paintName]})
		end
	end

	function Themer:AddPaintedItem(obj, paintData)
		local getId = obj:GetDebugId(8)
		assert(self._PaintMap[getId] == nil, "Object already exists in the Themer system.")

		self._PaintMap[getId] = paintData
		self._PaintedItemMap[getId]  = obj
		self:_paint(obj, paintData)
	end
	function Themer:RemovePaintedItem(obj)
		local getId = obj:GetDebugId(8)
		assert(self._PaintMap[getId] ~= nil, "Object does not exist in the Themer system.")

		if self._TweenMap[getId] then
			self._TweenMap[getId][1]:Cancel()
			for prop, val in pairs(self._TweenMap[getId][2]) do
				obj[prop] = val
			end
			self._TweenMap[getId] = nil
		end
		self._PaintMap[getId] = nil
		self._PaintedItemMap[getId]  = nil
	end

	function Themer:SetItemPaint(obj, newPaintData, tweenTime)
		local getId = obj:GetDebugId(8)
		assert(self._PaintMap[getId] ~= nil, "Object does not exist in the Themer system.")

		local getItemPaintData = self._PaintMap[getId]
		for prop, paintName in pairs(newPaintData) do
			if getItemPaintData[prop] then
				getItemPaintData[prop] = paintName
			end
		end
		self:_paint(obj, getItemPaintData, tweenTime)
	end
end
------------------------------------------------------------
do
	function Themer:_paintAll(noTween)
		for itemId, paintData in pairs(self._PaintMap) do
			self:_paint(self._PaintedItemMap[itemId],  paintData, noTween and 0 or 0.4)
		end
	end

	function Themer:SetTheme(newTheme)
		if newTheme == nil then
			newTheme = _g.Themer._BuiltInThemes.Default
		elseif type(newTheme) == "string" then
			if themes[newTheme] == nil then saved = newTheme return false end
			newTheme = _g.Themer._BuiltInThemes[newTheme]
		end
		
		local no_tween = newTheme == _g.Themer._BuiltInThemes.Default or newTheme == _g.Themer._BuiltInThemes.Dark or newTheme == _g.Themer._BuiltInThemes.Lunar or newTheme == _g.Themer._BuiltInThemes.Subspace

		_g.Mouse.Icon = ""
		for paintName, paint in pairs(newTheme) do
			if paintName == "locked" then paintName = "highlight" end
			if self._BuiltInThemes.Default[paintName] then
				self._Theme[paintName] = Color3.fromRGB(paint[1], paint[2], paint[3])
			end
		end
		self:_paintAll(no_tween)
		for _, f in pairs(self.theme_changed) do
			f(newTheme, no_tween)
		end
	end
	
	local count = 0
	function Themer:AddTheme(theme)
		if themes[theme] or self.theme_buttons[theme] == nil then return end
		themes[theme] = true
		count = count + 1
		for _, mi in pairs(self.theme_buttons[theme]) do
			mi.price_frame.Icon.TextTransparency = 1
			mi.price_frame.Label.TextTransparency = 1
		end
		if saved == theme then
			self:SetTheme(theme)
		end
		if count == 10 then
			for _, tbl in pairs(self.theme_buttons) do
				for _, mi in pairs(tbl) do
					mi.Menu.sized = false
					mi.price_frame.Icon.Visible = false
					mi.price_frame.Label.Visible = false
					mi.price_frame.Frame3.Size = UDim2.new(0, 14, 1, 0)
				end
			end
		end
	end
end

return Themer
