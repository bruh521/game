local Button = require(script.Parent.Button)
local CheckBox = require(script.Parent.CheckBox)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local Container = require(script.Parent.Container)
local IconButton = require(script.Parent.IconButton)
local InputBox = require(script.Parent.InputBox)
local Profiles = require(script.Parent.Parent.Plugin.Profiles)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local ThemeContext = require(script.Parent.ThemeContext)

local SIDE_MENU_WIDTH = Constants.SideMenuWidth
local PADDING = Constants.SideMenuPadding
local MENU_BUTTON_SIZE = Constants.SideMenuButtonSize

local SideMenu = Roact.Component:extend("SideMenu")

local TweenService = game:GetService("TweenService")

function SideMenu:init()
	self:setState({
		Position = UDim2.new(0, 0, 0, 0),
		DSNameInput = self.props.DSNameText,
		DSScopeInput = self.props.DSScopeText,
		UseOrdered = self.props.UseOrdered,
		UseGlobal = self.props.UseGlobal,
	})
	self.FrameRef = Roact.createRef()
	self.ListTopRef = Roact.createRef()
	self.ListBottomRef = Roact.createRef()
	self._tweens = {}
end

function SideMenu:tweenPosition(ref, pos)
	if self._tweens[ref] then
		self._tweens[ref]:Cancel()
		self._tweens[ref]:Destroy()
	end
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(ref:getValue(), tweenInfo, { Position = pos })
	tween:Play()
	tween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			self._tweens[ref] = nil
			tween:Destroy()
		end
	end)
	self._tweens[ref] = tween
end

function SideMenu:shouldUpdate(props)
	local shouldUpdate = props.Show == self.props.Show or not next(self._tweens)
	return shouldUpdate
end

function SideMenu:willUpdate(nextProps)
	if nextProps.Show ~= self.props.Show then
		if nextProps.Show then
			self:tweenPosition(self.FrameRef, UDim2.new(0, 0, 0, 0))
			self:tweenPosition(self.ListTopRef, UDim2.new(0, 0, 0, 0))
			self:tweenPosition(self.ListBottomRef, UDim2.new(0, 0, 0, 0))
		else
			self:tweenPosition(self.FrameRef, UDim2.new(0, -(SIDE_MENU_WIDTH - (PADDING * 2) - MENU_BUTTON_SIZE), 0, 0))
			self:tweenPosition(self.ListTopRef, UDim2.new(0, -(PADDING + MENU_BUTTON_SIZE), 0, 0))
			self:tweenPosition(self.ListBottomRef, UDim2.new(0, -(PADDING + MENU_BUTTON_SIZE), 0, 0))
		end
	end
end

function SideMenu:didUpdate(prevProps)
	if
		prevProps.DSNameText ~= self.props.DSNameText
		or prevProps.DSScopeText ~= self.props.DSScopeText
		or prevProps.UseOrdered ~= self.props.UseOrdered
		or prevProps.UseGlobal ~= self.props.UseGlobal
	then
		self:setState({
			DSNameInput = self.props.DSNameText,
			DSScopeInput = self.props.DSScopeText,
			UseOrdered = self.props.UseOrdered,
			UseGlobal = self.props.UseGlobal,
		})
	end
end

function SideMenu:willUnmount()
	for _, tween in pairs(self._tweens) do
		tween:Destroy()
	end
end

