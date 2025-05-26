--------------------------------------------------------------------------
-- @ CloneTrooper1019, 2020-2021
--   Thread.lua
--------------------------------------------------------------------------

local Thread = {}

--------------------------------------------------------------------------
-- Task Scheduler
--------------------------------------------------------------------------

local RunService = game:GetService("RunService")
local front

-- use array indices for speed
-- and avoiding lua hash tables

local THREAD = 1
local RESUME = 2

local NEXT = 3
local PREV = 4

local function pushThread(thread: thread, resume: number)
	local node =
		{
			[THREAD] = thread;
			[RESUME] = resume;
		}

	if front then
		if front[RESUME] >= resume then
			node[NEXT] = front
			front = node
		else
			local prev = front

			while prev[NEXT] and prev[NEXT][RESUME] < resume do
				prev = prev[NEXT]
			end

			node[NEXT] = prev[NEXT]

			if prev[NEXT] then
				node[NEXT][PREV] = node
			end

			prev[NEXT] = node
			node[PREV] = prev
		end
	else
		front = node
	end
end

local function popThreads()
	local now = os.clock()

	while front do
		-- Resume if we're reasonably close enough.
		if front[RESUME] - now < (1 / 120) then
			local thread = front[THREAD]
			local nextNode = front[NEXT]

			if nextNode then
				nextNode[PREV] = nil
			end

			front = nextNode
			coroutine.resume(thread, now)
		else
			break
		end
	end
end

RunService.Heartbeat:Connect(popThreads)

--------------------------------------------------------------------------
-- Thread
--------------------------------------------------------------------------

local errorStack = "ERROR: %s\nStack Begin\n%sStack End"

local function HandleError(err)
	local errMsg = errorStack:format(err, debug.traceback())
	warn(errMsg)
end

function Thread:Wait(t: number?)
	local t = tonumber(t)
	local start = os.clock()

	local thread = coroutine.running()
	pushThread(thread, start + (t or 1/60))

	-- Wait for the thread to resume.
	local now = coroutine.yield()
	return now - start, os.clock()
end

function Thread:Spawn(func: any, ...)
	local args = { ... }
	local numArgs = select('#', ...)
	local bindable = Instance.new("BindableEvent")

	bindable.Event:Connect(function (stack)
		xpcall(func, HandleError, stack())
	end)

	bindable:Fire(function ()
		return unpack(args, 1, numArgs)
	end)
end

function Thread:Delay(t: number, callback: any)
	self:Spawn(function ()
		local delayTime, elapsed = self:Wait(t)
		xpcall(callback, HandleError, delayTime, elapsed)
	end)
end

--------------------------------------------------------------------------

return Thread