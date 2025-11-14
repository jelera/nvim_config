--[[
Completion Module Init Unit Tests
==================================

Unit tests for completion module orchestrator.
--]]

describe("modules.completion #unit", function()
	local spec_helper = require("spec.spec_helper")
	local completion

	before_each(function()
		spec_helper.setup()

		-- Reset module cache
		package.loaded["modules.completion"] = nil
		package.loaded["modules.completion.init"] = nil
		package.loaded["modules.completion.snippets"] = nil
		package.loaded["modules.completion.completion"] = nil

		-- Track setup calls
		_G._test_snippets_setup_called = false
		_G._test_completion_setup_called = false

		-- Mock snippets module
		package.preload["modules.completion.snippets"] = function()
			return {
				setup = function(config)
					_G._test_snippets_setup_called = true
					return true
				end,
				get_luasnip = function()
					return { lsp_expand = function() end }
				end,
			}
		end

		-- Mock completion module
		package.preload["modules.completion.completion"] = function()
			return {
				setup = function(config)
					_G._test_completion_setup_called = true
					return true
				end,
			}
		end

		completion = require("modules.completion")
	end)

	after_each(function()
		spec_helper.teardown()
		_G._test_snippets_setup_called = nil
		_G._test_completion_setup_called = nil
	end)

	describe("Module structure", function()
		it("should have a setup function", function()
			assert.is_function(completion.setup)
		end)
	end)

	describe("setup()", function()
		it("should return true on successful setup", function()
			local result = completion.setup()
			assert.is_true(result)
		end)

		it("should call snippets.setup", function()
			completion.setup()
			assert.is_true(_G._test_snippets_setup_called)
		end)

		it("should call completion.setup", function()
			completion.setup()
			assert.is_true(_G._test_completion_setup_called)
		end)

		it("should accept empty config", function()
			local result = completion.setup({})
			assert.is_true(result)
		end)

		it("should accept nil config", function()
			local result = completion.setup(nil)
			assert.is_true(result)
		end)

		it("should setup snippets before completion", function()
			local setup_order = {}

			package.loaded["modules.completion.snippets"] = nil
			package.preload["modules.completion.snippets"] = function()
				return {
					setup = function()
						table.insert(setup_order, "snippets")
						return true
					end,
					get_luasnip = function()
						return {}
					end,
				}
			end

			package.loaded["modules.completion.completion"] = nil
			package.preload["modules.completion.completion"] = function()
				return {
					setup = function()
						table.insert(setup_order, "completion")
						return true
					end,
				}
			end

			package.loaded["modules.completion"] = nil
			local comp = require("modules.completion")
			comp.setup()

			assert.equal("snippets", setup_order[1])
			assert.equal("completion", setup_order[2])
		end)
	end)

	describe("Graceful degradation", function()
		it("should return false when snippets setup fails", function()
			package.loaded["modules.completion"] = nil
			package.loaded["modules.completion.snippets"] = nil
			package.preload["modules.completion.snippets"] = function()
				return {
					setup = function()
						return false
					end,
					get_luasnip = function()
						return nil
					end,
				}
			end

			local comp = require("modules.completion")
			local result = comp.setup()

			assert.is_false(result)
		end)

		it("should return false when completion setup fails", function()
			package.loaded["modules.completion"] = nil
			package.loaded["modules.completion.completion"] = nil
			package.preload["modules.completion.completion"] = function()
				return {
					setup = function()
						return false
					end,
				}
			end

			local comp = require("modules.completion")
			local result = comp.setup()

			assert.is_false(result)
		end)
	end)
end)
