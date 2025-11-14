--[[
Rubocop Language Server Configuration
======================================

Custom configuration for rubocop (Ruby linter/formatter).

Rubocop provides linting diagnostics and auto-fix capabilities.
Supports rubocop-rails and rubocop-rspec extensions automatically.

Returns a table that gets merged with default LSP settings.
--]]

return {
  cmd = { 'rubocop', '--lsp' },

  settings = {
    -- Rubocop automatically detects .rubocop.yml configuration
    -- It also detects rubocop-rails and rubocop-rspec if they're in the Gemfile
  },
}
