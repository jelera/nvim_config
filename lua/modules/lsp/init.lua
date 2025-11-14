--[[
LSP Module
==========

Unified LSP (Language Server Protocol) configuration with Mason installer.

Features:
- Auto-install LSP servers via Mason
- All LSP features (go-to, hover, diagnostics, etc.)
- Format on save (toggleable per buffer)
- Per-language server customization

Dependencies:
All plugins should be installed via lazy.nvim.
See modules/lsp/plugins.lua for the plugin list.

Usage:
```lua
local lsp = require('modules.lsp')

-- Setup with defaults (auto-installs core servers)
lsp.setup()

-- Setup with custom config
lsp.setup({
  ensure_installed = { 'lua_ls', 'pyright' },
  format_on_save = true,
})
```

API:
- setup(config) - Initialize LSP with Mason and servers
--]]

local M = {}

local utils = require("nvim.lib.utils")
local lsp_config = require("modules.lsp.config")
local event_handlers = require("modules.lsp.event_handlers")
local diagnostics = require("modules.lsp.diagnostics")

---Setup LSP module
---@param config table|nil Configuration options
---@param config.ensure_installed table|nil List of servers to auto-install
---@param config.automatic_installation boolean|nil Auto-install on file open
---@param config.format_on_save boolean|nil Format on save (default: false)
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge config with defaults using shared utility
	local merged_config = utils.merge_config(lsp_config.default_config, config)

	-- Load required plugins
	local mason_ok, mason = pcall(require, "mason")
	if not mason_ok then
		vim.notify("mason.nvim not found", vim.log.levels.WARN, { title = "LSP Module" })
		return false
	end

	local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if not mason_lsp_ok then
		vim.notify("mason-lspconfig.nvim not found", vim.log.levels.WARN, { title = "LSP Module" })
		return false
	end

	-- Load nvim-lspconfig to make configs available to vim.lsp.config
	-- We don't need to use lspconfig directly, just ensure it's loaded
	-- so that vim.lsp.config can find the server configurations
	local lspconfig_ok = pcall(require, "lspconfig")
	if not lspconfig_ok then
		vim.notify("nvim-lspconfig not found", vim.log.levels.WARN, { title = "LSP Module" })
		return false
	end

	local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if not cmp_lsp_ok then
		vim.notify("cmp-nvim-lsp not found", vim.log.levels.WARN, { title = "LSP Module" })
		return false
	end

	-- Setup Mason
	local mason_setup_ok, mason_err = pcall(function()
		mason.setup({ ui = merged_config.mason_ui })
	end)

	if not mason_setup_ok then
		vim.notify("Failed to setup Mason: " .. tostring(mason_err), vim.log.levels.ERROR, { title = "LSP Module" })
		return false
	end

	-- Setup diagnostics
	diagnostics.setup()

	-- Get default capabilities from cmp_nvim_lsp
	local capabilities = cmp_nvim_lsp.default_capabilities()

	-- Create on_attach callback with project detection
	local on_attach = event_handlers.create_on_attach(merged_config)

	-- Load project detection modules
	local ruby_detection = require("modules.lsp.detection.ruby")
	local js_detection = require("modules.lsp.detection.javascript")

	-- Detect project configuration
	local ruby_config = ruby_detection.detect()
	local js_config = js_detection.detect()

	-- Build list of servers to enable based on project detection
	local servers_to_enable = {}

	-- Add Ruby servers based on detection
	for _, server in ipairs(ruby_config.servers) do
		servers_to_enable[server] = true
	end

	-- Add JavaScript servers based on detection
	for _, server in ipairs(js_config.servers) do
		servers_to_enable[server] = true
	end

	-- Add language-agnostic servers (always enable)
	local always_enable = {
		"lua_ls",
		"pyright",
		"bashls",
		"vimls",
		"postgres_lsp",
		"marksman",
		"dockerls",
		"docker_compose_language_service",
		"html",
		"cssls",
		"emmet_ls",
		"yamlls",
		"terraformls",
		"elixirls",
		"gopls",
		"rust_analyzer",
	}

	for _, server in ipairs(always_enable) do
		servers_to_enable[server] = true
	end

	-- Setup mason-lspconfig with handlers
	-- This approach ensures servers are configured as they become available
	local mason_lsp_setup_ok, mason_lsp_err = pcall(function()
		mason_lspconfig.setup({
			ensure_installed = merged_config.ensure_installed,
			automatic_installation = false, -- We control which servers to enable
			handlers = {
				-- Default handler - called for each installed server
				function(server_name)
					-- Only enable servers that are appropriate for this project
					if servers_to_enable[server_name] then
						-- Load per-language config if it exists
						local server_config = lsp_config.load_server_config(server_name) or {}

						-- Merge with default settings
						local final_config = utils.deep_merge({
							capabilities = capabilities,
							on_attach = on_attach,
						}, server_config)

						-- Setup the server using the new Neovim 0.11 vim.lsp.config API
						local setup_ok, setup_err = pcall(function()
							vim.lsp.config(server_name, final_config)
							vim.lsp.enable(server_name)
						end)

						if not setup_ok then
							vim.notify(
								string.format("Failed to setup LSP server %s: %s", server_name, setup_err),
								vim.log.levels.WARN,
								{ title = "LSP Module" }
							)
						end
					end
				end,
			},
		})
	end)

	if not mason_lsp_setup_ok then
		vim.notify(
			"Failed to setup mason-lspconfig: " .. tostring(mason_lsp_err),
			vim.log.levels.ERROR,
			{ title = "LSP Module" }
		)
		return false
	end

	return true
end

return M
