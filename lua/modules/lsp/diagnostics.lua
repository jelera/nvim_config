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
  -- Configure diagnostic display
  vim.diagnostic.config({
    virtual_text = true, -- Show diagnostics as virtual text
    signs = true, -- Show signs in sign column
    underline = true, -- Underline diagnostics
    update_in_insert = false, -- Don't update diagnostics in insert mode
    severity_sort = true, -- Sort by severity
  })

  -- Define diagnostic signs with emojis
  local signs = {
    Error = '❌',
    Warn = '⚠️',
    Hint = '💡',
    Info = 'ℹ️',
  }

  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, {
      text = icon,
      texthl = hl,
      numhl = hl,
    })
  end
end

return M
