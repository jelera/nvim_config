--[[
AI Module
=========

AI assistance via sidekick.nvim - unified Copilot NES and AI CLI terminal.

Features:
- Copilot NES: Multi-line refactorings and edit suggestions
- AI Terminal: Built-in terminal for Claude, Gemini, Grok, and more
- Unified interface: One plugin for all AI assistance

Submodules:
- sidekick.lua - Sidekick.nvim configuration
- keymaps.lua - AI key mappings

Dependencies:
- folke/sidekick.nvim

Usage:
```lua
local ai = require('modules.ai')
ai.setup({
  sidekick = {
    nes = { enabled = true },
    terminal = { enabled = true, default_tool = 'claude' }
  }
})
```

API:
- setup(config) - Initialize AI module
--]]

local M = {}

---Setup the AI module
---@param config table|nil Optional configuration
---@param config.sidekick table|nil Sidekick configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Setup sidekick
  local sidekick = require('modules.ai.sidekick')
  local sidekick_ok = sidekick.setup(config.sidekick or {})
  if not sidekick_ok then
    vim.notify('Failed to setup sidekick. AI features disabled.', vim.log.levels.WARN)
  end

  -- Setup keymaps (after sidekick is initialized)
  local keymaps = require('modules.ai.keymaps')
  local keymaps_ok = keymaps.setup()
  if not keymaps_ok then
    vim.notify('Failed to setup AI keymaps.', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
