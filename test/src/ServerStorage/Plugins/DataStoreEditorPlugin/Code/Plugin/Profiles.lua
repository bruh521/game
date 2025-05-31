-- Profiles
-- August 07, 2020

--[[

	Profiles:Save(name, gameId, dsName, dsScope, ordered)
	Profiles:Delete(id)
	Profiles:Filter(propertyName, propertyValue)
	Profiles:Search(propertyName, query)
	Profiles:FindFirstFromProperties(dsName, dsScope, ordered [, gameId])
	Profiles:GetAll()

--]]

local PROFILES_KEY = "dse_profiles"

local HttpService = game:GetService("HttpService")

local Profiles = {}

local allProfiles

function Profiles:Save(name, gameId, dsName, dsScope, ordered)
	local profile = {
		ID = HttpService:GenerateGUID(false),
		Name = name,
		GameId = gameId,
		DSName = dsName,
		DSScope = dsScope == "" and "global" or dsScope,
		Ordered = ordered,
	}
	table.insert(allProfiles, profile)
	self.Plugin:SetSetting(PROFILES_KEY, allProfiles)
end

function Profiles:Delete(id)
	for i, profile in allProfiles do
		if profile.ID == id then
			table.remove(allProfiles, i)
			self.Plugin:SetSetting(PROFILES_KEY, allProfiles)
			break
		end
	end
end

function Profiles:FindFirstFromProperties(dsName, dsScope, ordered, gameId)
	dsScope = (dsScope == "" and "global" or dsScope)
	for _, profile in allProfiles do
		if profile.DSName == dsName and profile.DSScope == dsScope and profile.Ordered == ordered then
			if (not gameId) or (profile.GameId == gameId) then
				return profile
			end
		end
	end
	return nil
end

function Profiles:Filter(property, propertyValue)
	local result = {}
	for _, profile in allProfiles do
		if profile[property] == propertyValue then
			table.insert(result, profile)
		end
	end
	return result
end

function Profiles:Search(property, searchQuery)
	local result = {}
	searchQuery = tostring(searchQuery):lower()
	local function Check(profile, val)
		if val == searchQuery then
			table.insert(result, 1, profile)
		elseif val:find(searchQuery) or searchQuery:find(val) then
			table.insert(result, profile)
		end
	end
	if property then
		for _, profile in allProfiles do
			Check(profile, tostring(profile[property]):lower())
		end
	else
		for _, profile in allProfiles do
			for _, val in pairs(profile) do
				Check(profile, tostring(val):lower())
			end
		end
	end
	return result
end

function Profiles:GetAll()
	return allProfiles
end

function Profiles:Init()
	allProfiles = self.Plugin:GetSetting(PROFILES_KEY) or {}
end

return Profiles