--[[
Core Autocmds Module
====================

Manages autocommand registration in a structured, testable way.

Features:
- Organized autocmd groups
- User configuration override support
- Default sensible autocommands
- Support for all vim events
- Error handling

Dependencies:
- nvim.lib.utils (for deep_merge)

Usage:
```lua
local autocmds = require('modules.core.autocmds')

-- Use defaults
autocmds.setup()

-- Add custom autocmds
autocmds.setup({
  custom_group = {
    {
      event = 'BufEnter',
      pattern = '*.lua',
      callback = function()
        print('Lua file opened')
      end,
      desc = 'Notify on Lua file open'
    }
  }
})

-- Create augroup
local group_id = autocmds.create_augroup('my_group', { clear = true })

-- Register single autocmd
autocmds.register('BufEnter', {
  pattern = '*.lua',
  group = group_id,
  callback = function() print('test') end
})
```

API:
- setup(config) - Initialize with config (merges with defaults)
- get_defaults() - Get default autocmd definitions
- create_augroup(name, opts) - Create an augroup
- register(event, opts) - Register a single autocommand
- register_all(autocmds_config) - Register all autocmds from config
--]]

local utils = require('nvim.lib.utils')

local M = {}

---Get default autocommand definitions organized by group
---@return table defaults Default autocmds by group
function M.get_defaults()
  return {
    -- General autocommands
    general = {
      {
        event = 'FileType',
        pattern = 'qf,help,man',
        callback = function()
          -- Close with 'q' for quickfix, help, and man pages
          vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, silent = true })
        end,
        desc = 'Close special buffers with q',
      },
      {
        event = 'BufReadPost',
        pattern = '*',
        callback = function()
          -- Return to last edit position when opening files
          local mark = vim.api.nvim_buf_get_mark(0, '"')
          local lcount = vim.api.nvim_buf_line_count(0)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end,
        desc = 'Restore cursor position',
      },
    },

    -- Highlight on yank
    highlight_yank = {
      {
        event = 'TextYankPost',
        pattern = '*',
        callback = function()
          vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
        end,
        desc = 'Highlight on yank',
      },
    },

    -- File type specific settings
    file_types = {
      {
        event = 'FileType',
        pattern = 'lua',
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
        end,
        desc = 'Lua indent settings',
      },
      {
        event = 'FileType',
        pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
        end,
        desc = 'JS/TS indent settings',
      },
      {
        event = 'FileType',
        pattern = { 'python' },
        callback = function()
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
        end,
        desc = 'Python indent settings',
      },
    },
  }
end

---Create an autocommand group
---@param name string The group name
---@param opts? table Optional group options (default: { clear = true })
---@return number|nil group_id The group ID, or nil on error
function M.create_augroup(name, opts)
  opts = opts or {}

  -- Default to clearing the group
  local default_opts = {
    clear = true,
  }

  local final_opts = vim.tbl_extend('force', default_opts, opts)

  local success, result = pcall(function()
    return vim.api.nvim_create_augroup(name, final_opts)
  end)

  if not success then
    vim.notify(
      'Failed to create augroup: ' .. name .. ' - ' .. tostring(result),
      vim.log.levels.ERROR
    )
    return nil
  end

  return result
end

---Register a single autocommand
---@param event string|table The event(s) to trigger on
---@param opts table Autocommand options (pattern, callback/command, group, desc, etc.)
---@return number|nil autocmd_id The autocmd ID, or nil on error
function M.register(event, opts)
  local success, result = pcall(function()
    return vim.api.nvim_create_autocmd(event, opts)
  end)

  if not success then
    local event_str = type(event) == 'table' and table.concat(event, ',') or event
    vim.notify(
      'Failed to register autocmd for event: ' .. event_str .. ' - ' .. tostring(result),
      vim.log.levels.ERROR
    )
    return nil
  end

  return result
end

---Register all autocommands from configuration
---Each group in the config becomes an augroup with its autocmds
---@param autocmds_config table Autocmds organized by group
---@return boolean success Whether all autocmds were registered successfully
function M.register_all(autocmds_config)
  if not autocmds_config then
    return true
  end

  local success, err = pcall(function()
    -- Iterate through each group
    for group_name, autocmds_list in pairs(autocmds_config) do
      if type(autocmds_list) == 'table' then
        -- Create augroup
        local group_id = M.create_augroup(group_name)
        if not group_id then
          error('Failed to create augroup: ' .. group_name)
        end

        -- Register each autocmd in the group
        for _, autocmd_def in ipairs(autocmds_list) do
          local event = autocmd_def.event
          local opts = {}

          -- Copy all opts except 'event' (event is passed separately)
          for key, value in pairs(autocmd_def) do
            if key ~= 'event' then
              opts[key] = value
            end
          end

          -- Set the group
          opts.group = group_id

          local autocmd_id = M.register(event, opts)
          if not autocmd_id then
            error('Failed to register autocmd in group: ' .. group_name)
          end
        end
      end
    end
  end)

  if not success then
    vim.notify('Failed to register autocmds: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

---Setup autocommands with optional user configuration
---Merges user config with defaults and registers all autocmds
---@param user_config? table User autocmd configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
  user_config = user_config or {}

  -- Get defaults
  local defaults = M.get_defaults()

  -- Merge user config with defaults (user config overrides)
  local final_config = utils.deep_merge(defaults, user_config)

  -- Register all autocmds
  local success = M.register_all(final_config)

  if not success then
    vim.notify('Autocmds setup failed', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
