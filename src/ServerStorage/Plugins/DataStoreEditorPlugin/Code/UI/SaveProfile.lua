local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local OverlayPage = require(script.Parent.OverlayPage)
local InputBox = require(script.Parent.InputBox)
local Button = require(script.Parent.Button)
local KeyValuePair = require(script.Parent.KeyValuePair)
local Profiles = require(script.Parent.Parent.Plugin.Profiles)

local SaveProfile = Roact.Component:extend("SaveProfile")

function SaveProfile:init()
	self:setState({
		InputProfileName = "",
	})
end

function SaveProfile:render()
	local text = nil
	if self.state.InputProfileName ~= "" then
		text = self.state.InputProfileName
	end
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement(OverlayPage, {}, {
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
				Title = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 0,
					FontFace = Constants.Font.Regular,
					Text = "Save Connection",
					TextSize = 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				ProfileName = Roact.createElement(InputBox, {
					Placeholder = "Name",
					LayoutOrder = 1,
					ForceFocus = self.props.IsVisible,
					MaxCharacters = 20,
					Text = text,
					OnInput = function(txt)
						self:setState({ InputProfileName = txt })
					end,
				}),
				DSName = Roact.createElement(KeyValuePair, {
					Key = "DataStore Name",
					Value = self.props.DSName,
					LayoutOrder = 2,
				}),
				DSScope = Roact.createElement(KeyValuePair, {
					Key = "DataStore Scope",
					Value = self.props.DSScope == "" and "global" or self.props.DSScope,
					LayoutOrder = 3,
				}),
				DSOrdered = Roact.createElement(KeyValuePair, {
					Key = "OrderedDataStore",
					Value = self.props.UseOrdered and "Yes" or "No",
					LayoutOrder = 4,
				}),
				GameId = Roact.createElement(KeyValuePair, {
					Key = "Game ID",
					Value = tostring(game.GameId),
					LayoutOrder = 5,
				}),
				ButtonFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 6,
				}, {
					SaveButton = Roact.createElement(Button, {
						Label = "Save",
						ImageColor = "DialogMainButton",
						TextColor = "DialogMainButtonText",
						Size = UDim2.new(0.5, -5, 1, 0),
						Disabled = (self.state.InputProfileName == ""),
						OnActivated = function(_rbx)
							Profiles:Save(
								self.state.InputProfileName,
								game.GameId,
								self.props.DSName,
								self.props.DSScope,
								self.props.UseOrdered
							)
							self:setState({ InputProfileName = "" })
							self.props.ShowFrame("Main")
						end,
					}),
					Cancel = Roact.createElement(Button, {
						Label = "Cancel",
						ImageColor = "CheckedFieldBorder",
						TextColor = "DialogMainButtonText",
						Size = UDim2.new(0.5, -5, 1, 0),
						Position = UDim2.new(0.5, 5, 0, 0),
						OnActivated = function(_rbx)
							self:setState({ InputProfileName = "" })
							self.props.ShowFrame("Main")
						end,
					}),
				}),
			})
		end,
	})
end

SaveProfile = RoactRodux.connect(function(state)
	return {
		DSName = state.DSNameInput,
		DSScope = state.DSScopeInput,
		UseOrdered = state.UseOrderedInput,
	}
end, function(dispatch)
	return {
		ShowFrame = function(frameName)
			dispatch({ type = "ShowFrame", Frame = frameName })
		end,
	}
end)(SaveProfile)

return SaveProfile