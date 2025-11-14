--[[
JavaScript/TypeScript Debug Adapter
====================================

DAP adapter for JavaScript, TypeScript, Node.js, and Chrome debugging.
Uses mxsdev/nvim-dap-vscode-js + microsoft/vscode-js-debug.

Supports:
- Node.js debugging (launch/attach)
- Chrome debugging (for Angular, React, etc.)
- Jest testing
- TypeScript debugging
--]]

local M = {}

function M.setup(dap)
	-- Setup vscode-js-debug adapter
	local ok, dap_vscode_js = pcall(require, "dap-vscode-js")
	if not ok then
		return
	end

	dap_vscode_js.setup({
		debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
		adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
	})

	-- Configurations for JavaScript/TypeScript
	local configs = {
		-- Node.js
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch Node file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to Node",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
		-- Jest
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug Jest Tests",
			runtimeExecutable = "node",
			runtimeArgs = {
				"./node_modules/jest/bin/jest.js",
				"--runInBand",
			},
			rootPath = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
		},
		-- Chrome (for Angular, React, etc.)
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch Chrome (Angular)",
			url = "http://localhost:4200",
			webRoot = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			type = "pwa-chrome",
			request = "attach",
			name = "Attach to Chrome",
			port = 9222,
			webRoot = "${workspaceFolder}",
		},
	}

	dap.configurations.javascript = configs
	dap.configurations.typescript = configs
	dap.configurations.javascriptreact = configs
	dap.configurations.typescriptreact = configs
end

return M
