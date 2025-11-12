--[[
Frameworks Module Integration Tests
===================================

Tests for the frameworks module (Rails, Angular support).
--]]

describe("modules.frameworks", function()
	local spec_helper = require("spec.spec_helper")
	local frameworks

	before_each(function()
		spec_helper.setup()

		-- Clear module cache
		package.loaded["modules.frameworks"] = nil
		package.loaded["modules.frameworks.rails"] = nil
		package.loaded["modules.frameworks.angular"] = nil

		frameworks = require("modules.frameworks")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("Module structure", function()
		it("should have setup function", function()
			assert.is_function(frameworks.setup)
		end)
	end)

	describe("setup()", function()
		it("should setup without errors", function()
			local success, err = pcall(frameworks.setup)
			assert.is_true(success, err)
		end)

		it("should call Rails and Angular setup", function()
			-- Mock vim.fn for project detection
			vim.fn = vim.fn or {}
			vim.fn.findfile = function()
				return ""
			end

			local result = frameworks.setup()
			-- Result can be true or false depending on project detection
			assert.is_not_nil(result)
		end)
	end)

	describe("Rails sub-module", function()
		it("should load Rails module", function()
			local rails = require("modules.frameworks.rails")
			assert.is_table(rails)
			assert.is_function(rails.setup)
		end)

		it("should setup Rails projections", function()
			local rails = require("modules.frameworks.rails")
			rails.setup()

			-- Verify projections are set
			assert.is_not_nil(vim.g.rails_projections)
			assert.is_table(vim.g.rails_projections)
		end)
	end)

	describe("Angular sub-module", function()
		it("should load Angular module", function()
			local angular = require("modules.frameworks.angular")
			assert.is_table(angular)
			assert.is_function(angular.setup)
		end)

		it("should setup without errors", function()
			local angular = require("modules.frameworks.angular")
			local success, err = pcall(angular.setup)
			assert.is_true(success, err)
		end)
	end)
end)
