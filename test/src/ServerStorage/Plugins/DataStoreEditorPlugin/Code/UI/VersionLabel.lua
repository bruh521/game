local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local pluginVersion = script.Parent.Parent.Version.Value

local VersionLabel = Roact.PureComponent:extend("VersionLabel")

function VersionLabel:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 1),
				Size = UDim2.new(1, 0, 0, 14),
				Position = UDim2.new(1, -10, 1, -10),
				LayoutOrder = 0,
				FontFace = Font.fromEnum(Enum.Font.SourceSans),
				Text = pluginVersion,
				TextSize = 14,
				TextColor3 = theme.MainText.Default,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTransparency = 0.75,
			})
		end,
	})
end

return VersionLabel