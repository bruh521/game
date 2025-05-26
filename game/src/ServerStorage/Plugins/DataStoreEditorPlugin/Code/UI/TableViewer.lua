local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local PluginWidget = require(script.Parent.Parent.Plugin.PluginWidget)
local ThemeContext = require(script.Parent.ThemeContext)
local ItemViewer = require(script.Parent.ItemViewer)
local ContextMenu = require(script.Parent.ContextMenu)
local NewKey = require(script.Parent.NewKey)
local DataVer = require(script.Parent.Parent.Plugin.DataVer)

local TableViewer = Roact.Component:extend("TableViewer")

function TableViewer:init()
	self:setState({
		Expanded = self.props.Expanded,
		RenderId = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Num = 0,
		ContextMenu = {
			Showing = false,
			Context = {},
			Position = UDim2.new(),
			Items = {},
		},
		NewKey = {
			Showing = false,
			KeyExists = false,
			Key = "",
		},
	})
	self.UITableLayout = Roact.createRef()
	self._labelKey = {}
end

function TableViewer:setContextMenu(showing, context, pos, items)
	self:setState({
		ContextMenu = {
			Showing = showing,
			Context = (context or self.state.ContextMenu.Context),
			Position = (pos or self.state.ContextMenu.Position),
			Items = (items or {}),
		},
	})
end

function TableViewer:setNewKeyModal(showing, keyExists, key, position)
	self:setState({
		NewKey = {
			Showing = showing,
			KeyExists = keyExists,
			Key = key,
			Position = (position or self.state.NewKey.Position),
		},
	})
end

function TableViewer:didMount()
	self:calcSize()
	self.widgetSizeChangedListener = PluginWidget:GetWidget()
		:GetPropertyChangedSignal("AbsoluteSize")
		:Connect(function()
			self:calcSize()
		end)
end

function TableViewer:willUnmount()
	self.widgetSizeChangedListener:Disconnect()
end

function TableViewer:toggleExpanded()
	if self.state.Expanded then
		self:setState({
			Expanded = false,
			RenderId = self.state.RenderId + 1,
		})
	else
		self:setState({ Expanded = true })
	end
end

function TableViewer:calcSize()
	local contentSize = self.UITableLayout:getValue().AbsoluteContentSize
	self:setState({ Size = UDim2.new(0, contentSize.X, 0, contentSize.Y) })
end

function TableViewer:onContextMenuItemSelected(itemValue, _itemText)
	local context = self.state.ContextMenu.Context
	if itemValue == "insert_before" then
		local index = context.Key
		table.insert(context.Table, index, "item")
		self.props.MarkDirty()
	elseif itemValue == "insert_after" then
		local index = context.Key
		table.insert(context.Table, index + 1, "item")
		self.props.MarkDirty()
	elseif itemValue == "insert" or itemValue == "insert_into" then
		local pos = context.Rbx.AbsolutePosition
		local size = context.Rbx.AbsoluteSize
		local modalPos = UDim2.new(0, pos.X, 0, pos.Y + (size.Y / 2))
		if itemValue == "insert_into" then
			context.Table = context.Value
		end
		self:setNewKeyModal(true, false, nil, modalPos)
	elseif itemValue == "delete_array_index" or itemValue == "delete_array" then
		local index = context.Key
		table.remove(context.Table, index)
		self.props.MarkDirty()
	elseif itemValue == "delete_dict_index" or itemValue == "delete_dict" then
		local index = context.Key
		context.Table[index] = nil
		self.props.MarkDirty()
	elseif itemValue == "insert_first" then
		table.insert(context.Value, 1, "item")
		self.props.MarkDirty()
	elseif itemValue == "insert_last" then
		table.insert(context.Value, "item")
		self.props.MarkDirty()
	elseif itemValue == "move_up" then
		if context.Key > 1 then
			local t = context.Table
			local k = context.Key
			t[k - 1], t[k] = t[k], t[k - 1]
			self.props.MarkDirty()
		end
	elseif itemValue == "move_down" then
		if context.Key < #context.Table then
			local t = context.Table
			local k = context.Key
			t[k + 1], t[k] = t[k], t[k + 1]
			self.props.MarkDirty()
		end
	end
