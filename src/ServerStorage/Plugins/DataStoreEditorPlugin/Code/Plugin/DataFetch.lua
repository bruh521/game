local Promise = require(script.Parent.Parent.Parent.Packages.Promise)
local DataNil = require(script.Parent.Constants).DataNil

local DataStoreService = game:GetService("DataStoreService")

local ORDERED_ITEMS_PER_PAGE = 20

local DataFetch = {}

local store

local fetchId = 0
local listStoresId = 0
local listKeysId = 0
local saveId = 0

local function GetDataStore(state)
	local dsName = state.DSName
	local dsScope = state.DSScope
	local ordered = state.UseOrdered
	local global = state.UseGlobal
	local dataStore

	-- Retrieve DataStore:
	if ordered then
		dataStore = DataStoreService:GetOrderedDataStore(dsName, if dsScope == "" then nil else dsScope)
	elseif global then
		dataStore = DataStoreService:GetGlobalDataStore()
	else
		dataStore = DataStoreService:GetDataStore(dsName, if dsScope == "" then nil else dsScope)
	end

	return dataStore
end

function DataFetch:Fetch(state)
	fetchId += 1
	local id = fetchId

	local key = state.Key
	local dataStore = GetDataStore(state)
	local ordered = state.UseOrdered

	if key == "" and not ordered then
		store:dispatch({ type = "Data", Data = DataNil })
		return Promise.resolve()
	end

	-- Inform application that we are fetching data:
	store:dispatch({ type = "FetchingData", FetchingData = true, ClearData = true })

	-- Fetch data:
	local fetchPromise = Promise.new(function(resolve, reject)
		local success, data = pcall(function()
			if ordered and key == "" then
				local min = state.OrderedMin
				local max = state.OrderedMax
				if min == DataNil then
					min = nil
				end
				if max == DataNil then
					max = nil
				end
				return dataStore:GetSortedAsync(state.OrderedAscend, ORDERED_ITEMS_PER_PAGE, min, max)
			else
				return dataStore:GetAsync(key)
			end
		end)
		if success then
			resolve(data)
		else
			reject(data)
		end
	end)

	-- Inform application of fetched data or error:
	return fetchPromise
		:andThen(function(data)
			if id ~= fetchId then
				return
			end
			if data == nil then
				data = DataNil
			end
			store:dispatch({ type = "Data", Data = data })
		end)
		:catch(function(err)
			if id ~= fetchId then
				return
			end
			store:dispatch({ type = "DataError", DataError = tostring(err) })
			store:dispatch({ type = "ShowAlert", Title = "Data Fetch Error", Message = tostring(err) })
		end)
end

function DataFetch:ListStores(state)
	listStoresId += 1
	local id = listStoresId

	local prefix = state.StorePrefix
	if prefix == "" then
		prefix = nil
	end

	store:dispatch({ type = "FetchingStores", FetchingStores = true, ClearStores = true })

	local storesPromise = Promise.new(function(resolve, reject)
		local success, data = pcall(function()
			return DataStoreService:ListDataStoresAsync(prefix)
		end)
		if success then
			resolve(data)
		else
			reject(data)
		end
	end)

	return storesPromise
		:andThen(function(data)
			if id ~= listStoresId then
				return
			end
			if data == nil then
				data = DataNil
			end
			store:dispatch({ type = "Stores", Stores = data })
		end)
		:catch(function(err)
			if id ~= listStoresId then
				return
			end
			store:dispatch({ type = "DataError", DataError = tostring(err) })
			store:dispatch({ type = "ShowAlert", Title = "List Keys Error", Message = tostring(err) })
		end)
end

