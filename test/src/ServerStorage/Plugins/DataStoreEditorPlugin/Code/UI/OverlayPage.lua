local Roact = require(script.Parent.Parent.Parent.Packages.Roact)

local OverlayPage = Roact.Component:extend("OverlayPage")

function OverlayPage:render()
	self.props[Roact.Children].UIListLayout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})
	self.props[Roact.Children].UIPadding = Roact.createElement("UIPadding", {
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10),
	})
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
		}, self.props[Roact.Children]),
	})
end

return OverlayPage