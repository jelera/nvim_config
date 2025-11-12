--[[
Core Commands Module
====================

Manages user command registration in a structured, testable way.

Features:
- User command registration
- User configuration override support
- Default useful commands
- Support for all command options (bang, range, nargs, etc.)
- Error handling

Dependencies:
- nvim.lib.utils (for deep_merge)

Usage:
```lua
local commands = require('modules.core.commands')

-- Use defaults
commands.setup()

-- Add custom commands
commands.setup({
  CustomCommand = {
    callback = function(opts)
      print('Custom command called with args:', opts.args)
    end,
    opts = {
      nargs = '*',
      desc = 'My custom command'
    }
  }
})

-- Register single command
commands.register('TestCommand', function(opts)
  print('Test:', opts.args)
end, { nargs = '*', desc = 'Test command' })
```

API:
- setup(config) - Initialize with config (merges with defaults)
- get_defaults() - Get default command definitions
- register(name, callback, opts) - Register a single command
- register_all(commands_config) - Register all commands from config
--]]

local utils = require('nvim.lib.utils')

local M = {}

---Get default command definitions
---@return table defaults Default commands
function M.get_defaults()
  return {
    -- Format current buffer
    Format = {
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
      opts = {
        desc = 'Format current buffer with LSP',
      },
    },

    -- Delete buffer without closing window
    BufDelete = {
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local win_count = 0

        -- Count windows showing this buffer
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            win_count = win_count + 1
          end
        end

        -- If buffer is shown in multiple windows, just switch to another buffer
        if win_count > 1 then
          vim.cmd('bprevious')
        end

        -- Delete the buffer
        vim.cmd('bdelete ' .. buf)
      end,
      opts = {
        desc = 'Delete buffer without closing window',
      },
    },

    -- Reload configuration
    ReloadConfig = {
      callback = function()
        -- Clear all module caches
        for k, _ in pairs(package.loaded) do
          if k:match('^nvim%.') or k:match('^modules%.') or k:match('^config%.') then
            package.loaded[k] = nil
          end
        end

        -- Reload init.lua
        vim.cmd('source ~/.config/nvim/init.lua')
        vim.notify('Configuration reloaded', vim.log.levels.INFO)
      end,
      opts = {
        desc = 'Reload NeoVim configuration',
      },
    },
  }
end

---Register a single user command
---@param name string The command name (must start with uppercase)
---@param callback string|function The command implementation
---@param opts? table Optional command options (bang, range, nargs, desc, etc.)
---@return boolean success Whether command was registered successfully
function M.register(name, callback, opts)
  opts = opts or {}

  local success, err = pcall(function()
    vim.api.nvim_create_user_command(name, callback, opts)
  end)

  if not success then
    vim.notify(
      'Failed to register command: ' .. name .. ' - ' .. tostring(err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

---Register all commands from configuration
---@param commands_config table Commands to register
---@return boolean success Whether all commands were registered successfully
function M.register_all(commands_config)
  if not commands_config then
    return true
  end

  local success, err = pcall(function()
    -- Iterate through each command
    for name, cmd_def in pairs(commands_config) do
      if type(cmd_def) == 'table' then
        local callback = cmd_def.callback
        local opts = cmd_def.opts or {}

        local register_success = M.register(name, callback, opts)
        if not register_success then
          error('Failed to register command: ' .. name)
        end
      end
    end
  end)

  if not success then
    vim.notify('Failed to register commands: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

---Setup commands with optional user configuration
---Merges user config with defaults and registers all commands
---@param user_config? table User command configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
  user_config = user_config or {}

  -- Get defaults
  local defaults = M.get_defaults()

  -- Merge user config with defaults (user config overrides)
  local final_config = utils.deep_merge(defaults, user_config)

  -- Register all commands
  local success = M.register_all(final_config)

  if not success then
    vim.notify('Commands setup failed', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
