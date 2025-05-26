local HttpService = game:GetService("HttpService")

local DataVer = {}

local function TryJSONDecode(str)
	return pcall(function()
		return HttpService:JSONDecode(str)
	end)
end

function DataVer:Verify(text)
	local newValue = nil
	if text == "true" then
		newValue = true
	elseif text == "false" then
		newValue = false
	elseif text:match('^".*"$') and tonumber(text:sub(2, #text - 1)) then
		text = text:sub(2, #text - 1)
	elseif tonumber(text) then
		newValue = tonumber(text)
	elseif text:sub(1, 1) == "{" or text:sub(1, 1) == "[" then
		local success, t = TryJSONDecode(text)
		if success then
			newValue = t
		end
	end
	if newValue == nil then
		newValue = text
	end
	return newValue
end

return DataVer