--[[
Test Helper and NeoVim API Mocks
=================================

This module provides:
- Mock vim API for testing without running NeoVim
- Test utilities and helper functions
- Fixtures and factories for common test data
- Setup and teardown helpers

Usage:
  local spec_helper = require('spec.spec_helper')

  describe('My module', function()
    before_each(function()
      spec_helper.setup()
    end)

    after_each(function()
      spec_helper.teardown()
    end)

    it('should work with standard assertions', function()
      assert.is_not_nil(vim.api)
      assert.is_table(vim.api)
    end)

    -- Future: Custom namespaced assertions
    -- assert.vim.has_keymap('n', '<leader>ff')
    -- assert.module.is_loaded('nvim.core.module_loader')
  end)
--]]

local M = {}

-- Load luassert for custom assertions (future use)
-- We'll use this to create namespaced assertions like:
-- assert.vim.has_keymap(), assert.module.is_loaded(), etc.
local _luassert = require("luassert")

-- Store original vim global if it exists
M._original_vim = _G.vim

-- Log levels matching NeoVim's vim.log.levels
M.log_levels = {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	OFF = 5,
}

-- Mock vim.api - Core NeoVim API
M.mock_api = {
	-- Buffer management
	nvim_create_buf = function(listed, scratch)
		return math.random(1, 10000) -- Mock buffer handle
	end,

	nvim_buf_set_lines = function(buffer, start, end_, strict_indexing, replacement)
		-- Mock: no-op
	end,

	nvim_buf_get_lines = function(buffer, start, end_, strict_indexing)
		return {} -- Mock: empty lines
	end,

	nvim_buf_set_option = function(buffer, name, value)
		-- Mock: no-op
	end,

	nvim_buf_get_option = function(buffer, name)
		return nil -- Mock: nil value
	end,

	-- Window management
	nvim_get_current_win = function()
		return 1000 -- Mock window handle
	end,

	nvim_win_set_option = function(window, name, value)
		-- Mock: no-op
	end,

	nvim_win_get_option = function(window, name)
		return nil -- Mock: nil value
	end,

	-- Autocommands
	nvim_create_autocmd = function(event, opts)
		return math.random(1, 10000) -- Mock autocmd ID
	end,

	nvim_create_augroup = function(name, opts)
		return math.random(1, 10000) -- Mock augroup ID
	end,

	-- Keymaps
	nvim_set_keymap = function(mode, lhs, rhs, opts)
		-- Mock: no-op
	end,

	nvim_del_keymap = function(mode, lhs)
		-- Mock: no-op
	end,

	-- Commands
	nvim_create_user_command = function(name, command, opts)
		-- Mock: no-op
	end,

	nvim_del_user_command = function(name)
		-- Mock: no-op
	end,

	-- Variables
	nvim_set_var = function(name, value)
		-- Mock: no-op
	end,

	nvim_get_var = function(name)
		return nil -- Mock: nil value
	end,

	-- Options (global)
	nvim_set_option = function(name, value)
		-- Mock: no-op
	end,

	nvim_get_option = function(name)
		return nil -- Mock: nil value
	end,
}

-- Mock vim.fn - Vimscript functions
M.mock_fn = {
	expand = function(expr)
		if expr == "%:p" then
			return "/mock/file/path.lua"
		elseif expr == "~" then
			return "/home/mockuser"
		end
		return expr
	end,

	stdpath = function(what)
		local paths = {
			config = "/mock/config",
			data = "/mock/data",
			cache = "/mock/cache",
			state = "/mock/state",
		}
		return paths[what] or "/mock/path"
	end,

	has = function(feature)
		-- Mock: return true for common features
		local features = {
			nvim = true,
			["nvim-0.9"] = true,
			["nvim-0.10"] = true,
			lua = true,
		}
		return features[feature] or false
	end,

	executable = function(program)
		-- Mock: return true for common executables
		local executables = {
			git = true,
			rg = true,
			fd = true,
		}
		return executables[program] and 1 or 0
	end,

	filereadable = function(path)
		return 0 -- Mock: file not readable
	end,

	isdirectory = function(path)
		return 0 -- Mock: not a directory
	end,

	mkdir = function(path, mode)
		-- Mock: directory creation (no-op in tests)
		return 1 -- Success
	end,

	getcwd = function()
		return "/mock/cwd"
	end,
}

