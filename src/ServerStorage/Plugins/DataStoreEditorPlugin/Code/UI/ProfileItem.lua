local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local IconButton = require(script.Parent.IconButton)
local KeyValuePair = require(script.Parent.KeyValuePair)

local ProfileItem = Roact.PureComponent:extend("ProfileItem")

function ProfileItem:render()
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement("Frame", {
				BackgroundColor3 = theme.CheckedFieldBackground.Default,
				Size = UDim2.new(0.9, 0, 0, 100),
				AnchorPoint = Vector2.new(0.5, 0),
				LayoutOrder = self.props.LayoutOrder,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 2),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
				}),
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				TopBar = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					LayoutOrder = 0,
				}, {
					Title = Roact.createElement("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -52, 1, 0),
						FontFace = Constants.Font.Bold,
						Text = self.props.Profile.Name,
						TextSize = 16,
						TextColor3 = theme.MainText.Default,
						TextXAlignment = Enum.TextXAlignment.Left,
						ClipsDescendants = true,
					}),
					DeleteButton = Roact.createElement(IconButton, {
						Icon = "rbxassetid://5516413280",
						ImageColor = "MainText",
						Tooltip = "Delete",
						Size = UDim2.new(0, 16, 0, 16),
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -26, 0, 0),
						Disabled = false,
						OnActivated = function()
							self.props.OnDelete()
						end,
					}),
					LoadButton = Roact.createElement(IconButton, {
						Icon = "rbxassetid://5516414405",
						ImageColor = "MainText",
						Tooltip = "Load",
						Size = UDim2.new(0, 16, 0, 16),
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, 0, 0, 0),
						Disabled = false,
						OnActivated = function()
							self.props.OnLoad()
						end,
					}),
				}),
				DSName = Roact.createElement(KeyValuePair, {
					Key = "DataStore Name",
					Value = self.props.Profile.DSName,
					LayoutOrder = 1,
					TextSize = 14,
				}),
				DSScope = Roact.createElement(KeyValuePair, {
					Key = "DataStore Scope",
					Value = self.props.Profile.DSScope,
					LayoutOrder = 2,
					TextSize = 14,
				}),
				Ordered = Roact.createElement(KeyValuePair, {
					Key = "OrderedDataStore",
					Value = self.props.Profile.Ordered and "Yes" or "No",
					LayoutOrder = 3,
					TextSize = 14,
				}),
			})
		end,
	})
end

return ProfileItem