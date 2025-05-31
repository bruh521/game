local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local Constants = require(script.Parent.Parent.Plugin.Constants)
local ThemeContext = require(script.Parent.ThemeContext)
local OverlayPage = require(script.Parent.OverlayPage)
local InputBox = require(script.Parent.InputBox)
local Button = require(script.Parent.Button)
local ProfileItem = require(script.Parent.ProfileItem)
local ScrollingFrame = require(script.Parent.ScrollingFrame)
local Profiles = require(script.Parent.Parent.Plugin.Profiles)

local LoadProfile = Roact.Component:extend("LoadProfile")

function LoadProfile:init()
	self:setState({
		InputFilter = "",
		Num = 0,
	})
end

function LoadProfile:getResults()
	local filter = self.state.InputFilter
	if filter == "" then
		return Profiles:GetAll()
	end
	return Profiles:Search(nil, filter)
end

function LoadProfile:render()
	local filterText = nil
	if self.state.InputFilter ~= "" then
		filterText = self.state.InputFilter
	end
	local results = self:getResults()
	local resultItems = {}
	if #results == 0 then
		resultItems.NoResults = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 0,
					FontFace = Constants.Font.Regular,
					Text = self.state.InputFilter == "" and "No saved connections" or "No results",
					TextSize = 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			end,
		})
	else
		for i, profile in results do
			resultItems[profile.ID] = Roact.createElement(ProfileItem, {
				Profile = profile,
				LayoutOrder = i,
				OnLoad = function()
					self.props.Load(profile)
					self:setState({ InputFilter = "" })
					self.props.ShowFrame("Main")
				end,
				OnDelete = function()
					Profiles:Delete(profile.ID)
					self:setState({ Num = self.state.Num + 1 })
				end,
			})
		end
	end
	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			return Roact.createElement(OverlayPage, {}, {
				Title = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 0,
					FontFace = Constants.Font.Regular,
					Text = "Load Connection",
					TextSize = 16,
					TextColor3 = theme.MainText.Default,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				ButtonFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					LayoutOrder = 1,
				}, {
					SearchFilter = Roact.createElement(InputBox, {
						Placeholder = "Filter",
						LayoutOrder = 1,
						Text = filterText,
						Size = UDim2.new(0.7, -5, 1, 0),
						ForceFocus = self.props.IsVisible,
						MaxCharacters = 20,
						OnInput = function(txt)
							self:setState({ InputFilter = txt })
						end,
					}),
					Cancel = Roact.createElement(Button, {
						Label = "Cancel",
						ImageColor = "CheckedFieldBorder",
						TextColor = "DialogMainButtonText",
						Size = UDim2.new(0.3, -5, 1, 0),
						Position = UDim2.new(1, 0, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						OnActivated = function(_rbx)
							self:setState({ InputFilter = "" })
							self.props.ShowFrame("Main")
						end,
					}),
				}),
				ResultsScrollingFrame = Roact.createElement(ScrollingFrame, {
					Size = UDim2.new(1, 0, 1, -82),
					LayoutOrder = 7,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					KeepShadowInBounds = true,
				}, resultItems),
			})
		end,
	})
end

LoadProfile = RoactRodux.connect(function(state)
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
		Load = function(profile)
			dispatch({ type = "DSName", DSName = "" })
			dispatch({ type = "DSScope", DSScope = "" })
			dispatch({ type = "Ordered", UseOrdered = false })
			dispatch({ type = "Global", UseGlobal = false })
			-- Hack to wait 2 heartbeats:
			task.delay(0, function()
				task.wait()
				dispatch({ type = "DSName", DSName = profile.DSName })
				dispatch({ type = "DSScope", DSScope = profile.DSScope })
				dispatch({ type = "Ordered", UseOrdered = profile.Ordered })
				dispatch({ type = "Global", UseGlobal = false })
				dispatch({ type = "Key", Key = "" })
			end)
		end,
	}
end)(LoadProfile)

return LoadProfile