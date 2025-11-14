--[[
Framework Integration Tests
============================

Integration tests that verify core modules work together correctly.

Test Categories:
1. Framework initialization flow
2. Event bus + plugin system integration
3. Plugin system + module loader integration
4. Config schema + plugin system integration
5. Full framework lifecycle

Uses standard luassert syntax with #integration tag.
--]]

local spec_helper = require("spec.spec_helper")

describe("framework integration #integration", function()
	before_each(function()
		spec_helper.setup()
		-- Clear all module caches
		package.loaded["nvim"] = nil
		package.loaded["nvim.core.event_bus"] = nil
		package.loaded["nvim.core.plugin_system"] = nil
		package.loaded["nvim.core.module_loader"] = nil
		package.loaded["nvim.core.config_schema"] = nil
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("event bus + plugin system", function()
		it("should emit lifecycle events when plugins are loaded", function()
			local event_bus = require("nvim.core.event_bus")
			local plugin_system = require("nvim.core.plugin_system")

			local events_received = {}

			-- Subscribe to all plugin events
			event_bus.on("plugin:before_load", function(data)
				table.insert(events_received, { event = "before_load", plugin = data.name })
			end)

			event_bus.on("plugin:loaded", function(data)
				table.insert(events_received, { event = "loaded", plugin = data.name })
			end)

			event_bus.on("plugin:configured", function(data)
				table.insert(events_received, { event = "configured", plugin = data.name })
			end)

			-- Register and load a plugin
			plugin_system.register("test_plugin", {
				config = function() end,
			})
			plugin_system.load("test_plugin")

			-- Verify events were emitted in correct order
			assert.equals(3, #events_received)
			assert.equals("before_load", events_received[1].event)
			assert.equals("loaded", events_received[2].event)
			assert.equals("configured", events_received[3].event)
		end)

		it("should emit error event when plugin loading fails", function()
			local event_bus = require("nvim.core.event_bus")
			local plugin_system = require("nvim.core.plugin_system")

			local error_received = false
			local error_plugin = nil

			event_bus.on("plugin:error", function(data)
				error_received = true
				error_plugin = data.name
			end)

			-- Register plugin with failing config
			plugin_system.register("failing_plugin", {
				config = function()
					error("Test error")
				end,
			})
			plugin_system.load("failing_plugin")

			assert.is_true(error_received)
			assert.equals("failing_plugin", error_plugin)
		end)
	end)

	describe("plugin system + module loader", function()
		it("should handle plugin dependencies correctly", function()
			local plugin_system = require("nvim.core.plugin_system")

			local load_order = {}

			-- Register plugins with dependencies
			plugin_system.register("base", {
				config = function()
					table.insert(load_order, "base")
				end,
			})

			plugin_system.register("depends_on_base", {
				dependencies = { "base" },
				config = function()
					table.insert(load_order, "depends_on_base")
				end,
			})

			-- Load dependent plugin
			plugin_system.load("depends_on_base")

			-- Verify dependency was loaded first
			assert.equals(2, #load_order)
			assert.equals("base", load_order[1])
			assert.equals("depends_on_base", load_order[2])
		end)
	end)

	describe("config schema + validation", function()
		it("should validate and merge plugin configurations", function()
			local config_schema = require("nvim.core.config_schema")
			local _utils = require("nvim.lib.utils")

			-- Define a plugin config schema
			config_schema.define("my_plugin", {
				enabled = { type = "boolean", default = true },
				timeout = { type = "number", default = 5000 },
				servers = { type = "array", items = { type = "string" }, default = {} },
			})

			-- User config
			local user_config = {
				timeout = 10000,
				servers = { "server1" },
			}

			-- Merge with defaults
			local merged = config_schema.merge("my_plugin", user_config)

			-- Verify merge worked correctly
			assert.is_true(merged.enabled) -- From default
			assert.equals(10000, merged.timeout) -- From user
			assert.equals(1, #merged.servers) -- From user
			assert.equals("server1", merged.servers[1])
		end)

		it("should validate config and report errors", function()
			local config_schema = require("nvim.core.config_schema")

			config_schema.define("validated_plugin", {
				port = {
					type = "number",
					required = true,
					validator = function(value)
						return value > 0 and value <= 65535, "Port must be between 1 and 65535"
					end,
				},
			})

			-- Valid config
			local valid, errors = config_schema.validate("validated_plugin", { port = 8080 })
			assert.is_true(valid)
			assert.is_nil(errors)

			-- Invalid config (missing required)
			valid, errors = config_schema.validate("validated_plugin", {})
			assert.is_false(valid)
			assert.is_not_nil(errors)

			-- Invalid config (failed validator)
			valid, errors = config_schema.validate("validated_plugin", { port = 99999 })
			assert.is_false(valid)
			assert.is_not_nil(errors.port)
		end)
	end)

	describe("complete framework initialization", function()
		it("should initialize all core modules successfully", function()
			local nvim = require("nvim")

			-- Verify all core modules are accessible
			assert.is_not_nil(nvim.core.module_loader)
			assert.is_not_nil(nvim.core.event_bus)
			assert.is_not_nil(nvim.core.plugin_system)
			assert.is_not_nil(nvim.core.config_schema)

			-- Verify all lib modules are accessible
			assert.is_not_nil(nvim.lib.utils)
			assert.is_not_nil(nvim.lib.validator)
		end)

		it("should have working version information", function()
			local nvim = require("nvim")

			assert.is_string(nvim.version)
			assert.is_not_nil(nvim.version:match("%d+%.%d+%.%d+"))
		end)
	end)

	describe("cross-module workflows", function()
		it("should support complete plugin registration and validation workflow", function()
			local event_bus = require("nvim.core.event_bus")
			local plugin_system = require("nvim.core.plugin_system")
			local config_schema = require("nvim.core.config_schema")

			-- Define plugin config schema
			config_schema.define("workflow_plugin", {
				enabled = { type = "boolean", default = true },
				features = { type = "array", items = { type = "string" } },
			})

			-- User config
			local user_config = { features = { "feature1", "feature2" } }

			-- Validate config
			local valid, _errors = config_schema.validate("workflow_plugin", user_config)
			assert.is_true(valid)

			-- Merge with defaults
			local config = config_schema.merge("workflow_plugin", user_config)

			-- Track events
			local setup_complete = false
			event_bus.on("plugin:configured", function(data)
				if data.name == "workflow_plugin" then
					setup_complete = true
				end
			end)

			-- Register plugin with merged config
			plugin_system.register("workflow_plugin", {
				config = function()
					-- Plugin would use the merged config here
					assert.is_true(config.enabled)
					assert.equals(2, #config.features)
				end,
			})

			-- Load plugin
			plugin_system.load("workflow_plugin")

			-- Verify workflow completed
			assert.is_true(setup_complete)
		end)

		it("should handle multiple plugins with event coordination", function()
			local event_bus = require("nvim.core.event_bus")
			local plugin_system = require("nvim.core.plugin_system")

			local plugin_states = {}

			-- Track all plugin lifecycle events
			event_bus.on("plugin:configured", function(data)
				plugin_states[data.name] = "configured"
			end)

			-- Register multiple plugins
			plugin_system.register("plugin_a", {
				config = function() end,
			})

			plugin_system.register("plugin_b", {
				dependencies = { "plugin_a" },
				config = function()
					-- Verify dependency was configured first
					assert.equals("configured", plugin_states["plugin_a"])
				end,
			})

			plugin_system.register("plugin_c", {
				dependencies = { "plugin_b" },
				config = function()
					-- Verify dependencies were configured
					assert.equals("configured", plugin_states["plugin_a"])
					assert.equals("configured", plugin_states["plugin_b"])
				end,
			})

			-- Load top-level plugin (should cascade)
			plugin_system.load("plugin_c")

			-- Verify all plugins were configured
			assert.equals("configured", plugin_states["plugin_a"])
			assert.equals("configured", plugin_states["plugin_b"])
			assert.equals("configured", plugin_states["plugin_c"])
		end)
	end)

	describe("utility library integration", function()
		it("should use utils for deep copying and merging", function()
			local _utils = require("nvim.lib.utils")
			local config_schema = require("nvim.core.config_schema")

			-- Define schema with nested config
			config_schema.define("nested_config", {
				server = {
					type = "table",
					default = { host = "localhost", port = 3000 },
					fields = {
						host = { type = "string" },
						port = { type = "number" },
					},
				},
			})

			-- User overrides only port
			local user_config = {
				server = { port = 8080 },
			}

			-- Merge should preserve host from default
			local merged = config_schema.merge("nested_config", user_config)
			assert.equals("localhost", merged.server.host)
			assert.equals(8080, merged.server.port)

			-- Original configs should be unchanged (deep copy working)
			assert.is_nil(user_config.server.host)
		end)

		it("should use validator for type checking", function()
			local _validator = require("nvim.lib.validator")
			local config_schema = require("nvim.core.config_schema")

			config_schema.define("typed_config", {
				count = { type = "number", required = true },
				tags = { type = "array", items = { type = "string" } },
			})

			-- Valid config
			local valid = config_schema.validate("typed_config", {
				count = 10,
				tags = { "tag1", "tag2" },
			})
			assert.is_true(valid)

			-- Invalid config (wrong types)
			valid = config_schema.validate("typed_config", {
				count = "10", -- String instead of number
				tags = { "tag1", 123 }, -- Number in string array
			})
			assert.is_false(valid)
		end)
	end)
end)