-- Mock vim.loop - libuv event loop
M.mock_loop = {
	fs_stat = function(path, callback)
		if callback then
			callback(nil, nil) -- Mock: file doesn't exist
		end
		return nil, nil
	end,

	new_timer = function()
		return {
			start = function() end,
			stop = function() end,
			close = function() end,
		}
	end,
}

-- Mock vim.keymap - Keymap API
M.mock_keymap = {
	set = function(mode, lhs, rhs, opts)
		-- Mock: no-op
	end,

	del = function(mode, lhs, opts)
		-- Mock: no-op
	end,
}

-- Mock vim.notify - Notification API
M.mock_notify = function(msg, level, opts)
	-- Store notification for testing
	table.insert(M._notifications, {
		msg = msg,
		level = level or M.log_levels.INFO,
		opts = opts or {},
	})
end

-- Mock vim.schedule - Deferred execution
M.mock_schedule = function(fn)
	-- Execute immediately in tests
	fn()
end

-- Mock vim.schedule_wrap - Wrapped deferred execution
M.mock_schedule_wrap = function(fn)
	return function(...)
		fn(...)
	end
end

-- Mock vim.cmd - Execute Vimscript command
M.mock_cmd = function(command)
	-- Mock: no-op
	-- Store command for testing
	table.insert(M._commands, command)
end

-- Mock vim.diagnostic - Diagnostic API
M.mock_diagnostic = {
	severity = {
		ERROR = 1,
		WARN = 2,
		INFO = 3,
		HINT = 4,
	},
	config = function(opts) end,
	show = function() end,
	hide = function() end,
	get = function()
		return {}
	end,
	set = function() end,
}

