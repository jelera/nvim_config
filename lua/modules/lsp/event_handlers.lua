--[[
LSP Event Handlers
==================

LSP event handlers for on_attach and format-on-save.

Exports:
- create_on_attach(config) - Creates on_attach callback
- setup_format_on_save(client, bufnr, enabled) - Sets up format on save

Usage:
```lua
local event_handlers = require('modules.lsp.event_handlers')
local on_attach = event_handlers.create_on_attach(config)
```
--]]

local M = {}

local keymaps = require('modules.lsp.keymaps')

---Setup format on save for buffer
---@param client table LSP client
---@param bufnr number Buffer number
---@param enabled boolean Whether to enable format on save
function M.setup_format_on_save(client, bufnr, enabled)
  if not enabled then
    return
  end

  if client.supports_method('textDocument/formatting') then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end

---Create on_attach callback for LSP servers
---@param config table Module configuration
---@return function on_attach callback
function M.create_on_attach(config)
  return function(client, bufnr)
    -- Setup keymaps
    keymaps.setup(bufnr)

    -- Setup format on save
    M.setup_format_on_save(client, bufnr, config.format_on_save)

    -- Notify that LSP is attached
    vim.notify(
      'LSP attached: ' .. client.name,
      vim.log.levels.INFO,
      { title = 'LSP' }
    )
  end
end

return M
