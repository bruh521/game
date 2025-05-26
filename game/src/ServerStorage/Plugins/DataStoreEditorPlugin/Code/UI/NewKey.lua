local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local Modal = require(script.Parent.Modal)
local InputBox = require(script.Parent.InputBox)

local NewKey = Roact.Component:extend("NewKey")

function NewKey:render()
	local keyExistsLabel
	if self.props.KeyExists then
		keyExistsLabel = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 1),
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 1, 0),
					FontFace = Constants.Font.Italic,
					Text = "Key already exists",
					TextSize = 16,
					TextColor3 = theme.WarningText.Default,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
			end,
		})
	end
	local function Dismiss(...)
		self.props.OnHide(...)
	end
	return Roact.createElement(Modal, {
		Visible = self.props.Showing,
		Dismiss = Dismiss,
	}, {
		KeyInputFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = self.props.Position,
			Size = UDim2.new(0, 150, 0, 50),
			ZIndex = 2,
		}, {
			KeyInputBox = Roact.createElement(InputBox, {
				Active = true,
				Placeholder = "Key",
				Text = self.props.Key,
				ForceFocus = true,
				FilterText = function(text)
					return text:gsub("\r", "")
				end,
				OnFocusLost = function(submitted, text)
					if submitted then
						Dismiss(text)
					end
					return true
				end,
			}),
			KeyExistsLabel = keyExistsLabel,
		}),
	})
end

return NewKey