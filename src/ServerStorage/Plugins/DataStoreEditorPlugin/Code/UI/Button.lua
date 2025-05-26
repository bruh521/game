local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local OverlayContext = require(script.Parent.OverlayContext)
local Spinner = require(script.Parent.Spinner)
local Tooltip = require(script.Parent.Tooltip)

local Button = Roact.PureComponent:extend("Button")

function Button:init()
	self:setState({
		Processing = false,
		ShowTooltip = false,
	})
	self.ButtonRef = Roact.createRef()
end

function Button:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement(OverlayContext.Consumer, {
				render = function(showOverlay)
					local disabled = self.props.Disabled or showOverlay
					local items = {}
					if not self.props.Icon then
						items.Spinner = Roact.createElement(Spinner, {
							Show = self.state.Processing,
							Color = theme[self.props.TextColor or "MainText"].Default,
						})
					else
						items.Icon = Roact.createElement("ImageLabel", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = self.props.IconSize or UDim2.fromScale(1, 1),
							Image = self.props.Icon,
							ImageColor3 = theme[self.props.TextColor or "MainText"][disabled and "Disabled" or "Default"],
							Visible = not self.state.Processing,
						})
						items.Spinner = Roact.createElement(Spinner, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.5, 0.5),
							Show = self.state.Processing,
							Color = theme[self.props.TextColor or "MainText"].Default,
						})
					end
					if self.props.Tooltip then
						local pos = UDim2.new()
						local btn = self.ButtonRef:getValue()
						if btn then
							local sz = btn.AbsoluteSize
							pos = btn.AbsolutePosition + Vector2.new(sz.X / 2, sz.Y + 5)
							pos = UDim2.fromOffset(pos.X, pos.Y)
						end
						items.Tooltip = Roact.createElement(Tooltip, {
							AnchorPoint = Vector2.new(0.5, 0),
							Text = self.props.Tooltip,
							Position = pos,
							Visible = self.state.ShowTooltip,
						})
					end
					items.UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					})
					return Roact.createElement("TextButton", {
						Active = not disabled,
						AutoButtonColor = false,
						BackgroundColor3 = theme[self.props.ImageColor or "MainButton"][disabled and "Disabled" or "Default"],
						AnchorPoint = self.props.AnchorPoint or Vector2.new(),
						LayoutOrder = self.props.LayoutOrder or 0,
						Size = self.props.Size or UDim2.new(1, 0, 0, 30),
						Position = self.props.Position or UDim2.new(0, 0, 0, 0),
						FontFace = Constants.Font.Bold,
						Text = (not self.props.Icon) and self.props.Label or "",
						TextColor3 = theme[self.props.TextColor or "MainText"][disabled and "Disabled" or "Default"],
						TextSize = 16,
						[Roact.Event.Activated] = function(rbx)
							if self.state.Processing or not rbx.Active then
								return
							end
							self:setState({ Processing = true })
							self.props.OnActivated(rbx)
							self:setState({ Processing = false })
						end,
						[Roact.Event.MouseButton1Down] = function(rbx)
							self:setState({ ShowTooltip = false })
							if disabled then
								return
							end
							rbx.BackgroundColor3 = theme[self.props.ImageColor or "MainButton"].Pressed
						end,
						[Roact.Event.MouseButton1Up] = function(rbx)
							if disabled then
								return
							end
							rbx.BackgroundColor3 = theme[self.props.ImageColor or "MainButton"].Hover
						end,
						[Roact.Event.MouseEnter] = function(rbx)
							self:setState({ ShowTooltip = true })
							if disabled then
								return
							end
							rbx.BackgroundColor3 = theme[self.props.ImageColor or "MainButton"].Hover
						end,
						[Roact.Event.MouseLeave] = function(rbx)
							self:setState({ ShowTooltip = false })
							if disabled then
								return
							end
							rbx.BackgroundColor3 = theme[self.props.ImageColor or "MainButton"].Default
						end,
						[Roact.Ref] = self.ButtonRef,
					}, items)
				end,
			})
		end,
	})
end

return Button