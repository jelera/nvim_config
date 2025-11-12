--[[
AI Module - Plugin Specifications
==================================

Plugin specifications for the AI module (sidekick.nvim).

Dependencies:
- folke/sidekick.nvim - Unified Copilot NES and AI CLI terminal

Usage:
These plugin specs are loaded by lazy.nvim when the AI module
is enabled in the main configuration.
--]]

return {
	-- Sidekick: Copilot NES + AI Terminal
	{
		"folke/sidekick.nvim",
		keys = {
			"<leader>aa",
			"<leader>an",
			"<leader>ap",
			"<leader>ar",
			"<leader>at",
			"<leader>ac",
			"<leader>as",
			"<leader>aq",
			"<leader>ai",
		},
		config = function()
			-- Configure sidekick to use copilot LSP
			require("sidekick").setup({
				nes = {
					enabled = true,
					provider = "copilot_lsp", -- Use Copilot LSP for AI suggestions
				},
				terminal = {
					enabled = true,
					default_tool = "claude",
				},
			})
		end,
	},
}
