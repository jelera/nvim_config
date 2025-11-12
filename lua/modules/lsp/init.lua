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

---Load required plugins for LSP
---@return boolean success, table plugins Plugin loading success and loaded plugins
local function load_required_plugins()
	local plugins = {}
	local plugin_list = {
		{ name = "mason", message = "mason.nvim not found" },
		{ name = "mason-lspconfig", message = "mason-lspconfig.nvim not found" },
		{ name = "lspconfig", message = "nvim-lspconfig not found" },
		{ name = "cmp_nvim_lsp", message = "cmp-nvim-lsp not found" },
	}

	for _, plugin_info in ipairs(plugin_list) do
		local ok, plugin = pcall(require, plugin_info.name)
		if not ok then
			vim.notify(plugin_info.message, vim.log.levels.WARN, { title = "LSP Module" })
			return false, nil
		end
		plugins[plugin_info.name] = plugin
	end

	return true, plugins
end

---Build list of servers to enable based on project detection
---@param ruby_config table Ruby project configuration
---@param js_config table JavaScript project configuration
---@return table servers_to_enable Map of server names to enable
local function build_servers_list(ruby_config, js_config)
	local servers_to_enable = {}

	-- Add Ruby servers based on detection
	for _, server in ipairs(ruby_config.servers) do
		servers_to_enable[server] = true
	end

	-- Add JavaScript servers based on detection
	for _, server in ipairs(js_config.servers) do
		servers_to_enable[server] = true
	end

	-- Add language-agnostic servers
	local servers_to_configure = {
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

	for _, server in ipairs(servers_to_configure) do
		servers_to_enable[server] = true
	end

	return servers_to_enable
end

---Setup special servers (gopls, copilot) that are managed outside Mason
---@param servers_to_enable table Map of enabled servers
---@param capabilities table LSP capabilities
---@param on_attach function On attach callback
local function setup_special_servers(servers_to_enable, capabilities, on_attach)
	-- Configure gopls manually (managed by mise, not mason)
	if vim.fn.executable("gopls") == 1 and servers_to_enable["gopls"] then
		local gopls_config = lsp_config.load_server_config("gopls") or {}
		local final_gopls_config = utils.deep_merge({
			capabilities = capabilities,
			on_attach = on_attach,
		}, gopls_config)

		pcall(function()
			vim.lsp.config("gopls", final_gopls_config)
			vim.lsp.enable("gopls")
		end)
	end

	-- Configure copilot manually (installed via npm, not mason)
	if vim.fn.executable("copilot-language-server") == 1 then
		local copilot_config = lsp_config.load_server_config("copilot") or {}
		local final_copilot_config = utils.deep_merge({
			capabilities = capabilities,
			on_attach = on_attach,
		}, copilot_config)

		pcall(function()
			vim.lsp.config("copilot", final_copilot_config)
			vim.lsp.enable("copilot")
		end)
	end
end

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
	local plugins_ok, plugins = load_required_plugins()
	if not plugins_ok then
		return false
	end

	local mason = plugins["mason"]
	local mason_lspconfig = plugins["mason-lspconfig"]
	local cmp_nvim_lsp = plugins["cmp_nvim_lsp"]

	-- Setup Mason
	local mason_setup_ok, mason_err = pcall(function()
		mason.setup({ ui = merged_config.mason_ui })
	end)

	if not mason_setup_ok then
		local message = "Failed to setup Mason: " .. tostring(mason_err)
		vim.notify(message, vim.log.levels.ERROR, { title = "LSP Module" })
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
	local servers_to_enable = build_servers_list(ruby_config, js_config)

	-- Setup mason-lspconfig with handlers
	-- Servers are registered but lazy-loaded (they auto-start when you open a matching filetype)
	-- Filter out gopls from ensure_installed since it's managed by mise
	-- gopls will still be configured (it's in servers_to_configure), but installed via mise instead of mason
	local filtered_ensure_installed = {}
	for _, server in ipairs(merged_config.ensure_installed) do
		if server ~= "gopls" then
			table.insert(filtered_ensure_installed, server)
		end
	end

	local mason_lsp_setup_ok, mason_lsp_err = pcall(function()
		mason_lspconfig.setup({
			ensure_installed = filtered_ensure_installed,
			automatic_installation = false, -- We control which servers to enable
			handlers = {
				-- Default handler - called for each installed server
				function(server_name)
					-- Only configure servers that are appropriate for this project
					if servers_to_enable[server_name] then
						-- Load per-language config if it exists
						local server_config = lsp_config.load_server_config(server_name) or {}

						-- Merge our config (capabilities, on_attach) with per-language config
						-- vim.lsp.config() will automatically use lspconfig defaults (cmd, filetypes, root_dir, etc.)
						local final_config = utils.deep_merge({
							capabilities = capabilities,
							on_attach = on_attach,
						}, server_config)

						-- Register and enable the server configuration (will auto-start on matching filetype)
						local setup_ok, setup_err = pcall(function()
							vim.lsp.config(server_name, final_config)
							vim.lsp.enable(server_name)
						end)

						if not setup_ok then
							vim.notify(
								string.format("Failed to configure LSP server %s: %s", server_name, setup_err),
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

	-- Setup special servers (gopls, copilot) that are managed outside Mason
	setup_special_servers(servers_to_enable, capabilities, on_attach)

	return true
end

return M
