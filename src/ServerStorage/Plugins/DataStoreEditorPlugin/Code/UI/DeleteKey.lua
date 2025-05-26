local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local OverlayPage = require(script.Parent.OverlayPage)
local Button = require(script.Parent.Button)
local App = require(script.Parent.Parent.Plugin.App)
local DataFetch = require(script.Parent.Parent.Plugin.DataFetch)

local DeleteKey = Roact.Component:extend("DeleteKey")

function DeleteKey:init()
	self:setState({
		ErrorMessage = "",
	})
end

function DeleteKey:render()
	return Roact.createElement(OverlayPage, {}, {
		Title = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 0,
					FontFace = Constants.Font.Regular,
					Text = 'Delete Key "' .. (self.props.Key or "") .. '"',
					TextSize = 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			end,
		}),
		ButtonFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 1,
		}, {
			ConfirmDelete = Roact.createElement(Button, {
				Label = "Delete",
				ImageColor = "DialogMainButton",
				TextColor = "DialogMainButtonText",
				Size = UDim2.new(0.5, -5, 1, 0),
				Disabled = (self.props.Key == ""),
				OnActivated = function()
					local success, err = DataFetch:Delete(App:GetStore():getState()):await()
					if not success then
						self:setState({
							ErrorMessage = tostring(err),
						})
					else
						self.props.OnDataDeleted()
						self.props.ShowFrame("Main")
					end
				end,
			}),
			Cancel = Roact.createElement(Button, {
				Label = "Cancel",
				ImageColor = "CheckedFieldBorder",
				TextColor = "DialogMainButtonText",
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new(0.5, 5, 0, 0),
				OnActivated = function()
					self.props.ShowFrame("Main")
				end,
			}),
		}),
		ErrorMessage = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 2,
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
					LayoutOrder = 3,
					FontFace = Constants.Font.Italic,
					Text = "Note: This action cannot be undone.",
					TextSize = 16,
					TextColor3 = theme.WarningText.Default,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				})
			end,
		}),
	})
end

DeleteKey = RoactRodux.connect(function(state)
	return {
		Key = state.Key,
	}
end, function(dispatch)
	return {
		ShowFrame = function(frameName)
			dispatch({ type = "ShowFrame", Frame = frameName })
		end,
		OnDataDeleted = function()
			dispatch({ type = "DataDeleted" })
		end,
	}
end)(DeleteKey)

return DeleteKey