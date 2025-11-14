--[[
Core Options Module
===================

Manages all vim options (vim.opt, vim.g, vim.o) in a structured, testable way.

Features:
- Organized option categories (general, UI, editing, search, performance, files, providers)
- User configuration override support
- Validation and error handling
- Easy enable/disable

Dependencies:
- nvim.lib.utils (for deep_merge)

Usage:
```lua
local options = require('modules.core.options')

-- Use defaults
options.setup()

-- Override defaults
options.setup({
  ui = {
    number = false,
    relativenumber = false,
  },
  editing = {
    shiftwidth = 4,
    tabstop = 4,
  },
})
```

API:
- setup(config) - Initialize with config (merges with defaults)
- get_defaults() - Get default option values
- apply(options) - Apply options to vim
--]]

local utils = require("nvim.lib.utils")

local M = {}

---Get default option values organized by category
---@return table defaults Default options by category
function M.get_defaults()
	return {
		-- General Vim Settings
		general = {
			mouse = "a", -- Enable mouse support in all modes
			encoding = "utf-8", -- Set encoding
			clipboard = "unnamedplus", -- Use system clipboard
		},

		-- UI/Visual Settings
		ui = {
			number = true, -- Show line numbers
			relativenumber = true, -- Show relative line numbers
			signcolumn = "yes", -- Always show sign column
			colorcolumn = "80", -- Show column at 80 chars
			cursorline = true, -- Highlight current line
			wrap = false, -- Don't wrap lines
			scrolloff = 8, -- Keep 8 lines above/below cursor
			sidescrolloff = 8, -- Keep 8 columns left/right of cursor
			termguicolors = true, -- Enable 24-bit RGB colors
			showmode = false, -- Don't show mode (shown in statusline)
		},

		-- Editing Behavior
		editing = {
			expandtab = true, -- Use spaces instead of tabs
			shiftwidth = 2, -- Indent with 2 spaces
			tabstop = 2, -- Tab = 2 spaces
			softtabstop = 2, -- Backspace removes 2 spaces
			autoindent = true, -- Auto-indent new lines
			smartindent = true, -- Smart auto-indenting
			breakindent = true, -- Wrapped lines continue visually indented
			splitright = true, -- Vertical splits go right
			splitbelow = true, -- Horizontal splits go below
			completeopt = "menu,menuone,noselect", -- Completion options
		},

		-- Search Settings
		search = {
			ignorecase = true, -- Ignore case in search
			smartcase = true, -- Case-sensitive if uppercase in search
			hlsearch = true, -- Highlight search results
			incsearch = true, -- Show matches as you type
		},

		-- Performance Settings
		performance = {
			updatetime = 300, -- Faster completion (default 4000ms)
			timeoutlen = 500, -- Time to wait for mapped sequence
			lazyredraw = true, -- Don't redraw during macros
		},

		-- File Settings (backup, swap, undo)
		files = {
			backup = false, -- Don't create backup files
			writebackup = false, -- Don't backup before overwriting
			swapfile = false, -- Don't use swap files
			undofile = true, -- Enable persistent undo
		},

		-- Provider Settings (disable unused providers)
		providers = {
			loaded_perl_provider = 0, -- Disable perl provider
			loaded_node_provider = 1, -- Enable node provider (for plugins)
			loaded_python3_provider = 1, -- Enable python3 provider
			loaded_ruby_provider = 1, -- Enable ruby provider
		},
	}
end

---Apply options to vim
---@param opts table Options organized by category
---@return boolean success Whether options were applied successfully
function M.apply(opts)
	if not opts then
		return true
	end

	local success, err = pcall(function()
		-- Iterate through each category
		for category, options in pairs(opts) do
			if type(options) == "table" then
				-- Providers use vim.g (global variables)
				if category == "providers" then
					for option_name, option_value in pairs(options) do
						vim.g[option_name] = option_value
					end
				else
					-- All other options use vim.opt
					for option_name, option_value in pairs(options) do
						vim.opt[option_name] = option_value
					end
				end
			end
		end
	end)

	if not success then
		vim.notify("Failed to apply options: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	return true
end

---Setup options with optional user configuration
---Merges user config with defaults and applies to vim
---@param user_config? table User configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
	user_config = user_config or {}

	-- Get defaults
	local defaults = M.get_defaults()

	-- Merge user config with defaults
	local final_config = utils.deep_merge(defaults, user_config)

	-- Apply the merged configuration
	local success = M.apply(final_config)

	if not success then
		vim.notify("Options setup failed", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
