--[[
Tooling Module Integration Tests
=================================

Tests for the tooling module (database, REPL, HTTP client).
--]]

describe("modules.tooling", function()
	local tooling

	before_each(function()
		-- Clear module cache
		package.loaded["modules.tooling"] = nil
		package.loaded["modules.tooling.database"] = nil
		package.loaded["modules.tooling.repl"] = nil
		package.loaded["modules.tooling.http"] = nil

		tooling = require("modules.tooling")
	end)

	describe("Module structure", function()
		it("should have setup function", function()
			assert.is_function(tooling.setup)
		end)
	end)

	describe("setup()", function()
		it("should setup without errors", function()
			local success, err = pcall(tooling.setup)
			assert.is_true(success, err)
		end)
	end)

	describe("Database sub-module", function()
		it("should load database module", function()
			local database = require("modules.tooling.database")
			assert.is_table(database)
			assert.is_function(database.setup)
		end)

		it("should setup without errors when dbee is not available", function()
			local database = require("modules.tooling.database")
			-- Should not crash even if dbee plugin isn't loaded
			local success, err = pcall(database.setup)
			assert.is_true(success, err)
		end)
	end)

	describe("REPL sub-module", function()
		it("should load REPL module", function()
			local repl = require("modules.tooling.repl")
			assert.is_table(repl)
			assert.is_function(repl.setup)
		end)

		it("should setup without errors when iron.nvim is not available", function()
			local repl = require("modules.tooling.repl")
			-- Should not crash even if iron.nvim plugin isn't loaded
			local success, err = pcall(repl.setup)
			assert.is_true(success, err)
		end)
	end)

	describe("HTTP client sub-module", function()
		it("should load HTTP module", function()
			local http = require("modules.tooling.http")
			assert.is_table(http)
			assert.is_function(http.setup)
		end)

		it("should setup without errors when rest.nvim is not available", function()
			local http = require("modules.tooling.http")
			-- Should not crash even if rest.nvim plugin isn't loaded
			local success, err = pcall(http.setup)
			assert.is_true(success, err)
		end)
	end)
end)
