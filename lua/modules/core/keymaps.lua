--[[
Core Keymaps Module
===================

Manages keymap registration in a structured, testable way.

Features:
- Organized keymap categories (general, windows, buffers, editing)
- User configuration override support
- Default sensible keymaps
- Support for all vim modes (normal, insert, visual, etc.)
- Error handling

Dependencies:
- nvim.lib.utils (for deep_merge)

Usage:
```lua
local keymaps = require('modules.core.keymaps')

-- Use defaults
keymaps.setup()

-- Add custom keymaps
keymaps.setup({
  general = {
    ['<leader>custom'] = {
      rhs = ':echo "custom"<CR>',
      mode = 'n',
      opts = { desc = 'Custom keymap' }
    }
  }
})

-- Register single keymap
keymaps.register('n', '<leader>t', ':echo "test"<CR>', { desc = 'Test' })
```

API:
- setup(config) - Initialize with config (merges with defaults)
- get_defaults() - Get default keymap definitions
- register(mode, lhs, rhs, opts) - Register a single keymap
- register_all(keymaps_config) - Register all keymaps from config
--]]

local utils = require('nvim.lib.utils')

local M = {}

---Get default keymap definitions organized by category
---@return table defaults Default keymaps by category
function M.get_defaults()
  return {
    -- General Keymaps
    general = {
      -- Clear search highlighting
      ['<leader><space>'] = {
        rhs = ':noh<CR>',
        mode = 'n',
        opts = { desc = 'Clear search highlighting' },
      },

      -- Save file
      ['<leader>w'] = {
        rhs = ':w<CR>',
        mode = 'n',
        opts = { desc = 'Save file' },
      },

      -- Quit window
      ['<leader>q'] = {
        rhs = ':q<CR>',
        mode = 'n',
        opts = { desc = 'Quit window' },
      },

      -- Quit all
      ['<leader>Q'] = {
        rhs = ':qa<CR>',
        mode = 'n',
        opts = { desc = 'Quit all' },
      },
    },

    -- Window Navigation
    windows = {
      -- Navigate between windows
      ['<C-h>'] = {
        rhs = '<C-w>h',
        mode = 'n',
        opts = { desc = 'Move to left window' },
      },

      ['<C-j>'] = {
        rhs = '<C-w>j',
        mode = 'n',
        opts = { desc = 'Move to down window' },
      },

      ['<C-k>'] = {
        rhs = '<C-w>k',
        mode = 'n',
        opts = { desc = 'Move to up window' },
      },

      ['<C-l>'] = {
        rhs = '<C-w>l',
        mode = 'n',
        opts = { desc = 'Move to right window' },
      },

      -- Window splits
      ['<leader>sv'] = {
        rhs = '<C-w>v',
        mode = 'n',
        opts = { desc = 'Split vertically' },
      },

      ['<leader>sh'] = {
        rhs = '<C-w>s',
        mode = 'n',
        opts = { desc = 'Split horizontally' },
      },

      ['<leader>se'] = {
        rhs = '<C-w>=',
        mode = 'n',
        opts = { desc = 'Make splits equal size' },
      },

      ['<leader>sx'] = {
        rhs = ':close<CR>',
        mode = 'n',
        opts = { desc = 'Close current split' },
      },
    },

    -- Buffer Navigation
    buffers = {
      -- Next/previous buffer
      ['<S-l>'] = {
        rhs = ':bnext<CR>',
        mode = 'n',
        opts = { desc = 'Next buffer' },
      },

      ['<S-h>'] = {
        rhs = ':bprevious<CR>',
        mode = 'n',
        opts = { desc = 'Previous buffer' },
      },

      -- Close buffer
      ['<leader>bd'] = {
        rhs = ':bdelete<CR>',
        mode = 'n',
        opts = { desc = 'Delete buffer' },
      },
    },

    -- Editing Enhancements
    editing = {
      -- Stay in indent mode (visual)
      ['<'] = {
        rhs = '<gv',
        mode = 'v',
        opts = { desc = 'Indent left and reselect' },
      },

      ['>'] = {
        rhs = '>gv',
        mode = 'v',
        opts = { desc = 'Indent right and reselect' },
      },

      -- Move text up and down (visual)
      ['<A-j>'] = {
        rhs = ":m '>+1<CR>gv=gv",
        mode = 'v',
        opts = { desc = 'Move text down' },
      },

      ['<A-k>'] = {
        rhs = ":m '<-2<CR>gv=gv",
        mode = 'v',
        opts = { desc = 'Move text up' },
      },

      -- Better paste (don't yank replaced text)
      ['p'] = {
        rhs = '"_dP',
        mode = 'v',
        opts = { desc = 'Paste without yanking' },
      },
    },
  }
end

---Register a single keymap
---@param mode string|table The mode(s) for the keymap ('n', 'v', {'n', 'v'}, etc.)
---@param lhs string The left-hand side (key combination)
---@param rhs string|function The right-hand side (command or function)
---@param opts? table Optional keymap options
---@return boolean success Whether keymap was registered successfully
function M.register(mode, lhs, rhs, opts)
  opts = opts or {}

  -- Apply default options
  local default_opts = {
    noremap = true,
    silent = true,
  }

  -- Merge with user opts (user opts override defaults)
  local final_opts = vim.tbl_extend('force', default_opts, opts)

  local success, err = pcall(function()
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end)

  if not success then
    vim.notify(
      'Failed to register keymap: ' .. lhs .. ' - ' .. tostring(err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

---Register all keymaps from configuration
---@param keymaps_config table Keymaps organized by category
---@return boolean success Whether all keymaps were registered successfully
function M.register_all(keymaps_config)
  if not keymaps_config then
    return true
  end

  local success, err = pcall(function()
    -- Iterate through each category
    for category, keymaps in pairs(keymaps_config) do
      if type(keymaps) == 'table' then
        -- Register each keymap in the category
        for lhs, keymap_def in pairs(keymaps) do
          local mode = keymap_def.mode or 'n'
          local rhs = keymap_def.rhs
          local opts = keymap_def.opts or {}

          local register_success = M.register(mode, lhs, rhs, opts)
          if not register_success then
            error('Failed to register keymap: ' .. lhs)
          end
        end
      end
    end
  end)

  if not success then
    vim.notify('Failed to register keymaps: ' .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

---Setup keymaps with optional user configuration
---Merges user config with defaults and registers all keymaps
---@param user_config? table User keymap configuration to override defaults
---@return boolean success Whether setup succeeded
function M.setup(user_config)
  user_config = user_config or {}

  -- Get defaults
  local defaults = M.get_defaults()

  -- Merge user config with defaults (user config overrides)
  local final_config = utils.deep_merge(defaults, user_config)

  -- Register all keymaps
  local success = M.register_all(final_config)

  if not success then
    vim.notify('Keymaps setup failed', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
