local channel = {
	Time = 1
}
channel.mt = {
	__index = channel
}
function channel.new(t,func,dura)
	local timer = setmetatable({},channel.mt)
	timer.Time = t
	timer.Func = func
	timer.Duration = dura
	timer.TimeSpot = 0
	timer.Cancelled = false
	timer.StoppedShort = false
	
	return timer
end
local runService = game:GetService"RunService"
function channel.Start(timer)
	timer.timeTick = tick()
	coroutine.resume((coroutine.create(function()
		timer.TimeSpot = tick() - timer.timeTick
		while timer.TimeSpot < timer.Time and not timer.StoppedShort and not timer.Cancelled do
			timer.TimeSpot = tick() - timer.timeTick
			if timer.Duration then
				timer.Duration()
			end;
			runService.Stepped:Wait()	
		end
		if not timer.Cancelled then
			timer.Func()
		end
	end)))
end
function channel.Cancel(timer)
	timer.Cancelled = true
	timer.StoppedShort = true
end
function channel.StopShort(timer)
	timer.StoppedShort = true
	timer.Cancelled = true
	timer.Func()
end
function channel.Prolong(timer,t)
	timer.Time += t
end

function channel.Reset(timer,t)
	timer.timeTick = tick()
	timer.TimeSpot = tick() - timer.timeTick
end

function channel.GetRemaining(timer)
	local T = tick() - timer.timeTick
	local Time = timer.Time - T

	return Time > 0 and Time or 0
end

return channel
