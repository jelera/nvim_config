--[[
NeoVim IDE Framework
====================

Main entry point for the NeoVim IDE framework.

This module provides a clean API for initializing the framework and
accessing core modules and libraries.

Usage:
  -- In your init.lua or init.vim:
  local nvim = require('nvim')

  -- Initialize with default config
  nvim.setup()

  -- Or customize lazy.nvim config
  nvim.setup({
    plugins = {
      -- Your plugins here
    },
    performance = {
      -- Performance settings
    }
  })

  -- Access core modules
  local event_bus = nvim.core.event_bus
  local plugin_system = nvim.core.plugin_system

  -- Access utility libraries
  local utils = nvim.lib.utils
  local validator = nvim.lib.validator
--]]

local M = {}

-- Version information (semantic versioning)
M.version = '0.1.0'

--[[
Initialize the framework

This is the main entry point that:
1. Installs lazy.nvim if not present
2. Sets up the plugin manager
3. Initializes the framework

@param config table: Optional configuration for lazy.nvim
  - plugins: Plugin specifications
  - performance: Performance settings
  - ui: UI customization
  - ... (any lazy.nvim config options)
@return boolean: true if initialization succeeded, false otherwise
--]]
function M.setup(config)
  config = config or {}

  -- Load setup module
  local setup = require('nvim.setup')

  -- Initialize framework
  local success, err = pcall(function()
    return setup.init(config)
  end)

  if not success then
    vim.notify('Framework initialization failed: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return err
end

--[[
Core modules

Provides direct access to core framework modules:
- module_loader: Dynamic module loading
- event_bus: Pub/sub event system
- plugin_system: Plugin management
- config_schema: Configuration validation
--]]
M.core = {
  module_loader = require('nvim.core.module_loader'),
  event_bus = require('nvim.core.event_bus'),
  plugin_system = require('nvim.core.plugin_system'),
  config_schema = require('nvim.core.config_schema'),
}

--[[
Utility libraries

Provides direct access to shared utility libraries:
- utils: Table utilities (deep_copy, deep_merge, is_array, etc.)
- validator: Type and schema validation
--]]
M.lib = {
  utils = require('nvim.lib.utils'),
  validator = require('nvim.lib.validator'),
}

return M
