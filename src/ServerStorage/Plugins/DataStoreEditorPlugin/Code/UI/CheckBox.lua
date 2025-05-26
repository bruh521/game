local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)

local CheckBox = Roact.PureComponent:extend("CheckBox")

function CheckBox:init()
	self:setState({
		Checked = self.props.Checked,
	})
	self.FrameRef = Roact.createRef()
end

function CheckBox:didUpdate(prevProps)
	if prevProps.Checked ~= self.props.Checked and self.props.Checked ~= self.state.Checked then
		self:setState({ Checked = self.props.Checked })
	end
end

function CheckBox:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("TextButton", {
				BackgroundTransparency = 1,
				LayoutOrder = self.props.LayoutOrder or 0,
				Size = UDim2.new(1, 0, 0, 24),
				Text = "",
				TextTransparency = 1,
				[Roact.Event.Activated] = function()
					self:setState({
						Checked = not self.state.Checked,
					})
					if type(self.props.OnChecked) == "function" then
						self.props.OnChecked(self.state.Checked)
					end
				end,
				[Roact.Event.MouseEnter] = function()
					self.FrameRef:getValue().BackgroundColor3 = theme.InputFieldBackground.Hover
				end,
				[Roact.Event.MouseLeave] = function()
					self.FrameRef:getValue().BackgroundColor3 = theme.InputFieldBackground.Default
				end,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				InputFrameBorder = Roact.createElement("Frame", {
					LayoutOrder = 0,
					Size = UDim2.new(1, 0, 1, 0),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					BackgroundColor3 = theme.InputFieldBorder.Default,
					BorderSizePixel = 0,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					InputFrame = Roact.createElement("ImageLabel", {
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundColor3 = theme.InputFieldBackground.Default,
						BorderSizePixel = 0,
						[Roact.Ref] = self.FrameRef,
					}, {
						UICorner = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 7),
						}),
						UIPadding = Roact.createElement("UIPadding", {
							PaddingBottom = UDim.new(0, 5),
							PaddingLeft = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 5),
						}),
						Checkmark = Roact.createElement("ImageLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							Image = "rbxassetid://5051173276",
							ImageColor3 = theme.MainText.Default,
							ScaleType = Enum.ScaleType.Fit,
							Visible = self.state.Checked,
						}),
					}),
				}),
				Label = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(0, 10, 1, 0),
					FontFace = Constants.Font.Regular,
					Text = self.props.Label,
					TextColor3 = theme.MainText.Default,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			})
		end,
	})
end

return CheckBox