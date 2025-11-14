--[[
ESLint Language Server Configuration
=====================================

Custom configuration for eslint (ESLint LSP).

Provides linting diagnostics and code actions for JavaScript/TypeScript.

Returns a table that gets merged with default LSP settings.
--]]

return {
  -- ESLint settings
  settings = {
    eslint = {
      -- Auto-fix on save is handled by our format_on_save autocmd
      -- This just ensures ESLint is ready to provide fixes
      codeActionsOnSave = {
        mode = 'all',
        rules = {},
      },
      format = false, -- We let Prettier handle formatting if it's installed
      run = 'onType',
      quiet = false,
    },
  },

  -- Only attach to supported filetypes
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
  },
}
