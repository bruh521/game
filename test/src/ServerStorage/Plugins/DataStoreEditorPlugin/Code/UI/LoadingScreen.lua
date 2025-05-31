local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local Spinner = require(script.Parent.Spinner)

local LoadingScreen = Roact.Component:extend("LoadingScreen")

function LoadingScreen:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 120, 0, 30),
				LayoutOrder = 0,
				FontFace = Constants.Font.Regular,
				Text = "Loading...",
				TextSize = 24,
				TextColor3 = theme.MainText.Default,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {
				Spinner = Roact.createElement(Spinner, {
					Show = true,
					Color = theme.MainText.Default,
				}),
			})
		end,
	})
end

return LoadingScreen