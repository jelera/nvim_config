--[[
LSP Configuration
=================

Default LSP configuration and server config loading.

Exports:
- default_config - Default LSP settings
- load_server_config(server_name) - Load per-language config

Usage:
```lua
local config = require('modules.lsp.config')
local defaults = config.default_config
local lua_config = config.load_server_config('lua_ls')
```
--]]

local M = {}

---Default LSP configuration
---@type table
M.default_config = {
	-- Core servers to auto-install upfront
	-- NOTE: Only include valid LSP servers available through mason-lspconfig
	-- Tools like actionlint, gitleaks, etc. are not LSP servers and should be
	-- installed separately through Mason or your package manager
	ensure_installed = {
		-- Lua
		"lua_ls",

		-- JavaScript/TypeScript/Node/Angular
		"ts_ls", -- TypeScript/JavaScript LSP
		"eslint", -- JavaScript/TypeScript linter (can be configured for Standard style)
		"angularls", -- Angular Language Service

		-- Python
		"pyright",

		-- Ruby/Rails
		"solargraph", -- Ruby LSP for Rails (intellisense, goto def)
		"ruby_lsp", -- Official Ruby LSP (faster, for non-Rails)
		"rubocop", -- Ruby linter/formatter
		"standardrb", -- Ruby Standard Style (alternative)

		-- Elixir
		"elixirls",

		-- Shell
		"bashls",

		-- Vim Script
		"vimls",

		-- Database
		"postgres_lsp",

		-- Markdown
		"marksman",

		-- Docker
		"dockerls",
		"docker_compose_language_service", -- Docker Compose

		-- Web
		"html",
		"cssls", -- CSS/SCSS
		"emmet_ls", -- Emmet abbreviations

		-- Configuration Files
		"jsonls", -- JSON with SchemaStore validation
		"yamlls", -- YAML with SchemaStore validation
		"taplo", -- TOML language server

		-- Infrastructure/Cloud
		"terraformls",

		-- Go
		"gopls",

		-- Rust
		"rust_analyzer",
	},

	-- Format on save (can be toggled per-buffer)
	format_on_save = true,

	-- Mason UI settings
	mason_ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
}

---Load per-language server configuration
---
---Maps server names to language folders for custom configurations.
---Multiple servers can map to the same language folder, allowing
---multiple LSP servers per language (e.g., ts_ls + eslint for JavaScript).
---
---Example directory structure:
---  servers/
---    javascript/
---      ts_ls.lua      # TypeScript server
---      eslint.lua     # ESLint LSP (if added later)
---    python/
---      pyright.lua    # Pyright server
---      ruff_lsp.lua   # Ruff LSP (if added later)
---
---@param server_name string Server name (e.g., 'lua_ls', 'ts_ls', 'eslint')
---@return table|nil server_config Per-language config or nil if not found
function M.load_server_config(server_name)
	-- Map server names to language folders
	-- NOTE: Multiple servers can map to the same language folder
	-- This allows multiple LSP servers per language (e.g., ts_ls + eslint for JavaScript)
	local server_to_language = {
		-- Lua
		lua_ls = "lua",

		-- JavaScript/TypeScript
		-- (Can add multiple: ts_ls, eslint, angularls, etc.)
		ts_ls = "javascript",
		eslint = "javascript",
		angularls = "angular",

		-- Python
		-- (Can add multiple: pyright, ruff_lsp, etc.)
		pyright = "python",

		-- Ruby
		solargraph = "ruby",
		ruby_lsp = "ruby",
		rubocop = "ruby",
		standardrb = "ruby",

		-- Bash
		bashls = "bash",

		-- PostgreSQL
		postgres_lsp = "postgresql",

		-- Markdown
		marksman = "markdown",

		-- Docker
		dockerls = "docker",

		-- HTML
		html = "html",

		-- CSS/SCSS
		cssls = "css",

		-- Terraform
		terraformls = "terraform",

		-- Elixir
		elixirls = "elixir",

		-- Vim Script
		vimls = "vim",

		-- Configuration Files
		jsonls = "json",
		yamlls = "yaml",
		taplo = "toml",

		-- Docker Compose
		docker_compose_language_service = "docker",

		-- Go
		gopls = "go",

		-- Rust
		rust_analyzer = "rust",

		-- Emmet
		emmet_ls = "emmet",

		-- GitHub Copilot
		copilot = "copilot",
	}

	local language = server_to_language[server_name]
	if not language then
		return nil
	end

	-- Build config path: modules.lsp.servers.<language>.<server_name>
	local config_path = "modules.lsp.servers." .. language .. "." .. server_name
	local ok, server_config = pcall(require, config_path)

	if ok then
		return server_config
	end

	return nil
end

return M
