--[[
Telescope Module Unit Tests
============================

Unit tests for Telescope fuzzy finder configuration.
--]]

describe("modules.navigation.telescope #unit", function()
	local spec_helper = require("spec.spec_helper")
	local telescope

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.navigation.telescope"] = nil
		package.loaded["telescope"] = nil
		package.loaded["telescope.builtin"] = nil

		-- Track telescope setup calls
		_G._test_telescope_setup_called = false
		_G._test_telescope_config = nil
		_G._test_telescope_extensions = {}

		-- Mock Telescope
		package.preload["telescope"] = function()
			return {
				setup = function(config)
					_G._test_telescope_setup_called = true
					_G._test_telescope_config = config
				end,
				load_extension = function(name)
					table.insert(_G._test_telescope_extensions, name)
				end,
			}
		end

		-- Mock telescope.actions
		package.preload["telescope.actions"] = function()
			return {
				move_selection_next = function() end,
				move_selection_previous = function() end,
				send_selected_to_qflist = function() end,
				open_qflist = function() end,
				select_all = function() end,
				close = function() end,
				delete_buffer = function() end,
			}
		end

		-- Mock telescope.builtin
		package.preload["telescope.builtin"] = function()
			return {
				find_files = function() end,
				git_files = function() end,
				oldfiles = function() end,
				buffers = function() end,
				live_grep = function() end,
				grep_string = function() end,
				help_tags = function() end,
				man_pages = function() end,
				keymaps = function() end,
				git_commits = function() end,
				git_branches = function() end,
				git_status = function() end,
				commands = function() end,
			}
		end

		telescope = require("modules.navigation.telescope")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_telescope_setup_called = nil
		_G._test_telescope_config = nil
		_G._test_telescope_extensions = nil

		-- Clear package cache
		package.loaded["modules.navigation.telescope"] = nil
		package.loaded["telescope"] = nil
		package.loaded["telescope.actions"] = nil
		package.loaded["telescope.builtin"] = nil
		package.preload["telescope"] = nil
		package.preload["telescope.actions"] = nil
		package.preload["telescope.builtin"] = nil
	end)

	describe("Module structure", function()
		it("should have a setup function", function()
			assert.is_function(telescope.setup)
		end)

		it("should have a get_builtin function", function()
			assert.is_function(telescope.get_builtin)
		end)
	end)

	describe("setup()", function()
		it("should return true on successful setup", function()
			local result = telescope.setup()
			assert.is_true(result)
		end)

		it("should call telescope.setup", function()
			telescope.setup()
			assert.is_true(_G._test_telescope_setup_called)
		end)

		it("should accept empty config", function()
			local result = telescope.setup({})
			assert.is_true(result)
		end)

		it("should accept nil config", function()
			local result = telescope.setup(nil)
			assert.is_true(result)
		end)

		it("should load fzf extension", function()
			telescope.setup()
			local has_fzf = false
			for _, ext in ipairs(_G._test_telescope_extensions) do
				if ext == "fzf" then
					has_fzf = true
					break
				end
			end
			assert.is_true(has_fzf)
		end)
	end)

	describe("Configuration", function()
		it("should configure defaults", function()
			telescope.setup()
			assert.is_not_nil(_G._test_telescope_config)
			assert.is_not_nil(_G._test_telescope_config.defaults)
		end)

		it("should configure layout", function()
			telescope.setup()
			local defaults = _G._test_telescope_config.defaults
			assert.is_not_nil(defaults.layout_strategy)
		end)

		it("should configure sorting", function()
			telescope.setup()
			local defaults = _G._test_telescope_config.defaults
			assert.is_not_nil(defaults.sorting_strategy)
		end)

		it("should configure mappings", function()
			telescope.setup()
			local defaults = _G._test_telescope_config.defaults
			assert.is_not_nil(defaults.mappings)
		end)
	end)

	describe("get_builtin()", function()
		it("should return builtin after successful setup", function()
			telescope.setup()
			local builtin = telescope.get_builtin()
			assert.is_not_nil(builtin)
			assert.is_function(builtin.find_files)
		end)
	end)

	describe("Graceful degradation", function()
		it("should return false when telescope is not available", function()
			package.loaded["modules.navigation.telescope"] = nil
			package.loaded["telescope"] = nil
			package.preload["telescope"] = nil

			local telescope_module = require("modules.navigation.telescope")
			local result = telescope_module.setup()

			assert.is_false(result)
		end)
	end)
end)
