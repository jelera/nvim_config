--[[
TreeSitter Module Tests (Smoke Tests)
======================================

Basic smoke tests for the TreeSitter module.

Test Categories:
1. Module structure
2. setup() with defaults
3. setup() with custom config
4. Graceful degradation
--]]

describe("modules.treesitter #unit", function()
	local spec_helper = require("spec.spec_helper")
	local treesitter

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.treesitter"] = nil
		package.loaded["modules.treesitter.init"] = nil
		package.loaded["nvim-treesitter.configs"] = nil

		-- Track configuration
		_G._test_treesitter_config = nil

		-- Mock nvim-treesitter.configs
		package.preload["nvim-treesitter.configs"] = function()
			return {
				setup = function(config)
					_G._test_treesitter_config = config
				end,
			}
		end

		treesitter = require("modules.treesitter")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_treesitter_config = nil
	end)

	describe("Module structure", function()
		it("should load without errors", function()
			assert.is_not_nil(treesitter)
			assert.is_table(treesitter)
		end)

		it("should have setup function", function()
			assert.is_function(treesitter.setup)
		end)
	end)

	describe("setup() with defaults", function()
		it("should return true on success", function()
			local result = treesitter.setup()
			assert.is_true(result)
		end)

		it("should configure TreeSitter", function()
			treesitter.setup()
			assert.is_not_nil(_G._test_treesitter_config)
		end)

		it("should enable highlighting", function()
			treesitter.setup()
			assert.is_true(_G._test_treesitter_config.highlight.enable)
		end)

		it("should enable indentation", function()
			treesitter.setup()
			assert.is_true(_G._test_treesitter_config.indent.enable)
		end)

		it("should enable incremental selection", function()
			treesitter.setup()
			assert.is_not_nil(_G._test_treesitter_config.incremental_selection)
			assert.is_true(_G._test_treesitter_config.incremental_selection.enable)
		end)

		it("should enable text objects", function()
			treesitter.setup()
			assert.is_not_nil(_G._test_treesitter_config.textobjects)
		end)

		it("should configure parsers to install", function()
			treesitter.setup()
			assert.is_table(_G._test_treesitter_config.ensure_installed)
			-- Should include core languages
			local parsers = _G._test_treesitter_config.ensure_installed
			local has_lua, has_python, has_javascript = false, false, false
			for _, parser in ipairs(parsers) do
				if parser == "lua" then
					has_lua = true
				end
				if parser == "python" then
					has_python = true
				end
				if parser == "javascript" then
					has_javascript = true
				end
			end
			assert.is_true(has_lua)
			assert.is_true(has_python)
			assert.is_true(has_javascript)
		end)

		it("should set auto_install to true", function()
			treesitter.setup()
			assert.is_true(_G._test_treesitter_config.auto_install)
		end)
	end)

	describe("setup() with custom config", function()
		it("should accept empty config", function()
			local result = treesitter.setup({})
			assert.is_true(result)
		end)

		it("should allow disabling features", function()
			treesitter.setup({
				highlight = { enable = false },
				indent = { enable = false },
			})

			assert.is_false(_G._test_treesitter_config.highlight.enable)
			assert.is_false(_G._test_treesitter_config.indent.enable)
		end)

		it("should allow custom ensure_installed list", function()
			treesitter.setup({
				ensure_installed = { "lua", "python" },
			})

			assert.is_table(_G._test_treesitter_config.ensure_installed)
			assert.equal(2, #_G._test_treesitter_config.ensure_installed)
		end)

		it("should merge custom config with defaults", function()
			treesitter.setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
			})

			assert.is_true(_G._test_treesitter_config.highlight.enable)
			assert.is_true(_G._test_treesitter_config.highlight.additional_vim_regex_highlighting)
			-- Default should still be present
			assert.is_not_nil(_G._test_treesitter_config.indent)
		end)
	end)

	describe("Graceful degradation", function()
		it("should return false when TreeSitter not available", function()
			package.loaded["nvim-treesitter.configs"] = nil
			package.preload["nvim-treesitter.configs"] = function()
				error("not found")
			end

			local result = treesitter.setup()
			assert.is_false(result)
		end)

		it("should handle configuration errors", function()
			package.loaded["nvim-treesitter.configs"] = nil
			package.preload["nvim-treesitter.configs"] = function()
				return {
					setup = function()
						error("Configuration error")
					end,
				}
			end

			local result = treesitter.setup()
			assert.is_false(result)
		end)
	end)

	describe("Default configuration", function()
		it("should include expected language parsers", function()
			treesitter.setup()

			-- Should be a table of parsers for your tech stack
			assert.is_table(_G._test_treesitter_config.ensure_installed)
			local parsers = _G._test_treesitter_config.ensure_installed
			assert.is_true(#parsers > 0, "Should have at least one parser configured")
		end)

		it("should configure text objects with expected keymaps", function()
			treesitter.setup()

			local select_maps = _G._test_treesitter_config.textobjects.select.keymaps
			assert.is_not_nil(select_maps)
			assert.is_not_nil(select_maps["af"]) -- around function
			assert.is_not_nil(select_maps["if"]) -- inside function
		end)

		it("should configure incremental selection keymaps", function()
			treesitter.setup()

			local keymaps = _G._test_treesitter_config.incremental_selection.keymaps
			assert.is_not_nil(keymaps)
			assert.is_not_nil(keymaps.init_selection)
			assert.is_not_nil(keymaps.node_incremental)
			assert.is_not_nil(keymaps.node_decremental)
		end)
	end)
end)
