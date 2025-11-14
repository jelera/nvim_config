--[[
Event Bus Integration Tests
=============================

Integration tests for the event bus system, testing complex scenarios
with multiple events, subscribers, and interactions.

Test Categories:
1. Multi-event workflows
2. Complex data structures
3. Cross-module communication patterns
4. Real-world usage scenarios

Uses standard luassert syntax with plans for custom NeoVim-specific assertions
like assert.event.was_emitted() in the future.
--]]

local spec_helper = require("spec.spec_helper")

describe("event_bus #integration", function()
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

	describe("multi-event workflows", function()
		it("should handle multiple events and subscribers", function()
			local results = {}

			event_bus.on("user_login", function(data)
				results.login = data.username
			end)

			event_bus.on("user_logout", function(data)
				results.logout = data.username
			end)

			event_bus.on("data_update", function(data)
				results.update = data.count
			end)

			event_bus.emit("user_login", { username = "alice" })
			event_bus.emit("data_update", { count = 42 })
			event_bus.emit("user_logout", { username = "alice" })

			assert.equals("alice", results.login)
			assert.equals("alice", results.logout)
			assert.equals(42, results.update)
		end)

		it("should support event chaining", function()
			local events_triggered = {}

			-- Setup event chain: event1 -> event2 -> event3
			event_bus.on("event1", function()
				table.insert(events_triggered, "event1")
				event_bus.emit("event2")
			end)

			event_bus.on("event2", function()
				table.insert(events_triggered, "event2")
				event_bus.emit("event3")
			end)

			event_bus.on("event3", function()
				table.insert(events_triggered, "event3")
			end)

			event_bus.emit("event1")

			assert.equals(3, #events_triggered)
			assert.equals("event1", events_triggered[1])
			assert.equals("event2", events_triggered[2])
			assert.equals("event3", events_triggered[3])
		end)

		it("should handle concurrent event emissions", function()
			local counters = { a = 0, b = 0, c = 0 }

			event_bus.on("increment_a", function()
				counters.a = counters.a + 1
			end)
			event_bus.on("increment_b", function()
				counters.b = counters.b + 1
			end)
			event_bus.on("increment_c", function()
				counters.c = counters.c + 1
			end)

			-- Emit multiple events rapidly
			for i = 1, 10 do
				event_bus.emit("increment_a")
				event_bus.emit("increment_b")
				event_bus.emit("increment_c")
			end

			assert.equals(10, counters.a)
			assert.equals(10, counters.b)
			assert.equals(10, counters.c)
		end)
	end)

	describe("complex data structures", function()
		it("should support complex nested data", function()
			local received_data = nil

			event_bus.on("complex_event", function(data)
				received_data = data
			end)

			local complex_data = {
				user = { name = "Bob", age = 30, roles = { "admin", "editor" } },
				items = { "a", "b", "c" },
				metadata = {
					timestamp = 123456,
					source = "test",
					nested = { deep = { value = "found" } },
				},
			}

			event_bus.emit("complex_event", complex_data)

			assert.is_not_nil(received_data)
			assert.equals("Bob", received_data.user.name)
			assert.equals(30, received_data.user.age)
			assert.equals(2, #received_data.user.roles)
			assert.equals("admin", received_data.user.roles[1])
			assert.equals(3, #received_data.items)
			assert.equals("test", received_data.metadata.source)
			assert.equals("found", received_data.metadata.nested.deep.value)
		end)

		it("should handle data transformation between events", function()
			local final_result = nil

			-- Transform data through multiple handlers
			event_bus.on("data_input", function(data)
				-- First transformation
				local transformed = { value = data.raw * 2 }
				event_bus.emit("data_transformed", transformed)
			end)

			event_bus.on("data_transformed", function(data)
				-- Second transformation
				local enriched = { original = data.value, enriched = data.value + 10 }
				event_bus.emit("data_enriched", enriched)
			end)

			event_bus.on("data_enriched", function(data)
				final_result = data
			end)

			event_bus.emit("data_input", { raw = 5 })

			assert.is_not_nil(final_result)
			assert.equals(10, final_result.original) -- 5 * 2
			assert.equals(20, final_result.enriched) -- 10 + 10
		end)
	end)

	describe("cross-module communication patterns", function()
		it("should support request-response pattern", function()
			local response = nil

			-- Responder
			event_bus.on("request", function(data)
				local result = { status = "ok", data = data.query .. "_processed" }
				event_bus.emit("response", result)
			end)

			-- Requester
			event_bus.on("response", function(data)
				response = data
			end)

			event_bus.emit("request", { query = "test" })

			assert.is_not_nil(response)
			assert.equals("ok", response.status)
			assert.equals("test_processed", response.data)
		end)

		it("should support pub-sub with multiple subscribers", function()
			local subscribers = { s1 = {}, s2 = {}, s3 = {} }

			event_bus.on("broadcast", function(data)
				table.insert(subscribers.s1, data.message)
			end)

			event_bus.on("broadcast", function(data)
				table.insert(subscribers.s2, data.message)
			end)

			event_bus.on("broadcast", function(data)
				table.insert(subscribers.s3, data.message)
			end)

			event_bus.emit("broadcast", { message = "msg1" })
			event_bus.emit("broadcast", { message = "msg2" })

			-- All subscribers should receive all messages
			assert.equals(2, #subscribers.s1)
			assert.equals(2, #subscribers.s2)
			assert.equals(2, #subscribers.s3)
			assert.equals("msg1", subscribers.s1[1])
			assert.equals("msg2", subscribers.s2[2])
		end)

		it("should support filtering events by context", function()
			local admin_events = {}
			local user_events = {}

			event_bus.on("action", function(data)
				if data.role == "admin" then
					table.insert(admin_events, data.action)
				else
					table.insert(user_events, data.action)
				end
			end)

			event_bus.emit("action", { role = "admin", action = "delete" })
			event_bus.emit("action", { role = "user", action = "view" })
			event_bus.emit("action", { role = "admin", action = "create" })
			event_bus.emit("action", { role = "user", action = "edit" })

			assert.equals(2, #admin_events)
			assert.equals(2, #user_events)
			assert.equals("delete", admin_events[1])
			assert.equals("create", admin_events[2])
			assert.equals("view", user_events[1])
			assert.equals("edit", user_events[2])
		end)
	end)

	describe("real-world scenarios", function()
		it("should handle plugin lifecycle events", function()
			local lifecycle = {}

			event_bus.on("plugin:before_load", function(data)
				table.insert(lifecycle, "before_load:" .. data.name)
			end)

			event_bus.on("plugin:loaded", function(data)
				table.insert(lifecycle, "loaded:" .. data.name)
			end)

			event_bus.on("plugin:configured", function(data)
				table.insert(lifecycle, "configured:" .. data.name)
			end)

			-- Simulate plugin loading
			event_bus.emit("plugin:before_load", { name = "telescope" })
			event_bus.emit("plugin:loaded", { name = "telescope" })
			event_bus.emit("plugin:configured", { name = "telescope" })

			assert.equals(3, #lifecycle)
			assert.equals("before_load:telescope", lifecycle[1])
			assert.equals("loaded:telescope", lifecycle[2])
			assert.equals("configured:telescope", lifecycle[3])
		end)

		it("should handle configuration change propagation", function()
			local components_updated = {}

			-- Multiple components listen for config changes
			event_bus.on("config:changed", function(data)
				if data.key:match("^ui%.") then
					table.insert(components_updated, "ui")
				end
				if data.key:match("^editor%.") then
					table.insert(components_updated, "editor")
				end
				if data.key:match("^lsp%.") then
					table.insert(components_updated, "lsp")
				end
			end)

			event_bus.emit("config:changed", { key = "ui.theme", value = "dark" })
			event_bus.emit("config:changed", { key = "editor.tabsize", value = 2 })
			event_bus.emit("config:changed", { key = "lsp.timeout", value = 5000 })

			assert.equals(3, #components_updated)
			assert.equals("ui", components_updated[1])
			assert.equals("editor", components_updated[2])
			assert.equals("lsp", components_updated[3])
		end)

		it("should support cleanup with once and priorities", function()
			local execution_order = {}

			-- High priority, once
			event_bus.on("startup", function()
				table.insert(execution_order, "init_critical")
			end, { priority = 100, once = true })

			-- Medium priority
			event_bus.on("startup", function()
				table.insert(execution_order, "init_normal")
			end, { priority = 50 })

			-- Low priority, once
			event_bus.on("startup", function()
				table.insert(execution_order, "init_optional")
			end, { priority = 10, once = true })

			-- First startup
			event_bus.emit("startup")

			assert.equals(3, #execution_order)
			assert.equals("init_critical", execution_order[1])
			assert.equals("init_normal", execution_order[2])
			assert.equals("init_optional", execution_order[3])

			execution_order = {}

			-- Second startup - once handlers should not run
			event_bus.emit("startup")

			assert.equals(1, #execution_order)
			assert.equals("init_normal", execution_order[1])
		end)
	end)
end)
