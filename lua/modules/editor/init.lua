--[[
Editor Module
=============

Editor enhancements module for quality of life improvements.

Features:
- Auto-pairs: Automatic bracket/quote pairing
- Surround: Surround text with brackets, quotes, tags
- Comment: Smart commenting
- Session: Session persistence across restarts

Submodules:
- autopairs.lua - nvim-autopairs configuration
- surround.lua - nvim-surround configuration
- comment.lua - Comment.nvim configuration
- session.lua - persistence.nvim configuration
- keymaps.lua - Editor key mappings

Dependencies:
- windwp/nvim-autopairs
- kylechui/nvim-surround
- numToStr/Comment.nvim
- folke/persistence.nvim

Usage:
```lua
local editor = require('modules.editor')
editor.setup({
  autopairs = {},
  surround = {},
  comment = {},
  session = {}
})
```

API:
- setup(config) - Initialize editor module
--]]

local M = {}

---Setup the editor module
---@param config table|nil Optional configuration
---@param config.autopairs table|nil Autopairs configuration overrides
---@param config.surround table|nil Surround configuration overrides
---@param config.comment table|nil Comment configuration overrides
---@param config.session table|nil Session configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Setup autopairs
  local autopairs = require('modules.editor.autopairs')
  local autopairs_ok = autopairs.setup(config.autopairs or {})
  if not autopairs_ok then
    vim.notify('Failed to setup autopairs.', vim.log.levels.WARN)
  end

  -- Setup surround
  local surround = require('modules.editor.surround')
  local surround_ok = surround.setup(config.surround or {})
  if not surround_ok then
    vim.notify('Failed to setup surround.', vim.log.levels.WARN)
  end

  -- Setup comment
  local comment = require('modules.editor.comment')
  local comment_ok = comment.setup(config.comment or {})
  if not comment_ok then
    vim.notify('Failed to setup comment.', vim.log.levels.WARN)
  end

  -- Setup session
  local session = require('modules.editor.session')
  local session_ok = session.setup(config.session or {})
  if not session_ok then
    vim.notify('Failed to setup session.', vim.log.levels.WARN)
  end

  -- Setup keymaps (after all features are initialized)
  local keymaps = require('modules.editor.keymaps')
  local keymaps_ok = keymaps.setup()
  if not keymaps_ok then
    vim.notify('Failed to setup editor keymaps.', vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
