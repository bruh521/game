local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local ThemeContext = require(script.Parent.ThemeContext)
local Container = require(script.Parent.Container)
local InputBox = require(script.Parent.InputBox)
local SearchInput = require(script.Parent.SearchInput)
local DataViewer = require(script.Parent.DataViewer)
local Button = require(script.Parent.Button)
local App = require(script.Parent.Parent.Plugin.App)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local DataFetch = require(script.Parent.Parent.Plugin.DataFetch)
local FileIO = require(script.Parent.Parent.Plugin.FileIO)
local DataNil = require(script.Parent.Parent.Plugin.Constants).DataNil
local DataUsage = require(script.Parent.DataUsage)

-- local HttpService = game:GetService("HttpService")

local DataContainer = Roact.Component:extend("DataContainer")

function DataContainer:init()
	self.ShowOrderedData = (self.props.UseOrdered and self.props.Key == "")
	if self.ShowOrderedData and self.props.Data ~= DataNil then
		self:initOrderedState()
	end
end

function DataContainer:initOrderedState()
	self:setState({
		Pages = { self.props.Data:GetCurrentPage() },
		CurrentPage = 1,
	})
end

function DataContainer:didUpdate(prevProps)
	local showOrdered = (self.props.UseOrdered and self.props.Key == "")
	if
		(showOrdered ~= self.ShowOrderedData or (showOrdered and prevProps.Data ~= self.props.Data))
		and self.props.Data ~= DataNil
	then
		self.ShowOrderedData = showOrdered
		if showOrdered then
			self:initOrderedState()
		end
	end
end

function DataContainer:nextPage()
	if not self.ShowOrderedData then
		return
	end
	if self.state.CurrentPage == #self.state.Pages then
		if self.props.Data.IsFinished then
			return
		end
		self.props.Data:AdvanceToNextPageAsync()
		local page = self.props.Data:GetCurrentPage()
		local pages = self.state.Pages
		table.insert(pages, page)
		self:setState({
			Pages = pages,
			CurrentPage = #pages,
		})
	else
		self:setState({
			CurrentPage = (self.state.CurrentPage + 1),
		})
	end
end

function DataContainer:prevPage()
	if not self.ShowOrderedData then
		return
	end
	if self.state.CurrentPage == 1 then
		return
	end
	self:setState({
		CurrentPage = (self.state.CurrentPage - 1),
	})
end

--[[
function DataContainer:validateAndSanitizeData(data: unknown, dataVersion: number?)
	if not dataVersion then
		return pcall(function()
			return HttpService:JSONDecode(HttpService:JSONEncode(data))
		end)
	end

	if dataVersion == 1 then
		return pcall(function()
			assert(typeof(data) == "string", "expected string")
			return FileIO:Decode(data)
		end)
	else
		return false, "unknown version"
	end
end
]]

