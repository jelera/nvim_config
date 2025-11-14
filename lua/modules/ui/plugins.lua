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

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = false, -- We'll configure it in modules.ui.statusline
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = false, -- We'll configure it in modules.ui.indent
	},

	-- Notifications
	{
		"rcarriga/nvim-notify",
		config = false, -- We'll configure it in modules.ui.notifications
	},
}
