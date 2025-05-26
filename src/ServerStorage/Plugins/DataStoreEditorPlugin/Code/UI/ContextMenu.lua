local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local TextSize = require(script.Parent.Parent.Plugin.TextSize)
local PluginWidget = require(script.Parent.Parent.Plugin.PluginWidget)
local ThemeContext = require(script.Parent.ThemeContext)
local Modal = require(script.Parent.Modal)

local PADDING = 10
local TEXTBOX_HEIGHT = 20
local DIVIDER_HEIGHT = 6
local TEXTBOX_MIN_WIDTH = 80
local TEXT_SIZE = 16
local FONT_FACE = Constants.Font.Regular

local ContextMenu = Roact.Component:extend("ContextMenu")

local ContextMenuItem = Roact.Component:extend("ContextMenuItem")
function ContextMenuItem:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			if self.props.Type == "divider" then
				return Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, self.props.Width, 0, DIVIDER_HEIGHT),
					LayoutOrder = self.props.LayoutOrder,
				}, {
					Divider = Roact.createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.9, 0, 0, 1),
						BorderSizePixel = 0,
						BackgroundColor3 = theme.InputFieldBorder.Default,
					}),
				})
			elseif self.props.Type == "button" then
				return Roact.createElement("TextButton", {
					Active = not self.props.Disabled,
					AutoButtonColor = not self.props.Disabled,
					Size = UDim2.new(0, self.props.Width - 2, 0, TEXTBOX_HEIGHT),
					BackgroundColor3 = theme.InputFieldBackground.Default,
					BorderSizePixel = 0,
					TextSize = TEXT_SIZE,
					Text = self.props.Text,
					TextColor3 = theme.MainText.Default,
					TextTransparency = (self.props.Disabled and 0.75 or 0),
					FontFace = FONT_FACE,
					LayoutOrder = self.props.LayoutOrder,
					[Roact.Event.Activated] = function()
						self.props.OnActivated(self.props.Value, self.props.Text)
					end,
				})
			end
			return nil
		end,
	})
end

function ContextMenu:calcAnchorPoint(size)
	local pos = self.props.Position
	local widget = PluginWidget:GetWidget()
	local widgetPos = widget.AbsolutePosition
	local widgetSize = widget.AbsoluteSize
	local anchorX, anchorY = 0, 0
	if (size.X.Offset + pos.X.Offset) > (widgetPos.X + widgetSize.X) then
		anchorX = 1
	end
	if (size.Y.Offset + pos.Y.Offset) > (widgetPos.Y + widgetSize.Y) then
		anchorY = 1
	end
	return Vector2.new(anchorX, anchorY)
end

function ContextMenu:calcTextWidth()
	self.TextWidthId += 1
	local id = self.TextWidthId
	task.spawn(function()
		local textWidth = TEXTBOX_MIN_WIDTH
		for _, item in self.props.Items do
			if item.Type == "button" then
				local width = TextSize.calcWidth(FONT_FACE, item.Text, TEXT_SIZE) + (PADDING * 2)
				if id ~= self.TextWidthId then
					return
				end
				if width > textWidth then
					textWidth = width
				end
			end
		end
		self:setState({ TextWidth = textWidth })
	end)
end

function ContextMenu:didItemsChange(prevProps)
	if prevProps.Items ~= self.props.Items then
		return true
	elseif typeof(prevProps.Items) == "table" and #prevProps.Items ~= #self.props.Items then
		return true
	end

	return false
end

function ContextMenu:didUpdate(prevProps, _prevState)
	if self:didItemsChange(prevProps) then
		self:calcTextWidth()
	end
end

function ContextMenu:init()
	self.UIListLayoutRef = Roact.createRef()
	self.TextWidthId = 0
	self:setState({ TextWidth = 0 })
	self:calcTextWidth()
end

function ContextMenu:render()
	local items = {}
	items.UIPadding = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0, PADDING),
		PaddingBottom = UDim.new(0, PADDING),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
	})
	items.UIListLayout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	items.UICorner = Roact.createElement("UICorner", {
		CornerRadius = UDim.new(0, 7),
	})
	local textWidth = self.state.TextWidth
	local size = UDim2.new(0, textWidth, 0, 32)
	if self.props.Items then
		local height = (PADDING * 2)
		for _, item in ipairs(self.props.Items) do
			if item.Type == "button" then
				-- local width = TextSize.calcWidth(FONT_FACE, item.Text, TEXT_SIZE) + (PADDING * 2)
				-- if width > textWidth then
				-- 	textWidth = width
				-- end
				height += TEXTBOX_HEIGHT
			elseif item.Type == "divider" then
				height += DIVIDER_HEIGHT
			end
		end
		for i, item in ipairs(self.props.Items) do
			items["item_" .. tostring(i)] = Roact.createElement(ContextMenuItem, {
				LayoutOrder = i,
				Type = item.Type,
				Text = item.Text,
				Value = item.Value,
				Disabled = item.Disabled,
				Width = textWidth,
				OnActivated = function(value, text)
					self.props.OnHide(value, text)
				end,
			})
		end
		size = UDim2.new(0, textWidth, 0, math.max(32, height))
	end
	return Roact.createElement(Modal, {
		BackgroundTransparency = 1,
		Visible = self.props.Showing,
		Dismiss = self.props.OnHide,
	}, {
		InputFrameBorder = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					AnchorPoint = self:calcAnchorPoint(size),
					Size = size,
					Position = self.props.Position,
					BackgroundColor3 = theme.InputFieldBorder.Default,
					BorderSizePixel = 0,
					ZIndex = 2,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					InputFrame = Roact.createElement("Frame", {
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundColor3 = theme.InputFieldBackground.Default,
						BorderSizePixel = 0,
					}, items),
				})
			end,
		}),
	})
end

return ContextMenu