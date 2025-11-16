--[[
LSP Module Plugins
==================

Plugin specifications for LSP (Language Server Protocol) and related tools.
Include these in your lazy.nvim setup:

```lua
local lsp_plugins = require('modules.lsp.plugins')
require('lazy').setup(lsp_plugins)
```

Or merge with your own plugins:
```lua
local lsp_plugins = require('modules.lsp.plugins')
require('lazy').setup(vim.list_extend(lsp_plugins, {
  -- Your custom plugins here
}))
```
--]]

return {
	-- LSP configuration (defer to FileType for performance)
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" }, -- Load before file content is read
		config = false, -- We'll configure it in modules.lsp
	},

	-- Mason - LSP server installer with UI
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" }, -- Lazy-load on commands
		config = false,
	},

	-- SchemaStore - JSON/YAML schema catalog integration
	{
		"b0o/schemastore.nvim",
		lazy = true, -- Only load when required by LSP servers
	},

	-- Bridge between Mason and nvim-lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"b0o/schemastore.nvim", -- Schema validation for JSON/YAML
		},
		event = { "BufReadPre", "BufNewFile" }, -- Load with lspconfig
		config = function()
			-- Auto-configure LSP when plugins load
			local ok, lsp_module = pcall(require, "modules.lsp")
			if ok and lsp_module.setup then
				lsp_module.setup()
			end
		end,
	},

	-- LSP capabilities for nvim-cmp (completion)
	{
		"hrsh7th/cmp-nvim-lsp",
		event = { "BufReadPre", "BufNewFile" }, -- Load with lspconfig
		config = false,
	},
}
