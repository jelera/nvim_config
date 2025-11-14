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
		config = false, -- We'll configure it in modules.ui.colorscheme
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
			local ok, module = pcall(require, "modules.ui")
			if ok then
				-- Call internal setup function for statusline only
				pcall(function()
					local lualine = require("lualine")
					lualine.setup({
						options = {
							theme = "gruvbox",
							icons_enabled = true,
							component_separators = { left = "", right = "" },
							section_separators = { left = "", right = "" },
						},
					})
				end)
			end
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
