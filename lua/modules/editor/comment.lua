--[[
Comment Configuration
=====================

Configures Comment.nvim for smart code commenting.

Features:
- Line commenting: gcc
- Block commenting: gbc
- Visual mode support
- TreeSitter integration for context-aware commenting
- Supports multiple languages and comment styles

Dependencies:
- numToStr/Comment.nvim

Usage:
- gcc - Toggle line comment
- gbc - Toggle block comment
- gc{motion} - Comment motion (e.g., gcip for paragraph)
- gb{motion} - Block comment motion
- gc (visual) - Comment selection
- gb (visual) - Block comment selection

API:
- setup(config) - Configure comment
--]]

local M = {}

---Default configuration for comment (uses plugin defaults)
local default_config = {
	-- LHS of toggle mappings in NORMAL mode
	toggler = {
		line = "gcc", -- Line-comment toggle keymap
		block = "gbc", -- Block-comment toggle keymap
	},
	-- LHS of operator-pending mappings in NORMAL and VISUAL mode
	opleader = {
		line = "gc", -- Line-comment keymap
		block = "gb", -- Block-comment keymap
	},
	-- LHS of extra mappings
	extra = {
		above = "gcO", -- Add comment on the line above
		below = "gco", -- Add comment on the line below
		eol = "gcA", -- Add comment at the end of line
	},
	-- Enable keybindings
	mappings = {
		basic = true,
		extra = true,
	},
}

---Setup comment with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Try to load comment plugin
	local ok, comment = pcall(require, "Comment")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup comment
	local setup_ok, err = pcall(comment.setup, merged_config)
	if not setup_ok then
		vim.notify(string.format("Failed to setup comment: %s", err), vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
