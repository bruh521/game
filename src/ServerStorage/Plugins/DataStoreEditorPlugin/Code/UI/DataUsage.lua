local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local TextSize = require(script.Parent.Parent.Plugin.TextSize)
local ThemeContext = require(script.Parent.ThemeContext)
local Tooltip = require(script.Parent.Tooltip)
local DataNil = require(script.Parent.Parent.Plugin.Constants).DataNil
local HumanBytes = require(script.Parent.Parent.Plugin.HumanBytes)

local HttpService = game:GetService("HttpService")

-- Data limit is 1 byte less than 4MB
-- See: https://devforum.roblox.com/t/datastore-editor-v3/716915/68
local MAX_DATA_SIZE = 4194303
local TEXT_SIZE = 16
local FONT_FACE = Constants.Font.Regular

local DataUsage = Roact.Component:extend("DataUsage")

local function calcDataSize(data, dataErr)
	if data == DataNil or dataErr ~= "" then
		return 0
	end

	local size = 0
	local success, dataStr = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		size = string.len(dataStr)
	end

	return size
end

function DataUsage:init()
	self:setState({ ShowTooltip = false, DataSize = -1, DataSizeText = "" })
	self.LabelRef = Roact.createRef()
	self.TextWidth, self.UpdateTextWidth = Roact.createBinding(0)
end

function DataUsage:calcDataSize()
	return calcDataSize(self.props.Data, self.props.DataError)
end

function DataUsage:didUpdate(_prevProps, prevState)
	if prevState.DataSizeText ~= self.state.DataSizeText then
		task.spawn(function()
			local width = TextSize.calcWidth(FONT_FACE, self.state.DataSizeText, TEXT_SIZE)
			self.UpdateTextWidth(width)
		end)
	end
end

function DataUsage.getDerivedStateFromProps(nextProps, _lastState)
	local dataSize = calcDataSize(nextProps.Data, nextProps.DataError)
	local dataFormatted = HumanBytes.Format(dataSize, false, 1)
	local dataSizeText = string.format("Data Usage: %s (%.2f%%)", dataFormatted, (dataSize / MAX_DATA_SIZE) * 100)

	return {
		DataSize = dataSize,
		DataSizeText = dataSizeText,
	}
end

function DataUsage:render()
	local dataSize = self.state.DataSize
	local dataSizeText = self.state.DataSizeText
	local tooltipText = string.format("%i / %i bytes", dataSize, MAX_DATA_SIZE)
	local tooltipPos = UDim2.new()
	local lbl = self.LabelRef:getValue()
	if lbl then
		local sz = lbl.AbsoluteSize
		tooltipPos = lbl.AbsolutePosition + Vector2.new((sz.X / 2), 0)
		tooltipPos = UDim2.new(0, tooltipPos.X, 0, tooltipPos.Y)
	end

	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Visible = self.props.Visible,
			}, {
				Label = if self.props.Data ~= DataNil
					then Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = self.TextWidth:map(function(width)
							return UDim2.new(0, width, 0, 30)
						end),
						FontFace = FONT_FACE,
						Text = dataSizeText,
						TextSize = TEXT_SIZE,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
						[Roact.Event.MouseEnter] = function()
							self:setState({ ShowTooltip = true })
						end,
						[Roact.Event.MouseLeave] = function()
							self:setState({ ShowTooltip = false })
						end,
						[Roact.Ref] = self.LabelRef,
					}, {
						Roact.createElement(Tooltip, {
							AnchorPoint = Vector2.new(0.5, 1),
							Text = tooltipText,
							Position = tooltipPos,
							Visible = self.state.ShowTooltip,
						}),
					})
					else nil,
			})
		end,
	})
end

DataUsage = RoactRodux.connect(function(state)
	return {
		Data = state.Data,
		DataError = state.DataError,
	}
end)(DataUsage)

return DataUsage