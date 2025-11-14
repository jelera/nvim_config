--[[
Gitsigns Configuration
======================

Configures gitsigns.nvim for git decorations and hunk operations.

Features:
- Visual git indicators in sign column
- Current line blame (optional)
- Hunk preview, staging, and reset
- Hunk navigation

Dependencies:
- lewis6991/gitsigns.nvim

API:
- setup(config) - Configure gitsigns
--]]

local M = {}

---Default configuration for gitsigns
local default_config = {
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true,
	numhl = false,
	linehl = false,
	word_diff = false,
	watch_gitdir = {
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = false,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol",
		delay = 1000,
		ignore_whitespace = false,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	max_file_length = 40000,
	preview_config = {
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
}

---Setup gitsigns with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Try to load gitsigns plugin
	local ok, gitsigns = pcall(require, "gitsigns")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup gitsigns
	local setup_ok, err = pcall(gitsigns.setup, merged_config)
	if not setup_ok then
		vim.notify(string.format("Failed to setup gitsigns: %s", err), vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