function DataFetch:ListKeys(state)
	listKeysId += 1
	local id = listKeysId

	local prefix = state.KeyPrefix
	if prefix == "" then
		prefix = nil
	end

	local dataStore = GetDataStore(state)

	store:dispatch({ type = "FetchingKeys", FetchingKeys = true, ClearKeys = true })

	local keysPromise = Promise.new(function(resolve, reject)
		local success, data = pcall(function()
			return dataStore:ListKeysAsync(prefix)
		end)
		if success then
			resolve(data)
		else
			reject(data)
		end
	end)

	-- Inform application of fetched keys or error:
	return keysPromise
		:andThen(function(data)
			if id ~= listKeysId then
				return
			end
			if data == nil then
				data = DataNil
			end
			store:dispatch({ type = "Keys", Keys = data })
		end)
		:catch(function(err)
			if id ~= listKeysId then
				return
			end
			store:dispatch({ type = "DataError", DataError = tostring(err) })
			store:dispatch({ type = "ShowAlert", Title = "List Keys Error", Message = tostring(err) })
		end)
end

function DataFetch:Save(state)
	local id = (saveId + 1)
	saveId = id

	local key = state.Key

	if key == "" then
		--store:dispatch({type = "SavingData"; SavingData = true})
		return Promise.resolve()
	end

	local dataStore = GetDataStore(state)
	--local ordered = state.UseOrdered
	local data = state.Data

	-- Inform application that we are saving data:
	store:dispatch({ type = "SavingData", SavingData = true })

	-- Fetch data:
	local savePromise = Promise.new(function(resolve, reject)
		local success, dataSaved = pcall(function()
			return dataStore:UpdateAsync(key, function(oldVal)
				if id ~= saveId then
					return oldVal
				end
				return data
			end)
		end)
		if success then
			resolve(dataSaved)
		else
			reject(dataSaved)
		end
	end)

	-- Inform application of saved data or error:
	return savePromise
		:andThen(function(_dataSaved)
			if id ~= fetchId then
				return
			end
		end)
		:catch(function(err)
			if id ~= fetchId then
				return
			end
			store:dispatch({ type = "DataError", DataError = tostring(err) })
			store:dispatch({ type = "ShowAlert", Title = "Data Save Error", Message = tostring(err) })
		end)
		:finally(function()
			store:dispatch({ type = "SavingData", SavingData = false })
		end)
end

function DataFetch:Delete(state)
	local key = state.Key

	if key == "" then
		return Promise.resolve()
	end

	local dataStore = GetDataStore(state)

	local deletePromise = Promise.new(function(resolve, reject)
		local success, err = pcall(function()
			return dataStore:RemoveAsync(key)
		end)
		if success then
			resolve()
		else
			reject(err)
		end
	end)

	return deletePromise:catch(function(err)
		store:dispatch({ type = "DataError", DataError = tostring(err) })
		store:dispatch({ type = "ShowAlert", Title = "Data Delete Error", Message = tostring(err) })
	end)
end

function DataFetch:Start()
	store = self.Modules.App:GetStore()
	local function DidChange(s1, s2, name)
		return s1[name] ~= s2[name]
	end
	local function DidAnyChange(s1, s2, ...)
		for _, name in ipairs({ ... }) do
			if s1[name] ~= s2[name] then
				return true
			end
		end
		return false
	end
	store.changed:connect(function(new, old)
		if
			DidAnyChange(new, old, "Key", "Refresh", "ConnectedView", "UseGlobal")
			or (
				new.UseOrdered
				and DidAnyChange(
					new,
					old,
					"UseOrdered",
					"OrderedMin",
					"OrderedMax",
					"OrderedAscend",
					"DSName",
					"DSScope"
				)
			)
		then
			if new.ConnectedView == "StoreListContainer" then
				self:ListStores(new)
			elseif new.DSName ~= "" or new.UseGlobal then
				if new.ConnectedView == "KeyListContainer" then
					self:ListKeys(new)
				elseif new.ConnectedView == "DataContainer" then
					self:Fetch(new)
				end
			end
		elseif DidChange(new, old, "UseOrdered") and not new.UseOrdered then
			store:dispatch({ type = "Data", Data = DataNil })
		end
	end)
end

function DataFetch:Init() end

return DataFetch