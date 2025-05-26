local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Packages.RoactRodux)
local InputBox = require(script.Parent.InputBox)

local SearchInput = Roact.Component:extend("SearchInput")

function SearchInput:init()
	self:setState({
		KeyInput = self.props.Text or "",
	})
end

function SearchInput:didUpdate(prevProps, _prevState)
	if prevProps.Key ~= self.props.Key then
		self:setState({ KeyInput = self.props.Key })
	end
end

function SearchInput:render()
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = self.props.Position,
		Size = self.props.Size,
		LayoutOrder = self.props.LayoutOrder or 0,
	}, {
		Search = Roact.createElement(InputBox, {
			Active = self.props.Active,
			Placeholder = "Key",
			Text = self.state.KeyInput,
			OnInput = function(text)
				self:setState({ KeyInput = text })
			end,
			OnFocusLost = function()
				self.props.SetKey(self.state.KeyInput)
			end,
			OnCleared = function()
				self.props.SetKey("")
			end,
		}),
		SizeConstraint = Roact.createElement("UISizeConstraint", {
			MaxSize = Vector2.new(if self.props.MaxWidth then self.props.MaxWidth else math.huge, math.huge),
		}),
	})
end

SearchInput = RoactRodux.connect(function(state)
	return {
		Key = state.Key,
	}
end, function(dispatch)
	return {
		SetKey = function(key)
			dispatch({ type = "Key", Key = key })
		end,
	}
end)(SearchInput)

return SearchInput