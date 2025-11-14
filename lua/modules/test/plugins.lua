--[[
Test Module - Plugin Specifications
====================================

Plugin specifications for the test module (neotest + language adapters).

Dependencies:
- nvim-neotest/neotest - Core test runner
- nvim-neotest/neotest-jest - JavaScript/TypeScript (Jest)
- nvim-neotest/neotest-vim-test - Karma support via vim-test
- vim-test/vim-test - Test runner framework (for Karma)
- nvim-neotest/neotest-python - Python (Pytest)
- olimorris/neotest-rspec - Ruby (RSpec)
- nvim-neotest/neotest-busted - Lua (Busted)

Usage:
These plugin specs are loaded by lazy.nvim when the test module
is enabled in the main configuration.
--]]

return {
	-- Core neotest: Modern async test runner
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim", -- Fixes cursor hold performance
			"nvim-neotest/nvim-nio",
		},
		keys = {
			"<leader>tt",
			"<leader>tf",
			"<leader>ts",
			"<leader>tl",
			"<leader>td",
			"<leader>to",
			"<leader>tO",
			"<leader>tc",
			"<leader>tS",
			"<leader>ta",
		},
		config = false,
	},

	-- JavaScript/TypeScript: Jest adapter
	{
		"nvim-neotest/neotest-jest",
		dependencies = {
			"nvim-neotest/neotest",
		},
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = false,
	},

	-- Karma support via vim-test
	{
		"nvim-neotest/neotest-vim-test",
		dependencies = {
			"nvim-neotest/neotest",
			"vim-test/vim-test",
		},
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = false,
	},

	-- vim-test: Test runner framework (required for Karma)
	{
		"vim-test/vim-test",
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
	},

	-- Python: Pytest adapter
	{
		"nvim-neotest/neotest-python",
		dependencies = {
			"nvim-neotest/neotest",
		},
		ft = "python",
		config = false,
	},

	-- ========================================
	-- Ruby Test Adapters
	-- ========================================

	-- RSpec
	{
		"olimorris/neotest-rspec",
		dependencies = { "nvim-neotest/neotest" },
		ft = "ruby",
		config = false,
	},

	-- Minitest
	{
		"zidhuss/neotest-minitest",
		dependencies = { "nvim-neotest/neotest" },
		ft = "ruby",
		config = false,
	},

	-- Lua: Busted adapter
	-- Note: Commented out due to authentication issues
	-- Uncomment if you have access to the repo
	-- {
	--   'nvim-neotest/neotest-busted',
	--   dependencies = {
	--     'nvim-neotest/neotest',
	--   },
	--   ft = 'lua',
	--   config = false,
	-- },
}
