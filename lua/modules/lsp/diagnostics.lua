--[[
LSP Diagnostics
===============

LSP diagnostic configuration and signs.

Features:
- Virtual text for diagnostics
- Diagnostic signs in sign column
- Underline for errors/warnings
- Severity sorting

Usage:
```lua
local diagnostics = require('modules.lsp.diagnostics')
diagnostics.setup()
```
--]]

local M = {}

---Setup LSP diagnostics configuration
function M.setup()
  -- Define diagnostic signs with emojis
  local signs = {
    Error = '❌',
    Warn = '⚠️',
    Hint = '💡',
    Info = 'ℹ️',
  }

  -- Configure diagnostic display with new signs API (Neovim 0.10+)
  vim.diagnostic.config({
    virtual_text = false, -- Disable virtual text, show in lualine instead
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.HINT] = signs.Hint,
        [vim.diagnostic.severity.INFO] = signs.Info,
      },
    },
    underline = true, -- Underline diagnostics
    update_in_insert = false, -- Don't update diagnostics in insert mode
    severity_sort = true, -- Sort by severity
  })
end

return M
