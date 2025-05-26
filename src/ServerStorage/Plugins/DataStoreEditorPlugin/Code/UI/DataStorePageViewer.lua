local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local ItemViewer = require(script.Parent.ItemViewer)
local DataFetch = require(script.Parent.Parent.Plugin.DataFetch)

local DataStorePageViewer = Roact.Component:extend("DataStorePageViewer")

function DataStorePageViewer:init()
	self:setState({
		Size = UDim2.new(),
		TableLayoutCount = 0,
	})
	self.TableLayoutRef = Roact.createRef()
end

function DataStorePageViewer:didMount()
	self:calcSizeY()
end

function DataStorePageViewer:calcSizeY()
	local uiTableLayout = self.TableLayoutRef:getValue()
	if not uiTableLayout then
		return
	end
	local size = uiTableLayout.AbsoluteContentSize
	self:setState({
		Size = UDim2.fromOffset(size.X, size.Y),
	})
end

function DataStorePageViewer:didUpdate(prevProps)
	if self.props.DataPage ~= prevProps.DataPage then
		self:setState({
			TableLayoutCount = self.state.TableLayoutCount + 1,
		})
	end
end

function DataStorePageViewer:render()
	local items = {}

	items["UITableLayout" .. self.state.TableLayoutCount] = Roact.createElement("UITableLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim2.new(0, 20, 0, 0),
		[Roact.Change.AbsoluteContentSize] = function()
			self:calcSizeY()
		end,
		[Roact.Ref] = self.TableLayoutRef,
	})

	local page = self.props.DataPage
	if page then
		for order, data in page do
			items[data.key] = Roact.createElement(ItemViewer, {
				Key = data.key,
				Value = data.value,
				LayoutOrder = order,
				Level = 1,
				NoSave = true,
				FilterText = function(text)
					if text == "" then
						return text
					end
					return text:match("^%-?%d*")
				end,
				SubmitChange = function(text)
					local n = tonumber(text)
					if n and text:match("^%-?%d*") then
						local success, err = DataFetch:Save({
							Key = data.key,
							Data = n,
							DSName = self.props.DSName,
							DSScope = self.props.DSScope,
							UseOrdered = true,
						}):await()
						if not success then
							warn(err)
						end
						return n
					else
						return data.value
					end
				end,
			})
		end
	end

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = self.state.Size,
	}, items)
end

DataStorePageViewer = RoactRodux.connect(function(state)
	return {
		DSName = state.DSName,
		DSScope = state.DSScope,
	}
end)(DataStorePageViewer)

return DataStorePageViewer