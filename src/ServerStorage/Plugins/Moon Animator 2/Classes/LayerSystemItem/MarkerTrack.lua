local _g = _G.MoonGlobal; _g.req("Track")
local MarkerTrack = super:new()

function MarkerTrack:new(LayerSystem, ItemObject, hierLevel)
	local ctor = super:new(LayerSystem, ItemObject, hierLevel)
	table.insert(ctor.type, 1, script.Name)
	setmetatable(ctor, self)
	self.__index = self

	if LayerSystem then
		ctor.ListComponent.Label.Text = "Events"
	end

	return ctor
end

function MarkerTrack:set_select(value)
	super.set_select(self, value)
	local middle_color = value and "highlight" or "third"
	self.TrackItems:Iterate(function(mk)
		mk:SetItemPaint(mk.UI.BG_Middle.Line, {BackgroundColor3 = middle_color})
		mk:SetItemPaint(mk.UI.Start, {BackgroundColor3 = middle_color})
		mk:SetItemPaint(mk.UI.End, {BackgroundColor3 = middle_color})
	end)
end

function MarkerTrack:_Execute(code)
	task.spawn(function()
		local succ, err = pcall(function()
			loadstring(code)()
		end)

		if not succ then
			warn(err)
		end
	end)
end

function MarkerTrack:_RunCodeAt(frm_pos)
	local TargetMarker = self.TrackItemPositions[frm_pos]

	if TargetMarker then
		if TargetMarker.frm_pos == frm_pos and TargetMarker.codeBegin ~= "" then
			self:_Execute(TargetMarker.codeBegin)
		end
		if TargetMarker.frm_pos + TargetMarker.width == frm_pos and TargetMarker.codeEnd ~= "" then
			self:_Execute(TargetMarker.codeEnd)
		end
	end
end

function MarkerTrack:_Update(frm_pos)
	if not self.LayerSystem.PlaybackHandler.Playing then return end

	if frm_pos < self.LastUpdate then
		for pos = self.LastUpdate + 1, self.LayerSystem.length, 1 do
			self:_RunCodeAt(pos)
		end
		self.LastUpdate = -1
	end
	for pos = self.LastUpdate + 1, frm_pos do
		self:_RunCodeAt(pos)
	end

	self.LastUpdate = frm_pos
end

function MarkerTrack:Destroy()
	super.Destroy(self)
end

function MarkerTrack:SetEnabled(value, inputted)
	self.LastUpdate = self.LayerSystem.SliderFrame - 1
	super.SetEnabled(self, value, inputted)
	
	self.LayerSystem.PlaybackHandler.ActiveTracks[tostring(self)] = value and self or nil
end

do
	function MarkerTrack:ResizeMarker(Marker, width)
		for ind = Marker.frm_pos, Marker.frm_pos + Marker.width do
			self.TrackItemPositions[ind] = nil
		end

		Marker.width = width
		Marker:_Size()

		for ind = Marker.frm_pos, Marker.frm_pos + width do
			assert(self.TrackItemPositions[ind] == nil, "Marker collision.")
			self.TrackItemPositions[ind] = Marker
		end
	end

	function MarkerTrack:MoveMarker(Marker, frm_pos)
		assert(self.TrackItems:Contains(Marker), "Marker is not in MarkerTrack.")
		super.MoveTrackItem(self, Marker, frm_pos)
		return Marker
	end

	function MarkerTrack:AddMarker(Marker, overwrite)
		assert(Marker.ParentTrack == nil, "Marker already is parented to a MarkerTrack.")
		super.AddTrackItem(self, Marker, overwrite)
		if self.selected then
			Marker:SetItemPaint(Marker.UI.BG_Middle.Line, {BackgroundColor3 = "highlight"})
			Marker:SetItemPaint(Marker.UI.Start, {BackgroundColor3 = "highlight"})
			Marker:SetItemPaint(Marker.UI.End, {BackgroundColor3 = "highlight"})
		end
		return Marker
	end

	function MarkerTrack:RemoveMarker(Marker)
		assert(Marker.ParentTrack == self, "Marker does not exist in MarkerTrack.")
		super.RemoveTrackItem(self, Marker)
		return Marker
	end
end

return MarkerTrack
