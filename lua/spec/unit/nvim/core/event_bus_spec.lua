--[[
Event Bus Unit Tests
=====================

Unit tests for the event bus system that provides pub/sub messaging,
event handling, and inter-module communication.

Test Categories:
1. Event subscription
2. Event emission
3. Event filtering
4. Callback execution
5. Error handling
6. Unsubscription

Uses standard luassert syntax with plans for custom NeoVim-specific assertions
like assert.event.was_emitted() in the future.
--]]

local spec_helper = require("spec.spec_helper")

describe("event_bus #unit", function()
	local event_bus

	before_each(function()
		spec_helper.setup()
		-- Clear any previously loaded module
		package.loaded["nvim.core.event_bus"] = nil
		event_bus = require("nvim.core.event_bus")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("initialization", function()
		it("should create an event bus instance", function()
			assert.is_not_nil(event_bus)
			assert.is_table(event_bus)
		end)

		it("should have an on method for subscribing", function()
			assert.is_function(event_bus.on)
		end)

		it("should have an emit method for publishing", function()
			assert.is_function(event_bus.emit)
		end)

		it("should have an off method for unsubscribing", function()
			assert.is_function(event_bus.off)
		end)

		it("should have a clear method for clearing subscriptions", function()
			assert.is_function(event_bus.clear)
		end)

		it("should have a get_subscribers method", function()
			assert.is_function(event_bus.get_subscribers)
		end)
	end)

	describe("on() - event subscription", function()
		it("should subscribe to an event", function()
			local callback_called = false
			local callback = function()
				callback_called = true
			end

			event_bus.on("test_event", callback)
			event_bus.emit("test_event")

			assert.is_true(callback_called)
		end)

		it("should return a subscription id", function()
			local callback = function() end
			local subscription_id = event_bus.on("test_event", callback)

			assert.is_not_nil(subscription_id)
			assert.is_number(subscription_id)
		end)

		it("should allow multiple subscriptions to the same event", function()
			local callback1_called = false
			local callback2_called = false

			event_bus.on("test_event", function()
				callback1_called = true
			end)
			event_bus.on("test_event", function()
				callback2_called = true
			end)

			event_bus.emit("test_event")

			assert.is_true(callback1_called)
			assert.is_true(callback2_called)
		end)

		it("should require a valid event name", function()
			local success, err = pcall(function()
				event_bus.on(nil, function() end)
			end)

			assert.is_false(success)
			assert.is_string(err)
		end)

		it("should require a valid callback function", function()
			local success, err = pcall(function()
				event_bus.on("test_event", nil)
			end)

			assert.is_false(success)
			assert.is_string(err)
		end)

		it("should support subscription options", function()
			local callback = function() end
			local subscription_id = event_bus.on("test_event", callback, {
				once = false,
				priority = 10,
			})

			assert.is_not_nil(subscription_id)
		end)
	end)

	describe("emit() - event publishing", function()
		it("should emit an event", function()
			local callback_called = false

			event_bus.on("test_event", function()
				callback_called = true
			end)

			event_bus.emit("test_event")

			assert.is_true(callback_called)
		end)

		it("should pass data to callbacks", function()
			local received_data = nil

			event_bus.on("test_event", function(data)
				received_data = data
			end)

			local test_data = { foo = "bar", baz = 123 }
			event_bus.emit("test_event", test_data)

			assert.is_not_nil(received_data)
			assert.equals("bar", received_data.foo)
			assert.equals(123, received_data.baz)
		end)

		it("should handle events with no subscribers", function()
			-- Should not error
			local success = pcall(function()
				event_bus.emit("non_existent_event")
			end)

			assert.is_true(success)
		end)

		it("should execute callbacks in order of subscription", function()
			local call_order = {}

			event_bus.on("test_event", function()
				table.insert(call_order, "first")
			end)

			event_bus.on("test_event", function()
				table.insert(call_order, "second")
			end)

			event_bus.emit("test_event")

			assert.equals(2, #call_order)
			assert.equals("first", call_order[1])
			assert.equals("second", call_order[2])
		end)

		it("should respect callback priorities", function()
			local call_order = {}

			event_bus.on("test_event", function()
				table.insert(call_order, "low")
			end, { priority = 1 })

			event_bus.on("test_event", function()
				table.insert(call_order, "high")
			end, { priority = 10 })

			event_bus.emit("test_event")

			assert.equals(2, #call_order)
			-- Higher priority should be called first
			assert.equals("high", call_order[1])
			assert.equals("low", call_order[2])
		end)
	end)

	describe("off() - unsubscription", function()
		it("should unsubscribe by subscription id", function()
			local callback_called = false
			local callback = function()
				callback_called = true
			end

			local subscription_id = event_bus.on("test_event", callback)
			event_bus.off(subscription_id)
			event_bus.emit("test_event")

			assert.is_false(callback_called)
		end)

		it("should unsubscribe all callbacks for an event", function()
			local callback1_called = false
			local callback2_called = false

			event_bus.on("test_event", function()
				callback1_called = true
			end)
			event_bus.on("test_event", function()
				callback2_called = true
			end)

			event_bus.off("test_event")
			event_bus.emit("test_event")

			assert.is_false(callback1_called)
			assert.is_false(callback2_called)
		end)

		it("should handle invalid subscription ids gracefully", function()
			local success = pcall(function()
				event_bus.off(999999)
			end)

			assert.is_true(success)
		end)
	end)

	describe("once() - one-time subscriptions", function()
		it("should only call callback once", function()
			local callback_count = 0

			event_bus.on("test_event", function()
				callback_count = callback_count + 1
			end, { once = true })

			event_bus.emit("test_event")
			event_bus.emit("test_event")
			event_bus.emit("test_event")

			assert.equals(1, callback_count)
		end)

		it("should automatically unsubscribe after first call", function()
			local callback = function() end
			local subscription_id = event_bus.on("test_event", callback, { once = true })

			event_bus.emit("test_event")

			-- Try to unsubscribe again (should not error)
			local success = pcall(function()
				event_bus.off(subscription_id)
			end)

			assert.is_true(success)
		end)
	end)

	describe("clear() - clearing subscriptions", function()
		it("should clear all subscriptions", function()
			local callback1_called = false
			local callback2_called = false

			event_bus.on("event1", function()
				callback1_called = true
			end)
			event_bus.on("event2", function()
				callback2_called = true
			end)

			event_bus.clear()

			event_bus.emit("event1")
			event_bus.emit("event2")

			assert.is_false(callback1_called)
			assert.is_false(callback2_called)
		end)

		it("should clear subscriptions for a specific event", function()
			local event1_called = false
			local event2_called = false

			event_bus.on("event1", function()
				event1_called = true
			end)
			event_bus.on("event2", function()
				event2_called = true
			end)

			event_bus.clear("event1")

			event_bus.emit("event1")
			event_bus.emit("event2")

			assert.is_false(event1_called)
			assert.is_true(event2_called)
		end)
	end)

	describe("get_subscribers() - introspection", function()
		it("should return list of subscribers for an event", function()
			event_bus.on("test_event", function() end)
			event_bus.on("test_event", function() end)

			local subscribers = event_bus.get_subscribers("test_event")

			assert.is_table(subscribers)
			assert.equals(2, #subscribers)
		end)

		it("should return empty list for events with no subscribers", function()
			local subscribers = event_bus.get_subscribers("non_existent_event")

			assert.is_table(subscribers)
			assert.equals(0, #subscribers)
		end)

		it("should return all events when no event name provided", function()
			event_bus.on("event1", function() end)
			event_bus.on("event2", function() end)

			local all_subscriptions = event_bus.get_subscribers()

			assert.is_table(all_subscriptions)
			assert.is_not_nil(all_subscriptions.event1)
			assert.is_not_nil(all_subscriptions.event2)
		end)
	end)

	describe("error handling", function()
		it("should handle callback errors gracefully", function()
			local callback2_called = false

			event_bus.on("test_event", function()
				error("Intentional error for testing")
			end)

			event_bus.on("test_event", function()
				callback2_called = true
			end)

			-- Should not throw, should continue to next callback
			local success = pcall(function()
				event_bus.emit("test_event")
			end)

			assert.is_true(success)
			assert.is_true(callback2_called)
		end)

		it("should notify about callback errors", function()
			event_bus.on("test_event", function()
				error("Intentional error")
			end)

			event_bus.emit("test_event")

			-- Check that an error notification was sent
			local notified = spec_helper.assert_notification("error", vim.log.levels.ERROR)
			assert.is_true(notified)
		end)

		it("should provide detailed error messages", function()
			local success, err = pcall(function()
				event_bus.on(123, function() end)
			end)

			assert.is_false(success)
			assert.is_string(err)
			assert.is_not_nil(err:match("event") or err:match("name") or err:match("string"))
		end)
	end)
end)
