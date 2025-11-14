--[[
Core Module Orchestrator
=========================

Coordinates initialization of all core vim configuration modules.

This module provides a single entry point to initialize all core functionality:
- Options (vim settings)
- Keymaps (key bindings)
- Autocommands (event handlers)
- Commands (user commands)

Features:
- Single setup() call initializes all core modules
- User configuration override support for each sub-module
- Error handling and reporting
- Module exposure for direct access

Usage:
```lua
local core = require('modules.core')

-- Initialize with defaults
core.setup()

-- Or customize each module
core.setup({
  options = {
    ui = { number = false },
  },
  keymaps = {
    general = {
      ['<leader>custom'] = { rhs = ':echo "custom"<CR>', mode = 'n' }
    }
  },
  autocmds = {
    custom_group = {
      { event = 'BufEnter', pattern = '*.lua', callback = function() end }
    }
  },
  commands = {
    CustomCommand = { callback = function() end, opts = {} }
  }
})

-- Or access modules directly
core.options.setup({ ui = { number = false } })
core.keymaps.setup({ ... })
```

API:
- setup(config) - Initialize all core modules with optional config
- options - Direct access to options module
- keymaps - Direct access to keymaps module
- autocmds - Direct access to autocmds module
- commands - Direct access to commands module
--]]

local M = {}

-- Load all core modules
M.options = require("modules.core.options")
M.keymaps = require("modules.core.keymaps")
M.autocmds = require("modules.core.autocmds")
M.commands = require("modules.core.commands")

---Setup all core modules with optional configuration
---Initializes modules in order: options, keymaps, autocmds, commands
---@param config? table Optional configuration for each module
---@param config.options? table Configuration for options module
---@param config.keymaps? table Configuration for keymaps module
---@param config.autocmds? table Configuration for autocmds module
---@param config.commands? table Configuration for commands module
---@return boolean success Whether all modules were initialized successfully
function M.setup(config)
	config = config or {}

	-- Setup options first (vim settings)
	local options_success = M.options.setup(config.options)
	if not options_success then
		vim.notify("Core module setup failed: options", vim.log.levels.ERROR)
		return false
	end

	-- Setup keymaps (key bindings)
	local keymaps_success = M.keymaps.setup(config.keymaps)
	if not keymaps_success then
		vim.notify("Core module setup failed: keymaps", vim.log.levels.ERROR)
		return false
	end

	-- Setup autocommands (event handlers)
	local autocmds_success = M.autocmds.setup(config.autocmds)
	if not autocmds_success then
		vim.notify("Core module setup failed: autocmds", vim.log.levels.ERROR)
		return false
	end

	-- Setup commands (user commands)
	local commands_success = M.commands.setup(config.commands)
	if not commands_success then
		vim.notify("Core module setup failed: commands", vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
