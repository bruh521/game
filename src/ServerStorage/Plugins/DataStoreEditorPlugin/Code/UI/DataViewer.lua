local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local Spinner = require(script.Parent.Spinner)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local TableViewer = require(script.Parent.TableViewer)
local DataStorePageViewer = require(script.Parent.DataStorePageViewer)
local ItemViewer = require(script.Parent.ItemViewer)
local DataVer = require(script.Parent.Parent.Plugin.DataVer)
local PluginWidget = require(script.Parent.Parent.Plugin.PluginWidget)
local Button = require(script.Parent.Button)
local ContextMenu = require(script.Parent.ContextMenu)

local DataNil = Constants.DataNil

local DataViewer = Roact.Component:extend("DataViewer")

function DataViewer:init()
	self:setState({
		Num = 0,
		NewDataMenu = {
			Showing = false,
			Position = UDim2.new(),
			Items = {},
		},
	})
end

function DataViewer:showNewDataMenu(items, position)
	self:setState({
		NewDataMenu = {
			Showing = true,
			Position = position,
			Items = items,
		},
	})
end

function DataViewer:hideNewDataMenu()
	self:setState({
		NewDataMenu = {
			Showing = false,
			Position = self.state.NewDataMenu.Position,
			Items = {},
		},
	})
end

function DataViewer:render()
	local showOrdered = (self.props.UseOrdered and self.props.Key == "")
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			local item
			if self.props.Data ~= nil and self.props.Data ~= DataNil then
				if type(self.props.Data) == "table" then
					-- Show table item:
					item = Roact.createElement(TableViewer, {
						Key = self.props.Key,
						Table = self.props.Data,
						Expanded = (next(self.props.Data) ~= nil),
						Level = 1,
					})
				elseif showOrdered then
					item = Roact.createElement(DataStorePageViewer, {
						DataPage = self.props.DataPage,
					})
				else
					-- Show item:
					item = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 30),
					}, {
						UITableLayout = Roact.createElement("UITableLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim2.new(0, 20, 0, 0),
						}),
						Item = Roact.createElement(ItemViewer, {
							Key = self.props.Key,
							Value = self.props.Data,
							Level = 1,
							FilterText = function(text)
								if self.props.UseOrdered then
									return text:match("^%-?%d*")
								else
									return text
								end
							end,
							SubmitChange = function(text)
								if self.props.UseOrdered then
									local n = tonumber(text)
									if n and text:match("^%-?%d*") then
										return n
									else
										return 0
									end
								else
									local newValue = DataVer:Verify(text)
									self.props.SetSingleItemData(newValue)
									return newValue
								end
							end,
						}),
					})
				end
			elseif (self.props.Key ~= "" or showOrdered) and not self.props.FetchingData then
				-- Item to show when no data is available for a given key:
				item = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
				}, {
					NewDataContextMenu = Roact.createElement(ContextMenu, {
						Showing = self.state.NewDataMenu.Showing,
						Position = self.state.NewDataMenu.Position,
						Items = self.state.NewDataMenu.Items,
						OnHide = function(itemValue)
							if itemValue then
								local newValue = nil
								if itemValue == "string" then
									newValue = "item"
								elseif itemValue == "number" then
									newValue = 0
								elseif itemValue == "boolean_true" then
									newValue = true
								elseif itemValue == "boolean_false" then
									newValue = false
								elseif itemValue == "table" then
									newValue = {}
								end
								if newValue ~= nil then
									self.props.SetSingleItemData(newValue)
									self.props.MarkDirty()
								end
							end
							self:hideNewDataMenu()
						end,
					}),
					NoDataLabel = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 120, 0, 30),
						FontFace = Constants.Font.Regular,
						Text = "No Data",
						TextSize = 20,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					CreateDataButton = Roact.createElement(Button, {
						Label = "Create Data",
						ImageColor = "DialogMainButton",
						TextColor = "DialogMainButtonText",
						Size = UDim2.new(0, 90, 0, 30),
						Position = UDim2.new(0, 80, 0, 0),
						Disabled = false,
						OnActivated = function(_rbx)
							if self.props.UseOrdered then
								self.props.SetSingleItemData(0)
								self.props.MarkDirty()
							else
								local items = {
									{ Type = "button", Value = "string", Text = "String" },
									{ Type = "button", Value = "number", Text = "Number" },
									{ Type = "button", Value = "boolean_true", Text = "Boolean (true)" },
									{ Type = "button", Value = "boolean_false", Text = "Boolean (false)" },
									{ Type = "button", Value = "table", Text = "Table" },
								}
								local pos = PluginWidget:GetMousePosition()
								self:showNewDataMenu(items, UDim2.new(0, pos.X, 0, pos.Y))
							end
						end,
					}),
				})
			end
			return Roact.createElement(ScrollingFrame, {
				Size = self.props.Size,
				Position = self.props.Position,
			}, {
				LoadingMessage = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "Fetching data...",
					TextSize = 20,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
					Visible = self.props.FetchingData,
				}, {
					Spinner = Roact.createElement(Spinner, {
						Show = self.props.FetchingData,
						Color = theme.MainText.Default,
					}),
				}),
				Viewer = item,
			})
		end,
	})
end

DataViewer = RoactRodux.connect(function(state)
	return {
		Data = state.Data,
		DataError = state.DataError,
		FetchingData = state.FetchingData,
		Key = state.Key,
		UseOrdered = state.UseOrdered,
	}
end, function(dispatch)
	return {
		SetSingleItemData = function(data)
			dispatch({ type = "Data", Data = data })
		end,
		MarkDirty = function()
			dispatch({ type = "MarkDirty" })
		end,
	}
end)(DataViewer)

return DataViewer