function DataContainer:render()
	local offset = (Constants.SideMenuButtonSize + (Constants.SideMenuPadding * 2))
	local showOrderedData = (self.props.UseOrdered and self.props.Key == "")

	local topbarItems = {}
	if showOrderedData then
		topbarItems.TopRow = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Search = Roact.createElement(SearchInput, {
				Active = not self.props.ShowSideMenu,
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 0,
				MaxWidth = 350,
			}),
		})
		topbarItems.BottomRow = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			Position = UDim2.new(0, 0, 0, 40),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			MinInput = Roact.createElement(InputBox, {
				Placeholder = "Min Value",
				Width = 100,
				LayoutOrder = 0,
				Text = self.props.OrderedMin ~= DataNil and self.props.OrderedMin or "",
				FilterText = function(text)
					if text == "" then
						return text
					end
					return text:match("^%-?%d*")
				end,
				OnFocusLost = function(_submitted, text, rbx)
					if text == "" then
						self.props.SetOrderedMin(DataNil)
						return
					end
					local n = tonumber(text)
					if n and text:match("^%-?%d*") then
						if self.props.OrderedMax ~= DataNil and n > self.props.OrderedMax then
							n = self.props.OrderedMax
							rbx.Text = tostring(n)
						end
						self.props.SetOrderedMin(n)
					else
						rbx.Text = self.props.OrderedMin ~= DataNil and self.props.OrderedMin or ""
					end
				end,
			}),
			MaxInput = Roact.createElement(InputBox, {
				Placeholder = "Max Value",
				Width = 100,
				LayoutOrder = 1,
				Text = self.props.OrderedMax ~= DataNil and self.props.OrderedMax or "",
				FilterText = function(text)
					if text == "" then
						return text
					end
					return text:match("^%-?%d*")
				end,
				OnFocusLost = function(_submitted, text, rbx)
					if text == "" then
						self.props.SetOrderedMax(DataNil)
						return
					end
					local n = tonumber(text)
					if n and text:match("^%-?%d*") then
						if self.props.OrderedMin ~= DataNil and n < self.props.OrderedMin then
							n = self.props.OrderedMin
							rbx.Text = tostring(n)
						end
						self.props.SetOrderedMax(n)
					else
						rbx.Text = self.props.OrderedMax ~= DataNil and self.props.OrderedMax or ""
					end
				end,
			}),
			AscendButton = Roact.createElement(Button, {
				Icon = self.props.OrderedAscend and "rbxassetid://5516412893" or "rbxassetid://5516411715",
				IconSize = UDim2.new(0, 16, 0, 16),
				Label = self.props.OrderedAscend and "Ascend" or "Descend",
				Tooltip = "Order",
				ImageColor = "DialogMainButton",
				TextColor = "DialogMainButtonText",
				Size = UDim2.new(0, 30, 0, 30),
				LayoutOrder = 2,
				OnActivated = function()
					self.props.SetOrderedAscend(not self.props.OrderedAscend)
				end,
			}),
			PrevButton = Roact.createElement(Button, {
				Icon = "rbxassetid://5516412197",
				IconSize = UDim2.new(0, 16, 0, 16),
				Label = "Prev",
				Tooltip = "Previous",
				ImageColor = "DialogMainButton",
				TextColor = "DialogMainButtonText",
				Size = UDim2.new(0, 30, 0, 30),
				LayoutOrder = 3,
				Disabled = (self.state.CurrentPage == 1),
				OnActivated = function()
					self:prevPage()
				end,
			}),
			PageLabel = Roact.createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 30, 0, 30),
						FontFace = Constants.Font.Regular,
						Text = tostring(self.state.CurrentPage or 1)
							.. (
								self.props.Data ~= DataNil
									and self.props.Data.IsFinished
									and self.state.Pages
									and (" / " .. #self.state.Pages)
								or ""
							),
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Center,
						LayoutOrder = 4,
					})
				end,
			}),
			NextButton = Roact.createElement(Button, {
				Icon = "rbxassetid://5516412563",
				IconSize = UDim2.new(0, 16, 0, 16),
				Label = "Next",
				Tooltip = "Next",
				ImageColor = "DialogMainButton",
				TextColor = "DialogMainButtonText",
				Size = UDim2.new(0, 30, 0, 30),
				LayoutOrder = 5,
				Disabled = (
					self.props.Data ~= DataNil
					and self.props.Data.IsFinished
					and self.state.CurrentPage
					and self.state.CurrentPage == #self.state.Pages
				),
				OnActivated = function()
					self:nextPage()
				end,
			}),
		})
	else
		topbarItems.UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		topbarItems.Search = Roact.createElement(SearchInput, {
			Active = not self.props.ShowSideMenu,
			Size = UDim2.new(1, -200, 1, 0),
			LayoutOrder = 0,
			Text = self.props.Key,
			MaxWidth = 350,
		})
		topbarItems.ImportButton = Roact.createElement(Button, {
			Icon = "rbxassetid://5516414010",
			IconSize = UDim2.new(0, 16, 0, 16),
			Label = "Import",
			Tooltip = "Import",
			ImageColor = "DialogMainButton",
			TextColor = "DialogMainButtonText",
			Size = UDim2.new(0, 30, 0, 30),
			Disabled = (self.props.Key == "" or self.props.FetchingData or self.props.SavingData),
			LayoutOrder = 1,
			OnActivated = function(_rbx)
				-- local dataVersion, data = FileIO:PromptLoadFile()
				-- if data then
				-- 	local isValid, newData = self:validateAndSanitizeData(data, dataVersion)
				-- 	if isValid then
				-- 		self.props.OnImportedData(newData)
				-- 	else
				-- 		self.props.ShowAlert("Import Error", tostring(newData))
				-- 	end
				-- end
				local contents = FileIO:PromptLoadFile()
				if contents then
					local success, data = pcall(function()
						return FileIO:Decode(contents)
					end)
					if success then
						self.props.OnImportedData(data)
					else
						self.props.ShowAlert("Import Error", tostring(data))
					end
				end
			end,
		})
		topbarItems.ExportButton = Roact.createElement(Button, {
			Icon = "rbxassetid://5516413670",
			IconSize = UDim2.new(0, 16, 0, 16),
			Label = "Export",
			Tooltip = "Export",
			ImageColor = "DialogMainButton",
			TextColor = "DialogMainButtonText",
			Size = UDim2.new(0, 30, 0, 30),
			Disabled = (self.props.Data == Constants.DataNil or self.props.FetchingData or self.props.SavingData),
			LayoutOrder = 2,
			OnActivated = function(_rbx)
				local data = self.props.Data
				-- local version = "--version.0001\n\n"
				-- local header =
				-- 	"--[[\n\tDataStore Editor Plugin - Exported Data\n\n\tGameId: %i\n\tPlaceId: %i\n\n\tDataStore Key: %q\n\tDataStore Name: %q\n\tDataStore Scope: %q\n--]]"

				-- local scope = self.props.DSScope
				-- if scope == "" then
				-- 	scope = "global"
				-- end

				-- local contents = version
				-- 	.. header:format(game.GameId, game.PlaceId, self.props.DSName, scope, self.props.Key)
				-- 	.. "\n\nreturn [==========["
				-- 	.. FileIO:Encode(data)
				-- 	.. "]==========]\n"

				-- FileIO:PromptSaveFile(self.props.Key, contents)

				local meta = {
					Key = self.props.Key,
					DSName = self.props.DSName,
					DSScope = self.props.DSScope,
				}
				if meta.DSScope == "" then
					meta.DSScope = "global"
				end
				FileIO:PromptSaveFile(self.props.Key, FileIO:Encode(data, meta))
			end,
		})
		topbarItems.RefreshButton = Roact.createElement(Button, {
			Icon = "rbxassetid://5950842824",
			IconSize = UDim2.new(0, 16, 0, 16),
			Label = "Refresh",
			Tooltip = "Refresh",
			ImageColor = "DialogMainButton",
			TextColor = "DialogMainButtonText",
			Size = UDim2.new(0, 30, 0, 30),
			Disabled = (self.props.Key == "" or self.props.FetchingData or self.props.SavingData),
			LayoutOrder = 3,
			OnActivated = function(_rbx)
				self.props.Refresh()
			end,
		})
		topbarItems.SaveButton = Roact.createElement(Button, {
			Icon = "rbxassetid://5516414743",
			IconSize = UDim2.new(0, 16, 0, 16),
			Label = "Save",
			Tooltip = "Save",
			ImageColor = "DialogMainButton",
			TextColor = "DialogMainButtonText",
			Size = UDim2.new(0, 30, 0, 30),
			Disabled = (not self.props.DataDirty) or self.props.FetchingData or self.props.SavingData,
			LayoutOrder = 4,
			OnActivated = function(_rbx)
				local success, err = DataFetch:Save(App:GetStore():getState()):await()
				if not success then
					warn(err)
				end
			end,
		})
		topbarItems.DeleteButton = Roact.createElement(Button, {
			Icon = "rbxassetid://5516413280",
			IconSize = UDim2.new(0, 16, 0, 16),
			Label = "Delete",
			Tooltip = "Delete",
			ImageColor = "CheckedFieldBorder",
			TextColor = "DialogMainButtonText",
			Size = UDim2.new(0, 30, 0, 30),
			Disabled = (
				self.props.DataDirty
				or self.props.FetchingData
				or self.props.SavingData
				or self.props.Key == ""
				or self.props.Data == Constants.DataNil
			),
			LayoutOrder = 5,
			OnActivated = function(_rbx)
				self.props.ShowFrame("DeleteKey")
			end,
		})
	end

	return Roact.createElement(Container, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(offset, 0),
		Size = UDim2.new(1, -offset, 1, 0),
		Padding = 10,
		PaddingBottom = self.ShowOrderedData and 10 or 0,
		Visible = self.props.Connected,
		Overlay = self.props.ShowSideMenu,
	}, {
		TopBar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, topbarItems),
		DataViewer = Roact.createElement(DataViewer, {
			Position = UDim2.new(0, 0, 0, showOrderedData and 80 or 40),
			Size = UDim2.new(1, 0, 1, showOrderedData and -80 or -70),
			DataPage = (
				self.ShowOrderedData
					and self.state.Pages
					and self.state.CurrentPage
					and self.state.Pages[self.state.CurrentPage]
				or nil
			),
		}),
		DataUsage = Roact.createElement(DataUsage, {
			Visible = not self.ShowOrderedData,
		}),
	})
