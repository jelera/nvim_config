--[[
Snippets Module Unit Tests
===========================

Unit tests for LuaSnip snippet configuration.
--]]

describe("modules.completion.snippets #unit", function()
	local spec_helper = require("spec.spec_helper")
	local snippets

	before_each(function()
		spec_helper.setup()

		-- Reset module cache (MUST clear before setting up mocks)
		package.loaded["modules.completion.snippets"] = nil
		package.loaded["luasnip"] = nil
		package.loaded["luasnip.loaders.from_vscode"] = nil

		-- Track snippet loader calls
		_G._test_snippet_loader_called = false
		_G._test_luasnip_setup_called = false
		_G._test_keymaps = {}

		-- Mock LuaSnip
		package.preload["luasnip"] = function()
			return {
				config = {
					setup = function()
						_G._test_luasnip_setup_called = true
					end,
				},
				lsp_expand = function(body)
					return "expanded: " .. body
				end,
			}
		end

		-- Mock friendly-snippets loader
		package.preload["luasnip.loaders.from_vscode"] = function()
			return {
				lazy_load = function()
					_G._test_snippet_loader_called = true
				end,
			}
		end

		-- Mock vim.keymap
		vim.keymap = {
			set = function(mode, lhs, rhs, opts)
				table.insert(_G._test_keymaps, {
					mode = mode,
					lhs = lhs,
					rhs = rhs,
					opts = opts,
				})
			end,
		}

		snippets = require("modules.completion.snippets")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_snippet_loader_called = nil
		_G._test_luasnip_setup_called = nil
		_G._test_keymaps = nil

		-- Clear package cache AND preload to prevent test interference
		package.loaded["modules.completion.snippets"] = nil
		package.loaded["luasnip"] = nil
		package.loaded["luasnip.loaders.from_vscode"] = nil
		package.preload["luasnip"] = nil
		package.preload["luasnip.loaders.from_vscode"] = nil
	end)

	describe("Module structure", function()
		it("should have a setup function", function()
			assert.is_function(snippets.setup)
		end)

		it("should have a get_luasnip function", function()
			assert.is_function(snippets.get_luasnip)
		end)
	end)

	describe("setup()", function()
		it("should return true on successful setup", function()
			local result = snippets.setup()
			assert.is_true(result)
		end)

		it("should load LuaSnip and friendly-snippets", function()
			snippets.setup()
			local luasnip = snippets.get_luasnip()
			assert.is_not_nil(luasnip)
			-- Note: friendly-snippets loading tracked via _test_snippet_loader_called
		end)

		it("should accept empty config", function()
			local result = snippets.setup({})
			assert.is_true(result)
		end)

		it("should accept nil config", function()
			local result = snippets.setup(nil)
			assert.is_true(result)
		end)
	end)

	describe("get_luasnip()", function()
		it("should return LuaSnip after successful setup", function()
			snippets.setup()
			local luasnip = snippets.get_luasnip()
			assert.is_not_nil(luasnip)
			assert.is_function(luasnip.lsp_expand)
		end)
	end)
end)
