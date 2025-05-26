local Constants = require(script.Parent.Constants)

local TextService = game:GetService("TextService")

local TextSize = {}

local warmParams: { [Font]: GetTextBoundsParams } = {}

local function GetParams(font: Font): GetTextBoundsParams
	local params = warmParams[font]

	if not params then
		local newParams = Instance.new("GetTextBoundsParams")
		newParams.Font = font
		newParams.Width = 100000
		warmParams[font] = newParams
		params = newParams
	end

	return params
end

function TextSize.calc(font: Font, text: string, size: number): Vector2
	local params = GetParams(font)
	params.Size = size
	params.Text = text

	return TextService:GetTextBoundsAsync(params)
end

function TextSize.calcWidth(font: Font, text: string, size: number): number
	return TextSize.calc(font, text, size).X
end

for _, font in Constants.Font do
	GetParams(font)
	TextSize.calc(font, "Test", 16)
end

return TextSize