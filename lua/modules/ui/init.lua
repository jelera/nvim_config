--[[
UI Module
=========

Unified UI configuration for NeoVim.

Features:
- Colorscheme (gruvbox - Treesitter-compatible)
- Icons (nvim-web-devicons)
- Statusline (lualine)
- Indent guides (indent-blankline)
- Notifications (nvim-notify)

Dependencies:
All plugins should be installed via lazy.nvim.
See modules/ui/plugins.lua for the plugin list.

Usage:
```lua
local ui = require('modules.ui')

-- Setup with defaults
ui.setup()

-- Setup with custom config
ui.setup({
  colorscheme = {
    background = 'light', -- 'dark' or 'light'
  },
  statusline = {
    theme = 'gruvbox',
  },
})
```

API:
- setup(config) - Initialize all UI components
--]]

local M = {}

---Setup colorscheme
---@param config table|nil Configuration
---@return boolean success
local function setup_colorscheme(config)
	config = config or {}

	-- Set background
	vim.o.background = config.background or "dark"

	-- Apply gruvbox
	local ok = pcall(vim.cmd, "colorscheme gruvbox")
	if not ok then
		vim.notify("gruvbox colorscheme not found", vim.log.levels.WARN)
		return false
	end

	return true
end

---Setup icons
---@return boolean success
local function setup_icons()
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		vim.notify("nvim-web-devicons not found", vim.log.levels.WARN)
		return false
	end

	devicons.setup({
		default = true,
		color_icons = true,
	})

	return true
end

---Setup all UI components
---@param config table|nil Configuration options
---@param config.colorscheme table|nil Colorscheme configuration
---@param config.colorscheme.background string|nil Background: 'dark' or 'light' (default: 'dark')
---@param config.statusline table|nil Statusline configuration
---@param config.statusline.theme string|nil Lualine theme (default: 'gruvbox')
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Only setup eager-loaded components (colorscheme, icons)
	-- Other components (statusline, indent, notifications) are lazy-loaded
	-- and configure themselves when their events trigger
	local results = {
		colorscheme = setup_colorscheme(config.colorscheme),
		icons = setup_icons(),
	}

	-- Report any failures
	local failures = {}
	for component, success in pairs(results) do
		if not success then
			table.insert(failures, component)
		end
	end

	if #failures > 0 then
		vim.notify(
			"Some UI components failed to load: " .. table.concat(failures, ", "),
			vim.log.levels.WARN,
			{ title = "UI Module" }
		)
		return false
	end

	return true
end

return M
