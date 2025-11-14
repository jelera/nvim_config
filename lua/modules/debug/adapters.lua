--[[
Debug Adapters Configuration
=============================

Loads language-specific debug adapters for nvim-dap.

Supported Languages:
- JavaScript/TypeScript (vscode-js-debug via nvim-dap-vscode-js)
- Python (debugpy)
- Ruby (rdbg/debug gem)
- Lua (local-lua-debugger-vscode)

Adapters are organized by language in adapters/<language>.lua

Dependencies:
- mfussenegger/nvim-dap
- mxsdev/nvim-dap-vscode-js (for JS/TS)
- Mason for adapter installation

API:
- setup(config) - Configure debug adapters
--]]

local M = {}

---Default configuration
local default_config = {
  -- Languages to setup
  languages = { 'javascript', 'typescript', 'python', 'ruby', 'lua' }
}

---Load and setup language adapter
---@param language string Language name
---@param dap table nvim-dap module
local function load_adapter(language, dap)
  local adapter_module = 'modules.debug.adapters.' .. language
  local ok, adapter = pcall(require, adapter_module)
  if not ok then
    vim.notify(
      string.format('Failed to load debug adapter for %s', language),
      vim.log.levels.WARN
    )
    return false
  end

  -- Setup the adapter
  local setup_ok, setup_err = pcall(adapter.setup, dap)
  if not setup_ok then
    vim.notify(
      string.format('Failed to setup debug adapter for %s: %s', language, setup_err),
      vim.log.levels.WARN
    )
    return false
  end

  return true
end

---Setup debug adapters with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load nvim-dap plugin
  local ok, dap = pcall(require, 'dap')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup adapters for all configured languages
  local languages = merged_config.languages or default_config.languages
  for _, lang in ipairs(languages) do
    load_adapter(lang, dap)
  end

  return true
end

return M
