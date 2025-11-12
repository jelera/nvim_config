--[[
TreeSitter Module
=================

Unified TreeSitter configuration for advanced syntax highlighting and code understanding.

Features:
- Syntax highlighting (better than regex-based)
- Smart indentation
- Code folding
- Text objects (select functions, classes, etc.)
- Incremental selection (expand selection to AST nodes)
- Auto-install parsers on file open

Dependencies:
All plugins should be installed via lazy.nvim.
See modules/treesitter/plugins.lua for the plugin list.

Usage:
```lua
local treesitter = require('modules.treesitter')

-- Setup with defaults (recommended - maximizes TreeSitter features)
treesitter.setup()

-- Setup with custom config
treesitter.setup({
  highlight = { enable = true },
  indent = { enable = true },
  ensure_installed = { 'lua', 'python' }, -- or 'all'
})
```

API:
- setup(config) - Initialize TreeSitter with all features
--]]

local M = {}

local utils = require('nvim.lib.utils')

---Default TreeSitter configuration
---Maximizes TreeSitter features for best IDE experience
---@type table
local default_config = {
  -- Auto-install parsers when entering buffer
  auto_install = true,

  -- Install all maintained parsers
  -- This ensures parsers are available for all supported languages
  ensure_installed = 'all',

  -- Syntax highlighting
  highlight = {
    enable = true,
    -- Disable regex highlighting when TreeSitter is active
    additional_vim_regex_highlighting = false,
  },

  -- Smart indentation
  indent = {
    enable = true,
  },

  -- Incremental selection based on AST
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn', -- Start selection
      node_incremental = 'grn', -- Increment to next node
      scope_incremental = 'grc', -- Increment to next scope
      node_decremental = 'grm', -- Decrement to previous node
    },
  },

  -- Text objects for functions, classes, etc.
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Jump forward to textobj if not already in one
      keymaps = {
        -- Functions
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        -- Classes
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        -- Conditionals
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',
        -- Loops
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
        -- Parameters/arguments
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        -- Comments
        ['a/'] = '@comment.outer',
      },
    },

    -- Move between text objects
    move = {
      enable = true,
      set_jumps = true, -- Add to jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },

    -- Swap text objects (e.g., swap function parameters)
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

---Merge user configuration with defaults
---@param user_config table|nil User configuration
---@return table merged_config The merged configuration
local function merge_config(user_config)
  if not user_config then
    return utils.deep_copy(default_config)
  end

  -- Start with defaults
  local merged = utils.deep_copy(default_config)

  -- Deep merge user config
  merged = utils.deep_merge(merged, user_config)

  return merged
end

---Setup TreeSitter with configuration
---@param config table|nil Configuration options
---@param config.highlight table|nil Highlighting configuration
---@param config.indent table|nil Indentation configuration
---@param config.incremental_selection table|nil Incremental selection config
---@param config.textobjects table|nil Text objects configuration
---@param config.ensure_installed string|table|nil Parsers to install ('all' or list)
---@param config.auto_install boolean|nil Auto-install parsers (default: true)
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Try to load nvim-treesitter
  local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
  if not ok then
    vim.notify(
      'nvim-treesitter not found. Install it via lazy.nvim',
      vim.log.levels.WARN,
      { title = 'TreeSitter Module' }
    )
    return false
  end

  -- Merge config with defaults
  local merged_config = merge_config(config)

  -- Configure TreeSitter
  local setup_ok, err = pcall(function()
    ts_configs.setup(merged_config)
  end)

  if not setup_ok then
    vim.notify(
      'Failed to configure TreeSitter: ' .. tostring(err),
      vim.log.levels.ERROR,
      { title = 'TreeSitter Module' }
    )
    return false
  end

  -- Enable folding based on TreeSitter
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  vim.opt.foldenable = false -- Don't fold by default (use 'zc' to fold)

  return true
end

return M
