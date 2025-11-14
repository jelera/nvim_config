--[[
LSP Keymaps
===========

LSP key mappings applied when LSP attaches to a buffer.

Keymaps:
- gd - Go to definition
- gD - Go to declaration
- gr - Go to references
- gi - Go to implementation
- gt - Go to type definition
- K - Hover documentation
- <C-k> - Signature help
- <leader>rn - Rename symbol
- <leader>ca - Code actions
- <leader>f - Format buffer
- [d / ]d - Previous/next diagnostic
- <leader>d - Show line diagnostics
- <leader>q - Show diagnostics list

Usage:
```lua
local keymaps = require('modules.lsp.keymaps')
keymaps.setup(bufnr)
```
--]]

local M = {}

---Setup LSP keymaps for a buffer
---@param bufnr number Buffer number
function M.setup(bufnr)
	local opts = { buffer = bufnr, silent = true }

	-- Go to...
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

	-- Hover & signature
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)

	-- Actions
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, opts)

	-- Diagnostics
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
end

return M
