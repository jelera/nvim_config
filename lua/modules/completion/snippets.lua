--[[
LuaSnip Snippet Configuration
==============================

Configures LuaSnip snippet engine and loads friendly-snippets.

Features:
- LuaSnip basic setup
- friendly-snippets loading (VS Code-style snippets)
- Snippet expansion function for nvim-cmp integration

API:
- setup(config) - Initialize LuaSnip and load snippets
- get_luasnip() - Get LuaSnip instance after setup

Usage:
```lua
local snippets = require('modules.completion.snippets')
snippets.setup()
local luasnip = snippets.get_luasnip()
```
--]]

local M = {}

-- Store LuaSnip instance
local luasnip = nil

---Get LuaSnip instance
---@return table|nil luasnip LuaSnip module or nil if not loaded
function M.get_luasnip()
	return luasnip
end

---Setup LuaSnip and load snippets
---@param config? table Optional configuration (currently unused, for future extensibility)
---@return boolean success Whether setup succeeded
function M.setup(_config)
	_config = _config or {}

	-- Load LuaSnip
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		vim.notify("LuaSnip not found. Snippets disabled.", vim.log.levels.WARN)
		return false
	end

	luasnip = ls

	-- Load friendly-snippets (VS Code-style snippets)
	local loader_ok, loader = pcall(require, "luasnip.loaders.from_vscode")
	if not loader_ok then
		vim.notify("friendly-snippets loader not found.", vim.log.levels.WARN)
		return false
	end

	-- Lazy load VS Code-style snippets
	loader.lazy_load()

	return true
end

return M