function SideMenu:render()
	local hasProfile = Profiles:FindFirstFromProperties(
		self.state.DSNameInput,
		self.state.DSScopeInput,
		self.state.UseOrdered,
		game.GameId
	) ~= nil
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = theme.MainBackground.Default,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Size = UDim2.new(0, SIDE_MENU_WIDTH, 1, 0),
				Position = self.state.Position,
				ZIndex = 2,
				[Roact.Ref] = self.FrameRef,
			}, {
				Content = Roact.createElement(Container, { Transparency = 1, Padding = PADDING }, {
					MenuButton = Roact.createElement("ImageButton", {
						AnchorPoint = Vector2.new(1, 0),
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(0, MENU_BUTTON_SIZE, 0, MENU_BUTTON_SIZE),
						ImageColor3 = theme.MainText.Default,
						Image = "rbxassetid://5051226242",
						Visible = self.props.Connected,
						[Roact.Event.Activated] = function(rbx)
							rbx.ImageColor3 = theme.MainText.Default
							self.props.SetMenuShown(not self.props.Show)
						end,
						[Roact.Event.MouseEnter] = function(rbx)
							rbx.ImageColor3 = theme.MainText.Hover
						end,
						[Roact.Event.MouseLeave] = function(rbx)
							rbx.ImageColor3 = theme.MainText.Default
						end,
					}),
					ListTop = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						[Roact.Ref] = self.ListTopRef,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							Padding = UDim.new(0, 10),
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),
						TopItem = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, MENU_BUTTON_SIZE),
							LayoutOrder = 0,
						}, {
							Title = Roact.createElement("TextLabel", {
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 1, 0),
								LayoutOrder = 0,
								FontFace = Constants.Font.Regular,
								Text = "Connect to DataStore",
								TextSize = 16,
								TextColor3 = theme.MainText.Default,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
							SaveButton = Roact.createElement(IconButton, {
								Icon = "rbxassetid://5516414743",
								ImageColor = "MainText",
								Tooltip = "Save Connection",
								Size = UDim2.new(0, 16, 0, 16),
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, self.props.Connected and -52 or -26, 0, 0),
								Disabled = (hasProfile or self.state.DSNameInput == "" or self.state.UseGlobal),
								OnActivated = function()
									self.props.SetInputs(
										self.state.DSNameInput,
										self.state.DSScopeInput,
										self.state.UseOrdered,
										self.state.UseGlobal
									)
									self.props.ShowFrame("SaveProfile")
								end,
							}),
							LoadButton = Roact.createElement(IconButton, {
								Icon = "rbxassetid://5516414405",
								ImageColor = "MainText",
								Tooltip = "Load Connection",
								Size = UDim2.new(0, 16, 0, 16),
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, self.props.Connected and -26 or 0, 0, 0),
								Disabled = false,
								OnActivated = function()
									self.props.ShowFrame("LoadProfile")
								end,
							}),
						}),
						DSName = Roact.createElement(InputBox, {
							Placeholder = "Name",
							Text = if self.state.UseGlobal then "global" else self.state.DSNameInput,
							Active = not self.state.UseGlobal,
							LayoutOrder = 1,
							OnInput = function(text)
								if self.state.UseGlobal then
									return
								end
								self:setState({ DSNameInput = text })
							end,
						}),
						DSScope = Roact.createElement(InputBox, {
							Placeholder = "Scope",
							Text = if self.state.UseGlobal then "global" else self.state.DSScopeInput,
							Active = not self.state.UseGlobal,
							LayoutOrder = 2,
							OnInput = function(text)
								if self.state.UseGlobal then
									return
								end
								self:setState({ DSScopeInput = text })
							end,
						}),
						OrderedDataStore = Roact.createElement(CheckBox, {
							Label = "Use OrderedDataStore",
							LayoutOrder = 3,
							Checked = self.state.UseOrdered,
							OnChecked = function(checked)
								self:setState({ UseOrdered = checked })
								if checked then
									self:setState({ UseGlobal = false })
								end
							end,
						}),
						GlobalDataStore = Roact.createElement(CheckBox, {
							Label = "Use GlobalDataStore",
							LayoutOrder = 4,
							Checked = self.state.UseGlobal,
							OnChecked = function(checked)
								self:setState({ UseGlobal = checked })
								if checked then
									self:setState({ UseOrdered = false })
								end
							end,
						}),
						ButtonList = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),
							LayoutOrder = 5,
						}, {
							UIListLayout = Roact.createElement("UIListLayout", {
								Padding = UDim.new(0, 10),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							ConnectButton = Roact.createElement(Button, {
								Label = "Connect",
								ImageColor = "DialogMainButton",
								TextColor = "DialogMainButtonText",
								Size = UDim2.new(0.5, -5, 1, 0),
								LayoutOrder = 1,
								Disabled = (self.state.DSNameInput == "" and not self.state.UseGlobal),
								OnActivated = function()
									self.props.TextChanged("DSName", self.state.DSNameInput)
									self.props.TextChanged("DSScope", self.state.DSScopeInput)
									self.props.OrderedChanged(self.state.UseOrdered)
									self.props.GlobalChanged(self.state.UseGlobal)
									self.props.SetMenuShown(false)
									self.props.SetConnected(true, "DataContainer")
									self.props.ClearKey()
								end,
							}),
							ListKeysButton = Roact.createElement(Button, {
								Label = "List Keys",
								ImageColor = "DialogMainButton",
								TextColor = "DialogMainButtonText",
								Size = UDim2.new(0.5, -5, 1, 0),
								LayoutOrder = 2,
								Disabled = (
									(self.state.DSNameInput == "" and not self.state.UseGlobal)
									or self.state.UseOrdered
								),
								OnActivated = function()
									self.props.TextChanged("DSName", self.state.DSNameInput)
									self.props.TextChanged("DSScope", self.state.DSScopeInput)
									self.props.GlobalChanged(self.state.UseGlobal)
									self.props.SetMenuShown(false)
									self.props.SetConnected(true, "KeyListContainer")
									self.props.Refresh()
								end,
							}),
						}),
						Sponsorship = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),
							LayoutOrder = 6,
						}, {
							UIListLayout = Roact.createElement("UIListLayout", {
								Padding = UDim.new(0, 10),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							-- SponsorshipIcon = Roact.createElement("ImageLabel", {
							-- 	Size = UDim2.new(1, 0, 1, 0),
							-- 	SizeConstraint = Enum.SizeConstraint.RelativeYY,
							-- 	LayoutOrder = 1,
							-- 	BackgroundTransparency = 1,
							-- 	Image = "",
							-- }),
							-- SponsorshipLabel = Roact.createElement("TextLabel", {
							-- 	BackgroundTransparency = 1,
							-- 	Size = UDim2.new(1, 0, 1, 0),
							-- 	LayoutOrder = 2,
							-- 	FontFace = Constants.Font.Regular,
							-- 	Text = "Supported by [NAME]",
							-- 	TextSize = 16,
							-- 	TextColor3 = theme.MainText.Default,
							-- 	TextXAlignment = Enum.TextXAlignment.Left,
							-- }),
						}),
					}),
					ListBottom = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						[Roact.Ref] = self.ListBottomRef,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							Padding = UDim.new(0, 10),
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Bottom,
						}),
						ButtonList = Roact.createElement("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),
							LayoutOrder = 2,
						}, {
							UIListLayout = Roact.createElement("UIListLayout", {
								Padding = UDim.new(0, 10),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							ListStoresButton = Roact.createElement(Button, {
								Label = "List Stores",
								ImageColor = "DialogMainButton",
								TextColor = "DialogMainButtonText",
								Size = UDim2.new(0.5, -5, 1, 0),
								LayoutOrder = 1,
								OnActivated = function()
									self.props.SetMenuShown(false)
									self.props.SetConnected(true, "StoreListContainer")
								end,
							}),
							SetPlaceId = Roact.createElement(Button, {
								Label = "Set Place ID",
								ImageColor = "CheckedFieldBorder",
								TextColor = "DialogMainButtonText",
								Size = UDim2.new(0.5, -5, 1, 0),
								LayoutOrder = 2,
								OnActivated = function()
									self.props.ShowFrame("PlaceId")
								end,
							}),
						}),
					}),
				}),
				Shadow = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 8, 1, 0),
					Image = "rbxassetid://5051528605",
					ImageTransparency = 0.7,
					ImageColor3 = Color3.new(0, 0, 0),
				}),
			})
		end,
	})
