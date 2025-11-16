--[[
UI Module Tests
===============

Tests for the unified UI module.

Test Categories:
1. Module structure
2. setup() with defaults
3. setup() with custom config
4. Graceful degradation
--]]

describe("modules.ui #unit", function()
	local spec_helper = require("spec.spec_helper")
	local ui

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.ui"] = nil
		package.loaded["modules.ui.init"] = nil

		-- Track configuration calls
		_G._test_colorscheme = nil
		_G._test_background = nil
		_G._test_plugins_configured = {}

		-- Mock vim APIs
		vim.cmd = function(cmd)
			if type(cmd) == "string" then
				local scheme = cmd:match("^colorscheme%s+(.+)$")
				if scheme then
					_G._test_colorscheme = scheme
				end
			end
		end

		vim.o = setmetatable({}, {
			__newindex = function(_, key, value)
				if key == "background" then
					_G._test_background = value
				end
			end,
		})

		-- Mock plugin modules
		package.preload["nvim-web-devicons"] = function()
			return {
				setup = function(config)
					_G._test_plugins_configured.devicons = config
				end,
			}
		end

		package.preload["lualine"] = function()
			return {
				setup = function(config)
					_G._test_plugins_configured.lualine = config
				end,
			}
		end

		package.preload["ibl"] = function()
			return {
				setup = function(config)
					_G._test_plugins_configured.ibl = config
				end,
			}
		end

		package.preload["notify"] = function()
			-- Create a table that acts like a function
			local notify_mod = setmetatable({
				setup = function(config)
					_G._test_plugins_configured.notify = config
				end,
			}, {
				__call = function(self, msg, level, opts)
					-- Mock notify function - do nothing
				end,
			})
			return notify_mod
		end

		ui = require("modules.ui")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_colorscheme = nil
		_G._test_background = nil
		_G._test_plugins_configured = nil
	end)

	describe("Module structure", function()
		it("should load without errors", function()
			assert.is_not_nil(ui)
			assert.is_table(ui)
		end)

		it("should have setup function", function()
			assert.is_function(ui.setup)
		end)
	end)

	describe("setup() with defaults", function()
		it("should return true on success", function()
			local result = ui.setup()
			assert.is_true(result)
		end)

		it("should apply gruvbox colorscheme", function()
			ui.setup()
			assert.equal("gruvbox", _G._test_colorscheme)
		end)

		it("should configure devicons (eager-loaded)", function()
			ui.setup()
			assert.is_not_nil(_G._test_plugins_configured.devicons)
		end)

		it("should not configure lazy-loaded plugins during setup", function()
			ui.setup()
			-- Lualine, ibl, notify are lazy-loaded and configured on-demand
			assert.is_nil(_G._test_plugins_configured.lualine)
			assert.is_nil(_G._test_plugins_configured.ibl)
			assert.is_nil(_G._test_plugins_configured.notify)
		end)
	end)

	describe("setup() with custom config", function()
		it("should accept empty config", function()
			local result = ui.setup({})
			assert.is_true(result)
		end)

		it("should apply light background when specified", function()
			ui.setup({ colorscheme = { background = "light" } })
			assert.equal("light", _G._test_background)
		end)

		it("should apply dark background when specified", function()
			ui.setup({ colorscheme = { background = "dark" } })
			assert.equal("dark", _G._test_background)
		end)
	end)

	describe("Graceful degradation", function()
		it("should return false when colorscheme fails", function()
			vim.cmd = function()
				error("Colorscheme not found")
			end

			local result = ui.setup()
			assert.is_false(result)
		end)

		it("should return false when devicons missing", function()
			package.loaded["nvim-web-devicons"] = nil
			package.preload["nvim-web-devicons"] = function()
				error("not found")
			end

			local result = ui.setup()
			assert.is_false(result)
		end)
	end)
end)
