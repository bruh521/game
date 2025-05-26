local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local ThemeContext = require(script.Parent.ThemeContext)
local Spinner = require(script.Parent.Spinner)
local Container = require(script.Parent.Container)
local Button = require(script.Parent.Button)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local InputBox = require(script.Parent.InputBox)
local Constants = require(script.Parent.Parent.Plugin.Constants)

local DataNil = Constants.DataNil
local LoadMoreButtonKey = {}
local LoadingMoreLabelKey = {}
local ErrorKey = {}

local StoreListContainer = Roact.Component:extend("StoreListContainer")

function StoreListContainer:init()
	self:setState({
		LoadedStores = DataNil,
		FetchingPage = self.props.DataError == "",
		StorePrefixInput = self.props.StorePrefixInput or "",
		StorePrefix = self.props.StorePrefixInput or "",
	})
	if self.props.Stores ~= DataNil then
		self:fetchNextPage(true)
	end
end

function StoreListContainer:didUpdate(prevProps, _prevState)
	if self.props.Stores ~= prevProps.Stores or self.props.DataError ~= prevProps.DataError then
		if self.props.Stores == DataNil then
			self:setState({
				LoadedStores = DataNil,
				FetchingPage = self.props.DataError == "",
			})
		else
			self:fetchNextPage(true)
		end
	end
end

function StoreListContainer:cancelCurrentPageFetch()
	if self.pageFetchPromise then
		self.pageFetchPromise:cancel()
		self.pageFetchPromise = nil
	end
end

function StoreListContainer:fetchNextPage(initial)
	if self.props.Stores ~= DataNil then
		self:cancelCurrentPageFetch()
		if initial then
			self:setState({
				LoadedStores = self.props.Stores:GetCurrentPage(),
				FetchingPage = false,
			})
		elseif not self.props.Stores.IsFinished then
			self:setState({
				FetchingPage = true,
			})
			self.pageFetchPromise = Promise.new(function(resolve, reject, onCancel)
				local cancelled = false
				onCancel(function()
					cancelled = true
				end)
				local success, err = pcall(function()
					self.props.Stores:AdvanceToNextPageAsync()
				end)
				if cancelled then
					return
				end
				self.pageFetchPromise = nil
				if success then
					resolve(self.props.Stores:GetCurrentPage())
				else
					reject(err)
				end
			end)
			self.pageFetchPromise
				:andThen(function(page)
					local stores = table.create(#self.state.LoadedStores + #page)
					table.move(self.state.LoadedStores, 1, #self.state.LoadedStores, 1, stores)
					table.move(page, 1, #page, #self.state.LoadedStores + 1, stores)
					self:setState({
						LoadedStores = stores,
						FetchingPage = false,
					})
				end)
				:finally(function()
					self:setState({
						FetchingPage = false,
					})
				end)
		end
	end
end

function StoreListContainer:willUnmount()
	self:cancelCurrentPageFetch()
end

function StoreListContainer:render()
	local offset = (Constants.SideMenuButtonSize + (Constants.SideMenuPadding * 2))

	local stores = self.state.LoadedStores
	local storesChildren = {}

	if stores == DataNil then
		stores = {}
	end

	for i, dataStoreInfo in stores do
		local dataStoreName = dataStoreInfo.DataStoreName
		storesChildren[dataStoreName] = Roact.createElement(Button, {
			LayoutOrder = i,
			ImageColor = "CheckedFieldBorder",
			TextColor = "DialogMainButtonText",
			Label = dataStoreName,
			Size = UDim2.new(1, 0, 0, 30),
			OnActivated = function()
				self.props.SelectStore(dataStoreName)
			end,
		})
	end

	if self.props.DataError ~= "" then
		storesChildren[ErrorKey] = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "Error fetching DataStores",
					TextSize = 20,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			end,
		})
	elseif (not self.props.Stores.IsFinished) and not self.state.FetchingPage then
		storesChildren[LoadMoreButtonKey] = Roact.createElement(Button, {
			LayoutOrder = #stores + 1,
			ImageColor = "DialogMainButton",
			TextColor = "DialogMainButtonText",
			Label = "Load More",
			Size = UDim2.new(1, 0, 0, 30),
			OnActivated = function()
				if self.pageFetchPromise then
					return
				end
				self:fetchNextPage()
			end,
		})
	elseif (not self.props.Stores.IsFinished) and self.state.FetchingPage then
		storesChildren[LoadingMoreLabelKey] = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					LayoutOrder = #stores + 1,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "Fetching stores...",
					TextSize = 20,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
					Visible = self.props.FetchingData,
				}, {
					Spinner = Roact.createElement(Spinner, {
						Show = self.props.FetchingData,
						Color = theme.MainText.Default,
					}),
				})
			end,
		})
	end

	return Roact.createElement(Container, {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, offset, 0, 0),
		Size = UDim2.new(1, -offset, 1, 0),
		Padding = 10,
		Overlay = self.props.ShowSideMenu,
	}, {
		SizeConstraint = Roact.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(400, math.huge),
		}),
		TopBar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, {
			StorePrefixSearch = Roact.createElement(InputBox, {
				Active = not self.props.ShowSideMenu,
				Placeholder = "DataStore Name Prefix",
				Text = self.state.StorePrefixInput,
				OnInput = function(text)
					self:setState({ StorePrefixInput = text })
				end,
				OnFocusLost = function()
					if self.state.StorePrefix == self.state.StorePrefixInput then
						return
					end
					self.props.SetStorePrefix(self.state.StorePrefixInput)
					self.props.Refresh()
					self:setState({ StorePrefix = self.state.StorePrefixInput })
				end,
				OnCleared = function()
					self.props.SetStorePrefix("")
					self.props.Refresh()
					self:setState({ StorePrefix = "" })
				end,
			}),
		}),
		StoreListViewer = Roact.createElement(ScrollingFrame, {
			NoScrollX = true,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(1, 0, 1, -40),
			BackgroundTransparency = 1,
		}, storesChildren),
	})
end

StoreListContainer = RoactRodux.connect(function(state)
	return {
		Stores = state.Stores,
		StorePrefixInput = state.StorePrefix,
		ShowSideMenu = state.ShowSideMenu,
		DataError = state.DataError,
	}
end, function(dispatch)
	return {
		SetStorePrefix = function(storePrefix)
			dispatch({ type = "StorePrefix", StorePrefix = storePrefix })
			dispatch({ type = "Stores", Stores = DataNil })
		end,
		SelectStore = function(storeName)
			dispatch({ type = "Connected", Connected = false, ConnectedView = "" })
			dispatch({ type = "DSName", DSName = storeName })
			dispatch({ type = "DSScope", DSScope = "" })
			dispatch({ type = "SideMenu", Show = true })
		end,
		Refresh = function()
			dispatch({ type = "Refresh" })
		end,
	}
end)(StoreListContainer)

return StoreListContainer