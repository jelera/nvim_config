--[[
Completion Module
=================

Orchestrates nvim-cmp completion and LuaSnip snippet configuration.

This module coordinates:
- LuaSnip snippet engine setup
- nvim-cmp completion engine setup
- Integration between completion and snippets

Features:
- Intelligent completion with multiple sources (LSP, snippets, buffer, path)
- VS Code-style snippets via friendly-snippets
- Super-tab keymaps for completion navigation
- Command-line completion

API:
- setup(config) - Initialize completion system

Usage:
```lua
local completion = require('modules.completion')
completion.setup()
```
--]]

local M = {}

---Setup completion system
---@param config? table Optional configuration
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Setup snippets first (required for completion)
	local snippets = require("modules.completion.snippets")
	local snippets_ok = snippets.setup(config)
	if not snippets_ok then
		vim.notify("Failed to setup snippets. Completion may not work properly.", vim.log.levels.ERROR)
		return false
	end

	-- Setup completion
	local completion = require("modules.completion.completion")
	local completion_ok = completion.setup(config)
	if not completion_ok then
		vim.notify("Failed to setup completion.", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
