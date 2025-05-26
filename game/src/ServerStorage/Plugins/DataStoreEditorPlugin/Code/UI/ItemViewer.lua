local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local ThemeContext = require(script.Parent.ThemeContext)
local ExpandableInputBox = require(script.Parent.ExpandableInputBox)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local TextSize = require(script.Parent.Parent.Plugin.TextSize)

local DataNil = Constants.DataNil

local TweenService = game:GetService("TweenService")

local ItemViewer = Roact.PureComponent:extend("ItemViewer")

local LEVEL_SPACING = 16
local SIZE_Y = 24
local FONT_FACE = Constants.Font.Mono
local TEXT_SIZE = 15

local DOUBLE_CLICK_INTERVAL = 0.5

local TEXT_COLORS = {
	"DialogMainButton",
	"SensitiveText",
	"WarningText",
}

local function IsNaN(n)
	return type(n) == "number" and n ~= n
end

local function FormatValue(value, t)
	if t == "string" then
		return '"' .. value:gsub("\r", "\\r"):gsub("\n", "\\n") .. '"'
	elseif t == "table" then
		if #value > 0 then
			return "array"
		elseif next(value) ~= nil then
			return "dict"
		else
			return "table"
		end
	elseif IsNaN(value) then
		return "NAN"
	else
		return tostring(value)
	end
end

local function FormatValueForTextBox(value)
	local t = type(value)
	if t == "string" and tonumber(value) then
		value = ('"' .. value .. '"')
	end
	return tostring(value)
end

local function FormatKey(key)
	if type(key) == "number" then
		return (tostring(key) .. ")")
	elseif type(key) == "string" then
		if key == "" or key:sub(1, 1) == " " or key:sub(#key) == " " then
			return ('"' .. key .. '"')
		end
		return key
	else
		return tostring(key)
	end
end

function ItemViewer:init()
	self:setState({
		LastValueClick = 0,
		ShowEditor = false,
		Value = self.props.Value,
		IsExpanded = false,
		ValueDisplay = "",
		KeyDisplay = "",
	})
	self.CaretRef = Roact.createRef()
	self.KeyDisplayWidth, self.SetKeyDisplayWidth = Roact.createBinding(0)
	self.ValDisplayWidth, self.SetValDisplayWidth = Roact.createBinding(0)
	self:setTexts()
	self:getTextSizes()
end

function ItemViewer:tweenCaret(instant)
	if self._tweenCaret then
		self._tweenCaret:Destroy()
	end
	if instant then
		self.CaretRef:getValue().Rotation = self.props.CaretRotation
		return
	end
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.CaretRef:getValue(), tweenInfo, { Rotation = self.props.CaretRotation })
	self._tweenCaret = tween
	tween:Play()
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			tween:Destroy()
			self._tweenCaret = nil
		end
	end)
end

function ItemViewer:getTextSizes()
	local keyDisplay = self.state.KeyDisplay
	local valueDisplay = self.state.ValueDisplay
	task.spawn(function()
		local keyDisplayWidth = TextSize.calcWidth(FONT_FACE, keyDisplay, TEXT_SIZE)
		local valueDisplayWidth = TextSize.calcWidth(FONT_FACE, valueDisplay, TEXT_SIZE)
		self.SetKeyDisplayWidth(keyDisplayWidth)
		self.SetValDisplayWidth(valueDisplayWidth)
	end)
end

function ItemViewer:setTexts()
	local valueType = type(self.state.Value)
	local valueDisplay = (
		(self.state.Value == DataNil or self.state.Value == nil) and "No data"
		or FormatValue(self.state.Value, valueType)
	)
	local keyDisplay = FormatKey(self.props.Key)
	self:setState({ ValueDisplay = valueDisplay, KeyDisplay = keyDisplay })
end

function ItemViewer:didMount()
	if self.props.ShowCaret then
		self:tweenCaret(true)
	end
end

function ItemViewer:didUpdate(prevProps, prevState)
	if prevProps.CaretRotation ~= self.props.CaretRotation and self.props.ShowCaret then
		self:tweenCaret(false)
	end
	local prevNaN = IsNaN(prevProps.Value)
	local nextNaN = IsNaN(self.props.Value)
	local bothNaN = (prevNaN and nextNaN)
	if prevProps.Value ~= self.props.Value and not bothNaN and self.state.Value ~= self.props.Value then
		self:setState({ Value = self.props.Value })
	end

	if prevState.Value ~= self.state.Value or prevProps.Key ~= self.props.Key then
		self:setTexts()
	end

	if prevState.ValueDisplay ~= self.state.ValueDisplay or prevState.KeyDisplay ~= self.state.KeyDisplay then
		self:getTextSizes()
	end
end

function ItemViewer:submit(text)
	if type(self.props.SubmitChange) == "function" then
		local newValue = self.props.SubmitChange(text)
		if not self.props.NoSave then
			if newValue ~= self.state.Value then
				self.props.MarkDirty()
			end
		end
		self:setState({ Value = newValue })
	end
end

