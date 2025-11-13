--[[
Git Module
==========

Orchestrates git integration including gitsigns, fugitive, and diffview.

Features:
- Gitsigns: Visual git indicators and hunk operations
- Fugitive: Git commands and operations
- Diffview: Advanced diff visualization
- Git keymaps: Comprehensive git key bindings

Submodules:
- signs.lua - Gitsigns configuration
- fugitive.lua - Fugitive setup
- diffview.lua - Diffview configuration
- keymaps.lua - Git key mappings

Dependencies:
- lewis6991/gitsigns.nvim
- tpope/vim-fugitive
- sindrets/diffview.nvim

Usage:
```lua
local git = require('modules.git')
git.setup({
  signs = {
    current_line_blame = true
  },
  fugitive = {},
  diffview = {}
})
```

API:
- setup(config) - Initialize git module
--]]

local M = {}

---Setup the git module
---@param config table|nil Optional configuration
---@param config.signs table|nil Gitsigns configuration overrides
---@param config.fugitive table|nil Fugitive configuration overrides
---@param config.diffview table|nil Diffview configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Check if git is available (warn but don't fail)
  if vim.fn.executable('git') == 0 then
    vim.notify('Git executable not found. Git features will be limited.', vim.log.levels.WARN)
  end

  -- Setup gitsigns
  local signs = require('modules.git.signs')
  local signs_ok = signs.setup(config.signs or {})
  if not signs_ok then
    vim.notify('Failed to setup gitsigns. Git decorations disabled.', vim.log.levels.WARN)
  end

  -- Setup fugitive
  local fugitive = require('modules.git.fugitive')
  local fugitive_ok = fugitive.setup(config.fugitive or {})
  if not fugitive_ok then
    vim.notify('Failed to setup fugitive. Git commands disabled.', vim.log.levels.WARN)
  end

  -- Setup diffview
  local diffview = require('modules.git.diffview')
  local diffview_ok = diffview.setup(config.diffview or {})
  if not diffview_ok then
    vim.notify('Failed to setup diffview. Diff views disabled.', vim.log.levels.WARN)
  end

  -- Setup keymaps (after components are initialized)
  local keymaps = require('modules.git.keymaps')
  local keymaps_ok = keymaps.setup()
  if not keymaps_ok then
    vim.notify('Failed to setup git keymaps.', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
