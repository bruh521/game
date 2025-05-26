local Theme = {}

function Theme:Get()
	local theme = {}
	local colors = Enum.StudioStyleGuideColor:GetEnumItems()
	local modifiers = Enum.StudioStyleGuideModifier:GetEnumItems()
	local studioTheme = settings().Studio.Theme
	for _, color in colors do
		local c = {}
		for _, modifier in modifiers do
			c[modifier.Name] = studioTheme:GetColor(color, modifier)
		end
		theme[color.Name] = c
	end
	return theme
end

return Theme