end

DataContainer = RoactRodux.connect(function(state)
	return {
		Data = state.Data,
		DSName = state.DSName,
		DSScope = state.DSScope,
		ShowSideMenu = state.ShowSideMenu,
		Connected = state.Connected,
		DataDirty = state.DataDirty,
		Key = state.Key,
		UseOrdered = state.UseOrdered,
		OrderedMin = state.OrderedMin,
		OrderedMax = state.OrderedMax,
		OrderedAscend = state.OrderedAscend,
		FetchingData = state.FetchingData,
		SavingData = state.SavingData,
	}
end, function(dispatch)
	return {
		OnImportedData = function(importedData)
			dispatch({ type = "Data", Data = importedData, WasImported = true })
		end,
		ShowFrame = function(frameName)
			dispatch({ type = "ShowFrame", Frame = frameName })
		end,
		SetOrderedMin = function(min)
			dispatch({ type = "OrderedMin", Min = min })
		end,
		SetOrderedMax = function(max)
			dispatch({ type = "OrderedMax", Max = max })
		end,
		SetOrderedAscend = function(ascend)
			dispatch({ type = "OrderedAscend", Ascend = ascend })
		end,
		ShowAlert = function(title, message)
			dispatch({ type = "ShowAlert", Title = title, Message = message })
		end,
		Refresh = function()
			dispatch({ type = "Refresh" })
		end,
	}
end)(DataContainer)

return DataContainer