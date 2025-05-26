local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local Modal = require(script.Parent.Modal)
local Button = require(script.Parent.Button)

local Alert = Roact.Component:extend("Alert")

function Alert:render()
	return Roact.createElement(Modal, {
		Visible = self.props.Showing,
		Dismiss = self.props.OnHide,
		NoClickDismiss = true,
	}, {
		Alert = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					BackgroundColor3 = theme.MainBackground.Default,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 250, 0, 150),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 10),
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
					}),
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					Title = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 20),
						FontFace = Constants.Font.Bold,
						Text = self.props.Title or "Alert",
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Center,
					}),
					Message = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 50),
						Position = UDim2.new(0, 0, 0, 30),
						FontFace = Constants.Font.Regular,
						Text = self.props.Message or "",
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
					DismissButton = Roact.createElement(Button, {
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.new(0.5, 0, 1, 0),
						Label = self.props.DismissLabel or "OK",
						ImageColor = "DialogMainButton",
						TextColor = "DialogMainButtonText",
						Size = UDim2.new(0.5, -5, 0, 30),
						Disabled = false,
						OnActivated = function()
							self.props.OnHide()
						end,
					}),
				})
			end,
		}),
	})
end

return Alert