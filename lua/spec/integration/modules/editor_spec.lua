--[[
Editor Module Integration Tests
================================

Integration tests for editor enhancements module.

Tags: #integration #editor
--]]

describe("modules.editor #integration #editor", function()
	local spec_helper = require("spec.spec_helper")
	local editor

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.editor"] = nil
		package.loaded["modules.editor.autopairs"] = nil
		package.loaded["modules.editor.surround"] = nil
		package.loaded["modules.editor.comment"] = nil
		package.loaded["modules.editor.project"] = nil
		package.loaded["modules.editor.session"] = nil
		package.loaded["modules.editor.keymaps"] = nil

		-- Reset tracking flags
		_G._test_editor_autopairs_setup_called = false
		_G._test_editor_surround_setup_called = false
		_G._test_editor_comment_setup_called = false
		_G._test_editor_project_setup_called = false
		_G._test_editor_session_setup_called = false
		_G._test_editor_keymaps_setup_called = false

		-- Mock submodules
		package.preload["modules.editor.autopairs"] = function()
			return {
				setup = function(config)
					_G._test_editor_autopairs_setup_called = true
					return true
				end,
			}
		end

		package.preload["modules.editor.surround"] = function()
			return {
				setup = function(config)
					_G._test_editor_surround_setup_called = true
					return true
				end,
			}
		end

		package.preload["modules.editor.comment"] = function()
			return {
				setup = function(config)
					_G._test_editor_comment_setup_called = true
					return true
				end,
			}
		end

		package.preload["modules.editor.project"] = function()
			return {
				setup = function(config)
					_G._test_editor_project_setup_called = true
					return true
				end,
			}
		end

		package.preload["modules.editor.session"] = function()
			return {
				setup = function(config)
					_G._test_editor_session_setup_called = true
					return true
				end,
			}
		end

		package.preload["modules.editor.keymaps"] = function()
			return {
				setup = function()
					_G._test_editor_keymaps_setup_called = true
					return true
				end,
			}
		end
	end)

	after_each(function()
		spec_helper.teardown()

		-- Clean up test globals
		_G._test_editor_autopairs_setup_called = nil
		_G._test_editor_surround_setup_called = nil
		_G._test_editor_comment_setup_called = nil
		_G._test_editor_project_setup_called = nil
		_G._test_editor_session_setup_called = nil
		_G._test_editor_keymaps_setup_called = nil
	end)

	describe("module loading", function()
		it("should load editor module", function()
			editor = require("modules.editor")
			assert.is_table(editor)
			assert.is_function(editor.setup)
		end)

		it("should load autopairs submodule", function()
			package.preload["modules.editor.autopairs"] = nil
			local autopairs = require("modules.editor.autopairs")
			assert.is_table(autopairs)
			assert.is_function(autopairs.setup)
		end)

		it("should load surround submodule", function()
			package.preload["modules.editor.surround"] = nil
			local surround = require("modules.editor.surround")
			assert.is_table(surround)
			assert.is_function(surround.setup)
		end)

		it("should load comment submodule", function()
			package.preload["modules.editor.comment"] = nil
			local comment = require("modules.editor.comment")
			assert.is_table(comment)
			assert.is_function(comment.setup)
		end)

		-- project submodule removed in favor of vim-projectionist

		it("should load session submodule", function()
			package.preload["modules.editor.session"] = nil
			local session = require("modules.editor.session")
			assert.is_table(session)
			assert.is_function(session.setup)
		end)

		it("should load keymaps submodule", function()
			package.preload["modules.editor.keymaps"] = nil
			local keymaps = require("modules.editor.keymaps")
			assert.is_table(keymaps)
			assert.is_function(keymaps.setup)
		end)
	end)

	describe("editor.setup()", function()
		it("should setup with default config", function()
			editor = require("modules.editor")
			local result = editor.setup()
			assert.is_true(result)
		end)

		it("should setup all features", function()
			editor = require("modules.editor")
			editor.setup()

			assert.is_true(_G._test_editor_autopairs_setup_called)
			assert.is_true(_G._test_editor_surround_setup_called)
			assert.is_true(_G._test_editor_comment_setup_called)
			-- project submodule removed in favor of vim-projectionist
			assert.is_true(_G._test_editor_session_setup_called)
			assert.is_true(_G._test_editor_keymaps_setup_called)
		end)

		it("should setup with custom config", function()
			editor = require("modules.editor")
			local result = editor.setup({
				autopairs = {},
				surround = {},
				comment = {},
				project = {},
				session = {},
			})
			assert.is_true(result)
		end)

		it("should setup keymaps last", function()
			editor = require("modules.editor")
			editor.setup()

			assert.is_true(_G._test_editor_keymaps_setup_called)
		end)
	end)

	describe("autopairs.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.editor.autopairs"] = nil
			local autopairs = require("modules.editor.autopairs")
			local result = autopairs.setup()
			assert.is_true(result)
		end)

		it("should accept custom config", function()
			package.preload["modules.editor.autopairs"] = nil
			local autopairs = require("modules.editor.autopairs")
			local result = autopairs.setup({
				check_ts = true,
			})
			assert.is_true(result)
		end)
	end)

	describe("surround.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.editor.surround"] = nil
			local surround = require("modules.editor.surround")
			local result = surround.setup()
			assert.is_true(result)
		end)

		it("should accept custom keymaps", function()
			package.preload["modules.editor.surround"] = nil
			local surround = require("modules.editor.surround")
			local result = surround.setup({
				keymaps = {
					insert = "<C-g>s",
				},
			})
			assert.is_true(result)
		end)
	end)

	describe("comment.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.editor.comment"] = nil
			local comment = require("modules.editor.comment")
			local result = comment.setup()
			assert.is_true(result)
		end)

		it("should accept custom mappings", function()
			package.preload["modules.editor.comment"] = nil
			local comment = require("modules.editor.comment")
			local result = comment.setup({
				toggler = { line = "gcc" },
			})
			assert.is_true(result)
		end)
	end)

	-- project module removed in favor of vim-projectionist
	-- Tests removed

	describe("session.setup()", function()
		it("should setup with default config", function()
			package.preload["modules.editor.session"] = nil
			local session = require("modules.editor.session")
			local result = session.setup()
			assert.is_true(result)
		end)

		it("should accept custom options", function()
			package.preload["modules.editor.session"] = nil
			local session = require("modules.editor.session")
			local result = session.setup({
				options = { "buffers", "curdir", "tabpages" },
			})
			assert.is_true(result)
		end)
	end)

	describe("integration", function()
		it("should setup all features together", function()
			editor = require("modules.editor")
			local result = editor.setup({
				autopairs = {},
				surround = {},
				comment = {},
				session = {},
			})

			assert.is_true(result)
			assert.is_true(_G._test_editor_autopairs_setup_called)
			assert.is_true(_G._test_editor_surround_setup_called)
			assert.is_true(_G._test_editor_comment_setup_called)
			-- project submodule removed in favor of vim-projectionist
			assert.is_true(_G._test_editor_session_setup_called)
			assert.is_true(_G._test_editor_keymaps_setup_called)
		end)
	end)
end)
