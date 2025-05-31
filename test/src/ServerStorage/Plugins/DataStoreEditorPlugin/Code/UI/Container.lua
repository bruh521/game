local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local OverlayContext = require(script.Parent.OverlayContext)

local Container = Roact.Component:extend("Container")

local TweenService = game:GetService("TweenService")

local OVERLAY_OPAQUE_TRANSPARENCY = 0.5
local OVERLAY_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Container:init()
	self.OverlayRef = Roact.createRef()
end

function Container:didMount()
	local overlay = self.OverlayRef:getValue()
	if overlay then
		overlay.BackgroundTransparency = self.props.Overlay and OVERLAY_OPAQUE_TRANSPARENCY or 1
	end
end

function Container:willUnmount()
	self:cancelOverlayTween()
end

function Container:didUpdate(prevProps)
	if self.props.Overlay ~= prevProps.Overlay then
		self:tweenOverlayTransparency(self.props.Overlay)
	end
end

function Container:tweenOverlayTransparency(showOverlay)
	local overlayFrame = self.OverlayRef:getValue()
	if not overlayFrame then
		return
	end
	self:cancelOverlayTween()
	local goalTransparency = showOverlay and OVERLAY_OPAQUE_TRANSPARENCY or 1
	local tween = TweenService:Create(overlayFrame, OVERLAY_TWEEN_INFO, { BackgroundTransparency = goalTransparency })
	self.overlayTween = tween
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			tween:Destroy()
			self.overlayTween = nil
		end
	end)
	tween:Play()
end

function Container:cancelOverlayTween()
	if self.overlayTween then
		self.overlayTween:Cancel()
		self.overlayTween:Destroy()
		self.overlayTween = nil
	end
end

function Container:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			self.props[Roact.Children].Padding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, self.props.PaddingBottom or self.props.Padding or 0),
				PaddingLeft = UDim.new(0, self.props.PaddingLeft or self.props.Padding or 0),
				PaddingRight = UDim.new(0, self.props.PaddingRight or self.props.Padding or 0),
				PaddingTop = UDim.new(0, self.props.PaddingTop or self.props.Padding or 0),
			})
			return Roact.createElement("Frame", {
				Size = self.props.Size or UDim2.fromScale(1, 1),
				Position = self.props.Position or UDim2.fromScale(0, 0),
				BackgroundColor3 = theme.MainBackground.Default,
				BackgroundTransparency = self.props.Transparency or 0,
				BorderSizePixel = 0,
				ZIndex = self.props.ZIndex or 1,
				Visible = (self.props.Visible == nil and true or not not self.props.Visible),
			}, {
				Overlay = Roact.createElement("Frame", {
					Active = self.props.Overlay,
					BackgroundColor3 = Color3.new(0, 0, 0),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 10,
					[Roact.Ref] = self.OverlayRef,
				}),
				InnerFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				}, {
					OverlayProvider = Roact.createElement(OverlayContext.Provider, {
						value = self.props.Overlay,
					}, self.props[Roact.Children]),
				}),
			})
		end,
	})
end

return Container