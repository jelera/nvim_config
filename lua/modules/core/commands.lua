--[[
Core Commands Module
====================

Manages user command registration in a structured, testable way.

Features:
- User command registration
- User configuration override support
- Default useful commands
- Support for all command options (bang, range, nargs, etc.)
- Error handling

Dependencies:
- nvim.lib.utils (for deep_merge)

Usage:
```lua
local commands = require('modules.core.commands')

-- Use defaults
commands.setup()

-- Add custom commands
commands.setup({
  CustomCommand = {
    callback = function(opts)
      print('Custom command called with args:', opts.args)
    end,
    opts = {
      nargs = '*',
      desc = 'My custom command'
    }
  }
})

-- Register single command
commands.register('TestCommand', function(opts)
  print('Test:', opts.args)
end, { nargs = '*', desc = 'Test command' })
```

API:
- setup(config) - Initialize with config (merges with defaults)
- get_defaults() - Get default command definitions
- register(name, callback, opts) - Register a single command
- register_all(commands_config) - Register all commands from config
--]]

local utils = require("nvim.lib.utils")

local M = {}

---Get default command definitions
---@return table defaults Default commands
function M.get_defaults()
	return {
		-- Format current buffer
		Format = {
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
			opts = {
				desc = "Format current buffer with LSP",
			},
		},

		-- Delete buffer without closing window
		BufDelete = {
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				local win_count = 0

				-- Count windows showing this buffer
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == buf then
						win_count = win_count + 1
					end
				end

				-- If buffer is shown in multiple windows, just switch to another buffer
				if win_count > 1 then
					vim.cmd("bprevious")
				end

				-- Delete the buffer
				vim.cmd("bdelete " .. buf)
			end,
			opts = {
				desc = "Delete buffer without closing window",
			},
		},

		-- Reload configuration
		ReloadConfig = {
			callback = function()
				-- Clear all module caches
				for k, _ in pairs(package.loaded) do
					if k:match("^nvim%.") or k:match("^modules%.") or k:match("^config%.") then
						package.loaded[k] = nil
					end
				end

				-- Reload init.lua
				vim.cmd("source ~/.config/nvim/init.lua")
				vim.notify("Configuration reloaded", vim.log.levels.INFO)
			end,
			opts = {
				desc = "Reload NeoVim configuration",
			},
		},

		-- Profile startup time
		ProfileStartup = {
			callback = function()
				local cache_dir = vim.fn.stdpath("cache")
				local profile_file = cache_dir .. "/startup.log"

				-- Run nvim with startuptime profiling
				vim.notify("Profiling startup time...", vim.log.levels.INFO)
				local cmd = string.format(
					"nvim --headless --startuptime %s +qall && cat %s",
					vim.fn.shellescape(profile_file),
					vim.fn.shellescape(profile_file)
				)

				vim.fn.system(cmd)

				-- Open the profile in a new buffer
				vim.cmd("new")
				vim.cmd("file StartupProfile")
				vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
				vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.fn.readfile(profile_file), "\n"))

				-- Extract and show summary
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				local total_time = "Unknown"
				for _, line in ipairs(lines) do
					if line:match("NVIM STARTED") then
						total_time = line:match("^%s*([%d.]+)")
						break
					end
				end

				vim.notify(
					string.format("Startup time: %sms (see buffer for details)", total_time),
					vim.log.levels.INFO
				)
			end,
			opts = {
				desc = "Profile NeoVim startup time and show results",
			},
		},

		-- Benchmark startup (multiple runs)
		BenchmarkStartup = {
			callback = function(opts)
				local runs = tonumber(opts.args) or 5
				vim.notify(string.format("Running %d startup benchmarks...", runs), vim.log.levels.INFO)

				local cache_dir = vim.fn.stdpath("cache")
				local times = {}

				for i = 1, runs do
					local profile_file = cache_dir .. "/startup_bench_" .. i .. ".log"
					local cmd =
						string.format("nvim --headless --startuptime %s +qall", vim.fn.shellescape(profile_file))
					vim.fn.system(cmd)

					-- Extract time from log
					local log_content = vim.fn.readfile(profile_file)
					for _, line in ipairs(log_content) do
						if line:match("NVIM STARTED") then
							local time = tonumber(line:match("^%s*([%d.]+)"))
							if time then
								table.insert(times, time)
							end
							break
						end
					end
				end

				-- Calculate statistics
				if #times > 0 then
					table.sort(times)
					local sum = 0
					for _, time in ipairs(times) do
						sum = sum + time
					end
					local avg = sum / #times
					local min = times[1]
					local max = times[#times]

					-- Show results
					local results = {
						string.format("Startup Benchmark Results (%d runs):", runs),
						string.format("  Average: %.1fms", avg),
						string.format("  Best:    %.1fms", min),
						string.format("  Worst:   %.1fms", max),
						"",
						"All runs:",
					}

					for i, time in ipairs(times) do
						table.insert(results, string.format("  Run %d: %.1fms", i, time))
					end

					-- Display in buffer
					vim.cmd("new")
					vim.cmd("file BenchmarkResults")
					vim.cmd("setlocal buftype=nofile bufhidden=wipe noswapfile")
					vim.api.nvim_buf_set_lines(0, 0, -1, false, results)

					vim.notify(
						string.format("Benchmark complete: %.1fms avg (best: %.1fms)", avg, min),
						vim.log.levels.INFO
					)
				else
					vim.notify("Failed to collect benchmark data", vim.log.levels.ERROR)
				end
			end,
			opts = {
				nargs = "?",
				desc = "Benchmark startup time (default: 5 runs, usage: :BenchmarkStartup [runs])",
			},
		},

		-- Profile plugins with lazy.nvim
		ProfilePlugins = {
			callback = function()
				-- Open lazy.nvim profile
				vim.cmd("Lazy profile")
			end,
			opts = {
				desc = "Open lazy.nvim plugin profiler",
			},
		},
	}
end

---Register a single user command
---@param name string The command name (must start with uppercase)
---@param callback string|function The command implementation
---@param opts? table Optional command options (bang, range, nargs, desc, etc.)
---@return boolean success Whether command was registered successfully
function M.register(name, callback, opts)
	opts = opts or {}

	local success, err = pcall(function()
		vim.api.nvim_create_user_command(name, callback, opts)
	end)

	if not success then
		vim.notify("Failed to register command: " .. name .. " - " .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	return true
end

---Register all commands from configuration
---@param commands_config table Commands to register
---@return boolean success Whether all commands were registered successfully
function M.register_all(commands_config)
	if not commands_config then
		return true
	end

	local success, err = pcall(function()
		-- Iterate through each command
		for name, cmd_def in pairs(commands_config) do
			if type(cmd_def) == "table" then
				local callback = cmd_def.callback
				local opts = cmd_def.opts or {}

				local register_success = M.register(name, callback, opts)
				if not register_success then
					error("Failed to register command: " .. name)
				end
			end
		end
	end)

	if not success then
		vim.notify("Failed to register commands: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	return true
end

---Setup commands with optional user configuration
---Merges user config with defaults and registers all commands
---@param user_config? table User command configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
	user_config = user_config or {}

	-- Get defaults
	local defaults = M.get_defaults()

	-- Merge user config with defaults (user config overrides)
	local final_config = utils.deep_merge(defaults, user_config)

	-- Register all commands
	local success = M.register_all(final_config)

	if not success then
		vim.notify("Commands setup failed", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