end

SideMenu = RoactRodux.connect(function(state)
	return {
		Show = state.ShowSideMenu,
		DSNameText = state.DSName,
		DSScopeText = state.DSScope,
		UseOrdered = state.UseOrdered,
		UseGlobal = state.UseGlobal,
		Connected = state.Connected,
		DSNameInputSync = state.DSNameInput,
		DSScopeInputSync = state.DSScopeInput,
		UseOrderedInputSync = state.UseOrderedInput,
		UseGlobalInputSync = state.UseGlobalInput,
	}
end, function(dispatch)
	return {
		TextChanged = function(name, value)
			dispatch({ type = name, [name] = value })
		end,
		OrderedChanged = function(isOrdered)
			dispatch({ type = "Ordered", UseOrdered = isOrdered })
		end,
		GlobalChanged = function(isGlobal)
			dispatch({ type = "Global", UseGlobal = isGlobal })
		end,
		SetMenuShown = function(show)
			dispatch({ type = "SideMenu", Show = show })
		end,
		ShowFrame = function(frameName)
			dispatch({ type = "ShowFrame", Frame = frameName })
		end,
		SetConnected = function(isConnected, connectedView)
			dispatch({ type = "Connected", Connected = isConnected, ConnectedView = connectedView })
			if connectedView == "KeyListContainer" then
				dispatch({ type = "Keys", Keys = Constants.DataNil })
			end
		end,
		SetInputs = function(dsName, dsScope, useOrdered, useGlobal)
			dispatch({
				type = "SideMenuInputs",
				DSName = dsName,
				DSScope = dsScope,
				UseOrdered = useOrdered,
				UseGlobal = useGlobal,
			})
		end,
		ClearKey = function()
			dispatch({ type = "Key", Key = "" })
		end,
		Refresh = function()
			dispatch({ type = "Refresh" })
		end,
	}
end)(SideMenu)

return SideMenu