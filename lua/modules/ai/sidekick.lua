--[[
Sidekick.nvim Configuration
============================

Configures sidekick.nvim for AI assistance.

Features:
- Copilot NES: Next Edit Suggestions for multi-line refactorings
- AI Terminal: Built-in terminal for Claude, Gemini, Grok, etc.
- Uses sidekick.nvim's excellent defaults

Dependencies:
- folke/sidekick.nvim

API:
- setup(config) - Configure sidekick.nvim
--]]

local M = {}

---Default configuration for sidekick
local default_config = {
  -- NES (Next Edit Suggestions) configuration
  nes = {
    enabled = true,
  },
  -- AI Terminal configuration
  terminal = {
    enabled = true,
    default_tool = 'claude', -- Default AI tool (claude, gemini, grok, etc.)
  },
  -- AI Tools configuration (optional overrides)
  tools = {},
}

---Setup sidekick with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load sidekick plugin
  local ok, sidekick = pcall(require, 'sidekick')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Build sidekick config (use plugin's defaults for most things)
  local sidekick_config = {}

  -- Configure NES if specified
  if merged_config.nes then
    sidekick_config.nes = merged_config.nes
  end

  -- Configure terminal if specified
  if merged_config.terminal then
    sidekick_config.terminal = merged_config.terminal
  end

  -- Configure custom tools if specified
  if merged_config.tools and next(merged_config.tools) then
    sidekick_config.tools = merged_config.tools
  end

  -- Setup sidekick (use defaults if config is empty)
  local setup_ok, err = pcall(sidekick.setup, sidekick_config)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup sidekick: %s', err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

return M
