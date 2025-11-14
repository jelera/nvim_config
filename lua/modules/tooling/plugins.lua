--[[
Tooling Plugins
===============

Cross-cutting development tools: database, REPL, HTTP client, projectionist.
--]]

return {
	-- Database UI (Lua-based)
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			require("dbee").install()
		end,
		cmd = { "Dbee" },
		config = false, -- Manual setup in tooling/database
	},

	-- REPL manager (Lua-based)
	{
		"Vigemus/iron.nvim",
		cmd = { "IronRepl", "IronFocus", "IronSend" },
		keys = {
			"<leader>rs",
			"<leader>rr",
			"<leader>rf",
		},
		config = false, -- Manual setup in tooling/repl
	},

	-- HTTP client (Lua-based)
	{
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = false, -- Manual setup in tooling/http
	},

	-- Project navigation (VimScript but configurable via Lua)
	{
		"tpope/vim-projectionist",
		lazy = false, -- Load early for project detection
		config = false, -- Configured by frameworks module
	},

	-- .env file support
	{
		"tpope/vim-dotenv",
		ft = { "ruby", "eruby", "javascript", "typescript" },
	},

	-- Linting (for tools without LSP support)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = false, -- Manual setup in tooling/lint
	},
}
