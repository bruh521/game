local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

local encodingVersion = 1

local FileIO = {}

function FileIO:ToLuaString(data)
	local keywords = {
		["and"] = true,
		["end"] = true,
		["in"] = true,
		["repeat"] = true,
		["break"] = true,
		["false"] = true,
		["local"] = true,
		["return"] = true,
		["do"] = true,
		["for"] = true,
		["nil"] = true,
		["then"] = true,
		["else"] = true,
		["function"] = true,
		["not"] = true,
		["true"] = true,
		["elseif"] = true,
		["if"] = true,
		["or"] = true,
		["until"] = true,
		["while"] = true,
		["continue"] = true,
	}
	local function IsKeyFine(key)
		return (keywords[key] == nil) and (key:match("^[_%a][_%w]*$") ~= nil)
	end
	local function Dump(obj)
		if type(obj) == "table" then
			local s = { "{" }
			for k, v in pairs(obj) do
				local key = k
				if type(key) == "string" and IsKeyFine(key) then
					table.insert(s, k .. "=")
				else
					if type(k) ~= "number" then
						k = '"' .. k .. '"'
					end
					table.insert(s, "[" .. k .. "]=")
				end
				table.insert(s, Dump(v))
				if next(obj, key) then
					table.insert(s, ",")
				end
			end
			table.insert(s, "}")
			return table.concat(s, "")
		elseif type(obj) == "string" then
			return '"' .. obj:gsub('"', '\\"') .. '"'
		else
			return tostring(obj)
		end
	end
	return Dump(data)
end

type EncodeMetadata = {
	Key: string,
	DSName: string,
	DSScope: string,
}

function FileIO:Encode(data: unknown, meta: EncodeMetadata)
	local lines = {
		"EXPORTED FROM DATASTORE EDITOR - DO NOT MODIFY",
		"",
		string.format("Version: %i", encodingVersion),
		"",
		string.format("GameId: %i", game.GameId),
		string.format("PlaceId: %i", game.PlaceId),
		"",
		string.format("Key: %q", meta.Key),
		string.format("DataStore Name: %q", meta.DSName),
		string.format("DataStore Scope: %q", meta.DSScope),
		"",
		string.format("Data: %s", HttpService:JSONEncode(data)),
		"",
	}

	for i, line in lines do
		if line ~= "" then
			lines[i] = "-- " .. line
		end
	end

	return table.concat(lines, "\n")
end

function FileIO:DecodeLegacy(encodedData: string)
	local ms = Instance.new("ModuleScript")
	ms.Name = "import"
	ms.Archivable = false
	ScriptEditorService:UpdateSourceAsync(ms, function()
		return encodedData
	end)

	task.defer(function()
		ms:Destroy()
	end)

	return require(ms)
end

function FileIO:Decode(encodedData: string)
	if encodedData:match("^return .+") then
		-- Old encoded format
		return self:DecodeLegacy(encodedData)
	end

	local lines = encodedData:split("\n")

	-- Remove \r if present, meaning EOL was \r\n instead of just \n:
	for i, line in lines do
		if line:sub(#line) == "\r" then
			lines[i] = line:sub(1, #line - 1)
		end
	end

	-- Key/pair (all keys are lowercase and spaces trimmed):
	local dict = {} :: { [string]: string }
	for _, line in lines do
		local key, value = line:match("%-%-%s*(.-):%s?(.+)")
		if key and value then
			key = key:gsub("%s+", ""):lower()
			if dict[key] ~= nil then
				error("Duplicate key in imported data: " .. key, 0)
			end
			dict[key] = value
		end
	end

	if dict.version == nil then
		error("Encoding version not found", 0)
	end

	if tonumber(dict.version) == 1 then
		local data = dict.data

		if data == nil then
			error("Data not found", 0)
		end

		return HttpService:JSONDecode(data)
	end

	error("Unknown encoding version: " .. tostring(dict.version), 0)
end

function FileIO:PromptSaveFile(filename, contents)
	local ms = Instance.new("ModuleScript")
	ms.Name = "export_" .. filename
	ms.Archivable = false
	ScriptEditorService:UpdateSourceAsync(ms, function()
		return contents
	end)
	ms.Parent = ServerStorage

	game:GetService("Selection"):Set({ ms })

	if RunService:IsRunning() then
		warn("Cannot prompt to save while game is running")
		return false
	end

	local saved = self.Plugin:PromptSaveSelection(filename)

	if saved then
		ms:Destroy()
	end

	return saved
end

function FileIO:PromptLoadFile(): string?
	local file = StudioService:PromptImportFile({ "lua" })
	if file then
		local contents = file:GetBinaryContents() :: string

		-- local dataVersion = tonumber(contents:match("^%-%-version%.(%d+)%s"))

		-- local ms = Instance.new("ModuleScript")
		-- ms.Name = "import_" .. file.Name
		-- ms.Archivable = false
		-- ms.Source = contents
		-- local data = require(ms)
		-- ms:Destroy()
		-- return dataVersion, data
		return contents
	end
	return nil
end

return FileIO