end

function TableViewer:incNum()
	self:setState({ Num = self.state.Num + 1 })
end

function TableViewer:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(_theme)
			local items = {}
			items.ContextMenu = Roact.createElement(ContextMenu, {
				Showing = self.state.ContextMenu.Showing,
				Position = self.state.ContextMenu.Position,
				Items = self.state.ContextMenu.Items,
				OnHide = function(itemValue, itemText)
					if itemValue then
						self:onContextMenuItemSelected(itemValue, itemText)
					end
					self:setContextMenu(false)
				end,
			})
			items.NewKey = Roact.createElement(NewKey, {
				Showing = self.state.NewKey.Showing,
				KeyExists = self.state.NewKey.KeyExists,
				Position = self.state.NewKey.Position,
				Key = self.state.NewKey.Key,
				OnHide = function(newKey)
					if newKey and newKey ~= "" then
						local context = self.state.ContextMenu.Context
						if context.Table[newKey] == nil then
							context.Table[newKey] = "newitem"
							self:setNewKeyModal(false)
							self.props.MarkDirty()
						else
							self:setNewKeyModal(true, true, newKey)
						end
					else
						self:setNewKeyModal(false)
					end
				end,
			})
			items["UITableLayout" .. self.state.RenderId] = Roact.createElement("UITableLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim2.new(0, 18, 0, 0),
				[Roact.Change.AbsoluteContentSize] = function()
					self:calcSize()
				end,
				[Roact.Ref] = self.UITableLayout,
			})
			items[self._labelKey] = Roact.createElement(ItemViewer, {
				Key = self.props.Key,
				Value = self.props.Table,
				Level = self.props.Level,
				ShowCaret = true,
				CaretRotation = (self.state.Expanded and 90 or 0),
				CaretDisabled = (next(self.props.Table) == nil),
				LayoutOrder = 0,
				OnClicked = function()
					if next(self.props.Table) == nil then
						return
					end
					self:toggleExpanded()
				end,
				RightClicked = function(x, y, rbx)
					local tbl = self.props.Table
					local context = { Table = tbl, Key = self.props.Key, Value = tbl, Rbx = rbx }
					local pos = UDim2.new(0, x, 0, y)
					if #tbl > 0 then
						self:setContextMenu(true, context, pos, {
							{ Type = "button", Value = "insert_first", Text = "Insert First" },
							{ Type = "button", Value = "insert_last", Text = "Insert Last" },
						})
					elseif next(tbl) ~= nil then
						self:setContextMenu(true, context, pos, {
							{ Type = "button", Value = "insert_into", Text = "Insert Into" },
						})
					else
						self:setContextMenu(true, context, pos, {
							{ Type = "button", Value = "insert_first", Text = "Insert (Array)" },
							{ Type = "button", Value = "insert_into", Text = "Insert (Dictionary)" },
						})
					end
				end,
			})
			local order = 0
			local function ScanItems(tbl, subLvl)
				local itemsArray = table.create(#tbl)
				for k, v in pairs(tbl) do
					table.insert(itemsArray, { k, v })
				end
				if #tbl > 0 then
					table.sort(itemsArray, function(a, b)
						return a[1] < b[1]
					end)
				else
					table.sort(itemsArray, function(a, b)
						return tostring(a[1]) < tostring(b[1])
					end)
				end
				for _, v in itemsArray do
					order += 1
					if type(v[2]) == "table" then
						local expandedKey = tostring(v[2])
						local initiallyExpanded = self.state[expandedKey]
						items[tostring(v[2])] = Roact.createElement(ItemViewer, {
							Key = v[1],
							Value = v[2],
							Level = subLvl,
							LayoutOrder = order,
							ShowCaret = true,
							CaretRotation = (initiallyExpanded and 90 or 0),
							CaretDisabled = (next(v[2]) == nil),
							Visible = self.state.Expanded,
							OnClicked = function()
								if self.state[expandedKey] then
									self:setState({
										[expandedKey] = false,
										RenderId = self.state.RenderId + 1,
									})
								else
									self:setState({
										[expandedKey] = true,
									})
								end
							end,
							RightClicked = function(x, y, rbx)
								local context = { Table = tbl, Key = v[1], Value = v[2], Rbx = rbx }
								local pos = UDim2.new(0, x, 0, y)
								local isInArray = (#tbl > 0)
								if #v[2] > 0 then
									self:setContextMenu(true, context, pos, {
										{ Type = "button", Value = "insert_first", Text = "Insert First" },
										{ Type = "button", Value = "insert_last", Text = "Insert Last" },
										{ Type = "divider" },
										{
											Type = "button",
											Value = isInArray and "delete_array" or "delete_dict",
											Text = "Delete Table",
										},
									})
								elseif next(v[2]) ~= nil then
									self:setContextMenu(true, context, pos, {
										{ Type = "button", Value = "insert_into", Text = "Insert Into" },
										{ Type = "divider" },
										{
											Type = "button",
											Value = isInArray and "delete_array" or "delete_dict",
											Text = "Delete Table",
										},
									})
								else
									self:setContextMenu(true, context, pos, {
										{ Type = "button", Value = "insert_first", Text = "Insert (Array)" },
										{ Type = "button", Value = "insert_into", Text = "Insert (Dictionary)" },
										{ Type = "divider" },
										{
											Type = "button",
											Value = isInArray and "delete_array" or "delete_dict",
											Text = "Delete Table",
										},
									})
								end
							end,
						})
						if initiallyExpanded then
							ScanItems(v[2], subLvl + 1)
						end
					else
						items[tostring(tbl) .. "_" .. v[1]] = Roact.createElement(ItemViewer, {
							Key = v[1],
							Value = v[2],
							Level = subLvl,
							LayoutOrder = order,
							Visible = self.state.Expanded,
							SubmitChange = function(text)
								local newValue = DataVer:Verify(text)
								tbl[v[1]] = newValue
								if type(newValue) ~= type(v[2]) then
									task.defer(function()
										self:incNum()
									end)
								end
								return newValue
							end,
							RightClicked = function(x, y, rbx)
								local context = { Table = tbl, Key = v[1], Value = v[2], Rbx = rbx }
								local pos = UDim2.new(0, x, 0, y)
								if #tbl > 0 then
									self:setContextMenu(true, context, pos, {
										{ Type = "button", Value = "insert_before", Text = "Insert Before" },
										{ Type = "button", Value = "insert_after", Text = "Insert After" },
										{ Type = "divider" },
										{
											Type = "button",
											Value = "move_up",
											Text = "Move Up",
											Disabled = (context.Key == 1),
										},
										{
											Type = "button",
											Value = "move_down",
											Text = "Move Down",
											Disabled = (context.Key == #context.Table),
										},
										{ Type = "divider" },
										{ Type = "button", Value = "delete_array_index", Text = "Delete" },
									})
								else
									self:setContextMenu(true, context, pos, {
										{ Type = "button", Value = "insert", Text = "Insert" },
										{ Type = "divider" },
										{ Type = "button", Value = "delete_dict_index", Text = "Delete" },
									})
								end
							end,
						})
					end
				end
			end
			ScanItems(self.props.Table, self.props.Level + 1)
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = self.props.LayoutOrder or 0,
				Size = self.state.Size,
				Visible = (self.props.Visible == nil and true or not not self.props.Visible),
			}, items)
		end,
	})
end

TableViewer = RoactRodux.connect(function(_state)
	return {}
end, function(dispatch)
	return {
		MarkDirty = function()
			dispatch({ type = "MarkDirty" })
		end,
	}
end)(TableViewer)

return TableViewer