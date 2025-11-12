--[[
GitHub Copilot Language Server Configuration
=============================================

Custom configuration for copilot (GitHub Copilot LSP).

Provides AI-powered code completions and suggestions.
Used by sidekick.nvim for NES (Next Edit Suggestions).

Requirements:
- @github/copilot-language-server (npm global package)
- GitHub Copilot subscription
- Authentication via :Copilot auth

Returns a table that gets merged with default LSP settings.
--]]

return {
	-- Copilot LSP uses a custom command since it's not in Mason
	cmd = { "copilot-language-server", "--stdio" },

	-- File types where Copilot should be active
	filetypes = {
		"*", -- Enable for all file types
	},

	-- Copilot-specific settings
	settings = {
		copilot = {
			-- Enable completions
			enable = true,
		},
	},

	-- Single file support (Copilot works per-file)
	single_file_support = true,
}
