--[[
Lua Language Server Configuration
==================================

Custom configuration for lua_ls (Lua Language Server).

Optimized for NeoVim Lua development with:
- NeoVim runtime path
- Vim globals recognized
- Diagnostics tuned for NeoVim plugins

Returns a table that gets merged with default LSP settings.
--]]

return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- NeoVim uses LuaJIT
      },
      diagnostics = {
        globals = { 'vim' }, -- Recognize 'vim' global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false, -- Don't ask about luassert, busted, etc.
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
