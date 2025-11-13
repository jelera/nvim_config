--[[
Diffview Configuration
======================

Configures diffview.nvim for advanced diff visualization.

Features:
- Side-by-side or unified diff views
- File history browser
- Merge conflict resolution UI
- Customizable layouts

Dependencies:
- sindrets/diffview.nvim

API:
- setup(config) - Configure diffview
--]]

local M = {}

---Default configuration for diffview
local default_config = {
  enhanced_diff_hl = true,
  view = {
    default = {
      layout = 'diff2_horizontal',
      winbar_info = false
    },
    merge_tool = {
      layout = 'diff3_horizontal',
      disable_diagnostics = true,
      winbar_info = true
    },
    file_history = {
      layout = 'diff2_horizontal',
      winbar_info = false
    }
  },
  file_panel = {
    listing_style = 'tree',
    tree_options = {
      flatten_dirs = true,
      folder_statuses = 'only_folded'
    },
    win_config = {
      position = 'left',
      width = 35,
      win_opts = {}
    }
  },
  file_history_panel = {
    log_options = {
      git = {
        single_file = {
          diff_merges = 'combined'
        },
        multi_file = {
          diff_merges = 'first-parent'
        }
      }
    },
    win_config = {
      position = 'bottom',
      height = 16,
      win_opts = {}
    }
  },
  commit_log_panel = {
    win_config = {
      win_opts = {}
    }
  },
  default_args = {
    DiffviewOpen = {},
    DiffviewFileHistory = {}
  },
  hooks = {},
  keymaps = {
    disable_defaults = false,
    view = {
      { 'n', '<tab>',      '<cmd>DiffviewToggleFiles<cr>', { desc = 'Toggle file panel' } },
      { 'n', 'gf',         '<cmd>DiffviewFocusFiles<cr>',  { desc = 'Focus file panel' } },
      { 'n', '<leader>e',  '<cmd>DiffviewToggleFiles<cr>', { desc = 'Toggle file panel' } },
    },
    file_panel = {
      { 'n', 'j',             '<cmd>lua require("diffview").next_entry()<cr>',     { desc = 'Next entry' } },
      { 'n', '<down>',        '<cmd>lua require("diffview").next_entry()<cr>',     { desc = 'Next entry' } },
      { 'n', 'k',             '<cmd>lua require("diffview").prev_entry()<cr>',     { desc = 'Previous entry' } },
      { 'n', '<up>',          '<cmd>lua require("diffview").prev_entry()<cr>',     { desc = 'Previous entry' } },
      { 'n', '<cr>',          '<cmd>lua require("diffview").select_entry()<cr>',   { desc = 'Open diff' } },
      { 'n', 'o',             '<cmd>lua require("diffview").select_entry()<cr>',   { desc = 'Open diff' } },
      { 'n', '<2-LeftMouse>', '<cmd>lua require("diffview").select_entry()<cr>',   { desc = 'Open diff' } },
      { 'n', 'R',             '<cmd>lua require("diffview").refresh_files()<cr>',  { desc = 'Refresh' } },
      { 'n', '<tab>',         '<cmd>DiffviewToggleFiles<cr>',                      { desc = 'Toggle panel' } },
      { 'n', 'gf',            '<cmd>DiffviewFocusFiles<cr>',                       { desc = 'Focus files' } },
    },
    file_history_panel = {
      { 'n', 'g!',            '<cmd>lua require("diffview").open_commit_log()<cr>',        { desc = 'Open commit log' } },
      { 'n', '<C-A-d>',       '<cmd>lua require("diffview").show_diff_for_range()<cr>',    { desc = 'Show range diff' } },
      { 'v', '<C-A-d>',       '<cmd>lua require("diffview").show_diff_for_range()<cr>',    { desc = 'Show range diff' } },
      { 'n', 'y',             '<cmd>lua require("diffview").copy_hash()<cr>',              { desc = 'Copy commit hash' } },
      { 'n', '<cr>',          '<cmd>lua require("diffview").select_entry()<cr>',           { desc = 'Open diff' } },
      { 'n', 'o',             '<cmd>lua require("diffview").select_entry()<cr>',           { desc = 'Open diff' } },
      { 'n', '<2-LeftMouse>', '<cmd>lua require("diffview").select_entry()<cr>',           { desc = 'Open diff' } },
    },
    option_panel = {
      { 'n', '<tab>', '<cmd>lua require("diffview.config").actions.select_entry()<cr>',       { desc = 'Select option' } },
      { 'n', 'q',     '<cmd>lua require("diffview.config").actions.close()<cr>',              { desc = 'Close panel' } },
    },
  },
}

---Setup diffview with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load diffview plugin
  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup diffview
  local setup_ok, err = pcall(diffview.setup, merged_config)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup diffview: %s', err),
      vim.log.levels.ERROR
    )
    return false
  end

  return true
end

return M
