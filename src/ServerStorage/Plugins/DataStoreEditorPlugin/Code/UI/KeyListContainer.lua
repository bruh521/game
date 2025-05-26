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

local KeyListContainer = Roact.Component:extend("KeyListContainer")

function KeyListContainer:init()
	self:setState({
		LoadedKeys = DataNil,
		FetchingPage = self.props.DataError == "",
		KeyPrefixInput = self.props.KeyPrefixInput or "",
		KeyPrefix = self.props.KeyPrefixInput or "",
	})
	if self.props.Keys ~= DataNil then
		self:fetchNextPage(true)
	end
end

function KeyListContainer:didUpdate(prevProps, _prevState)
	if self.props.Keys ~= prevProps.Keys or self.props.DataError ~= prevProps.DataError then
		if self.props.Keys == DataNil then
			self:setState({
				LoadedKeys = DataNil,
				FetchingPage = self.props.DataError == "",
			})
		else
			self:fetchNextPage(true)
		end
	end
end

function KeyListContainer:cancelCurrentPageFetch()
	if self.pageFetchPromise then
		self.pageFetchPromise:cancel()
		self.pageFetchPromise = nil
	end
end

function KeyListContainer:fetchNextPage(initial)
	if self.props.Keys ~= DataNil then
		self:cancelCurrentPageFetch()
		if initial then
			self:setState({
				LoadedKeys = self.props.Keys:GetCurrentPage(),
				FetchingPage = false,
			})
		elseif not self.props.Keys.IsFinished then
			self:setState({
				FetchingPage = true,
			})
			self.pageFetchPromise = Promise.new(function(resolve, reject, onCancel)
				local cancelled = false
				onCancel(function()
					cancelled = true
				end)
				local success, err = pcall(function()
					self.props.Keys:AdvanceToNextPageAsync()
				end)
				if cancelled then
					return
				end
				self.pageFetchPromise = nil
				if success then
					resolve(self.props.Keys:GetCurrentPage())
				else
					reject(err)
				end
			end)
			self.pageFetchPromise
				:andThen(function(page)
					local keys = table.create(#self.state.LoadedKeys + #page)
					table.move(self.state.LoadedKeys, 1, #self.state.LoadedKeys, 1, keys)
					table.move(page, 1, #page, #self.state.LoadedKeys + 1, keys)
					self:setState({
						LoadedKeys = keys,
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

function KeyListContainer:willUnmount()
	self:cancelCurrentPageFetch()
end

function KeyListContainer:render()
	local offset = (Constants.SideMenuButtonSize + (Constants.SideMenuPadding * 2))

	local keys = self.state.LoadedKeys
	local keysChildren = {}

	if keys == DataNil then
		keys = {}
	end

	for i, dataStoreKey in keys do
		local keyName = dataStoreKey.KeyName
		keysChildren[keyName] = Roact.createElement(Button, {
			LayoutOrder = i,
			ImageColor = "CheckedFieldBorder",
			TextColor = "DialogMainButtonText",
			Label = keyName,
			Size = UDim2.new(1, 0, 0, 30),
			OnActivated = function()
				self.props.DisplayKey(keyName)
			end,
		})
	end

	if self.props.DataError ~= "" then
		keysChildren[ErrorKey] = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "Error fetching keys",
					TextSize = 20,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			end,
		})
	elseif (not self.props.Keys.IsFinished) and not self.state.FetchingPage then
		keysChildren[LoadMoreButtonKey] = Roact.createElement(Button, {
			LayoutOrder = #keys + 1,
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
	elseif (not self.props.Keys.IsFinished) and self.state.FetchingPage then
		keysChildren[LoadingMoreLabelKey] = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					LayoutOrder = #keys + 1,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "Fetching keys...",
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
	elseif self.props.Keys.IsFinished and not self.state.FetchingPage and #keys == 0 then
		keysChildren[LoadingMoreLabelKey] = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					LayoutOrder = #keys + 1,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 140, 0, 30),
					FontFace = Constants.Font.Regular,
					Text = "No keys found"
						.. (self.state.KeyPrefix == "" and "" or ' using prefix "' .. self.state.KeyPrefix .. '"'),
					TextSize = 20,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
					Visible = self.props.FetchingData,
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
			KeyPrefixSearch = Roact.createElement(InputBox, {
				Active = not self.props.ShowSideMenu,
				Placeholder = "Key Prefix",
				Text = self.state.KeyPrefixInput,
				OnInput = function(text)
					self:setState({ KeyPrefixInput = text })
				end,
				OnFocusLost = function()
					if self.state.KeyPrefix == self.state.KeyPrefixInput then
						return
					end
					self.props.SetKeyPrefix(self.state.KeyPrefixInput)
					self.props.Refresh()
					self:setState({ KeyPrefix = self.state.KeyPrefixInput })
				end,
				OnCleared = function()
					self.props.SetKeyPrefix("")
					self.props.Refresh()
					self:setState({ KeyPrefix = "" })
				end,
			}),
		}),
		KeyListViewer = Roact.createElement(ScrollingFrame, {
			NoScrollX = true,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(1, 0, 1, -40),
			BackgroundTransparency = 1,
		}, keysChildren),
	})
end

KeyListContainer = RoactRodux.connect(function(state)
	return {
		Keys = state.Keys,
		KeyPrefixInput = state.KeyPrefix,
		ShowSideMenu = state.ShowSideMenu,
		DSName = state.DSName,
		DSScope = state.DSScope,
		DataError = state.DataError,
	}
end, function(dispatch)
	return {
		SetKeyPrefix = function(keyPrefix)
			dispatch({ type = "KeyPrefix", KeyPrefix = keyPrefix })
			dispatch({ type = "Keys", Keys = DataNil })
		end,
		DisplayKey = function(key)
			dispatch({ type = "Connected", Connected = true, ConnectedView = "DataContainer" })
			dispatch({ type = "Key", Key = key })
		end,
		Refresh = function()
			dispatch({ type = "Refresh" })
		end,
	}
end)(KeyListContainer)

return KeyListContainer