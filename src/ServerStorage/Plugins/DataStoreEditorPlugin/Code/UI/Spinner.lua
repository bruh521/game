local Roact = require(script.Parent.Parent.Parent.Packages.Roact)

local DEG_PER_SEC = 600

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Spinner = Roact.PureComponent:extend("Spinner")

function Spinner:init()
	self._renderName = "Spinner_" .. HttpService:GenerateGUID(false)
	self._renderBound = false
	self.SpinnerRef = Roact.createRef()
end

function Spinner:bind()
	if self._renderBound then
		return
	end
	self._renderBound = true
	local spinner = self.SpinnerRef:getValue()
	local rotation = 0
	spinner.Rotation = rotation
	RunService:BindToRenderStep(self._renderName, Enum.RenderPriority.Last.Value, function(dt)
		rotation = (rotation + (DEG_PER_SEC * dt)) % 360
		spinner.Rotation = rotation
	end)
end

function Spinner:unbind()
	if not self._renderBound then
		return
	end
	self._renderBound = false
	RunService:UnbindFromRenderStep(self._renderName)
end

function Spinner:didMount()
	self:bind()
end

function Spinner:willUnmount()
	self:unbind()
end

function Spinner:didUpdate(prevProps)
	if self.props.Show ~= prevProps.Show then
		if self.props.Show then
			self:bind()
		else
			self:unbind()
		end
	end
end

function Spinner:render()
	return Roact.createElement("ImageLabel", {
		AnchorPoint = self.props.AnchorPoint or Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = self.props.LayoutOrder or 0,
		Position = self.props.Position or UDim2.new(1, -5, 0.5, 0),
		Size = self.props.Size or UDim2.new(0.5, 0, 0.5, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Image = "rbxassetid://5056179278",
		ImageColor3 = self.props.Color,
		Visible = self.props.Show,
		[Roact.Ref] = self.SpinnerRef,
	})
end

return Spinner