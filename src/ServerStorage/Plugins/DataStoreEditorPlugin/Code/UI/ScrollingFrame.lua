local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local ScrollingFrame = Roact.Component:extend("ScrollingFrame")

local SCROLLBAR_THICKNESS = 8

function ScrollingFrame:init()
	self:setState({
		CanvasSize = UDim2.new(1, 0, 1, 0),
		CanvasPosition = Vector2.new(),
		AbsoluteWindowSize = Vector2.new(),
	})
	self.ScrollingFrameRef = Roact.createRef()
end

function ScrollingFrame:didMount()
	self:setState({
		AbsoluteWindowSize = self.ScrollingFrameRef:getValue().AbsoluteWindowSize,
	})
end

function ScrollingFrame:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			if not self.props.IgnoreUIListLayout then
				self.props[Roact.Children].UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, self.props.Padding or 10),
					HorizontalAlignment = self.props.HorizontalAlignment or Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					[Roact.Change.AbsoluteContentSize] = function(rbx)
						local size = rbx.AbsoluteContentSize
						if self.props.NoScrollX then
							self:setState({ CanvasSize = UDim2.new(1, -(SCROLLBAR_THICKNESS + 1), 0, size.Y) })
						else
							self:setState({ CanvasSize = UDim2.fromOffset(size.X, size.Y) })
						end
					end,
				})
			end
			return Roact.createElement("Frame", {
				Size = self.props.Size or UDim2.new(1, 0, 1, 0),
				Position = self.props.Position or UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				ZIndex = self.props.ZIndex or 1,
				LayoutOrder = self.props.LayoutOrder or 0,
				Visible = (self.props.Visible == nil and true or not not self.props.Visible),
			}, {
				ScrollingFrame = Roact.createElement("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
					ScrollBarImageColor3 = theme.InputFieldBorder.Default,
					ScrollBarThickness = SCROLLBAR_THICKNESS,
					VerticalScrollBarInset = self.props.VerticalScrollBarInset or Enum.ScrollBarInset.None,
					HorizontalScrollBarInset = self.props.HorizontalScrollBarInset or Enum.ScrollBarInset.None,
					CanvasSize = self.props.CanvasSize or self.state.CanvasSize,
					CanvasPosition = self.props.CanvasPosition,
					[Roact.Change.CanvasPosition] = function(rbx)
						self:setState({ CanvasPosition = rbx.CanvasPosition })
					end,
					[Roact.Change.AbsoluteWindowSize] = function(rbx)
						self:setState({ AbsoluteWindowSize = rbx.AbsoluteWindowSize })
					end,
					[Roact.Ref] = self.ScrollingFrameRef,
				}, self.props[Roact.Children]),
				TopShadow = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(self.props.KeepShadowInBounds and 0 or 0.5, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(self.props.KeepShadowInBounds and 1 or 2, 0, 0, 8),
					Image = "rbxassetid://5072600298",
					ImageTransparency = 0.7,
					ImageColor3 = Color3.new(0, 0, 0),
					ZIndex = 2,
					Visible = self.state.CanvasPosition.Y > 5,
				}),
				BottomShadow = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(self.props.KeepShadowInBounds and 0 or 0.5, 1),
					BackgroundTransparency = 1,
					Size = UDim2.new(self.props.KeepShadowInBounds and 1 or 2, 0, 0, 8),
					Position = UDim2.new(0, 0, 1, 0),
					Rotation = 180,
					Image = "rbxassetid://5072600298",
					ImageTransparency = 0.7,
					ImageColor3 = Color3.new(0, 0, 0),
					ZIndex = 2,
					Visible = self.state.CanvasPosition.Y
						< (self.state.CanvasSize.Y.Offset - self.state.AbsoluteWindowSize.Y - 5),
				}),
			})
		end,
	})
end

return ScrollingFrame