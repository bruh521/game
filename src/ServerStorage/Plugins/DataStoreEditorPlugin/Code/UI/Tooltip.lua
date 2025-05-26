local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local TextSize = require(script.Parent.Parent.Plugin.TextSize)
local ThemeContext = require(script.Parent.ThemeContext)
local PluginWidget = require(script.Parent.Parent.Plugin.PluginWidget)

local TweenService = game:GetService("TweenService")

local DEFAULT_TEXT_SIZE = 16
local DEFAULT_FONT_FACE = Constants.Font.Regular
local PADDING_X = 10
local SIZE_Y = 30
local INTERVAL_BEFORE_SHOW = 0.5

local Tooltip = Roact.PureComponent:extend("Tooltip")

function Tooltip:init()
	self:setState({
		Width = 0,
		Visible = false,
	})
	self.UIScaleRef = Roact.createRef()
	self:_calcWidth()
end

function Tooltip:_calcWidth()
	local text = self.props.Text

	task.spawn(function()
		local sizeX = 0
		if text then
			sizeX = TextSize.calcWidth(
				self.props.FontFace or DEFAULT_FONT_FACE,
				text,
				self.props.TextSize or DEFAULT_TEXT_SIZE
			) + PADDING_X
		end
		self:setState({ Width = sizeX })
	end)
end

function Tooltip:didUpdate(prevProps)
	if prevProps.Text ~= self.props.Text then
		self:_calcWidth()
	end
	if prevProps.Visible ~= self.props.Visible then
		if self.props.Visible then
			self:_delayBeforeShow()
		else
			self:_clearDelay()
			self:_tween()
		end
	end
end

function Tooltip:_clearDelay()
	if self._delayer then
		self._delayer:cancel()
		self._delayer = nil
	end
end

function Tooltip:_delayBeforeShow()
	self:_clearDelay()
	self._delayer = Promise.delay(INTERVAL_BEFORE_SHOW):andThen(function()
		self:_tween()
	end)
end

function Tooltip:_tween()
	local uiScale = self.UIScaleRef:getValue()
	if not uiScale then
		return
	end
	if self._currentTween then
		self._currentTween:Cancel()
		self._currentTween:Destroy()
	end
	local show = self.props.Visible
	local tweenInfo
	if show then
		tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		self:setState({ Visible = true })
	else
		tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	local tween = TweenService:Create(uiScale, tweenInfo, { Scale = (show and 1 or 0) })
	self._currentTween = tween
	tween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			tween:Destroy()
			if not show then
				self:setState({ Visible = false })
			end
		end
	end)
	tween:Play()
end

function Tooltip:willUnmount()
	self:_clearDelay()
	if self._currentTween then
		self._currentTween:Cancel()
		self._currentTween:Destroy()
		self._currentTween = nil
	end
end

function Tooltip:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(_theme)
			return Roact.createElement(Roact.Portal, {
				target = PluginWidget:GetWidget(),
			}, {
				TooltipLabel = Roact.createElement("TextLabel", {
					AnchorPoint = self.props.AnchorPoint or Vector2.new(0.5, 0),
					BackgroundTransparency = 0.3,
					BackgroundColor3 = Color3.new(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, self.state.Width, 0, SIZE_Y),
					Position = self.props.Position,
					Text = self.props.Text or "",
					TextColor3 = Color3.new(1, 1, 1),
					Visible = self.state.Visible,
					ZIndex = 10,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					UIScale = Roact.createElement("UIScale", {
						Scale = 0,
						[Roact.Ref] = self.UIScaleRef,
					}),
				}),
			})
		end,
	})
end

return Tooltip