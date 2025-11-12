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
			mousehide = true, -- Hide mouse cursor while typing
			encoding = "utf-8", -- Set encoding
			fileencoding = "utf-8", -- File encoding
			fileformats = "unix,mac,dos", -- Support all line endings
			fileformat = "unix", -- Prefer unix line endings
			clipboard = "unnamedplus", -- Use system clipboard
			hidden = true, -- Allow switching buffers without saving
			title = true, -- Set window title to filename
			modeline = false, -- Disable modeline for security
			confirm = true, -- Confirm before closing unsaved buffers
			autoread = true, -- Reload file if changed outside vim
			history = 1000, -- Command history size
			undolevels = 1000, -- Undo levels
			report = 0, -- Always report changed lines
		},

		-- UI/Visual Settings
		ui = {
			number = true, -- Show line numbers
			relativenumber = true, -- Show relative line numbers
			numberwidth = 4, -- Width of line number column
			signcolumn = "yes", -- Always show sign column
			colorcolumn = "80", -- Show column at 80 chars
			cursorline = true, -- Highlight current line
			wrap = true, -- Wrap lines (soft wrap)
			linebreak = true, -- Break at word boundaries
			showbreak = "↪⋯⋯", -- String to show at start of wrapped lines
			scrolloff = 5, -- Keep 5 lines above/below cursor
			sidescrolloff = 20, -- Keep 20 columns left/right of cursor
			termguicolors = true, -- Enable 24-bit RGB colors
			showmode = false, -- Don't show mode (shown in statusline)
			showcmd = true, -- Show command in bottom bar
			showmatch = true, -- Highlight matching brackets
			ruler = true, -- Show cursor position in status line
			laststatus = 2, -- Always show status line
			cmdheight = 2, -- Command line height
			pumheight = 15, -- Popup menu height
			fillchars = { vert = "║" }, -- Vertical split character
			listchars = { tab = "↹ ", eol = "¬", trail = "⋅", extends = "❯", precedes = "❮" }, -- Show invisible characters
			list = false, -- Don't show listchars by default
			foldcolumn = "0", -- Don't show fold column (treesitter folding)
		},

		-- Editing Behavior
		editing = {
			expandtab = true, -- Use spaces instead of tabs
			shiftwidth = 2, -- Indent with 2 spaces
			tabstop = 2, -- Tab = 2 spaces
			softtabstop = 2, -- Backspace removes 2 spaces
			autoindent = true, -- Auto-indent new lines
			cindent = true, -- C-style indenting
			smartindent = true, -- Smart auto-indenting
			smarttab = true, -- Smart tab behavior
			shiftround = true, -- Round indent to multiple of shiftwidth
			breakindent = true, -- Wrapped lines continue visually indented
			splitright = true, -- Vertical splits go right
			splitbelow = true, -- Horizontal splits go below
			completeopt = "menu,menuone,preview,noselect,noinsert", -- Completion options
			matchpairs = "(:),{:},[:],<:>", -- Matching pairs (including < and > for HTML)
			iskeyword = "@,48-57,_,192-255,$,#,%", -- Keyword characters
			backspace = "indent,eol,start", -- Backspace behavior
			textwidth = 79, -- Line width for formatting
			formatoptions = "croqwanl1", -- Auto-formatting options
			startofline = false, -- Keep cursor column when moving
			diffopt = "internal,filler,closeoff,context:3", -- Diff options
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
			updatetime = 100, -- Faster completion and git gutter updates
			timeoutlen = 500, -- Time to wait for mapped sequence
			lazyredraw = true, -- Don't redraw during macros
		},

		-- Wildmenu (Command-line Completion)
		wildmenu = {
			wildmenu = true, -- Enable wildmenu
			wildmode = "full", -- Complete to next full match
			wildignore = ".svn,CVS,.git,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp", -- Ignore patterns
		},

		-- File Settings (backup, swap, undo)
		files = {
			backup = true, -- Create backup files
			writebackup = true, -- Backup before overwriting
			backupdir = ".backup/,~/.backup/,/tmp//", -- Backup directories
			swapfile = true, -- Use swap files
			directory = ".swp/,~/.swp/,/tmp//", -- Swap file directories
			undofile = true, -- Enable persistent undo
			undodir = ".undo/,~/.undo/,/tmp//", -- Undo file directories
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

---Ensure required directories exist (backup, swap, undo)
---Creates directories if they don't exist
local function ensure_directories()
	local dirs = {
		vim.fn.expand("~/.backup"),
		vim.fn.expand("~/.swp"),
		vim.fn.expand("~/.undo"),
	}

	for _, dir in ipairs(dirs) do
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end
end

---Setup options with optional user configuration
---Merges user config with defaults and applies to vim
---@param user_config? table User configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
	user_config = user_config or {}

	-- Ensure backup/swap/undo directories exist
	ensure_directories()

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
