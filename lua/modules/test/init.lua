--[[
Test Module
===========

Orchestrates testing support via neotest and language-specific test adapters.

Features:
- Neotest: Modern, async test runner with UI
- Language Adapters: JavaScript/TypeScript, Python, Ruby, Lua
- Auto-install: Common test adapters (Jest, Pytest) installed on setup
- Lazy-install: Language-specific adapters (RSpec, Busted) installed on filetype open
- Test keymaps: Run tests, toggle output, show coverage

Submodules:
- neotest.lua - Core neotest configuration
- adapters/javascript.lua - Jest/Vitest adapter
- adapters/python.lua - Pytest adapter
- adapters/ruby.lua - RSpec adapter
- adapters/lua.lua - Busted adapter
- keymaps.lua - Test key mappings

Dependencies:
- nvim-neotest/neotest
- Language-specific neotest adapters

Usage:
```lua
local test = require('modules.test')
test.setup({
  neotest = {
    adapters = { 'javascript', 'python', 'ruby', 'lua' }
  }
})
```

API:
- setup(config) - Initialize test module
--]]

local M = {}

---Setup the test module
---@param config table|nil Optional configuration
---@param config.neotest table|nil Neotest configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Setup neotest core
	local neotest = require("modules.test.neotest")
	local neotest_ok = neotest.setup(config.neotest or {})
	if not neotest_ok then
		vim.notify("Failed to setup neotest. Testing disabled.", vim.log.levels.WARN)
	end

	-- Setup keymaps (after neotest is initialized)
	local keymaps = require("modules.test.keymaps")
	local keymaps_ok = keymaps.setup()
	if not keymaps_ok then
		vim.notify("Failed to setup test keymaps.", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