-- Create complete mock vim object
function M.create_vim_mock()
	return {
		api = M.mock_api,
		fn = M.mock_fn,
		loop = M.mock_loop,
		keymap = M.mock_keymap,
		notify = M.mock_notify,
		schedule = M.mock_schedule,
		schedule_wrap = M.mock_schedule_wrap,
		cmd = M.mock_cmd,
		diagnostic = M.mock_diagnostic,

		-- Log levels
		log = {
			levels = M.log_levels,
		},

		-- Options (vim.o, vim.opt, etc.)
		o = {},
		opt = setmetatable({
			_values = {}, -- Store option values internally
		}, {
			__index = function(t, k)
				if k == "_values" then
					return rawget(t, k)
				end
				-- Return an object with the stored value and array methods
				return {
					_value = t._values[k],
					prepend = function(self, value)
						t._values[k] = value
					end,
					append = function(self, value)
						t._values[k] = value
					end,
					remove = function(self, value) end,
				}
			end,
			__newindex = function(t, k, v)
				-- Store the value
				t._values[k] = v
			end,
		}),
		opt_local = setmetatable({
			_values = {},
		}, {
			__index = function(t, k)
				if k == "_values" then
					return rawget(t, k)
				end
				return {
					_value = t._values[k],
				}
			end,
			__newindex = function(t, k, v)
				t._values[k] = v
			end,
		}),
		g = {},
		b = {},
		w = {},
		t = {},
		v = {},
		env = {},

		-- Inspection
		inspect = function(obj)
			return vim.inspect(obj) -- Use Lua's built-in if available
		end,

		-- Type checking
		tbl_isempty = function(t)
			return next(t) == nil
		end,

		tbl_extend = function(behavior, ...)
			local result = {}
			for _, tbl in ipairs({ ... }) do
				for k, v in pairs(tbl) do
					if behavior == "force" or result[k] == nil then
						result[k] = v
					end
				end
			end
			return result
		end,

		tbl_deep_extend = function(behavior, ...)
			local function deep_extend(t1, t2)
				for k, v in pairs(t2) do
					if type(v) == "table" and type(t1[k]) == "table" then
						t1[k] = deep_extend(t1[k], v)
					elseif behavior == "force" or t1[k] == nil then
						t1[k] = v
					end
				end
				return t1
			end

			local result = {}
			for _, tbl in ipairs({ ... }) do
				result = deep_extend(result, tbl)
			end
			return result
		end,

		tbl_contains = function(t, value)
			for _, v in ipairs(t) do
				if v == value then
					return true
				end
			end
			return false
		end,

		list_extend = function(dst, src)
			for _, v in ipairs(src) do
				table.insert(dst, v)
			end
			return dst
		end,

		split = function(s, sep)
			local fields = {}
			local pattern = string.format("([^%s]+)", sep or " ")
			s:gsub(pattern, function(c)
				fields[#fields + 1] = c
			end)
			return fields
		end,

		trim = function(s)
			return s:match("^%s*(.-)%s*$")
		end,

		startswith = function(s, prefix)
			return s:sub(1, #prefix) == prefix
		end,

		endswith = function(s, suffix)
			return s:sub(-#suffix) == suffix
		end,
	}
end

-- Setup function - call before each test
function M.setup()
	-- Reset tracking tables
	M._notifications = {}
	M._commands = {}

	-- Install mock vim global
	_G.vim = M.create_vim_mock()

	-- Set up proper module paths
	package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
end

-- Teardown function - call after each test
function M.teardown()
	-- Restore original vim global if it existed
	_G.vim = M._original_vim

	-- Clear tracking tables
	M._notifications = {}
	M._commands = {}

	-- Unload test modules to ensure clean state
	for k, _ in pairs(package.loaded) do
		if k:match("^nvim%.") or k:match("^modules%.") or k:match("^config%.") then
			package.loaded[k] = nil
		end
	end
end

-- Test utilities

-- Assert that a notification was sent
function M.assert_notification(msg_pattern, level)
	for _, notification in ipairs(M._notifications) do
		if notification.msg:match(msg_pattern) then
			if not level or notification.level == level then
				return true
			end
		end
	end
	return false
end

-- Assert that a command was executed
function M.assert_command(cmd_pattern)
	for _, command in ipairs(M._commands) do
		if type(command) == "string" and command:match(cmd_pattern) then
			return true
		end
	end
	return false
end

-- Get all notifications
function M.get_notifications()
	return M._notifications
end

-- Get all commands
function M.get_commands()
	return M._commands
end

-- Clear notifications
function M.clear_notifications()
	M._notifications = {}
end

-- Clear commands
function M.clear_commands()
	M._commands = {}
end

-- Create a spy function
function M.create_spy(return_value)
	local spy = {
		called = false,
		call_count = 0,
		calls = {},
		return_value = return_value,
	}

	local fn = function(...)
		spy.called = true
		spy.call_count = spy.call_count + 1
		table.insert(spy.calls, { ... })
		return spy.return_value
	end

	return fn, spy
end

-- Create a stub object
function M.create_stub(methods)
	local stub = {}
	for name, return_value in pairs(methods) do
		local fn, spy = M.create_spy(return_value)
		stub[name] = fn
		stub["_spy_" .. name] = spy
	end
	return stub
end

-- Deep copy utility
function M.deep_copy(obj)
	if type(obj) ~= "table" then
		return obj
	end

	local copy = {}
	for k, v in pairs(obj) do
		copy[k] = M.deep_copy(v)
	end

	return copy
end

-- Fixture loader
function M.load_fixture(name)
	local fixture_path = "./lua/spec/fixtures/" .. name .. ".lua"
	local ok, fixture = pcall(dofile, fixture_path)
	if ok then
		return fixture
	else
		return nil
	end
end

-- Initialize tracking tables
M._notifications = {}
M._commands = {}

return M
