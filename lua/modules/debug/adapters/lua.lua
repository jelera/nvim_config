--[[
Lua Debug Adapter
=================

DAP adapter for Lua debugging using local-lua-debugger-vscode.
--]]

local M = {}

function M.setup(dap)
	dap.adapters["local-lua"] = {
		type = "executable",
		command = "node",
		args = {
			vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.js",
		},
		enrich_config = function(config, on_config)
			if not config["extensionPath"] then
				local c = vim.deepcopy(config)
				c.extensionPath = vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/"
				on_config(c)
			else
				on_config(config)
			end
		end,
	}

	dap.configurations.lua = {
		{
			type = "local-lua",
			request = "launch",
			name = "Launch file",
			cwd = "${workspaceFolder}",
			program = {
				lua = "lua",
				file = "${file}",
			},
		},
	}
end

return M
