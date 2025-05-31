local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)

local KeyValuePair = Roact.PureComponent:extend("KeyValuePair")

function KeyValuePair:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = self.props.Size or UDim2.new(1, 0, 0, 16),
				LayoutOrder = self.props.LayoutOrder or 0,
			}, {
				Key = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					LayoutOrder = 0,
					FontFace = Constants.Font.Regular,
					Text = (self.props.Key .. ":"),
					TextSize = self.props.TextSize or 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				Value = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					LayoutOrder = 0,
					FontFace = Constants.Font.Bold,
					Text = self.props.Value,
					TextSize = self.props.TextSize or 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),
			})
		end,
	})
end

return KeyValuePair