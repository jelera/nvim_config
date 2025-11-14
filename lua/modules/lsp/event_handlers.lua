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

  -- Create autocmd group for this buffer
  local augroup = vim.api.nvim_create_augroup('LspFormatOnSave_' .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    buffer = bufnr,
    callback = function()
      -- Apply code actions (autofix) if supported
      if client.supports_method('textDocument/codeAction') then
        -- Request source.organizeImports and source.fixAll actions
        local context = {
          diagnostics = vim.diagnostic.get(bufnr),
          only = { 'source.fixAll', 'source.organizeImports' },
        }

        local params = vim.lsp.util.make_range_params()
        params.context = context

        -- Apply code actions synchronously
        local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)
        if result then
          for _, res in pairs(result) do
            if res.result then
              for _, action in pairs(res.result) do
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                elseif action.command then
                  vim.lsp.buf.execute_command(action.command)
                end
              end
            end
          end
        end
      end

      -- Format the buffer if formatting is supported
      if client.supports_method('textDocument/formatting') then
        vim.lsp.buf.format({ bufnr = bufnr })
      end
    end,
  })
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
