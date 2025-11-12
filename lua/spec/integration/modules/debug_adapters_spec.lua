--[[
Debug Adapters Integration Tests
=================================

Tests for reorganized debug adapters.
--]]

describe("modules.debug.adapters", function()
	local spec_helper = require("spec.spec_helper")
	local adapters

	before_each(function()
		spec_helper.setup()

		-- Clear module cache
		package.loaded["modules.debug.adapters"] = nil
		package.loaded["modules.debug.adapters.javascript"] = nil
		package.loaded["modules.debug.adapters.python"] = nil
		package.loaded["modules.debug.adapters.ruby"] = nil
		package.loaded["modules.debug.adapters.lua"] = nil

		adapters = require("modules.debug.adapters")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("Module structure", function()
		it("should have setup function", function()
			assert.is_function(adapters.setup)
		end)
	end)

	describe("setup()", function()
		it("should setup without crashing when DAP is not loaded", function()
			local success, err = pcall(adapters.setup)
			assert.is_true(success, err)
		end)
	end)

	describe("JavaScript adapter", function()
		it("should load JavaScript adapter module", function()
			local js_adapter = require("modules.debug.adapters.javascript")
			assert.is_table(js_adapter)
			assert.is_function(js_adapter.setup)
		end)

		it("should handle missing nvim-dap-vscode-js gracefully", function()
			local js_adapter = require("modules.debug.adapters.javascript")
			local mock_dap = {}
			local success, err = pcall(js_adapter.setup, mock_dap)
			assert.is_true(success, err)
		end)
	end)

	describe("Python adapter", function()
		it("should load Python adapter module", function()
			local python_adapter = require("modules.debug.adapters.python")
			assert.is_table(python_adapter)
			assert.is_function(python_adapter.setup)
		end)

		it("should setup Python adapter configuration", function()
			local python_adapter = require("modules.debug.adapters.python")
			local mock_dap = {
				adapters = {},
				configurations = {},
			}
			python_adapter.setup(mock_dap)

			assert.is_not_nil(mock_dap.adapters.python)
			assert.is_not_nil(mock_dap.configurations.python)
		end)
	end)

	describe("Ruby adapter", function()
		it("should load Ruby adapter module", function()
			local ruby_adapter = require("modules.debug.adapters.ruby")
			assert.is_table(ruby_adapter)
			assert.is_function(ruby_adapter.setup)
		end)

		it("should handle missing rdbg gracefully", function()
			local ruby_adapter = require("modules.debug.adapters.ruby")
			local mock_dap = {
				adapters = {},
				configurations = {},
			}

			-- Mock vim.fn for test
			vim.fn = vim.fn or {}
			local old_system = vim.fn.system
			local old_executable = vim.fn.executable

			vim.fn.system = function()
				return ""
			end
			vim.fn.executable = function()
				return 0
			end

			ruby_adapter.setup(mock_dap)

			-- Restore
			vim.fn.system = old_system
			vim.fn.executable = old_executable
		end)
	end)

	describe("Lua adapter", function()
		it("should load Lua adapter module", function()
			local lua_adapter = require("modules.debug.adapters.lua")
			assert.is_table(lua_adapter)
			assert.is_function(lua_adapter.setup)
		end)

		it("should setup Lua adapter configuration", function()
			local lua_adapter = require("modules.debug.adapters.lua")
			local mock_dap = {
				adapters = {},
				configurations = {},
			}
			lua_adapter.setup(mock_dap)

			assert.is_not_nil(mock_dap.adapters["local-lua"])
			assert.is_not_nil(mock_dap.configurations.lua)
		end)
	end)
end)
