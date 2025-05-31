local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)

local TweenService = game:GetService("TweenService")

local InputBox = Roact.Component:extend("InputBox")

function InputBox:init()
	self.TextBoxRef = Roact.createRef()
	self.UnderlineRef = Roact.createRef()
	self.ClearRef = Roact.createRef()
	self._tweenLine = nil
	self:setState({
		InputText = self.props.Text or "",
	})
end

function InputBox:tweenLine(show)
	local line = self.UnderlineRef:getValue()
	if not line then
		return
	end
	line.Visible = true
	if self._tweenLine then
		self._tweenLine:Destroy()
	end
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(line, tweenInfo, {
		Size = show and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 0),
	})
	tween:Play()
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			if not show then
				line.Visible = false
			end
			self._tweenLine = false
		end
	end)
	self._tweenLine = tween
end

function InputBox:willUpdate(nextProps)
	if self.props.Active ~= nextProps.Active then
		local textBox = self.TextBoxRef:getValue()
		if (not nextProps.Active) and textBox:IsFocused() then
			textBox:ReleaseFocus()
		end
	end
end

function InputBox:checkForceFocus()
	if self.props.ForceFocus then
		local textBox = self.TextBoxRef:getValue()
		if textBox then
			textBox:CaptureFocus()
		end
	end
end

function InputBox:didMount()
	self:checkForceFocus()
end

function InputBox:didUpdate()
	self:checkForceFocus()
end

function InputBox:render()
	local expandable = (type(self.props.OnExpand) == "function")
	local width = self.props.Width
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = self.props.Size or UDim2.new(width and 0 or 1, width or 0, 0, 30),
		LayoutOrder = self.props.LayoutOrder or 0,
		Visible = (self.props.Visible == nil and true or not not self.props.Visible),
	}, {
		InputFrameBorder = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = theme.InputFieldBorder.Default,
					BorderSizePixel = 0,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					InputFrame = Roact.createElement("Frame", {
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundColor3 = theme.InputFieldBackground.Default,
						BorderSizePixel = 0,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 7),
						}),
						UIPadding = Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
						}),
						TextBox = Roact.createElement("TextBox", {
							BackgroundTransparency = 1,
							ClearTextOnFocus = false,
							Size = UDim2.new(1, (expandable and -40 or -20), 1, 0),
							FontFace = self.props.Font or Constants.Font.Regular,
							PlaceholderColor3 = theme.DimmedText.Default,
							PlaceholderText = self.props.Placeholder or "",
							Text = self.props.Text or "",
							TextColor3 = theme.MainText.Default,
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							ClipsDescendants = true,
							Visible = (self.props.Active == nil and true or not not self.props.Active),
							[Roact.Ref] = self.TextBoxRef,
							[Roact.Event.Focused] = function()
								self:tweenLine(true)
							end,
							[Roact.Event.FocusLost] = function(rbx, submitted)
								self:tweenLine(false)
								if type(self.props.OnFocusLost) == "function" then
									local clearText = self.props.OnFocusLost(submitted, rbx.Text, rbx)
									if clearText then
										rbx.Text = ""
									end
								end
							end,
							[Roact.Change.Text] = function(rbx)
								local text = rbx.Text
								if text:sub(#text) == "\r" then
									text = text:sub(1, #text - 1)
									rbx.Text = text
									return
								end
								if self.props.MaxCharacters and #text > self.props.MaxCharacters then
									text = text:sub(1, self.props.MaxCharacters)
									rbx.Text = text
									return
								end
								self:setState({ InputText = text })
								if self.props.FilterText then
									local newText = self.props.FilterText(text)
									if newText ~= text then
										rbx.Text = newText
										return
									end
								end
								if type(self.props.OnInput) == "function" then
									self.props.OnInput(text)
								end
								local clearBtn = self.ClearRef:getValue()
								if clearBtn then
									if rbx.Text == "" then
										clearBtn.Text = ""
									else
										clearBtn.Text = "X"
									end
								end
							end,
						}),
						LabelMirror = Roact.createElement("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -20, 1, 0),
							FontFace = self.props.Font or Constants.Font.Regular,
							Text = self.state.InputText == "" and (self.props.Placeholder or "")
								or self.state.InputText,
							TextColor3 = (
								self.state.InputText == "" and theme.DimmedText.Default or theme.MainText.Default
							),
							TextSize = 16,
							TextTransparency = 0.7,
							TextXAlignment = Enum.TextXAlignment.Left,
							Visible = not (self.props.Active == nil and true or not not self.props.Active),
						}),
						Underline = Roact.createElement("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundColor3 = theme.LinkText.Default,
							BorderSizePixel = 0,
							Position = UDim2.new(0, 0, 1, -3),
							Size = UDim2.new(0, 0, 0, 0),
							Visible = false,
							[Roact.Ref] = self.UnderlineRef,
						}),
						Expand = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -20, 0, 0),
							Size = UDim2.new(0, 20, 1, 0),
							FontFace = Font.fromEnum(Enum.Font.Arcade),
							Text = "E",
							TextColor3 = theme.LinkText.Default,
							TextSize = 16,
							TextTransparency = 0.7,
							Visible = expandable and (self.props.Active == nil and true or not not self.props.Active),
							[Roact.Event.Activated] = function()
								local textBox = self.TextBoxRef:getValue()
								textBox:CaptureFocus()
								self.props.OnExpand()
							end,
							[Roact.Event.MouseEnter] = function(rbx)
								rbx.TextTransparency = 0
							end,
							[Roact.Event.MouseLeave] = function(rbx)
								rbx.TextTransparency = 0.7
							end,
						}),
						Clear = Roact.createElement("TextButton", {
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, 0, 0, 0),
							Size = UDim2.new(0, 20, 1, 0),
							FontFace = Font.fromEnum(Enum.Font.Arcade),
							Text = (self.props.Text and self.props.Text ~= "" and "X" or ""),
							TextColor3 = Color3.new(1, 0, 0),
							TextSize = 16,
							TextTransparency = 0.7,
							Visible = (self.props.Active == nil and true or not not self.props.Active),
							[Roact.Ref] = self.ClearRef,
							[Roact.Event.Activated] = function()
								local textBox = self.TextBoxRef:getValue()
								if textBox.Text ~= "" then
									textBox.Text = ""
									if type(self.props.OnCleared) == "function" then
										self.props.OnCleared()
									end
								end
								textBox:CaptureFocus()
							end,
							[Roact.Event.MouseEnter] = function(rbx)
								rbx.TextTransparency = 0
							end,
							[Roact.Event.MouseLeave] = function(rbx)
								rbx.TextTransparency = 0.7
							end,
						}),
					}),
				})
			end,
		}),
	})
end

return InputBox