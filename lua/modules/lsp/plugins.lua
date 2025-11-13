--[[
LSP Module Plugins
==================

Plugin specifications for LSP (Language Server Protocol) and related tools.
Include these in your lazy.nvim setup:

```lua
local lsp_plugins = require('modules.lsp.plugins')
require('lazy').setup(lsp_plugins)
```

Or merge with your own plugins:
```lua
local lsp_plugins = require('modules.lsp.plugins')
require('lazy').setup(vim.list_extend(lsp_plugins, {
  -- Your custom plugins here
}))
```
--]]

return {
  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    config = false, -- We'll configure it in modules.lsp
  },

  -- Mason - LSP server installer with UI
  {
    'williamboman/mason.nvim',
    config = false,
  },

  -- Bridge between Mason and nvim-lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = false,
  },

  -- LSP capabilities for nvim-cmp (completion)
  {
    'hrsh7th/cmp-nvim-lsp',
    config = false,
  },
}
