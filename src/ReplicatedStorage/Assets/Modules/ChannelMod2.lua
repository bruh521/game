
-- Decompiled with the Synapse X Luau decompiler.

local v2 = {
	Time = 1
};
v2.mt = {
	__index = v2
};
function v2.new(p1, p2, p3)
	local v3 = setmetatable({}, v2.mt);
	v3.Time = p1;
	v3.Func = p2;
	v3.Duration = p3;
	v3.TimeSpot = 0;
	v3.Cancelled = nil;
	v3.StoppedShort = nil;
	local u1 = v3;
	local u2 = nil;
	u2 = coroutine.create(function()
		wait(p1 + 5);
		if u1 and not u1.StoppedShort and not u1.Cancelled then
			u1.StoppedShort = true;
			u1.Cancelled = true;
			if not u1.LoopBegan then
				u1 = nil;
			end;
		end;
		if not coroutine.running() then
			coroutine.close(u2);
			return;
		end;
		u2 = nil;
		coroutine.yield();
	end);
	coroutine.resume(u2);
	return v3;
end;
local l__RunService__3 = game:GetService("RunService");
function v2.Start(p4)
	if p4.Cancelled then
		setmetatable(p4, nil);
		p4 = nil;
		return;
	end;
	local v4 = tick();
	p4.TimeSpot = tick() - v4;
	p4.LoopBegan = true;
	local u4 = p4;
	local u5 = nil;
	u5 = l__RunService__3.Heartbeat:Connect(function()
		if u4.StoppedShort then
			u5:Disconnect();
			setmetatable(u4, nil);
			u4 = nil;
			return;
		end;
		if u4.Time <= u4.TimeSpot and not u4.Cancelled then
			u5:Disconnect();
			local v5, v6 = pcall(function()
				u4.Func();
			end);
			if not v5 then
				print(v6);
			end;
			setmetatable(u4, nil);
			u4 = nil;
			return;
		end;
		u4.TimeSpot = tick() - v4;
		if u4.Duration then
			u4.Duration();
		end;
	end);
end;
function v2.Cancel(p5)
	if p5.StoppedShort or p5.Cancelled then
		return;
	end;
	p5.Cancelled = true;
	p5.StoppedShort = true;
end;
function v2.StopShort(p6)
	if p6.StoppedShort or p6.Cancelled then
		return;
	end;
	p6.StoppedShort = true;
	p6.Cancelled = true;
	p6.Func();
end;
function v2.Prolong(p7, p8)
	p7.Time = p7.Time + p8;
end;
return v2;

