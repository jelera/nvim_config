--[[
Completion Plugin Specifications
=================================

Plugin specifications for lazy.nvim plugin manager.

Plugins:
- nvim-cmp: Completion engine
- cmp-nvim-lsp: LSP completion source
- cmp-buffer: Buffer word completion source
- cmp-path: Filesystem path completion source
- cmp-cmdline: Command-line completion source
- cmp_luasnip: LuaSnip completion source
- LuaSnip: Snippet engine
- friendly-snippets: Pre-made snippet collection

All plugins use config = false to allow manual setup via completion module.
--]]

return {
  -- Completion engine
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      -- Completion sources
      'hrsh7th/cmp-nvim-lsp', -- LSP completions
      'hrsh7th/cmp-buffer', -- Buffer completions
      'hrsh7th/cmp-path', -- Path completions
      'hrsh7th/cmp-cmdline', -- Cmdline completions
      'saadparwaiz1/cmp_luasnip', -- Snippet completions
    },
    config = false, -- Manual setup in completion module
  },

  -- Snippet engine
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp', -- Optional: JS regex support
    dependencies = {
      'rafamadriz/friendly-snippets', -- VS Code-style snippets
    },
    config = false, -- Manual setup in snippets module
  },
}
