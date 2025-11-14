--[[
Setup
=====

Handles framework initialization including lazy.nvim installation,
plugin manager setup, and framework bootstrapping.

Features:
- Auto-install lazy.nvim if not present
- Initialize plugin manager
- Set up runtime path
- Emit setup:complete event

Usage:
  local setup = require('nvim.setup')

  -- Initialize the framework
  setup.init()

  -- Or customize lazy.nvim config
  setup.init({
    plugins = { ... },
    performance = { ... }
  })
--]]

local M = {}

-- Dependencies
local event_bus = require("nvim.core.event_bus")

-- lazy.nvim repository URL
local LAZY_REPO = "https://github.com/folke/lazy.nvim.git"
local LAZY_BRANCH = "stable"

--[[
Get the path where lazy.nvim should be installed

Uses vim.fn.stdpath('data') to get the standard NeoVim data directory,
then appends the lazy.nvim plugin path.

@return string: Full path to lazy.nvim installation directory
--]]
function M.get_lazy_path()
	return vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
end

--[[
Check if lazy.nvim is installed

Checks if the lazy.nvim path exists in the runtime path.

@return boolean: true if lazy.nvim is installed, false otherwise
--]]
function M.is_lazy_installed()
	local lazypath = M.get_lazy_path()
	return vim.loop.fs_stat(lazypath) ~= nil
end

--[[
Install lazy.nvim using git clone

Downloads lazy.nvim from GitHub and adds it to the runtime path.

@return boolean: true if installation succeeded, false otherwise
--]]
function M.install_lazy()
	local lazypath = M.get_lazy_path()

	-- Attempt to clone lazy.nvim
	local success, err = pcall(function()
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			LAZY_REPO,
			"--branch=" .. LAZY_BRANCH,
			lazypath,
		})
	end)

	if not success then
		vim.notify("Failed to install lazy.nvim: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	-- Add lazy.nvim to runtime path
	vim.opt.rtp:prepend(lazypath)

	return true
end

--[[
Set up lazy.nvim with configuration

Requires lazy.nvim and calls its setup function with the provided config.

@param config table: Configuration for lazy.nvim (optional)
@return boolean: true if setup succeeded, false otherwise
--]]
function M.setup_lazy(config)
	config = config or {}

	-- Try to require lazy.nvim
	local success, lazy = pcall(require, "lazy")
	if not success then
		vim.notify("Failed to require lazy.nvim", vim.log.levels.ERROR)
		return false
	end

	-- Try to setup lazy.nvim
	local setup_success, setup_err = pcall(function()
		lazy.setup(config)
	end)

	if not setup_success then
		vim.notify("Failed to setup lazy.nvim: " .. tostring(setup_err), vim.log.levels.ERROR)
		return false
	end

	return true
end

--[[
Initialize the framework

Main entry point that:
1. Checks if lazy.nvim is installed, installs if needed
2. Sets up lazy.nvim with provided config
3. Emits setup:complete event

@param config table: Optional configuration for lazy.nvim
@return boolean: true if initialization succeeded, false otherwise
--]]
function M.init(config)
	config = config or {}

	-- Install lazy.nvim if not present
	if not M.is_lazy_installed() then
		vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
		local install_success = M.install_lazy()
		if not install_success then
			return false
		end
		vim.notify("lazy.nvim installed successfully", vim.log.levels.INFO)
	else
		-- Add to runtimepath if already installed
		vim.opt.rtp:prepend(M.get_lazy_path())
	end

	-- Setup lazy.nvim
	local setup_success = M.setup_lazy(config)
	if not setup_success then
		return false
	end

	-- Emit setup complete event
	event_bus.emit("setup:complete", {
		lazy_installed = true,
		lazy_path = M.get_lazy_path(),
	})

	return true
end

return M
