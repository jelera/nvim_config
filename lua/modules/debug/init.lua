--[[
Debug Module
============

Orchestrates debugging support via nvim-dap, dap-ui, and language adapters.

Features:
- Core DAP: Breakpoints, stepping, variable inspection
- DAP UI: Visual debugging interface with scopes, watches, stack traces
- Language Adapters: JS/TS, Python, Ruby, Lua
- Lazy Loading: Adapters load automatically when opening files of the corresponding filetype
- Performance: No adapter warnings on startup, only loads what's needed

Submodules:
- dap.lua - Core nvim-dap configuration
- ui.lua - DAP UI setup
- adapters.lua - Language adapter configuration
- keymaps.lua - Debug key mappings

Dependencies:
- mfussenegger/nvim-dap
- rcarriga/nvim-dap-ui
- theHamsta/nvim-dap-virtual-text

Usage:
```lua
local debug = require('modules.debug')
debug.setup({
  dap = {
    virtual_text = true
  },
  ui = {
    floating = { border = 'rounded' }
  },
  adapters = {
    auto_install = { 'javascript', 'python' }
  }
})
```

API:
- setup(config) - Initialize debug module
--]]

local M = {}

---Setup the debug module
---@param config table|nil Optional configuration
---@param config.dap table|nil Core DAP configuration overrides
---@param config.ui table|nil DAP UI configuration overrides
---@param config.adapters table|nil Adapter configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Setup core DAP
	local dap = require("modules.debug.dap")
	local dap_ok = dap.setup(config.dap or {})
	if not dap_ok then
		vim.notify("Failed to setup nvim-dap. Debugging disabled.", vim.log.levels.WARN)
	end

	-- Setup DAP UI
	local ui = require("modules.debug.ui")
	local ui_ok = ui.setup(config.ui or {})
	if not ui_ok then
		vim.notify("Failed to setup dap-ui. Debug UI disabled.", vim.log.levels.WARN)
	end

	-- Setup language adapters
	local adapters = require("modules.debug.adapters")
	local adapters_ok = adapters.setup(config.adapters or {})
	if not adapters_ok then
		vim.notify("Failed to setup debug adapters. Language debugging disabled.", vim.log.levels.WARN)
	end

	-- Setup keymaps (after components are initialized)
	local keymaps = require("modules.debug.keymaps")
	local keymaps_ok = keymaps.setup()
	if not keymaps_ok then
		vim.notify("Failed to setup debug keymaps.", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
