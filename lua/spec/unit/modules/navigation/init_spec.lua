--[[
Navigation Module Unit Tests
=============================

Unit tests for navigation module orchestrator.
Tests that the module properly orchestrates telescope, tree, and keymaps.
--]]

describe("modules.navigation #unit", function()
	local spec_helper = require("spec.spec_helper")
	local navigation

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.navigation"] = nil
		package.loaded["modules.navigation.telescope"] = nil
		package.loaded["modules.navigation.tree"] = nil
		package.loaded["modules.navigation.keymaps"] = nil

		-- Track module setup calls
		_G._test_telescope_setup_called = false
		_G._test_tree_setup_called = false
		_G._test_keymaps_setup_called = false

		-- Mock telescope module
		package.preload["modules.navigation.telescope"] = function()
			return {
				setup = function(config)
					_G._test_telescope_setup_called = true
					return true
				end,
				get_builtin = function()
					return {}
				end,
			}
		end

		-- Mock tree module
		package.preload["modules.navigation.tree"] = function()
			return {
				setup = function(config)
					_G._test_tree_setup_called = true
					return true
				end,
				get_api = function()
					return {}
				end,
			}
		end

		-- Mock keymaps module
		package.preload["modules.navigation.keymaps"] = function()
			return {
				setup = function()
					_G._test_keymaps_setup_called = true
					return true
				end,
			}
		end

		navigation = require("modules.navigation")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_telescope_setup_called = nil
		_G._test_tree_setup_called = nil
		_G._test_keymaps_setup_called = nil

		-- Clear package cache
		package.loaded["modules.navigation"] = nil
		package.loaded["modules.navigation.telescope"] = nil
		package.loaded["modules.navigation.tree"] = nil
		package.loaded["modules.navigation.keymaps"] = nil
		package.preload["modules.navigation.telescope"] = nil
		package.preload["modules.navigation.tree"] = nil
		package.preload["modules.navigation.keymaps"] = nil
	end)

	describe("Module structure", function()
		it("should have a setup function", function()
			assert.is_function(navigation.setup)
		end)
	end)

	describe("setup()", function()
		it("should return true on successful setup", function()
			local result = navigation.setup()
			assert.is_true(result)
		end)

		it("should setup telescope", function()
			navigation.setup()
			assert.is_true(_G._test_telescope_setup_called)
		end)

		it("should setup tree", function()
			navigation.setup()
			assert.is_true(_G._test_tree_setup_called)
		end)

		it("should setup keymaps", function()
			navigation.setup()
			assert.is_true(_G._test_keymaps_setup_called)
		end)

		it("should accept empty config", function()
			local result = navigation.setup({})
			assert.is_true(result)
		end)

		it("should accept nil config", function()
			local result = navigation.setup(nil)
			assert.is_true(result)
		end)

		it("should pass config to submodules", function()
			local config = {
				telescope = { test = true },
				tree = { test = true },
			}
			local result = navigation.setup(config)
			assert.is_true(result)
		end)
	end)

	describe("Setup order", function()
		it("should setup telescope before keymaps", function()
			-- Reset flags
			_G._test_telescope_setup_called = false
			_G._test_keymaps_setup_called = false
			local telescope_setup_order = nil
			local keymaps_setup_order = nil
			local call_order = 0

			-- Override mocks to track order
			package.loaded["modules.navigation.telescope"] = nil
			package.preload["modules.navigation.telescope"] = function()
				return {
					setup = function(config)
						call_order = call_order + 1
						telescope_setup_order = call_order
						_G._test_telescope_setup_called = true
						return true
					end,
					get_builtin = function()
						return {}
					end,
				}
			end

			package.loaded["modules.navigation.keymaps"] = nil
			package.preload["modules.navigation.keymaps"] = function()
				return {
					setup = function()
						call_order = call_order + 1
						keymaps_setup_order = call_order
						_G._test_keymaps_setup_called = true
						return true
					end,
				}
			end

			-- Reload navigation module with new mocks
			package.loaded["modules.navigation"] = nil
			navigation = require("modules.navigation")
			navigation.setup()

			assert.is_true(telescope_setup_order < keymaps_setup_order)
		end)

		it("should setup tree before keymaps", function()
			-- Reset flags
			_G._test_tree_setup_called = false
			_G._test_keymaps_setup_called = false
			local tree_setup_order = nil
			local keymaps_setup_order = nil
			local call_order = 0

			-- Override mocks to track order
			package.loaded["modules.navigation.tree"] = nil
			package.preload["modules.navigation.tree"] = function()
				return {
					setup = function(config)
						call_order = call_order + 1
						tree_setup_order = call_order
						_G._test_tree_setup_called = true
						return true
					end,
					get_api = function()
						return {}
					end,
				}
			end

			package.loaded["modules.navigation.keymaps"] = nil
			package.preload["modules.navigation.keymaps"] = function()
				return {
					setup = function()
						call_order = call_order + 1
						keymaps_setup_order = call_order
						_G._test_keymaps_setup_called = true
						return true
					end,
				}
			end

			-- Reload navigation module with new mocks
			package.loaded["modules.navigation"] = nil
			navigation = require("modules.navigation")
			navigation.setup()

			assert.is_true(tree_setup_order < keymaps_setup_order)
		end)
	end)

	describe("Graceful degradation", function()
		it("should continue if telescope fails", function()
			package.loaded["modules.navigation.telescope"] = nil
			package.preload["modules.navigation.telescope"] = function()
				return {
					setup = function()
						return false
					end,
					get_builtin = function()
						return nil
					end,
				}
			end

			package.loaded["modules.navigation"] = nil
			navigation = require("modules.navigation")
			local result = navigation.setup()

			-- Should still succeed even if telescope fails
			assert.is_true(result)
			assert.is_true(_G._test_tree_setup_called)
			assert.is_true(_G._test_keymaps_setup_called)
		end)

		it("should continue if tree fails", function()
			package.loaded["modules.navigation.tree"] = nil
			package.preload["modules.navigation.tree"] = function()
				return {
					setup = function()
						return false
					end,
					get_api = function()
						return nil
					end,
				}
			end

			package.loaded["modules.navigation"] = nil
			navigation = require("modules.navigation")
			local result = navigation.setup()

			-- Should still succeed even if tree fails
			assert.is_true(result)
			assert.is_true(_G._test_telescope_setup_called)
			assert.is_true(_G._test_keymaps_setup_called)
		end)
	end)
end)
