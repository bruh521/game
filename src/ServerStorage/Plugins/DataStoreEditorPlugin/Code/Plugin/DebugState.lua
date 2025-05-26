local HttpService = game:GetService("HttpService")

local Constants = require(script.Parent.Constants)
local DataNil = Constants.DataNil

local DebugState = {}

local DEBUG_ENABLED = (game.PlaceId == 5047391271)

local MAX_VALUE_CHARS = 100
local EVEN_COLOR = Color3.new(0.1, 0.1, 0.1)
local ODD_COLOR = Color3.new(0.2, 0.2, 0.2)
local LABEL_TEXT_SIZE = 16
local LABEL_FONT_FACE = Constants.Font.Regular
local LABEL_HEIGHT = 24
local LABEL_PADDING_SIDES = 10

local WIDGET_INFO = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false, -- Initial enabled state
	true, -- Override previous enabled state
	400,
	300, -- Initial size
	150,
	100 -- Min size
)

local Label = {}
Label.__index = Label

function Label.new(title, value)
	local self = setmetatable({
		Frame = Instance.new("Frame"),
		Title = Instance.new("TextLabel"),
		Value = Instance.new("TextLabel"),
		_title = title,
	}, Label)
	for _, l in { self.Title, self.Value } do
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, 0, 1, 0)
		l.FontFace = LABEL_FONT_FACE
		l.TextColor3 = Color3.new(1, 1, 1)
		l.TextSize = LABEL_TEXT_SIZE
		l.Parent = self.Frame
	end
	self.Frame.Name = title
	self.Frame.BorderSizePixel = 0
	self.Frame.Size = UDim2.new(1, 0, 0, LABEL_HEIGHT)
	self.Title.Name = "Title"
	self.Title.Text = (title .. ":")
	self.Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Value.Name = "Value"
	self.Value.TextXAlignment = Enum.TextXAlignment.Right
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, LABEL_PADDING_SIDES)
	padding.PaddingRight = UDim.new(0, LABEL_PADDING_SIDES)
	padding.Parent = self.Frame
	self:SetValue(value)
	return self
end

function Label:SetBackground(color)
	self.Frame.BackgroundColor3 = color
end

function Label:SetValue(value)
	if type(value) == "table" then
		if value == DataNil then
			value = "DATA_NIL"
		else
			value = HttpService:JSONEncode(value)
		end
	else
		if typeof(value) == "Instance" then
			value = string.format("Instance (%s)", value.ClassName)
		else
			value = tostring(value)
		end
	end
	if #value > MAX_VALUE_CHARS then
		value = value:sub(1, MAX_VALUE_CHARS) .. "..."
	end
	self.Value.Text = value
	if self._tween then
		self._tween:Destroy()
	end
	self.Value.TextColor3 = Color3.fromRGB(0, 170, 255)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 2)
	local tween = game:GetService("TweenService"):Create(self.Value, tweenInfo, { TextColor3 = Color3.new(1, 1, 1) })
	tween:Play()
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			tween:Destroy()
			self._tween = nil
		end
	end)
	self._tween = tween
end

function Label:SetParent(parent)
	self.Frame.Parent = parent
end

function Label:Destroy()
	if self._tween then
		self._tween:Destroy()
	end
	self.Frame:Destroy()
end

function DebugState:Start()
	if not DEBUG_ENABLED then
		return
	end

	local store = self.Modules.App:GetStore()

	local labels = {}

	local widget = self.Plugin:CreateDockWidgetPluginGui("DataStoreEditorDebugState", WIDGET_INFO)
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	widget.Name = "DataStoreEditorDebugState"
	widget.Title = "DataStore Editor - Debug State"
	widget.Enabled = true

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = ODD_COLOR
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Parent = widget

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.CanvasSize = UDim2.new(1, 0, 1, 0)
	scrollingFrame.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollingFrame

	local function ResizeFrame()
		local layoutSize = listLayout.AbsoluteContentSize
		scrollingFrame.CanvasSize = UDim2.new(1, 0, 0, layoutSize.Y)
	end

	local function NewLabel(title, value)
		local label = Label.new(title, value)
		label:SetParent(scrollingFrame)
		return label
	end

	local function StateChanged(newState, oldState)
		local addedOrRemoved = false
		for k, v in pairs(newState) do
			if v ~= oldState[k] then
				local label = labels[k]
				if not label then
					addedOrRemoved = true
					label = NewLabel(k, v)
					labels[k] = label
				end
				label:SetValue(v)
			end
		end
		for k in pairs(oldState) do
			if newState[k] == nil then
				local label = labels[k]
				if label then
					addedOrRemoved = true
					label:Destroy()
					labels[k] = nil
				end
			end
		end
		if addedOrRemoved then
			local allLabels = {}
			for _, l in pairs(labels) do
				table.insert(allLabels, l)
			end
			table.sort(allLabels, function(a, b)
				return (a._title < b._title)
			end)
			for i, l in ipairs(allLabels) do
				l.Frame.LayoutOrder = i
				l:SetBackground((i % 2) == 0 and EVEN_COLOR or ODD_COLOR)
			end
		end
	end

	store.changed:connect(StateChanged)
	StateChanged(store:getState(), {})

	ResizeFrame()
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeFrame)
end

return DebugState