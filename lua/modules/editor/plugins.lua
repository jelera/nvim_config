--[[
Editor Module - Plugin Specifications
======================================

Plugin specifications for the editor enhancements module.

Dependencies:
- windwp/nvim-autopairs - Auto-pairs for brackets and quotes
- kylechui/nvim-surround - Surround text with brackets, quotes, tags
- numToStr/Comment.nvim - Smart commenting
- JoosepAlviste/nvim-ts-context-commentstring - Treesitter-aware comments
- ahmedkhalf/project.nvim - Project management and root detection
- folke/persistence.nvim - Session management

Usage:
These plugin specs are loaded by lazy.nvim when the editor module
is enabled in the main configuration.
--]]

return {
  -- Auto-pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = false,
  },

  -- Surround
  {
    'kylechui/nvim-surround',
    version = '*', -- Use stable releases
    event = 'VeryLazy',
    config = false,
  },

  -- Comment
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = false,
  },

  -- Treesitter context commentstring (for JSX, Vue, etc.)
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },

  -- Project management
  {
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
    config = false,
  },

  -- Session management
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    config = false,
  },
}
