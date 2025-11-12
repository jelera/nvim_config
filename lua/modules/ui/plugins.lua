--[[
UI Module Plugins
=================

Plugin specifications for all UI modules.
Include these in your lazy.nvim setup:

```lua
local ui_plugins = require('modules.ui.plugins')
require('lazy').setup(ui_plugins)
```

Or merge with your own plugins:
```lua
local ui_plugins = require('modules.ui.plugins')
require('lazy').setup(vim.list_extend(ui_plugins, {
  -- Your custom plugins here
}))
```
--]]

return {
	-- Colorscheme (Treesitter-compatible gruvbox)
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000, -- Load colorscheme first
		lazy = false, -- Load immediately, not lazy
		config = function()
			-- Apply colorscheme immediately to prevent flash/delay
			vim.o.background = "dark"
			vim.cmd.colorscheme("gruvbox")
		end,
	},

	-- Icons
	{
		"nvim-tree/nvim-web-devicons",
		config = false, -- We'll configure it in modules.ui.icons
	},

	-- Statusline (defer to UIEnter for performance)
	{
		"nvim-lualine/lualine.nvim",
		event = "UIEnter", -- Load after UI is ready
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Auto-configure when plugin loads
			pcall(function()
				local lualine = require("lualine")

				-- Custom component to show current line diagnostic message
				local function diagnostic_message()
					local bufnr = vim.api.nvim_get_current_buf()
					local line = vim.api.nvim_win_get_cursor(0)[1] - 1
					local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

					if #diagnostics == 0 then
						return ""
					end

					-- Get the first (most severe) diagnostic
					local diag = diagnostics[1]
					local message = diag.message or ""

					-- Truncate long messages
					if #message > 80 then
						message = message:sub(1, 77) .. "..."
					end

					-- Add severity icon
					local icons = {
						[vim.diagnostic.severity.ERROR] = "❌",
						[vim.diagnostic.severity.WARN] = "⚠️",
						[vim.diagnostic.severity.HINT] = "💡",
						[vim.diagnostic.severity.INFO] = "ℹ️",
					}
					local icon = icons[diag.severity] or ""

					return string.format("%s %s", icon, message)
				end

				lualine.setup({
					options = {
						theme = "gruvbox",
						icons_enabled = true,
						component_separators = { left = "", right = "" },
						section_separators = { left = "", right = "" },
					},
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "branch", "diff" },
						lualine_c = {
							"filename",
							{
								"diagnostics",
								sources = { "nvim_diagnostic" },
								symbols = { error = "❌ ", warn = "⚠️  ", info = "ℹ️  ", hint = "💡 " },
								diagnostics_color = {
									error = { fg = "#fb4934" }, -- gruvbox red
									warn = { fg = "#fabd2f" }, -- gruvbox yellow
									info = { fg = "#83a598" }, -- gruvbox blue
									hint = { fg = "#8ec07c" }, -- gruvbox aqua
								},
							},
						},
						lualine_x = {
							{
								diagnostic_message,
								color = { fg = "#fb4934" }, -- gruvbox red for visibility
							},
							"encoding",
							"fileformat",
							"filetype",
						},
						lualine_y = { "progress" },
						lualine_z = { "location" },
					},
				})
			end)
		end,
	},

	-- Indent guides (defer to BufReadPost for performance)
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufReadPost", -- Load after buffer is read
		main = "ibl",
		config = function()
			-- Auto-configure when plugin loads
			local ok, ibl = pcall(require, "ibl")
			if ok then
				ibl.setup({
					indent = { char = "│" },
					scope = {
						enabled = true,
						show_start = false,
						show_end = false,
					},
				})
			end
		end,
	},

	-- Notifications (defer to VeryLazy for performance)
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy", -- Load when idle
		config = function()
			-- Auto-configure when plugin loads
			local ok, notify = pcall(require, "notify")
			if ok then
				vim.notify = notify
				notify.setup({
					stages = "fade",
					timeout = 3000,
					background_colour = "#000000",
				})
			end
		end,
	},
}
