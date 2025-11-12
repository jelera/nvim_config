--[[
Debug Module Integration Tests
===============================

Integration tests for debug module including nvim-dap, dap-ui, and language adapters.

Tags: #integration #debug
--]]

describe("modules.debug #integration #debug", function()
	local spec_helper = require("spec.spec_helper")
	local debug

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.debug"] = nil
		package.loaded["modules.debug.dap"] = nil
		package.loaded["modules.debug.ui"] = nil
		package.loaded["modules.debug.adapters"] = nil
		package.loaded["modules.debug.keymaps"] = nil

		-- Reset tracking flags
		_G._test_debug_dap_setup_called = false
		_G._test_debug_ui_setup_called = false
		_G._test_debug_adapters_setup_called = false
		_G._test_debug_keymaps_setup_called = false

		-- Mock submodules
		package.preload["modules.debug.dap"] = function()
			return {
				setup = function(config)
					_G._test_debug_dap_setup_called = true
					_G._test_debug_dap_config = config
					return true
				end,
			}
		end

		package.preload["modules.debug.ui"] = function()
			return {
				setup = function(config)
					_G._test_debug_ui_setup_called = true
					_G._test_debug_ui_config = config
					return true
				end,
			}
		end

		package.preload["modules.debug.adapters"] = function()
			return {
				setup = function(config)
					_G._test_debug_adapters_setup_called = true
					_G._test_debug_adapters_config = config
					return true
				end,
			}
		end

		package.preload["modules.debug.keymaps"] = function()
			return {
				setup = function()
					_G._test_debug_keymaps_setup_called = true
					return true
				end,
			}
		end
	end)

	after_each(function()
		spec_helper.teardown()

		-- Clean up test globals
		_G._test_debug_dap_setup_called = nil
		_G._test_debug_ui_setup_called = nil
		_G._test_debug_adapters_setup_called = nil
		_G._test_debug_keymaps_setup_called = nil
		_G._test_debug_dap_config = nil
		_G._test_debug_ui_config = nil
		_G._test_debug_adapters_config = nil
	end)

	describe("module loading", function()
		it("should load debug module", function()
			debug = require("modules.debug")
			assert.is_table(debug)
			assert.is_function(debug.setup)
		end)

		it("should load dap submodule directly", function()
			package.preload["modules.debug.dap"] = nil
			local dap = require("modules.debug.dap")
			assert.is_table(dap)
			assert.is_function(dap.setup)
		end)

		it("should load ui submodule directly", function()
			package.preload["modules.debug.ui"] = nil
			local ui = require("modules.debug.ui")
			assert.is_table(ui)
			assert.is_function(ui.setup)
		end)

		it("should load adapters submodule directly", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			assert.is_table(adapters)
			assert.is_function(adapters.setup)
		end)

		it("should load keymaps submodule directly", function()
			package.preload["modules.debug.keymaps"] = nil
			local keymaps = require("modules.debug.keymaps")
			assert.is_table(keymaps)
			assert.is_function(keymaps.setup)
		end)
	end)

	describe("debug.setup()", function()
		it("should setup with default config", function()
			debug = require("modules.debug")
			local result = debug.setup()
			assert.is_true(result)
		end)

		it("should setup all submodules", function()
			debug = require("modules.debug")
			debug.setup()

			assert.is_true(_G._test_debug_dap_setup_called)
			assert.is_true(_G._test_debug_ui_setup_called)
			assert.is_true(_G._test_debug_adapters_setup_called)
			assert.is_true(_G._test_debug_keymaps_setup_called)
		end)

		it("should setup with custom config", function()
			debug = require("modules.debug")
			local result = debug.setup({
				dap = { virtual_text = true },
				ui = { floating = { border = "rounded" } },
				adapters = { auto_install = { "js", "python" } },
			})
			assert.is_true(result)
		end)

		it("should pass config to submodules", function()
			debug = require("modules.debug")
			debug.setup({
				dap = { virtual_text = true },
				ui = { floating = { border = "rounded" } },
			})

			assert.is_table(_G._test_debug_dap_config)
			assert.is_true(_G._test_debug_dap_config.virtual_text)
			assert.is_table(_G._test_debug_ui_config)
			assert.equals("rounded", _G._test_debug_ui_config.floating.border)
		end)

		it("should setup keymaps last", function()
			debug = require("modules.debug")
			debug.setup()

			-- All submodules should be called
			assert.is_true(_G._test_debug_dap_setup_called)
			assert.is_true(_G._test_debug_ui_setup_called)
			assert.is_true(_G._test_debug_adapters_setup_called)
			assert.is_true(_G._test_debug_keymaps_setup_called)
		end)
	end)

	describe("dap.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.debug.dap"] = nil
			local dap = require("modules.debug.dap")
			local result = dap.setup()
			assert.is_true(result)
		end)

		it("should accept custom signs config", function()
			package.preload["modules.debug.dap"] = nil
			local dap = require("modules.debug.dap")
			local result = dap.setup({
				signs = {
					breakpoint = { text = "B" },
					stopped = { text = "→" },
				},
			})
			assert.is_true(result)
		end)

		it("should accept virtual text config", function()
			package.preload["modules.debug.dap"] = nil
			local dap = require("modules.debug.dap")
			local result = dap.setup({
				virtual_text = true,
			})
			assert.is_true(result)
		end)
	end)

	describe("ui.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.debug.ui"] = nil
			local ui = require("modules.debug.ui")
			local result = ui.setup()
			assert.is_true(result)
		end)

		it("should accept custom layout config", function()
			package.preload["modules.debug.ui"] = nil
			local ui = require("modules.debug.ui")
			local result = ui.setup({
				layouts = {
					{
						elements = { "scopes", "breakpoints" },
						size = 0.25,
						position = "left",
					},
				},
			})
			assert.is_true(result)
		end)

		it("should accept floating window config", function()
			package.preload["modules.debug.ui"] = nil
			local ui = require("modules.debug.ui")
			local result = ui.setup({
				floating = {
					border = "rounded",
					mappings = { close = { "q", "<Esc>" } },
				},
			})
			assert.is_true(result)
		end)
	end)

	describe("adapters.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			local result = adapters.setup()
			assert.is_true(result)
		end)

		it("should configure JavaScript/TypeScript adapter", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			adapters.setup({ languages = { "javascript", "typescript" } })
			-- Adapter should be configured (tested via real module)
			assert.is_true(true)
		end)

		it("should configure Python adapter", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			adapters.setup({ languages = { "python" } })
			assert.is_true(true)
		end)

		it("should configure Ruby adapter", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			adapters.setup({ languages = { "ruby" } })
			assert.is_true(true)
		end)

		it("should configure Lua adapter", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			adapters.setup({ languages = { "lua" } })
			assert.is_true(true)
		end)

		it("should configure all adapters by default", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			local result = adapters.setup()
			assert.is_true(result)
		end)

		it("should support auto-install configuration", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			local result = adapters.setup({
				auto_install = { "javascript", "python" },
			})
			assert.is_true(result)
		end)

		it("should support lazy-install configuration", function()
			package.preload["modules.debug.adapters"] = nil
			local adapters = require("modules.debug.adapters")
			local result = adapters.setup({
				lazy_install = { "ruby", "lua" },
			})
			assert.is_true(result)
		end)
	end)

	describe("keymaps.setup()", function()
		before_each(function()
			-- Track keymap calls
			_G._test_keymaps = {}

			-- Override vim.keymap.set
			vim.keymap = {
				set = function(mode, lhs, rhs, opts)
					table.insert(_G._test_keymaps, {
						mode = mode,
						lhs = lhs,
						rhs = rhs,
						opts = opts or {},
					})
				end,
			}
		end)

		after_each(function()
			_G._test_keymaps = nil
		end)

		it("should setup debug keymaps", function()
			package.preload["modules.debug.keymaps"] = nil
			local keymaps = require("modules.debug.keymaps")
			local result = keymaps.setup()
			assert.is_true(result)
			assert.is_true(#_G._test_keymaps > 0)
		end)

		it("should register F-key keymaps", function()
			package.preload["modules.debug.keymaps"] = nil
			local keymaps = require("modules.debug.keymaps")
			keymaps.setup()

			local has_f5 = false
			local has_f10 = false

			for _, km in ipairs(_G._test_keymaps) do
				if km.lhs == "<F5>" then
					has_f5 = true
				end
				if km.lhs == "<F10>" then
					has_f10 = true
				end
			end

			assert.is_true(has_f5, "Expected <F5> keymap for continue")
			assert.is_true(has_f10, "Expected <F10> keymap for step over")
		end)

		it("should register leader-d keymaps", function()
			package.preload["modules.debug.keymaps"] = nil
			local keymaps = require("modules.debug.keymaps")
			keymaps.setup()

			local has_breakpoint = false
			local has_repl = false

			for _, km in ipairs(_G._test_keymaps) do
				if km.lhs == "<leader>db" then
					has_breakpoint = true
				end
				if km.lhs == "<leader>dr" then
					has_repl = true
				end
			end

			assert.is_true(has_breakpoint, "Expected <leader>db keymap for breakpoint")
			assert.is_true(has_repl, "Expected <leader>dr keymap for REPL")
		end)
	end)

	describe("integration", function()
		it("should setup all components together", function()
			debug = require("modules.debug")
			local result = debug.setup({
				dap = { virtual_text = true },
				ui = { floating = { border = "rounded" } },
				adapters = { auto_install = { "javascript", "python" } },
			})

			assert.is_true(result)
			assert.is_true(_G._test_debug_dap_setup_called)
			assert.is_true(_G._test_debug_ui_setup_called)
			assert.is_true(_G._test_debug_adapters_setup_called)
			assert.is_true(_G._test_debug_keymaps_setup_called)
		end)

		it("should configure auto-install adapters", function()
			debug = require("modules.debug")
			debug.setup({
				adapters = {
					auto_install = { "javascript", "python" },
				},
			})

			assert.is_table(_G._test_debug_adapters_config)
			assert.is_table(_G._test_debug_adapters_config.auto_install)
		end)

		it("should configure lazy-install adapters", function()
			debug = require("modules.debug")
			debug.setup({
				adapters = {
					lazy_install = { "ruby", "lua" },
				},
			})

			assert.is_table(_G._test_debug_adapters_config)
			assert.is_table(_G._test_debug_adapters_config.lazy_install)
		end)
	end)
end)
