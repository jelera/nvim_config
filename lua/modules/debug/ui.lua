--[[
DAP UI Configuration
====================

Configures nvim-dap-ui for visual debugging interface.

Features:
- Sidebar layouts (scopes, breakpoints, stacks, watches)
- Floating windows
- REPL integration
- Auto-open/close on debug events

Dependencies:
- rcarriga/nvim-dap-ui

API:
- setup(config) - Configure DAP UI
--]]

local M = {}

---Default configuration for DAP UI
local default_config = {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
  mappings = {
    expand = { '<CR>', '<2-LeftMouse>' },
    open = 'o',
    remove = 'd',
    edit = 'e',
    repl = 'r',
    toggle = 't',
  },
  element_mappings = {},
  expand_lines = vim.fn.has('nvim-0.7') == 1,
  layouts = {
    {
      elements = {
        { id = 'scopes', size = 0.25 },
        { id = 'breakpoints', size = 0.25 },
        { id = 'stacks', size = 0.25 },
        { id = 'watches', size = 0.25 },
      },
      size = 40,
      position = 'left',
    },
    {
      elements = {
        { id = 'repl', size = 0.5 },
        { id = 'console', size = 0.5 },
      },
      size = 10,
      position = 'bottom',
    },
  },
  controls = {
    enabled = true,
    element = 'repl',
    icons = {
      pause = '',
      play = '',
      step_into = '',
      step_over = '',
      step_out = '',
      step_back = '',
      run_last = '↻',
      terminate = '□',
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = 'single',
    mappings = {
      close = { 'q', '<Esc>' },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil,
    max_value_lines = 100,
  },
}

---Setup DAP UI with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load dap-ui plugin
  local ok, dapui = pcall(require, 'dapui')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup dap-ui
  local setup_ok, err = pcall(dapui.setup, merged_config)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup dap-ui: %s', err),
      vim.log.levels.ERROR
    )
    return false
  end

  -- Auto-open/close UI on debug events
  local dap_ok, dap = pcall(require, 'dap')
  if dap_ok then
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end
  end

  return true
end

return M
