local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local InputBox = require(script.Parent.InputBox)
local Button = require(script.Parent.Button)
local Spinner = require(script.Parent.Spinner)

local SetPlaceId = Roact.Component:extend("SetPlaceId")

function SetPlaceId:init()
	self:setState({
		PlaceName = "",
		InputPlaceId = tostring(game.PlaceId),
		ErrorMessage = "",
	})
end

function SetPlaceId:loadPlaceName()
	local delayTime = (tonumber(self.state.InputPlaceId) and 0.25 or 0)
	if self._loadDelay then
		self._loadDelay:cancel()
	end
	self._loadDelay = Promise.delay(delayTime):andThen(function()
		self:setState({ PlaceName = "__load__" })
		local id = tonumber(self.state.InputPlaceId)
		local success, info
		if id then
			success, info = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(id, Enum.InfoType.Asset)
			end)
			if success then
				success = (info.AssetTypeId == 9)
			end
		end
		if success then
			self:setState({ PlaceName = info.Name })
		else
			self:setState({ PlaceName = "" })
		end
		self._loadDelay = nil
	end)
end

function SetPlaceId:didMount()
	self:loadPlaceName()
end

function SetPlaceId:didUpdate(_prevProps, prevState)
	if self.state.InputPlaceId ~= prevState.InputPlaceId then
		self:loadPlaceName()
	end
end

function SetPlaceId:willUnmount()
	if self._loadDelay then
		self._loadDelay:cancel()
		self._loadDelay = nil
	end
end

function SetPlaceId:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 9,
	}, {
		UISizeConstraint = Roact.createElement("UISizeConstraint", {
			MinSize = Vector2.new(0, 0),
			MaxSize = Vector2.new(300, math.huge),
		}),
		Shadows = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			LeftShadow = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0, 8, 1, 0),
				Rotation = 180,
				Image = "rbxassetid://5051528605",
				ImageTransparency = 0.7,
				ImageColor3 = Color3.new(0, 0, 0),
			}),
			RightShadow = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 8, 1, 0),
				Image = "rbxassetid://5051528605",
				ImageTransparency = 0.7,
				ImageColor3 = Color3.new(0, 0, 0),
			}),
		}),
		Container = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
			}),
			Title = Roact.createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 30),
						LayoutOrder = 0,
						FontFace = Constants.Font.Regular,
						Text = "Set Place ID",
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
				end,
			}),
			PlaceId = Roact.createElement(InputBox, {
				Placeholder = "Place ID",
				Text = self.state.InputPlaceId,
				LayoutOrder = 1,
				FilterText = function(text)
					local idFromPlaceUrl = text:match("^https://www%.roblox%.com/games/(%d+)/?")
					return idFromPlaceUrl or text:gsub("%D+", "")
				end,
				OnInput = function(text)
					self:setState({ InputPlaceId = text })
				end,
			}),
			PlaceName = Roact.createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 30),
						LayoutOrder = 2,
						FontFace = if self.state.PlaceName == "" then Constants.Font.Italic else Constants.Font.Regular,
						Text = (
							self.state.PlaceName == "__load__" and ""
							or self.state.PlaceName == "" and "Invalid Place ID"
							or self.state.PlaceName
						),
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, {
						Spinner = Roact.createElement(Spinner, {
							Color = theme.MainText.Default,
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 5, 0.5, 0),
							Show = (self.state.PlaceName == "__load__"),
						}),
					})
				end,
			}),
			ButtonFrame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = 3,
			}, {
				SetPlaceId = Roact.createElement(Button, {
					Label = "Set Place ID",
					ImageColor = "DialogMainButton",
					TextColor = "DialogMainButtonText",
					Size = UDim2.new(0.5, -5, 1, 0),
					Disabled = (self.state.InputPlaceId == ""),
					OnActivated = function(_rbx)
						local text = self.state.InputPlaceId
						local id = tonumber(text)
						if id then
							local success, err = pcall(function()
								game:SetPlaceId(id)
							end)
							if success then
								self.props.ShowFrame("Main")
							else
								self:setState({ ErrorMessage = tostring(err) })
							end
						end
					end,
				}),
				Cancel = Roact.createElement(Button, {
					Label = "Cancel",
					ImageColor = "CheckedFieldBorder",
					TextColor = "DialogMainButtonText",
					Size = UDim2.new(0.5, -5, 1, 0),
					Position = UDim2.new(0.5, 5, 0, 0),
					OnActivated = function(_rbx)
						self.props.ShowFrame("Main")
					end,
				}),
			}),
			ErrorMessage = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = 4,
				FontFace = Constants.Font.Italic,
				Text = self.state.ErrorMessage,
				TextSize = 16,
				TextColor3 = Color3.new(1, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = (self.state.ErrorMessage ~= ""),
			}),
			Warning = Roact.createElement(ThemeContext.Consumer, {
				render = function(theme)
					return Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						LayoutOrder = 5,
						FontFace = Constants.Font.Italic,
						Text = "Setting the Place ID is not recommended. Whenever possible, open up the specific game from Studio instead.",
						TextSize = 16,
						TextColor3 = theme.WarningText.Default,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					})
				end,
			}),
		}),
	})
end

SetPlaceId = RoactRodux.connect(function()
	return {}
end, function(dispatch)
	return {
		ShowFrame = function(frameName)
			dispatch({ type = "ShowFrame", Frame = frameName })
		end,
	}
end)(SetPlaceId)

return SetPlaceId