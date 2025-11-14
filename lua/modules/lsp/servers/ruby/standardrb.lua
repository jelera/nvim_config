--[[
StandardRB Language Server Configuration
=========================================

Custom configuration for standardrb (Ruby Standard Style).

StandardRB is an opinionated Ruby linter/formatter with zero configuration.
It's an alternative to Rubocop with pre-configured rules.

Returns a table that gets merged with default LSP settings.
--]]

return {
  cmd = { 'standardrb', '--lsp' },

  settings = {
    -- StandardRB is zero-config by design
    -- It automatically uses .standard.yml if present
  },
}
