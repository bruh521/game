local _g = _G.MoonGlobal
------------------------------------------------------------
	local MoonSystem

	local Win  = _g.Window:new(script.Name, _g.WindowData:new("Frame Step Offset", script.Contents))

	NumberInput:new(Win.g_e.Offset, 1, nil, {1, _g.MAX_FRAMES, 1, true})

	Button:new(Win.g_e.Confirm)
	Win.FocusedTextBox = Offset.UI.Frame.Input
------------------------------------------------------------
do
	Win.OnOpen = function(args)
		Offset:Set(_g.frame_step_offset)
		return true
	end

	Win.OnClose = function(save)
		if save then
			local layer_sys = _g.Windows.MoonAnimator.g_e.LayerSystem
			_g.frame_step_offset = Offset.Value
		end
		return true
	end

	Win.g_e.Confirm.OnClick = function()
		Win:Close(true)
	end
end

return Win
