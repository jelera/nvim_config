--[[
Setup Unit Tests
================

Unit tests for the setup system that handles:
- lazy.nvim installation
- Plugin manager initialization
- Framework initialization

Test Categories:
1. lazy.nvim path detection
2. lazy.nvim installation (auto-install)
3. Framework initialization
4. Event emission (setup:complete)
5. Error handling

Uses standard luassert syntax.
--]]

local spec_helper = require("spec.spec_helper")

describe("setup #unit", function()
	local setup

	before_each(function()
		spec_helper.setup()
		package.loaded["nvim.setup"] = nil
		setup = require("nvim.setup")
	end)

	after_each(function()
		spec_helper.teardown()
	end)

	describe("initialization", function()
		it("should load setup module", function()
			assert.is_not_nil(setup)
			assert.is_table(setup)
		end)

		it("should have get_lazy_path function", function()
			assert.is_function(setup.get_lazy_path)
		end)

		it("should have is_lazy_installed function", function()
			assert.is_function(setup.is_lazy_installed)
		end)

		it("should have install_lazy function", function()
			assert.is_function(setup.install_lazy)
		end)

		it("should have setup_lazy function", function()
			assert.is_function(setup.setup_lazy)
		end)

		it("should have init function", function()
			assert.is_function(setup.init)
		end)
	end)

	describe("get_lazy_path()", function()
		it("should return a string path", function()
			local path = setup.get_lazy_path()
			assert.is_string(path)
		end)

		it("should return path with lazy.nvim in it", function()
			local path = setup.get_lazy_path()
			assert.is_not_nil(path:match("lazy%.nvim"))
		end)

		it("should use vim.fn.stdpath for data directory", function()
			-- Path should contain standard data path
			local path = setup.get_lazy_path()
			assert.is_not_nil(path)
			assert.is_true(#path > 0)
		end)
	end)

	describe("is_lazy_installed()", function()
		it("should return boolean", function()
			local installed = setup.is_lazy_installed()
			assert.is_boolean(installed)
		end)

		it("should check if lazy path exists in runtimepath", function()
			-- This tests the logic, actual result depends on environment
			local installed = setup.is_lazy_installed()
			assert.is_not_nil(installed)
		end)
	end)

	describe("install_lazy()", function()
		it("should return boolean indicating success", function()
			-- Mock the installation to avoid actual git clone
			local original_fn_system = vim.fn.system
			vim.fn.system = function()
				return ""
			end

			local success = setup.install_lazy()
			assert.is_boolean(success)

			vim.fn.system = original_fn_system
		end)

		it("should use git clone to install lazy.nvim", function()
			local git_called = false
			local git_url = nil

			local original_fn_system = vim.fn.system
			vim.fn.system = function(cmd)
				if type(cmd) == "table" and cmd[1] == "git" then
					git_called = true
					git_url = cmd[4] -- The URL is the 4th argument (git, clone, --filter, URL)
				end
				return ""
			end

			setup.install_lazy()

			assert.is_true(git_called)
			assert.is_not_nil(git_url)
			assert.is_not_nil(git_url:match("lazy%.nvim"))

			vim.fn.system = original_fn_system
		end)

		it("should add lazy path to runtimepath after install", function()
			local original_fn_system = vim.fn.system
			local original_opt = vim.opt

			local rtp_prepended = false
			vim.fn.system = function()
				return ""
			end

			-- Mock vim.opt to track rtp.prepend calls
			vim.opt = setmetatable({}, {
				__index = function(t, k)
					if k == "rtp" then
						return {
							prepend = function(self, path)
								rtp_prepended = true
							end,
						}
					end
					return nil
				end,
			})

			setup.install_lazy()

			assert.is_true(rtp_prepended)

			vim.fn.system = original_fn_system
			vim.opt = original_opt
		end)

		it("should handle installation errors gracefully", function()
			local original_fn_system = vim.fn.system
			vim.fn.system = function()
				error("Git error")
			end

			-- Should not throw, should return false
			local success = pcall(function()
				return setup.install_lazy()
			end)

			assert.is_true(success)

			vim.fn.system = original_fn_system
		end)
	end)

	describe("setup_lazy()", function()
		it("should return boolean indicating success", function()
			-- Mock lazy.nvim setup
			package.loaded["lazy"] = {
				setup = function() end,
			}

			local success = setup.setup_lazy({})
			assert.is_boolean(success)

			package.loaded["lazy"] = nil
		end)

		it("should require lazy and call setup", function()
			local setup_called = false
			local setup_config = nil

			package.loaded["lazy"] = {
				setup = function(config)
					setup_called = true
					setup_config = config
				end,
			}

			local test_config = { plugins = {} }
			setup.setup_lazy(test_config)

			assert.is_true(setup_called)
			assert.equals(test_config, setup_config)

			package.loaded["lazy"] = nil
		end)

		it("should handle missing lazy.nvim gracefully", function()
			package.loaded["lazy"] = nil

			local success = setup.setup_lazy({})
			assert.is_false(success)
		end)

		it("should handle lazy.setup errors gracefully", function()
			package.loaded["lazy"] = {
				setup = function()
					error("Lazy setup error")
				end,
			}

			local success = setup.setup_lazy({})
			assert.is_false(success)

			package.loaded["lazy"] = nil
		end)
	end)

	describe("init()", function()
		it("should initialize the framework", function()
			-- Mock all dependencies
			package.loaded["lazy"] = {
				setup = function() end,
			}

			local original_fn_system = vim.fn.system
			vim.fn.system = function()
				return ""
			end

			local success = setup.init()
			assert.is_boolean(success)

			vim.fn.system = original_fn_system
			package.loaded["lazy"] = nil
		end)

		it("should install lazy if not installed", function()
			local install_called = false

			-- Mock is_lazy_installed to return false
			local original_is_lazy_installed = setup.is_lazy_installed
			setup.is_lazy_installed = function()
				return false
			end

			-- Mock install_lazy
			local original_install_lazy = setup.install_lazy
			setup.install_lazy = function()
				install_called = true
				return true
			end

			-- Mock setup_lazy
			local original_setup_lazy = setup.setup_lazy
			setup.setup_lazy = function()
				return true
			end

			setup.init()

			assert.is_true(install_called)

			setup.is_lazy_installed = original_is_lazy_installed
			setup.install_lazy = original_install_lazy
			setup.setup_lazy = original_setup_lazy
		end)

		it("should skip install if lazy already installed", function()
			local install_called = false

			-- Mock is_lazy_installed to return true
			local original_is_lazy_installed = setup.is_lazy_installed
			setup.is_lazy_installed = function()
				return true
			end

			-- Mock install_lazy
			local original_install_lazy = setup.install_lazy
			setup.install_lazy = function()
				install_called = true
				return true
			end

			-- Mock setup_lazy
			local original_setup_lazy = setup.setup_lazy
			setup.setup_lazy = function()
				return true
			end

			setup.init()

			assert.is_false(install_called)

			setup.is_lazy_installed = original_is_lazy_installed
			setup.install_lazy = original_install_lazy
			setup.setup_lazy = original_setup_lazy
		end)

		it("should emit setup:complete event", function()
			local event_bus = require("nvim.core.event_bus")
			local event_emitted = false

			event_bus.on("setup:complete", function()
				event_emitted = true
			end)

			-- Mock all dependencies
			package.loaded["lazy"] = {
				setup = function() end,
			}

			local original_is_lazy_installed = setup.is_lazy_installed
			setup.is_lazy_installed = function()
				return true
			end

			local original_setup_lazy = setup.setup_lazy
			setup.setup_lazy = function()
				return true
			end

			setup.init()

			assert.is_true(event_emitted)

			setup.is_lazy_installed = original_is_lazy_installed
			setup.setup_lazy = original_setup_lazy
			package.loaded["lazy"] = nil
		end)

		it("should return false on initialization failure", function()
			-- Force setup_lazy to fail
			local original_setup_lazy = setup.setup_lazy
			setup.setup_lazy = function()
				return false
			end

			local success = setup.init()
			assert.is_false(success)

			setup.setup_lazy = original_setup_lazy
		end)
	end)
end)
