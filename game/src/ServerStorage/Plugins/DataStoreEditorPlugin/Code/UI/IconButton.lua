local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Spinner = require(script.Parent.Spinner)
local Tooltip = require(script.Parent.Tooltip)

local IconButton = Roact.PureComponent:extend("IconButton")

function IconButton:init()
	self:setState({
		Processing = false,
		ShowTooltip = false,
	})
	self.ButtonRef = Roact.createRef()
end

function IconButton:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			local children = {}
			children.Spinner = Roact.createElement(Spinner, {
				Show = self.state.Processing,
				Color = theme[self.props.ImageColor or "MainText"].Default,
			})
			if self.props.Tooltip then
				local pos = UDim2.new()
				local btn = self.ButtonRef:getValue()
				if btn then
					local sz = btn.AbsoluteSize
					pos = btn.AbsolutePosition + Vector2.new((sz.X / 2), sz.Y + 5)
					pos = UDim2.new(0, pos.X, 0, pos.Y)
				end
				children.Tooltip = Roact.createElement(Tooltip, {
					AnchorPoint = Vector2.new(0.5, 0),
					Text = self.props.Tooltip,
					Position = pos,
					Visible = self.state.ShowTooltip,
				})
			end
			return Roact.createElement("ImageButton", {
				Active = not self.props.Disabled,
				AutoButtonColor = not self.props.Disabled,
				AnchorPoint = self.props.AnchorPoint or Vector2.new(),
				BackgroundTransparency = 1,
				Size = self.props.Size or UDim2.new(1, 0, 1, 0),
				Position = self.props.Position or UDim2.new(0, 0, 0, 0),
				Image = self.props.Icon or "",
				ImageColor3 = theme[self.props.ImageColor or "MainButton"][self.props.Disabled and "Disabled" or "Default"],
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
					if self.props.Disabled then
						return
					end
					rbx.ImageColor3 = theme[self.props.ImageColor or "MainButton"].Pressed
				end,
				[Roact.Event.MouseButton1Up] = function(rbx)
					if self.props.Disabled then
						return
					end
					rbx.ImageColor3 = theme[self.props.ImageColor or "MainButton"].Hover
				end,
				[Roact.Event.MouseEnter] = function(rbx)
					self:setState({ ShowTooltip = true })
					if self.props.Disabled then
						return
					end
					rbx.ImageColor3 = theme[self.props.ImageColor or "MainButton"].Hover
				end,
				[Roact.Event.MouseLeave] = function(rbx)
					self:setState({ ShowTooltip = false })
					if self.props.Disabled then
						return
					end
					rbx.ImageColor3 = theme[self.props.ImageColor or "MainButton"].Default
				end,
				[Roact.Ref] = self.ButtonRef,
			}, children)
		end,
	})
end

return IconButton