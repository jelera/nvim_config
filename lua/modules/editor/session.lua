--[[
Session Management Configuration
=================================

Configures persistence.nvim for automatic session management.

Features:
- Auto-save sessions on exit
- Restore last session on startup
- Per-directory sessions
- Skip certain buffers (help, man, quickfix, etc.)

Dependencies:
- folke/persistence.nvim

Usage:
- Sessions are saved automatically
- Use keymaps to restore/stop sessions (defined in keymaps.lua)

API:
- setup(config) - Configure session management
--]]

local M = {}

---Default configuration for session management
local default_config = {
	-- Directory where session files are saved
	dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),

	-- Sessionoptions used for saving
	options = { "buffers", "curdir", "tabpages", "winsize" },

	-- Function to determine if a buffer should be saved
	pre_save = nil,

	-- Function to run before saving session
	save_empty = false, -- Don't save session if no buffers
}

---Setup session management with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Ensure session directory exists
	vim.fn.mkdir(merged_config.dir, "p")

	-- Try to load persistence plugin
	local ok, persistence = pcall(require, "persistence")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup persistence
	local setup_ok, err = pcall(persistence.setup, merged_config)
	if not setup_ok then
		vim.notify(string.format("Failed to setup session management: %s", err), vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
