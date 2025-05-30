return function()
	local Signal = require(script.Parent.Signal)

	it("should construct from nothing", function()
		local signal = Signal.new()

		expect(signal).to.be.ok()
	end)

	it("should fire connected callbacks", function()
		local callCount = 0
		local value1 = "Hello World"
		local value2 = 7

		local callback = function(arg1, arg2)
			expect(arg1).to.equal(value1)
			expect(arg2).to.equal(value2)
			callCount = callCount + 1
		end

		local signal = Signal.new()

		local connection = signal:connect(callback)
		signal:fire(value1, value2)

		expect(callCount).to.equal(1)

		connection:disconnect()
		signal:fire(value1, value2)

		expect(callCount).to.equal(1)
	end)

	it("should disconnect handlers", function()
		local callback = function()
			error("Callback was called after disconnect!")
		end

		local signal = Signal.new()

		local connection = signal:connect(callback)
		connection:disconnect()

		signal:fire()
	end)

	it("should fire handlers in order", function()
		local signal = Signal.new()
		local x = 0
		local y = 0

		local callback1 = function()
			expect(x).to.equal(0)
			expect(y).to.equal(0)
			x = x + 1
		end

		local callback2 = function()
			expect(x).to.equal(1)
			expect(y).to.equal(0)
			y = y + 1
		end

		signal:connect(callback1)
		signal:connect(callback2)
		signal:fire()

		expect(x).to.equal(1)
		expect(y).to.equal(1)
	end)

	it("should continue firing despite mid-event disconnection", function()
		local signal = Signal.new()
		local countA = 0
		local countB = 0

		local connectionA
		connectionA = signal:connect(function()
			connectionA:disconnect()
			countA = countA + 1
		end)

		signal:connect(function()
			countB = countB + 1
		end)

		signal:fire()

		expect(countA).to.equal(1)
		expect(countB).to.equal(1)
	end)

	it("should skip listeners that were disconnected during event evaluation", function()
		local signal = Signal.new()
		local countA = 0
		local countB = 0

		local connectionB

		signal:connect(function()
			countA = countA + 1
			connectionB:disconnect()
		end)

		connectionB = signal:connect(function()
			countB = countB + 1
		end)

		signal:fire()

		expect(countA).to.equal(1)
		expect(countB).to.equal(0)
	end)

	it("should throw an error if the argument to `connect` is not a function", function()
		local signal = Signal.new()
		expect(function()
			signal:connect("not a function" :: any)
		end).to.throw()
	end)

	it("should throw an error when disconnecting more than once", function()
		local signal = Signal.new()

		local connection = signal:connect(function() end)
		-- Okay to disconnect once
		expect(connection.disconnect).never.to.throw()

		-- Throw an error if we disconnect twice
		expect(connection.disconnect).to.throw()
	end)

	it("should throw an error when subscribing during dispatch", function()
		local mockStore = {
			_isDispatching = false,
		}
		local signal = Signal.new(mockStore)

		signal:connect(function()
			-- Subscribe while listeners are being fired
			signal:connect(function() end)
		end)

		mockStore._isDispatching = true
		expect(function()
			signal:fire()
		end).to.throw()
	end)

	it("should throw an error when unsubscribing during dispatch", function()
		local mockStore = {
			_isDispatching = false,
		}
		local signal = Signal.new(mockStore)

		local connection
		connection = signal:connect(function()
			connection.disconnect()
		end)

		mockStore._isDispatching = true
		expect(function()
			signal:fire()
		end).to.throw()
	end)
end