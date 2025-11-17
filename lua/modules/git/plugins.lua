--[[
Git Module - Plugin Specifications
===================================

Plugin specifications for the git module (gitsigns + fugitive + diffview + neogit).

Dependencies:
- lewis6991/gitsigns.nvim - Git decorations and hunk operations
- tpope/vim-fugitive - Git command integration
- sindrets/diffview.nvim - Advanced diff visualization
- NeogitOrg/neogit - Magit-inspired git interface with conflict resolution

Usage:
These plugin specs are loaded by lazy.nvim when the git module
is enabled in the main configuration.
--]]

return {
	-- Gitsigns: Git decorations and hunk operations
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = false,
	},

	-- Fugitive: Git command integration
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gstatus", "Gcommit", "Gpush", "Gpull", "Gblame", "Gdiff" },
		keys = {
			"<leader>gs",
			"<leader>gc",
			"<leader>gp",
			"<leader>gl",
			"<leader>gb",
			"<leader>gd",
		},
		config = false,
	},

	-- Diffview: Advanced diff visualization
	{
		"sindrets/diffview.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		keys = {
			"<leader>gdo",
			"<leader>gdc",
			"<leader>gdt",
			"<leader>gdh",
			"<leader>gdf",
		},
		-- Lazy-load on git conflict state
		event = "User GitConflictDetected",
		config = false,
	},

	-- Neogit: Magit-inspired git interface
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim", -- Integration for enhanced diffs
			"nvim-telescope/telescope.nvim", -- Optional, for integration
		},
		cmd = { "Neogit", "NeogitResetState" },
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit status" },
			{ "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
		},
		-- Lazy-load on git conflict state
		event = "User GitConflictDetected",
		config = false,
	},
}
