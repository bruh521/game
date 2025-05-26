local State = {}

local DataNil = require(script.Parent.Constants).DataNil

local defaultState = {
	Loaded = false,
	DSNameInput = "",
	DSScopeInput = "",
	UseOrderedInput = false,
	UseGlobalInput = false,
	DSName = "",
	DSScope = "",
	Key = "",
	KeyPrefix = "",
	StorePrefix = "",
	UseOrdered = false,
	UseGlobal = false,
	OrderedMin = DataNil,
	OrderedMax = DataNil,
	OrderedAscend = true,
	ShowSideMenu = true,
	ShowFrame = "Main",
	Connected = false,
	ConnectedView = "",
	Data = DataNil,
	FetchingData = false,
	FetchingStores = false,
	FetchingKeys = false,
	Stores = DataNil,
	Keys = DataNil,
	SavingData = false,
	DataError = "",
	DataDirty = false,
	ShowAlert = false,
	AlertTitle = "",
	AlertMessage = "",
	Refresh = 0,
}

local function Extend(original, newTbl)
	local tbl = table.clone(original)
	for k, v in newTbl do
		tbl[k] = v
	end
	return tbl
end

function State.Reducer(state, action)
	state = state or defaultState

	if action.type == "Loaded" then
		return Extend(state, {
			Loaded = action.IsLoaded,
		})
	elseif action.type == "SideMenuInputs" then
		return Extend(state, {
			DSNameInput = action.DSName or "",
			DSScopeInput = action.DSScope or "",
			UseOrderedInput = action.UseOrdered,
			UseGlobalInput = action.UseGlobal,
		})
	elseif action.type == "DSName" then
		return Extend(state, {
			DSName = action.DSName or "",
		})
	elseif action.type == "DSScope" then
		return Extend(state, {
			DSScope = action.DSScope or "",
		})
	elseif action.type == "Key" then
		return Extend(state, {
			Key = action.Key or "",
		})
	elseif action.type == "KeyPrefix" then
		return Extend(state, {
			KeyPrefix = action.KeyPrefix or "",
		})
	elseif action.type == "Keys" then
		return Extend(state, {
			Keys = action.Keys,
			FetchingKeys = false,
		})
	elseif action.type == "StorePrefix" then
		return Extend(state, {
			StorePrefix = action.StorePrefix or "",
		})
	elseif action.type == "Stores" then
		return Extend(state, {
			Stores = action.Stores,
			FetchingStores = false,
		})
	elseif action.type == "Global" then
		return Extend(state, {
			UseGlobal = action.UseGlobal,
		})
	elseif action.type == "Ordered" then
		return Extend(state, {
			UseOrdered = action.UseOrdered,
		})
	elseif action.type == "OrderedMin" then
		return Extend(state, {
			OrderedMin = action.Min,
		})
	elseif action.type == "OrderedMax" then
		return Extend(state, {
			OrderedMax = action.Max,
		})
	elseif action.type == "OrderedAscend" then
		return Extend(state, {
			OrderedAscend = action.Ascend,
		})
	elseif action.type == "SideMenu" then
		return Extend(state, {
			ShowSideMenu = action.Show,
		})
	elseif action.type == "ShowFrame" then
		return Extend(state, {
			ShowFrame = action.Frame,
		})
	elseif action.type == "Connected" then
		return Extend(state, {
			Connected = action.Connected,
			ConnectedView = action.ConnectedView or "",
		})
	elseif action.type == "Data" then
		return Extend(state, {
			FetchingData = false,
			Data = action.Data,
			DataDirty = not not action.WasImported,
		})
	elseif action.type == "FetchingData" then
		local data = action.Data
		if action.ClearData then
			data = DataNil
		end
		return Extend(state, {
			FetchingData = action.FetchingData,
			Data = data,
			DataError = "",
			DataDirty = false,
		})
	elseif action.type == "FetchingStores" then
		local stores = action.Stores
		if action.ClearStores then
			stores = DataNil
		end
		return Extend(state, {
			FetchingStores = action.FetchingStores,
			Stores = stores,
		})
	elseif action.type == "FetchingKeys" then
		local keys = action.Keys
		if action.ClearKeys then
			keys = DataNil
		end
		return Extend(state, {
			FetchingKeys = action.FetchingKeys,
			Keys = keys,
		})
	elseif action.type == "DataError" then
		return Extend(state, {
			FetchingData = false,
			DataError = action.DataError,
		})
	elseif action.type == "DataDeleted" then
		return Extend(state, {
			FetchingData = false,
			Data = DataNil,
			DataDirty = false,
		})
	elseif action.type == "MarkDirty" then
		return Extend(state, {
			DataDirty = true,
		})
	elseif action.type == "SavingData" then
		local dirty = state.DataDirty
		if state.SavingData and not action.SavingData then
			dirty = false
		end
		return Extend(state, {
			SavingData = action.SavingData,
			DataDirty = dirty,
		})
	elseif action.type == "ShowAlert" then
		return Extend(state, {
			ShowAlert = true,
			AlertTitle = action.Title,
			AlertMessage = action.Message,
		})
	elseif action.type == "HideAlert" then
		return Extend(state, {
			ShowAlert = false,
			AlertTitle = "",
			AlertMessage = "",
		})
	elseif action.type == "Refresh" then
		return Extend(state, {
			Refresh = (state.Refresh + 1),
		})
	elseif action.type == "ResetAll" then
		return defaultState
	end

	return state
end

return State