function ItemViewer:render()
	local startExpanded = (type(self.state.Value) == "string" and self.state.Value:find("\n") ~= nil)
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			local padding = ((self.props.Level + 1) * LEVEL_SPACING)
			local valueType = type(self.state.Value)
			local keyDisplay = self.state.KeyDisplay
			local valueDisplay = self.state.ValueDisplay
			local typeColor
			do
				if valueType == "number" then
					typeColor = theme.ChatModeratedMessageColor.Default
				elseif valueType == "string" then
					typeColor = theme.InfoText.Default
				elseif valueType == "boolean" then
					typeColor = theme.LinkText.Default
				elseif valueType == "table" then
					typeColor = theme.SubText.Default
				end
			end
			local caret
			local lines = {}
			if self.props.ShowCaret then
				caret = Roact.createElement("ImageButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -5, 0.5, 0),
					Size = UDim2.new(0, 6, 0, 6),
					Image = "rbxassetid://5076805718",
					ImageColor3 = theme.MainText.Default,
					ImageTransparency = (self.props.CaretDisabled and 0.7 or 0),
					LayoutOrder = 0,
					[Roact.Event.Activated] = function()
						if self.props.CaretDisabled then
							return
						end
						if type(self.props.OnClicked) == "function" then
							self.props.OnClicked()
						end
					end,
					[Roact.Ref] = self.CaretRef,
				})
			end
			if self.props.Level > 1 then
				for l = (self.props.ShowCaret and 2 or 1), self.props.Level - 1 do
					lines[l] = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = theme.Separator.Default,
						BackgroundTransparency = 0.5,
						BorderSizePixel = 0,
						Position = UDim2.new(1, (-LEVEL_SPACING * (l + 0)), 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
					})
				end
			end
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 0),
				LayoutOrder = self.props.LayoutOrder or 0,
				Visible = (self.props.Visible == nil and true or not not self.props.Visible),
			}, {
				Key = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = self.KeyDisplayWidth:map(function(width)
						return UDim2.new(0, padding + width, 0, SIZE_Y)
					end),
					LayoutOrder = 0,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					Spacer = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, padding, 1, 0),
					}, lines),
					KeyLabel = Roact.createElement("TextButton", {
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = self.KeyDisplayWidth:map(function(width)
							return UDim2.new(0, width, 0, SIZE_Y)
						end),
						FontFace = FONT_FACE,
						TextColor3 = self.props.Level
								and theme[TEXT_COLORS[((self.props.Level - 1) % #TEXT_COLORS) + 1]].Default
							or theme.DialogMainButton.Default,
						TextSize = TEXT_SIZE,
						Text = keyDisplay,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 1,
						[Roact.Event.Activated] = function()
							if self.props.CaretDisabled then
								return
							end
							if type(self.props.OnClicked) == "function" then
								self.props.OnClicked()
							end
						end,
						[Roact.Event.MouseButton2Up] = function(rbx, x, y)
							if type(self.props.RightClicked) == "function" then
								self.props.RightClicked(x, y, rbx)
							end
						end,
					}, {
						Caret = caret,
					}),
				}),
				Value = Roact.createElement("TextButton", {
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					Size = self.ValDisplayWidth:map(function(width)
						return UDim2.new(0, width, 0, SIZE_Y)
					end),
					FontFace = FONT_FACE,
					TextColor3 = typeColor or theme.MainText.Default,
					TextSize = TEXT_SIZE,
					Text = valueDisplay,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2,
					Visible = not self.state.ShowEditor,
					[Roact.Event.Activated] = function()
						if self.props.ShowCaret then
							return
						end
						local now = os.clock()
						local sinceLastClick = (now - self.state.LastValueClick)
						local showEditor = (sinceLastClick < DOUBLE_CLICK_INTERVAL)
						self:setState({
							LastValueClick = now,
							ShowEditor = showEditor,
							IsExpanded = (showEditor and startExpanded),
						})
					end,
				}),
				Editor = Roact.createElement(ExpandableInputBox, {
					Key = keyDisplay,
					Placeholder = "Value",
					Width = 200,
					Text = FormatValueForTextBox(self.state.Value),
					Font = Constants.Font.Mono,
					LayoutOrder = 2,
					Visible = self.state.ShowEditor,
					ForceFocus = self.state.ShowEditor,
					FilterText = self.props.FilterText,
					ForceExpanded = self.state.IsExpanded,
					OnExpand = function(isExpanded)
						self:setState({ IsExpanded = isExpanded })
					end,
					OnSet = function(text)
						self:submit(text)
						self:setState({ ShowEditor = false })
					end,
					OnCancel = function()
						if startExpanded then
							self:setState({ ShowEditor = false })
						end
					end,
					OnInput = function(_text) end,
					OnFocusLost = function(submitted, text, rbx)
						if submitted then
							self:submit(text)
						else
							task.wait(0.1)
							if self.state.IsExpanded or rbx:IsFocused() then
								return
							end
						end
						self:setState({ ShowEditor = false })
					end,
				}),
			})
		end,
	})
end

ItemViewer = RoactRodux.connect(function(_state)
	return {}
end, function(dispatch)
	return {
		MarkDirty = function()
			dispatch({ type = "MarkDirty" })
		end,
	}
end)(ItemViewer)

return ItemViewer