--[[
LSP Configuration
=================

Default LSP configuration and server config loading.

Exports:
- default_config - Default LSP settings
- load_server_config(server_name) - Load per-language config

Usage:
```lua
local config = require('modules.lsp.config')
local defaults = config.default_config
local lua_config = config.load_server_config('lua_ls')
```
--]]

local M = {}

---Default LSP configuration
---@type table
M.default_config = {
  -- Core servers to auto-install upfront
  ensure_installed = {
    'lua_ls', -- Lua
    'ts_ls', -- JavaScript/TypeScript
    'pyright', -- Python
    'solargraph', -- Ruby
    'bashls', -- Bash
    'sqlls', -- SQL
    'marksman', -- Markdown
  },

  -- Auto-install servers when opening supported files
  automatic_installation = true,

  -- Format on save (can be toggled per-buffer)
  format_on_save = false,

  -- Mason UI settings
  mason_ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
}

---Load per-language server configuration
---
---Maps server names to language folders for custom configurations.
---Multiple servers can map to the same language folder, allowing
---multiple LSP servers per language (e.g., ts_ls + eslint for JavaScript).
---
---Example directory structure:
---  servers/
---    javascript/
---      ts_ls.lua      # TypeScript server
---      eslint.lua     # ESLint LSP (if added later)
---    python/
---      pyright.lua    # Pyright server
---      ruff_lsp.lua   # Ruff LSP (if added later)
---
---@param server_name string Server name (e.g., 'lua_ls', 'ts_ls', 'eslint')
---@return table|nil server_config Per-language config or nil if not found
function M.load_server_config(server_name)
  -- Map server names to language folders
  -- NOTE: Multiple servers can map to the same language folder
  -- This allows multiple LSP servers per language (e.g., ts_ls + eslint for JavaScript)
  local server_to_language = {
    -- Lua
    lua_ls = 'lua',

    -- JavaScript/TypeScript
    -- (Can add multiple: ts_ls, eslint, etc.)
    ts_ls = 'javascript',

    -- Python
    -- (Can add multiple: pyright, ruff_lsp, etc.)
    pyright = 'python',

    -- Ruby
    solargraph = 'ruby',

    -- Bash
    bashls = 'bash',

    -- SQL
    sqlls = 'sql',

    -- Markdown
    marksman = 'markdown',

    -- Go
    gopls = 'go',

    -- Rust
    rust_analyzer = 'rust',
  }

  local language = server_to_language[server_name]
  if not language then
    return nil
  end

  -- Build config path: modules.lsp.servers.<language>.<server_name>
  local config_path = 'modules.lsp.servers.' .. language .. '.' .. server_name
  local ok, server_config = pcall(require, config_path)

  if ok then
    return server_config
  end

  return nil
end

return M
