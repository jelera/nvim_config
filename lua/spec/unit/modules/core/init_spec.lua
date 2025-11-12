--[[
Core Init Unit Tests
====================

Unit tests for the core module orchestrator that initializes all core modules.

Test Categories:
1. Module structure and API
2. Setup coordination
3. Module initialization order
4. Error handling
5. User configuration override

Uses standard luassert syntax with #unit tag.
--]]

local spec_helper = require("spec.spec_helper")

describe("modules.core.init #unit", function()
	local core

	before_each(function()
		spec_helper.setup()
		package.loaded["modules.core"] = nil
		package.loaded["modules.core.options"] = nil
		package.loaded["modules.core.keymaps"] = nil
		package.loaded["modules.core.autocmds"] = nil
		package.loaded["modules.core.commands"] = nil
		core = require("modules.core")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("module structure", function()
		it("should load core module", function()
			assert.is_not_nil(core)
			assert.is_table(core)
		end)

		it("should have setup function", function()
			assert.is_function(core.setup)
		end)

		it("should expose options module", function()
			assert.is_not_nil(core.options)
			assert.is_table(core.options)
		end)

		it("should expose keymaps module", function()
			assert.is_not_nil(core.keymaps)
			assert.is_table(core.keymaps)
		end)

		it("should expose autocmds module", function()
			assert.is_not_nil(core.autocmds)
			assert.is_table(core.autocmds)
		end)

		it("should expose commands module", function()
			assert.is_not_nil(core.commands)
			assert.is_table(core.commands)
		end)
	end)

	describe("setup()", function()
		it("should initialize with default config", function()
			-- Mock all sub-module setups
			vim.opt = setmetatable({ _values = {} }, {
				__index = function(t, k)
					if k == "_values" then
						return rawget(t, k)
					end
					return { _value = t._values[k] }
				end,
				__newindex = function(t, k, v)
					t._values[k] = v
				end,
			})
			vim.keymap.set = function() end
			vim.api.nvim_create_augroup = function()
				return 100
			end
			vim.api.nvim_create_autocmd = function()
				return 200
			end
			vim.api.nvim_create_user_command = function() end

			local success = core.setup()
			assert.is_true(success)
		end)

		it("should setup options module", function()
			local options_setup_called = false

			local options = require("modules.core.options")
			local original_setup = options.setup
			options.setup = function()
				options_setup_called = true
				return true
			end

			-- Mock other modules
			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end
			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end
			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			core.setup()

			assert.is_true(options_setup_called)

			options.setup = original_setup
		end)

		it("should setup keymaps module", function()
			local keymaps_setup_called = false

			local keymaps = require("modules.core.keymaps")
			local original_setup = keymaps.setup
			keymaps.setup = function()
				keymaps_setup_called = true
				return true
			end

			-- Mock other modules
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end
			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end
			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			core.setup()

			assert.is_true(keymaps_setup_called)

			keymaps.setup = original_setup
		end)

		it("should setup autocmds module", function()
			local autocmds_setup_called = false

			local autocmds = require("modules.core.autocmds")
			local original_setup = autocmds.setup
			autocmds.setup = function()
				autocmds_setup_called = true
				return true
			end

			-- Mock other modules
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end
			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end
			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			core.setup()

			assert.is_true(autocmds_setup_called)

			autocmds.setup = original_setup
		end)

		it("should setup commands module", function()
			local commands_setup_called = false

			local commands = require("modules.core.commands")
			local original_setup = commands.setup
			commands.setup = function()
				commands_setup_called = true
				return true
			end

			-- Mock other modules
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end
			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end
			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end

			core.setup()

			assert.is_true(commands_setup_called)

			commands.setup = original_setup
		end)

		it("should setup modules in correct order", function()
			local setup_order = {}

			local options = require("modules.core.options")
			options.setup = function()
				table.insert(setup_order, "options")
				return true
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				table.insert(setup_order, "keymaps")
				return true
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				table.insert(setup_order, "autocmds")
				return true
			end

			local commands = require("modules.core.commands")
			commands.setup = function()
				table.insert(setup_order, "commands")
				return true
			end

			core.setup()

			assert.equals(4, #setup_order)
			assert.equals("options", setup_order[1])
			assert.equals("keymaps", setup_order[2])
			assert.equals("autocmds", setup_order[3])
			assert.equals("commands", setup_order[4])
		end)

		it("should pass config to sub-modules", function()
			local options_config = nil
			local keymaps_config = nil
			local autocmds_config = nil
			local commands_config = nil

			local options = require("modules.core.options")
			options.setup = function(config)
				options_config = config
				return true
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function(config)
				keymaps_config = config
				return true
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function(config)
				autocmds_config = config
				return true
			end

			local commands = require("modules.core.commands")
			commands.setup = function(config)
				commands_config = config
				return true
			end

			local user_config = {
				options = { ui = { number = false } },
				keymaps = { custom = {} },
				autocmds = { custom_group = {} },
				commands = { CustomCommand = {} },
			}

			core.setup(user_config)

			assert.is_not_nil(options_config)
			assert.is_not_nil(keymaps_config)
			assert.is_not_nil(autocmds_config)
			assert.is_not_nil(commands_config)

			assert.equals(user_config.options, options_config)
			assert.equals(user_config.keymaps, keymaps_config)
			assert.equals(user_config.autocmds, autocmds_config)
			assert.equals(user_config.commands, commands_config)
		end)

		it("should return false if options setup fails", function()
			local options = require("modules.core.options")
			options.setup = function()
				return false
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end

			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			local success = core.setup()
			assert.is_false(success)
		end)

		it("should return false if keymaps setup fails", function()
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return false
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end

			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			local success = core.setup()
			assert.is_false(success)
		end)

		it("should return false if autocmds setup fails", function()
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return false
			end

			local commands = require("modules.core.commands")
			commands.setup = function()
				return true
			end

			local success = core.setup()
			assert.is_false(success)
		end)

		it("should return false if commands setup fails", function()
			local options = require("modules.core.options")
			options.setup = function()
				return true
			end

			local keymaps = require("modules.core.keymaps")
			keymaps.setup = function()
				return true
			end

			local autocmds = require("modules.core.autocmds")
			autocmds.setup = function()
				return true
			end

			local commands = require("modules.core.commands")
			commands.setup = function()
				return false
			end

			local success = core.setup()
			assert.is_false(success)
		end)
	end)
end)
