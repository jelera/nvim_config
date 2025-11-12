--[[
Navigation Module - Plugin Specifications
==========================================

Plugin specifications for the navigation module (Telescope + nvim-tree).

Dependencies:
- nvim-telescope/telescope.nvim - Fuzzy finder (replaces FZF)
- nvim-telescope/telescope-fzf-native.nvim - Fast C-based sorter
- nvim-tree/nvim-tree.lua - File explorer (replaces NERDTree)
- nvim-tree/nvim-web-devicons - File icons

Usage:
These plugin specs are loaded by lazy.nvim when the navigation module
is enabled in the main configuration.
--]]

return {
	-- Telescope: Fuzzy finder and picker
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		cmd = "Telescope",
		keys = {
			"<C-p>g",
			"<C-p>p",
			"<C-p>h",
			"<C-p>b",
			"<C-p>c",
			"<C-p>a",
			"<leader>rg",
			"<leader>ag",
			"\\",
		},
		config = false,
	},

	-- Nvim-tree: File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		cmd = {
			"NvimTreeToggle",
			"NvimTreeFindFile",
			"NvimTreeFocus",
			"NvimTreeCollapse",
			"NvimTreeRefresh",
		},
		keys = {
			"<C-t>",
			"<C-B>t",
			"<leader>e",
		},
		config = false,
	},
}
