--[[
Tree Module
===========

File explorer configuration using nvim-tree.
Replaces NERDTree from the original vim setup.

Features:
- Modern, Lua-native file explorer
- Git integration with status indicators
- File operations (create, delete, rename, copy)
- Auto-close, minimal UI like NERDTree
- Directory-based navigation

Dependencies:
- nvim-tree/nvim-tree.lua
- nvim-tree/nvim-web-devicons

Usage:
```lua
local tree = require('modules.navigation.tree')
tree.setup({
  -- Optional config overrides
})
```

API:
- setup(config) - Initialize nvim-tree with configuration
- get_api() - Get nvim-tree.api for custom operations
--]]

local M = {}

-- Private state
local tree_api = nil

---Get nvim-tree.api for custom operations
---@return table|nil api nvim-tree API or nil
function M.get_api()
	return tree_api
end

---Setup nvim-tree with configuration
---@param config table|nil Optional configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Disable netrw (vim's built-in file explorer)
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1

	-- Load nvim-tree
	local ok, nvim_tree = pcall(require, "nvim-tree")
	if not ok then
		vim.notify("nvim-tree not found. File explorer disabled.", vim.log.levels.WARN)
		return false
	end

	-- Load tree API
	local api_ok, api = pcall(require, "nvim-tree.api")
	if not api_ok then
		vim.notify("nvim-tree.api not found.", vim.log.levels.WARN)
		return false
	end

	tree_api = api

	-- Default configuration (based on NERDTree behavior)
	local default_config = {
		-- Disable netrw
		disable_netrw = true,
		hijack_netrw = true,

		-- Auto-close tree when opening a file (like NERDTree)
		actions = {
			open_file = {
				quit_on_open = true,
			},
		},

		-- View configuration
		view = {
			width = 30,
			side = "left",
			preserve_window_proportions = false,
			number = false,
			relativenumber = false,
			signcolumn = "yes",
		},

		-- Renderer configuration (minimal UI like NERDTree)
		renderer = {
			add_trailing = false,
			group_empty = false,
			highlight_git = true,
			full_name = false,
			highlight_opened_files = "none",
			root_folder_label = ":~:s?$?/..?",
			indent_width = 2,
			indent_markers = {
				enable = true,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					bottom = "─",
					none = " ",
				},
			},
			icons = {
				webdev_colors = true,
				git_placement = "before",
				padding = " ",
				symlink_arrow = " ➛ ",
				show = {
					file = true,
					folder = true,
					folder_arrow = true,
					git = true,
				},
				glyphs = {
					default = "",
					symlink = "",
					bookmark = "",
					folder = {
						arrow_closed = "",
						arrow_open = "",
						default = "",
						open = "",
						empty = "",
						empty_open = "",
						symlink = "",
						symlink_open = "",
					},
					git = {
						unstaged = "✗",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						untracked = "★",
						deleted = "",
						ignored = "◌",
					},
				},
			},
			special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
			symlink_destination = true,
		},

		-- Update focused file on BufEnter
		update_focused_file = {
			enable = true,
			update_root = false,
			ignore_list = {},
		},

		-- Git integration
		git = {
			enable = true,
			ignore = false,
			show_on_dirs = true,
			show_on_open_dirs = true,
			timeout = 400,
		},

		-- Filters
		filters = {
			dotfiles = false,
			git_clean = false,
			no_buffer = false,
			custom = { ".DS_Store", ".git", "node_modules", ".cache" },
			exclude = {},
		},

		-- Filesystem watchers
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
			ignore_dirs = {},
		},

		-- Diagnostics
		diagnostics = {
			enable = true,
			show_on_dirs = true,
			show_on_open_dirs = true,
			debounce_delay = 50,
			severity = {
				min = vim.diagnostic.severity.HINT,
				max = vim.diagnostic.severity.ERROR,
			},
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
	}

	-- Merge user config with defaults
	local utils = require("nvim.lib.utils")
	local final_config = utils.merge_config(default_config, config)

	-- Setup nvim-tree
	nvim_tree.setup(final_config)

	return true
end

return M
