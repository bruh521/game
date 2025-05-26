local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local PluginWidget = require(script.Parent.Parent.Plugin.PluginWidget)

local Modal = Roact.Component:extend("Modal")

function Modal:render()
	local visible = true
	if self.props.Visible ~= nil then
		visible = self.props.Visible
	end
	return Roact.createElement(Roact.Portal, {
		target = PluginWidget:GetWidget(),
	}, {
		ModalFrame = Roact.createElement("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = self.props.BackgroundTransparency or 0.3,
			BackgroundColor3 = self.props.BackgroundColor3 or Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			TextTransparency = 1,
			Visible = visible,
			ZIndex = 10,
			[Roact.Event.MouseButton1Down] = function()
				if self.props.NoClickDismiss then
					return
				end
				self.props.Dismiss()
			end,
			[Roact.Event.MouseButton2Down] = function()
				if self.props.NoClickDismiss then
					return
				end
				self.props.Dismiss()
			end,
		}, self.props[Roact.Children]),
	})
end

return Modal