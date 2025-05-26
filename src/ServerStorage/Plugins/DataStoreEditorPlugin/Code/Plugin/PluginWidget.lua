--[[

	PluginWidget:SetEnabled(enabled)
	PluginWidget:GetWidget()
	PluginWidget:GetMousePosition()

	PluginWidget.Disabled()

--]]

local Signal = require(script.Parent.Parent.Parent.Packages.Signal)

local PluginWidget = {}

local WIDGET_INFO = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Top,
	false, -- Initial enabled state
	true, -- Override previous enabled state
	400,
	300, -- Initial size
	400,
	300 -- Min size
)

local widget

function PluginWidget:GetWidget()
	return widget
end

function PluginWidget:SetEnabled(enabled)
	widget.Enabled = enabled
end

function PluginWidget:GetMousePosition()
	return widget:GetRelativeMousePosition()
end

function PluginWidget:Init()
	local plugin = self.Plugin
	widget = plugin:CreateDockWidgetPluginGui(self.Modules.Constants.WidgetName, WIDGET_INFO)
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	widget.Name = self.Modules.Constants.WidgetName
	widget.Title = self.Modules.Constants.WidgetTitle
	self.Disabled = Signal.new()
	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not widget.Enabled then
			self.Disabled:Fire()
		end
	end)
end

function PluginWidget:Start() end

return PluginWidget