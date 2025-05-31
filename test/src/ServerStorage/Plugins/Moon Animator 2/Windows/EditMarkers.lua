local _g = _G.MoonGlobal
------------------------------------------------------------
	local SelectionHandler

	local KFMarkerChanged = false
	local Marker_obj = require(_g.class.Marker)

	local TargetMarkers = {}
	local CurrentProperties = {}; local AllProperties = {"name", "width", "codeBegin", "codeEnd"}
	local VariedProperties = {}
	
	local data = _g.WindowData:new("Edit Events", script.Contents); data.resize = true; data.ResizeIncrement = {X = 0, Y = 15}
	local Win  = _g.Window:new(script.Name, data)

	Button:new(Win.g_e.Confirm)
	Tabs:new(Win.g_e.Tabs, "Events", nil)

	TextInput:new(Win.g_e.MarkerName, "", nil)
	TimeInput:new(Win.g_e.Width, 0, nil, {0, _g.MAX_FRAMES, 1})
	TimeInput:new(Win.g_e.EndTime, 0, nil, {0, _g.MAX_FRAMES, 1})
	MultiInput:new(Win.g_e.BeginCodeInput, "", nil)
	MultiInput:new(Win.g_e.EndCodeInput, "", nil)
	KeyValueList:new(Win.g_e.KeyValueList, {}, function() KFMarkerChanged = true end)

	local PropertyElementMap = {name = MarkerName, width = Width, codeBegin = BeginCodeInput, codeEnd = EndCodeInput}
------------------------------------------------------------
do
	Width._changed = function(value)
		if #TargetMarkers == 1 then
			EndTime:Set(TargetMarkers[1].frm_pos + value)
		end
	end
	EndTime._changed = function(value)
		if #TargetMarkers == 1 then
			Width:Set(value - TargetMarkers[1].frm_pos)
		end
	end

	Win.OnOpen = function()
		SelectionHandler = _g.Windows.MoonAnimator.g_e.LayerSystem.SelectionHandler
		if not SelectionHandler.TrackItemTypeMap["Marker"] then return false end

		KFMarkerChanged = false

		local maxWidth = SelectionHandler.LayerSystem.length

		for _, TrackItem in pairs(SelectionHandler.SelectedTrackItems.Objects) do
			if _g.objIsType(TrackItem, "Marker") then
				local nextTI = TrackItem.ParentTrack:GetNextTrackItem(TrackItem)
				if nextTI then
					nextTI = nextTI.frm_pos - TrackItem.frm_pos - 1
				else
					nextTI = SelectionHandler.LayerSystem.length - TrackItem.frm_pos
				end
				if nextTI < maxWidth then
					maxWidth = nextTI
				end
				table.insert(TargetMarkers, TrackItem)
			end
		end

		Width.Max = maxWidth

		for _, Marker in pairs(TargetMarkers) do
			for _, propName in pairs(AllProperties) do
				if VariedProperties[propName] == nil then
					local value = CurrentProperties[propName]
					if value == nil then
						CurrentProperties[propName] = Marker[propName]
					elseif value ~= nil and value ~= Marker[propName] then
						CurrentProperties[propName] = nil
						VariedProperties[propName] = true
					end
				end
			end
		end

		MarkerName:Set(CurrentProperties.name)
		Width:Set(CurrentProperties.width)
		BeginCodeInput:Set(CurrentProperties.codeBegin)
		EndCodeInput:Set(CurrentProperties.codeEnd)

		EndTime:SetEnabled(true)
		if #TargetMarkers == 1 then
			EndTime.Min = TargetMarkers[1].frm_pos
			EndTime.Max = TargetMarkers[1].frm_pos + maxWidth
			EndTime:Set(TargetMarkers[1].frm_pos + TargetMarkers[1].width)
			KeyValueList:SetList(_g.deepcopy(TargetMarkers[1].KFMarkers))
		else
			EndTime:Set(nil)
			EndTime:SetEnabled(false)
			KeyValueList:SetList({})
		end

		Win.g_e.Tabs:ShowTab("Events")

		return true
	end

	Win.OnClose = function(save)
		if save then
			local data = {TargetMarkers = TargetMarkers}
			for _, propName in pairs(AllProperties) do
				if (VariedProperties[propName] and PropertyElementMap[propName].Value ~= nil) or (CurrentProperties[propName] ~= PropertyElementMap[propName].Value) then
					data[propName] = PropertyElementMap[propName].Value
				end
			end
			if KFMarkerChanged then
				data.KFMarkers = KeyValueList.List
			end
			_g.Windows.MoonAnimator.DoCompositeAction("EditMarkers", data)
		end
		
		TargetMarkers = {}
		CurrentProperties = {}
		VariedProperties = {}

		return true
	end

	Win.g_e.Confirm.OnClick = function()
		Win:Close(true)
	end
end

return Win
