--[[
Debug Adapters Configuration
=============================

Loads language-specific debug adapters for nvim-dap on-demand via FileType autocmds.

Supported Languages:
- JavaScript/TypeScript (vscode-js-debug via nvim-dap-vscode-js)
- Python (debugpy)
- Ruby (rdbg/debug gem)
- Lua (local-lua-debugger-vscode)

Adapters are organized by language in adapters/<language>.lua and loaded
lazily when files of the corresponding filetype are opened. This prevents
warnings on startup and improves performance.

Dependencies:
- mfussenegger/nvim-dap
- mxsdev/nvim-dap-vscode-js (for JS/TS)
- Mason for adapter installation

API:
- setup(config) - Configure debug adapters with lazy loading
--]]

local M = {}

---Default configuration
local default_config = {
	-- Mapping of filetypes to adapter modules
	adapters = {
		javascript = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		python = { "python" },
		ruby = { "ruby" },
		lua = { "lua" },
	},
}

-- Track which adapters have been loaded
local loaded_adapters = {}

---Load and setup language adapter
---@param adapter_name string Adapter module name (e.g., 'javascript')
---@param dap table nvim-dap module
local function load_adapter(adapter_name, dap)
	-- Skip if already loaded
	if loaded_adapters[adapter_name] then
		return true
	end

	local adapter_module = "modules.debug.adapters." .. adapter_name
	local ok, adapter = pcall(require, adapter_module)
	if not ok then
		local message = string.format("Failed to load debug adapter for %s", adapter_name)
		vim.notify(message, vim.log.levels.WARN)
		return false
	end

	-- Setup the adapter
	local setup_ok, setup_err = pcall(adapter.setup, dap)
	if not setup_ok then
		vim.notify(
			string.format("Failed to setup debug adapter for %s: %s", adapter_name, setup_err),
			vim.log.levels.WARN
		)
		return false
	end

	-- Mark as loaded
	loaded_adapters[adapter_name] = true
	return true
end

---Setup debug adapters with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Create autocommands to lazy-load adapters based on filetype
	local adapters = merged_config.adapters or default_config.adapters

	for adapter_name, filetypes in pairs(adapters) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			once = false, -- Keep the autocmd active
			callback = function()
				-- Try to load nvim-dap plugin
				local ok, dap = pcall(require, "dap")
				if ok then
					load_adapter(adapter_name, dap)
				end
			end,
			desc = string.format("Load %s debug adapter", adapter_name),
		})
	end

	return true
end

return M
