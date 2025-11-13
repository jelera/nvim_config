--[[
Surround Configuration
======================

Configures nvim-surround for surrounding text with brackets, quotes, tags, etc.

Features:
- Add surroundings: ys{motion}{char}
- Delete surroundings: ds{char}
- Change surroundings: cs{target}{replacement}
- Visual mode support: S{char}

Dependencies:
- kylechui/nvim-surround

Usage:
- ysiw" - Surround word with quotes
- ds" - Delete surrounding quotes
- cs"' - Change double quotes to single quotes
- yss) - Surround line with parentheses

API:
- setup(config) - Configure surround
--]]

local M = {}

---Default configuration for surround (uses plugin defaults)
local default_config = {
  keymaps = {
    insert = '<C-g>s',
    insert_line = '<C-g>S',
    normal = 'ys',
    normal_cur = 'yss',
    normal_line = 'yS',
    normal_cur_line = 'ySS',
    visual = 'S',
    visual_line = 'gS',
    delete = 'ds',
    change = 'cs',
    change_line = 'cS',
  },
}

---Setup surround with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load surround plugin
  local ok, surround = pcall(require, 'nvim-surround')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup surround
  local setup_ok, err = pcall(surround.setup, merged_config)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup surround: %s', err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

return M
