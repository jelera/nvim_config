--[[
Telescope Module
================

Fuzzy finder and picker configuration using Telescope.
Replaces FZF from the original vim setup.

Features:
- Fast fuzzy finding with fzf-native sorter
- File, buffer, git, and grep pickers
- Customizable layout and mappings
- Project-wide search capabilities

Dependencies:
- telescope.nvim
- telescope-fzf-native.nvim
- plenary.nvim

Usage:
```lua
local telescope = require('modules.navigation.telescope')
telescope.setup({
  -- Optional config overrides
})
```

API:
- setup(config) - Initialize Telescope with configuration
- get_builtin() - Get telescope.builtin for custom picker usage
--]]

local M = {}

-- Private state
local telescope_builtin = nil

---Get telescope.builtin for custom picker usage
---@return table|nil builtin Telescope builtin pickers or nil
function M.get_builtin()
	return telescope_builtin
end

---Setup Telescope with configuration
---@param config table|nil Optional configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Load telescope
	local ok, telescope = pcall(require, "telescope")
	if not ok then
		vim.notify("Telescope not found. Navigation features disabled.", vim.log.levels.WARN)
		return false
	end

	-- Load telescope actions
	local actions_ok, _actions = pcall(require, "telescope.actions")
	if not actions_ok then
		vim.notify("Telescope actions not found.", vim.log.levels.WARN)
		return false
	end

	-- Load builtin pickers
	local builtin_ok, builtin = pcall(require, "telescope.builtin")
	if not builtin_ok then
		vim.notify("Telescope builtin not found.", vim.log.levels.WARN)
		return false
	end

	telescope_builtin = builtin

	-- Default configuration
	local default_config = {
		defaults = {
			-- Layout configuration (similar to FZF window layout)
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
					results_width = 0.8,
				},
				vertical = {
					mirror = false,
				},
				width = 0.87,
				height = 0.80,
				preview_cutoff = 120,
			},

			-- Sorting strategy
			sorting_strategy = "ascending",

			-- Appearance
			prompt_prefix = "🔍 ",
			selection_caret = "❯ ",
			entry_prefix = "  ",
			multi_icon = "+ ",

			-- File ignore patterns
			file_ignore_patterns = {
				"node_modules",
				".git/",
				"dist/",
				"build/",
				"target/",
				"%.lock",
			},

			-- Behavior
			set_env = { ["COLORTERM"] = "truecolor" },
			color_devicons = true,
			path_display = { "truncate" },

			-- Mappings (vim-style navigation)
			mappings = {
				i = {
					["<C-j>"] = function(bufnr)
						require("telescope.actions").move_selection_next(bufnr)
					end,
					["<C-k>"] = function(bufnr)
						require("telescope.actions").move_selection_previous(bufnr)
					end,
					["<C-q>"] = function(bufnr)
						local acts = require("telescope.actions")
						acts.send_selected_to_qflist(bufnr)
						acts.open_qflist(bufnr)
					end,
					["<C-a>"] = function(bufnr)
						require("telescope.actions").select_all(bufnr)
					end,
					["<Esc>"] = function(bufnr)
						require("telescope.actions").close(bufnr)
					end,
				},
				n = {
					["q"] = function(bufnr)
						require("telescope.actions").close(bufnr)
					end,
					["<C-q>"] = function(bufnr)
						local acts = require("telescope.actions")
						acts.send_selected_to_qflist(bufnr)
						acts.open_qflist(bufnr)
					end,
				},
			},
		},

		-- Picker-specific configurations
		pickers = {
			find_files = {
				hidden = true,
				follow = true,
			},
			git_files = {
				show_untracked = true,
			},
			buffers = {
				sort_mru = true,
				mappings = {
					i = {
						["<C-d>"] = function(bufnr)
							require("telescope.actions").delete_buffer(bufnr)
						end,
					},
				},
			},
			live_grep = {
				additional_args = function()
					return { "--hidden" }
				end,
			},
		},

		-- Extensions
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	}

	-- Merge user config with defaults
	local utils = require("nvim.lib.utils")
	local final_config = utils.merge_config(default_config, config)

	-- Setup telescope
	telescope.setup(final_config)

	-- Load fzf extension for better performance
	local fzf_ok = pcall(telescope.load_extension, "fzf")
	if not fzf_ok then
		vim.notify("telescope-fzf-native not found. Install for better performance.", vim.log.levels.WARN)
	end

	return true
end

return M
