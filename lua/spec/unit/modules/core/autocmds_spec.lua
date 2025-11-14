--[[
Autocmds Unit Tests
===================

Unit tests for the core autocmds module that handles autocommand registration.

Test Categories:
1. Module structure and API
2. Autocommand registration
3. Default autocommands
4. Event handling
5. Pattern matching
6. User configuration override

Uses standard luassert syntax with #unit tag.
--]]

local spec_helper = require("spec.spec_helper")

describe("modules.core.autocmds #unit", function()
	local autocmds

	before_each(function()
		spec_helper.setup()
		package.loaded["modules.core.autocmds"] = nil
		autocmds = require("modules.core.autocmds")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("module structure", function()
		it("should load autocmds module", function()
			assert.is_not_nil(autocmds)
			assert.is_table(autocmds)
		end)

		it("should have setup function", function()
			assert.is_function(autocmds.setup)
		end)

		it("should have get_defaults function", function()
			assert.is_function(autocmds.get_defaults)
		end)

		it("should have create_augroup function", function()
			assert.is_function(autocmds.create_augroup)
		end)

		it("should have register function", function()
			assert.is_function(autocmds.register)
		end)

		it("should have register_all function", function()
			assert.is_function(autocmds.register_all)
		end)
	end)

	describe("get_defaults()", function()
		it("should return default autocmds table", function()
			local defaults = autocmds.get_defaults()
			assert.is_table(defaults)
		end)

		it("should include general autocmds", function()
			local defaults = autocmds.get_defaults()
			assert.is_not_nil(defaults.general)
			assert.is_table(defaults.general)
		end)

		it("should include highlight autocmds", function()
			local defaults = autocmds.get_defaults()
			assert.is_not_nil(defaults.highlight_yank)
			assert.is_table(defaults.highlight_yank)
		end)

		it("should include file_types autocmds", function()
			local defaults = autocmds.get_defaults()
			assert.is_not_nil(defaults.file_types)
			assert.is_table(defaults.file_types)
		end)
	end)

	describe("default autocmds", function()
		local defaults

		before_each(function()
			defaults = autocmds.get_defaults()
		end)

		it("should have highlight on yank autocmd", function()
			assert.is_not_nil(defaults.highlight_yank)
			assert.is_table(defaults.highlight_yank)
			assert.equals("TextYankPost", defaults.highlight_yank[1].event)
		end)

		it("should have general autocmds group", function()
			assert.is_not_nil(defaults.general)
			assert.is_table(defaults.general)
		end)

		it("should have file_types autocmds group", function()
			assert.is_not_nil(defaults.file_types)
			assert.is_table(defaults.file_types)
		end)
	end)

	describe("create_augroup()", function()
		it("should create an augroup", function()
			local group_spy, spy_data = spec_helper.create_spy(100)
			vim.api.nvim_create_augroup = group_spy

			local group_id = autocmds.create_augroup("test_group")

			assert.is_true(spy_data.called)
			assert.equals(1, spy_data.call_count)
			assert.equals(100, group_id)
		end)

		it("should pass correct arguments", function()
			local calls = {}
			vim.api.nvim_create_augroup = function(name, opts)
				table.insert(calls, { name = name, opts = opts })
				return 100
			end

			autocmds.create_augroup("test_group")

			assert.equals(1, #calls)
			assert.equals("test_group", calls[1].name)
			assert.is_true(calls[1].opts.clear)
		end)

		it("should allow opts override", function()
			local calls = {}
			vim.api.nvim_create_augroup = function(name, opts)
				table.insert(calls, { name = name, opts = opts })
				return 100
			end

			autocmds.create_augroup("test_group", { clear = false })

			assert.is_false(calls[1].opts.clear)
		end)

		it("should handle errors gracefully", function()
			vim.api.nvim_create_augroup = function()
				error("Test error")
			end

			local group_id = autocmds.create_augroup("test_group")
			assert.is_nil(group_id)
		end)
	end)

	describe("register()", function()
		it("should register an autocommand", function()
			local autocmd_spy, spy_data = spec_helper.create_spy(200)
			vim.api.nvim_create_autocmd = autocmd_spy

			autocmds.register("BufEnter", { pattern = "*", command = ':echo "test"' })

			assert.is_true(spy_data.called)
			assert.equals(1, spy_data.call_count)
		end)

		it("should pass correct arguments", function()
			local calls = {}
			vim.api.nvim_create_autocmd = function(event, opts)
				table.insert(calls, { event = event, opts = opts })
				return 200
			end

			autocmds.register("BufEnter", {
				pattern = "*.lua",
				command = ':echo "test"',
				desc = "Test autocmd",
			})

			assert.equals(1, #calls)
			assert.equals("BufEnter", calls[1].event)
			assert.equals("*.lua", calls[1].opts.pattern)
			assert.equals(':echo "test"', calls[1].opts.command)
			assert.equals("Test autocmd", calls[1].opts.desc)
		end)

		it("should handle multiple events", function()
			local calls = {}
			vim.api.nvim_create_autocmd = function(event, opts)
				table.insert(calls, { event = event, opts = opts })
				return 200
			end

			autocmds.register({ "BufEnter", "BufLeave" }, { pattern = "*" })

			assert.equals(1, #calls)
			assert.is_table(calls[1].event)
			assert.equals(2, #calls[1].event)
		end)

		it("should handle callback functions", function()
			local calls = {}
			vim.api.nvim_create_autocmd = function(event, opts)
				table.insert(calls, { event = event, opts = opts })
				return 200
			end

			local callback = function()
				print("test")
			end
			autocmds.register("BufEnter", {
				pattern = "*",
				callback = callback,
			})

			assert.equals(1, #calls)
			assert.equals(callback, calls[1].opts.callback)
		end)

		it("should support group parameter", function()
			local calls = {}
			vim.api.nvim_create_autocmd = function(event, opts)
				table.insert(calls, { event = event, opts = opts })
				return 200
			end

			autocmds.register("BufEnter", {
				pattern = "*",
				group = 100,
				command = ':echo "test"',
			})

			assert.equals(100, calls[1].opts.group)
		end)

		it("should return autocmd ID", function()
			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local autocmd_id = autocmds.register("BufEnter", { pattern = "*" })
			assert.equals(200, autocmd_id)
		end)

		it("should return nil on error", function()
			vim.api.nvim_create_autocmd = function()
				error("Test error")
			end

			local autocmd_id = autocmds.register("BufEnter", { pattern = "*" })
			assert.is_nil(autocmd_id)
		end)
	end)

	describe("register_all()", function()
		it("should register all autocmds from config", function()
			local augroup_call_count = 0
			local autocmd_call_count = 0

			vim.api.nvim_create_augroup = function()
				augroup_call_count = augroup_call_count + 1
				return augroup_call_count * 100
			end

			vim.api.nvim_create_autocmd = function()
				autocmd_call_count = autocmd_call_count + 1
				return autocmd_call_count * 200
			end

			local config = {
				test_group = {
					{
						event = "BufEnter",
						pattern = "*.lua",
						command = ':echo "test1"',
					},
					{
						event = "BufLeave",
						pattern = "*.lua",
						command = ':echo "test2"',
					},
				},
			}

			autocmds.register_all(config)

			assert.equals(1, augroup_call_count) -- One group
			assert.equals(2, autocmd_call_count) -- Two autocmds
		end)

		it("should create augroup for each category", function()
			local augroups_created = {}
			vim.api.nvim_create_augroup = function(name, opts)
				table.insert(augroups_created, name)
				return #augroups_created * 100
			end

			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local config = {
				group1 = {
					{ event = "BufEnter", pattern = "*" },
				},
				group2 = {
					{ event = "BufLeave", pattern = "*" },
				},
			}

			autocmds.register_all(config)

			assert.equals(2, #augroups_created)
			assert.is_true(vim.tbl_contains(augroups_created, "group1"))
			assert.is_true(vim.tbl_contains(augroups_created, "group2"))
		end)

		it("should associate autocmds with their group", function()
			local created_autocmds = {}

			vim.api.nvim_create_augroup = function(name, opts)
				return name == "test_group" and 100 or 200
			end

			vim.api.nvim_create_autocmd = function(event, opts)
				table.insert(created_autocmds, { event = event, group = opts.group })
				return #created_autocmds
			end

			local config = {
				test_group = {
					{ event = "BufEnter", pattern = "*" },
					{ event = "BufLeave", pattern = "*" },
				},
			}

			autocmds.register_all(config)

			assert.equals(2, #created_autocmds)
			assert.equals(100, created_autocmds[1].group) -- Both should have group 100
			assert.equals(100, created_autocmds[2].group)
		end)

		it("should handle empty config", function()
			vim.api.nvim_create_augroup = function()
				return 100
			end
			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local success = autocmds.register_all({})
			assert.is_true(success)
		end)

		it("should handle nil config", function()
			vim.api.nvim_create_augroup = function()
				return 100
			end
			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local success = autocmds.register_all(nil)
			assert.is_true(success)
		end)

		it("should return false on error", function()
			vim.api.nvim_create_augroup = function()
				error("Test error")
			end

			local config = {
				test_group = {
					{ event = "BufEnter", pattern = "*" },
				},
			}

			local success = autocmds.register_all(config)
			assert.is_false(success)
		end)
	end)

	describe("setup()", function()
		it("should initialize with default config", function()
			vim.api.nvim_create_augroup = function()
				return 100
			end
			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local success = autocmds.setup()
			assert.is_true(success)
		end)

		it("should register default autocmds", function()
			local augroup_count = 0
			local autocmd_count = 0

			vim.api.nvim_create_augroup = function()
				augroup_count = augroup_count + 1
				return augroup_count * 100
			end

			vim.api.nvim_create_autocmd = function()
				autocmd_count = autocmd_count + 1
				return autocmd_count * 200
			end

			autocmds.setup()

			-- Should create at least some default autocmds
			assert.is_true(augroup_count > 0)
			assert.is_true(autocmd_count > 0)
		end)

		it("should merge user autocmds with defaults", function()
			local augroups_created = {}

			vim.api.nvim_create_augroup = function(name, opts)
				table.insert(augroups_created, name)
				return #augroups_created * 100
			end

			vim.api.nvim_create_autocmd = function()
				return 200
			end

			local user_config = {
				custom_group = {
					{ event = "BufEnter", pattern = "*.custom", command = ':echo "custom"' },
				},
			}

			autocmds.setup(user_config)

			-- Should have custom group
			assert.is_true(vim.tbl_contains(augroups_created, "custom_group"))
		end)

		it("should return false if setup fails", function()
			vim.api.nvim_create_augroup = function()
				error("Test error")
			end

			local success = autocmds.setup()
			assert.is_false(success)
		end)
	end)
end)
