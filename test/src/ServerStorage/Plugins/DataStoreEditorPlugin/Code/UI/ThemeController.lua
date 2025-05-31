local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Theme = require(script.Parent.Theme)

local ThemeController = Roact.Component:extend("ThemeController")

function ThemeController:init()
	self.state = { Theme = Theme:Get() }
end

function ThemeController:didMount()
	self._themeChanged = settings().Studio.ThemeChanged:Connect(function()
		self:setState({ Theme = Theme:Get() })
	end)
end

function ThemeController:willUnmount()
	self._themeChanged:Disconnect()
end

function ThemeController:render()
	return Roact.createElement(ThemeContext.Provider, {
		value = self.state.Theme,
	}, self.props[Roact.Children])
end

return ThemeController