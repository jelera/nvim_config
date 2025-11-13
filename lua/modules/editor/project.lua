--[[
Project Management Configuration
=================================

Configures project.nvim for automatic project root detection.

Features:
- Auto-detect project root (git, .nvimrc, Makefile, etc.)
- Automatically cd to project root
- Recent projects tracking
- Telescope integration

Dependencies:
- ahmedkhalf/project.nvim

Detection Methods:
- lsp: Use LSP to detect project root
- pattern: Detect root by pattern (.git, Makefile, etc.)

API:
- setup(config) - Configure project management
--]]

local M = {}

---Default configuration for project management
local default_config = {
  -- Detection methods (order matters)
  detection_methods = { 'lsp', 'pattern' },

  -- Patterns to detect project root
  patterns = {
    '.git',
    '_darcs',
    '.hg',
    '.bzr',
    '.svn',
    'Makefile',
    'package.json',
    'Cargo.toml',
    'go.mod',
    'Gemfile',
    'setup.py',
    'pyproject.toml',
  },

  -- Don't calculate root dir on specific directories
  exclude_dirs = {
    '~/',
    '~/Downloads',
    '/tmp/*',
  },

  -- Show hidden files in telescope
  show_hidden = false,

  -- Silent loading (no notifications)
  silent_chdir = true,

  -- Scope of chdir ('global', 'tab', 'win')
  scope_chdir = 'global',
}

---Setup project management with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load project plugin
  local ok, project = pcall(require, 'project_nvim')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup project
  local setup_ok, err = pcall(project.setup, merged_config)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup project: %s', err),
      vim.log.levels.ERROR
    )
    return false
  end

  -- Integration with Telescope (if available)
  local telescope_ok, telescope = pcall(require, 'telescope')
  if telescope_ok then
    pcall(telescope.load_extension, 'projects')
  end

  return true
end

return M
