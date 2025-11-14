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

---Setup statusline
---@param config table|nil Configuration
---@return boolean success
local function setup_statusline(config)
	config = config or {}

	local ok, lualine = pcall(require, "lualine")
	if not ok then
		vim.notify("lualine not found", vim.log.levels.WARN)
		return false
	end

	-- Custom component to show diagnostic message on current line
	local function current_line_diagnostic()
		local bufnr = vim.api.nvim_get_current_buf()
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

		if #diagnostics == 0 then
			return ""
		end

		-- Get the highest severity diagnostic for this line
		table.sort(diagnostics, function(a, b)
			return a.severity < b.severity
		end)

		local diag = diagnostics[1]
		local icons = {
			[vim.diagnostic.severity.ERROR] = "❌",
			[vim.diagnostic.severity.WARN] = "⚠️",
			[vim.diagnostic.severity.HINT] = "💡",
			[vim.diagnostic.severity.INFO] = "ℹ️",
		}

		local icon = icons[diag.severity] or ""
		local message = diag.message:gsub("\n", " "):gsub("%s+", " ")
		return string.format("%s %s", icon, message)
	end

	lualine.setup({
		options = {
			theme = config.theme or "gruvbox",
			icons_enabled = true,
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = {
				"filename",
				{
					current_line_diagnostic,
					color = { fg = "#ff9e64" },
				},
			},
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})

	return true
end

---Setup indent guides
---@return boolean success
local function setup_indent()
	local ok, ibl = pcall(require, "ibl")
	if not ok then
		vim.notify("indent-blankline not found", vim.log.levels.WARN)
		return false
	end

	ibl.setup({
		indent = {
			char = "│",
		},
		scope = {
			enabled = true,
			show_start = false,
			show_end = false,
		},
	})

	return true
end

---Setup notifications
---@return boolean success
local function setup_notifications()
	local ok, notify = pcall(require, "notify")
	if not ok then
		vim.notify("nvim-notify not found", vim.log.levels.WARN)
		return false
	end

	-- Replace vim.notify with nvim-notify
	vim.notify = notify

	notify.setup({
		stages = "fade",
		timeout = 3000,
		background_colour = "#000000",
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

	local results = {
		colorscheme = setup_colorscheme(config.colorscheme),
		icons = setup_icons(),
		statusline = setup_statusline(config.statusline),
		indent = setup_indent(),
		notifications = setup_notifications(),
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
