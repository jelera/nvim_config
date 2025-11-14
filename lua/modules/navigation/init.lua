--[[
Navigation Module
=================

Orchestrates the navigation system including Telescope fuzzy finder,
nvim-tree file explorer, and all navigation keymaps.

This module replaces FZF and NERDTree from the original vim configuration.

Features:
- Telescope: Modern fuzzy finder and navigation tool (replaces FZF)
- Nvim-tree: File explorer sidebar (replaces NERDTree)
- Navigation keymaps: All navigation-related key bindings

Submodules:
- telescope.lua - Fuzzy finder configuration
- tree.lua - File explorer configuration
- keymaps.lua - Navigation key mappings

Key Mappings (preserved from FZF setup):
- <C-p>g: Find files
- <C-p>p: Git files
- <C-p>h: Recent files
- <C-p>b: Buffers
- <C-t>: Toggle file tree
- <C-B>t: Find current file in tree

Dependencies:
- nvim-telescope/telescope.nvim
- nvim-telescope/telescope-fzf-native.nvim (performance)
- nvim-tree/nvim-tree.lua
- nvim-tree/nvim-web-devicons

Usage:
```lua
local navigation = require('modules.navigation')
navigation.setup({
  telescope = {
    -- Telescope config overrides
  },
  tree = {
    -- Tree config overrides
  },
})
```

API:
- setup(config) - Initialize navigation system
--]]

local M = {}

---Setup the navigation module
---@param config table|nil Optional configuration
---@param config.telescope table|nil Telescope configuration overrides
---@param config.tree table|nil Tree configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Setup Telescope
	local telescope = require("modules.navigation.telescope")
	local telescope_ok = telescope.setup(config.telescope or {})
	if not telescope_ok then
		vim.notify("Failed to setup Telescope. Some navigation features disabled.", vim.log.levels.WARN)
	end

	-- Setup nvim-tree
	local tree = require("modules.navigation.tree")
	local tree_ok = tree.setup(config.tree or {})
	if not tree_ok then
		vim.notify("Failed to setup nvim-tree. File explorer disabled.", vim.log.levels.WARN)
	end

	-- Setup keymaps (after telescope and tree are initialized)
	local keymaps = require("modules.navigation.keymaps")
	local keymaps_ok = keymaps.setup()
	if not keymaps_ok then
		vim.notify("Failed to setup navigation keymaps.", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
