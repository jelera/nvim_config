--[[
TreeSitter Module Plugins
=========================

Plugin specifications for TreeSitter and related plugins.
Include these in your lazy.nvim setup:

```lua
local treesitter_plugins = require('modules.treesitter.plugins')
require('lazy').setup(treesitter_plugins)
```

Or merge with your own plugins:
```lua
local ts_plugins = require('modules.treesitter.plugins')
require('lazy').setup(vim.list_extend(ts_plugins, {
  -- Your custom plugins here
}))
```
--]]

return {
	-- TreeSitter core
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = false, -- We'll configure it in modules.treesitter
	},

	-- TreeSitter text objects (advanced motions and selections)
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
}
