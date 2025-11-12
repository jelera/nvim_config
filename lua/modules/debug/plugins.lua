--[[
Debug Module - Plugin Specifications
=====================================

Plugin specifications for the debug module (nvim-dap + dap-ui + virtual-text).

Dependencies:
- mfussenegger/nvim-dap - Debug Adapter Protocol client
- rcarriga/nvim-dap-ui - UI for nvim-dap
- theHamsta/nvim-dap-virtual-text - Virtual text support

Usage:
These plugin specs are loaded by lazy.nvim when the debug module
is enabled in the main configuration.
--]]

return {
	-- Core DAP: Debug Adapter Protocol client
	{
		"mfussenegger/nvim-dap",
		keys = {
			"<F5>",
			"<F10>",
			"<F11>",
			"<F12>",
			"<leader>db",
			"<leader>dB",
			"<leader>dr",
			"<leader>dl",
			"<leader>dt",
			"<leader>du",
			"<leader>dh",
			"<leader>dp",
			"<leader>df",
			"<leader>ds",
		},
		config = false,
	},

	-- DAP UI: Visual debugging interface
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			"<leader>du",
		},
		config = false,
	},

	-- Virtual text: Show variable values inline
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		event = { "BufReadPre", "BufNewFile" },
		config = false,
	},

	-- JavaScript/TypeScript debugger (vscode-js-debug)
	{
		"microsoft/vscode-js-debug",
		lazy = true,
		build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
	},

	-- JS/TS debug adapter wrapper
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
			"microsoft/vscode-js-debug",
		},
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		config = false,
	},
}
