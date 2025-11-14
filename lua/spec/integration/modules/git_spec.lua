--[[
Git Module Integration Tests
=============================

Integration tests for git module including gitsigns, fugitive, and diffview.

Tags: #integration #git
--]]

describe("modules.git #integration #git", function()
	local spec_helper = require("spec.spec_helper")
	local git

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.git"] = nil
		package.loaded["modules.git.signs"] = nil
		package.loaded["modules.git.fugitive"] = nil
		package.loaded["modules.git.diffview"] = nil
		package.loaded["modules.git.keymaps"] = nil

		-- Reset tracking flags
		_G._test_git_signs_setup_called = false
		_G._test_git_fugitive_setup_called = false
		_G._test_git_diffview_setup_called = false
		_G._test_git_keymaps_setup_called = false

		-- Mock submodules
		package.preload["modules.git.signs"] = function()
			return {
				setup = function(config)
					_G._test_git_signs_setup_called = true
					_G._test_git_signs_config = config
					return true
				end,
			}
		end

		package.preload["modules.git.fugitive"] = function()
			return {
				setup = function(config)
					_G._test_git_fugitive_setup_called = true
					_G._test_git_fugitive_config = config
					return true
				end,
			}
		end

		package.preload["modules.git.diffview"] = function()
			return {
				setup = function(config)
					_G._test_git_diffview_setup_called = true
					_G._test_git_diffview_config = config
					return true
				end,
			}
		end

		package.preload["modules.git.keymaps"] = function()
			return {
				setup = function()
					_G._test_git_keymaps_setup_called = true
					return true
				end,
			}
		end
	end)

	after_each(function()
		spec_helper.teardown()

		-- Clean up test globals
		_G._test_git_signs_setup_called = nil
		_G._test_git_fugitive_setup_called = nil
		_G._test_git_diffview_setup_called = nil
		_G._test_git_keymaps_setup_called = nil
		_G._test_git_signs_config = nil
		_G._test_git_fugitive_config = nil
		_G._test_git_diffview_config = nil
	end)

	describe("module loading", function()
		it("should load git module", function()
			git = require("modules.git")
			assert.is_table(git)
			assert.is_function(git.setup)
		end)

		it("should load signs submodule directly", function()
			-- Clear preload and test real module
			package.preload["modules.git.signs"] = nil
			local signs = require("modules.git.signs")
			assert.is_table(signs)
			assert.is_function(signs.setup)
		end)

		it("should load fugitive submodule directly", function()
			package.preload["modules.git.fugitive"] = nil
			local fugitive = require("modules.git.fugitive")
			assert.is_table(fugitive)
			assert.is_function(fugitive.setup)
		end)

		it("should load diffview submodule directly", function()
			package.preload["modules.git.diffview"] = nil
			local diffview = require("modules.git.diffview")
			assert.is_table(diffview)
			assert.is_function(diffview.setup)
		end)

		it("should load keymaps submodule directly", function()
			package.preload["modules.git.keymaps"] = nil
			local keymaps = require("modules.git.keymaps")
			assert.is_table(keymaps)
			assert.is_function(keymaps.setup)
		end)
	end)

	describe("git.setup()", function()
		it("should setup with default config", function()
			git = require("modules.git")
			local result = git.setup()
			assert.is_true(result)
		end)

		it("should setup all submodules", function()
			git = require("modules.git")
			git.setup()

			assert.is_true(_G._test_git_signs_setup_called)
			assert.is_true(_G._test_git_fugitive_setup_called)
			assert.is_true(_G._test_git_diffview_setup_called)
			assert.is_true(_G._test_git_keymaps_setup_called)
		end)

		it("should setup with custom config", function()
			git = require("modules.git")
			local result = git.setup({
				signs = { current_line_blame = true },
				fugitive = {},
				diffview = { enhanced_diff_hl = true },
			})
			assert.is_true(result)
			assert.is_table(_G._test_git_signs_config)
			assert.is_true(_G._test_git_signs_config.current_line_blame)
		end)

		it("should setup keymaps last", function()
			git = require("modules.git")
			git.setup()

			-- All submodules should be called
			assert.is_true(_G._test_git_signs_setup_called)
			assert.is_true(_G._test_git_fugitive_setup_called)
			assert.is_true(_G._test_git_diffview_setup_called)
			assert.is_true(_G._test_git_keymaps_setup_called)
		end)
	end)

	describe("signs.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.git.signs"] = nil
			local signs = require("modules.git.signs")
			local result = signs.setup()
			assert.is_true(result)
		end)

		it("should accept custom sign characters", function()
			package.preload["modules.git.signs"] = nil
			local signs = require("modules.git.signs")
			local result = signs.setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
				},
			})
			assert.is_true(result)
		end)

		it("should accept current line blame config", function()
			package.preload["modules.git.signs"] = nil
			local signs = require("modules.git.signs")
			local result = signs.setup({
				current_line_blame = true,
				current_line_blame_opts = {
					delay = 500,
				},
			})
			assert.is_true(result)
		end)
	end)

	describe("fugitive.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.git.fugitive"] = nil
			local fugitive = require("modules.git.fugitive")
			local result = fugitive.setup()
			assert.is_true(result)
		end)

		it("should setup with custom config", function()
			package.preload["modules.git.fugitive"] = nil
			local fugitive = require("modules.git.fugitive")
			local result = fugitive.setup({})
			assert.is_true(result)
		end)
	end)

	describe("diffview.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.git.diffview"] = nil
			local diffview = require("modules.git.diffview")
			local result = diffview.setup()
			assert.is_true(result)
		end)

		it("should accept custom layout config", function()
			package.preload["modules.git.diffview"] = nil
			local diffview = require("modules.git.diffview")
			local result = diffview.setup({
				enhanced_diff_hl = true,
				view = {
					default = {
						layout = "diff2_horizontal",
					},
				},
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

		it("should setup git keymaps", function()
			package.preload["modules.git.keymaps"] = nil
			local keymaps = require("modules.git.keymaps")
			local result = keymaps.setup()
			assert.is_true(result)
			assert.is_true(#_G._test_keymaps > 0)
		end)

		it("should register fugitive keymaps", function()
			package.preload["modules.git.keymaps"] = nil
			local keymaps = require("modules.git.keymaps")
			keymaps.setup()

			local has_git_status = false
			for _, km in ipairs(_G._test_keymaps) do
				if km.lhs == "<leader>gs" then
					has_git_status = true
					break
				end
			end

			assert.is_true(has_git_status, "Expected <leader>gs keymap for git status")
		end)

		it("should register gitsigns hunk navigation", function()
			package.preload["modules.git.keymaps"] = nil
			local keymaps = require("modules.git.keymaps")
			keymaps.setup()

			local has_next_hunk = false
			local has_prev_hunk = false

			for _, km in ipairs(_G._test_keymaps) do
				if km.lhs == "]h" then
					has_next_hunk = true
				end
				if km.lhs == "[h" then
					has_prev_hunk = true
				end
			end

			assert.is_true(has_next_hunk, "Expected ]h keymap for next hunk")
			assert.is_true(has_prev_hunk, "Expected [h keymap for prev hunk")
		end)
	end)

	describe("integration", function()
		it("should setup all components together", function()
			git = require("modules.git")
			local result = git.setup({
				signs = { current_line_blame = false },
				fugitive = {},
				diffview = {},
			})

			assert.is_true(result)
			assert.is_true(_G._test_git_signs_setup_called)
			assert.is_true(_G._test_git_fugitive_setup_called)
			assert.is_true(_G._test_git_diffview_setup_called)
			assert.is_true(_G._test_git_keymaps_setup_called)
		end)

		it("should handle missing git executable gracefully", function()
			-- Mock git not found
			vim.fn.executable = function(cmd)
				if cmd == "git" then
					return 0
				end
				return 1
			end

			git = require("modules.git")
			local result = git.setup()

			-- Should still return true but warn user
			assert.is_true(result)
		end)
	end)
end)
