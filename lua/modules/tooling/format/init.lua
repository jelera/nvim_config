--[[
Format Module
=============

Provides automatic code formatting via conform.nvim.
Replaces the old ALE fixers configuration.

Strategy:
- Format on save for most file types
- Use language-specific formatters (organized in separate files)
- Always trim whitespace and trailing newlines for all files
- LSP formatting as fallback when no formatter is configured

Organization:
- format/ruby.lua - Ruby/ERB (smart standardrb vs rubocop selection)
- format/javascript.lua - JS/TS (eslint_d with prettier integration)
- format/web.lua - HTML/CSS/SCSS/Less
- format/config.lua - YAML/JSON/Markdown
- format/lua.lua - Lua
- format/python.lua - Python
- format/shell.lua - Shell scripts

Keymaps:
- <leader>cf: Manual format (works in normal and visual mode)
--]]

local M = {}

---Setup formatting with conform.nvim
---@param _config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(_config)

	-- Try to load conform.nvim
	local ok, conform = pcall(require, "conform")
	if not ok then
		-- Plugin not loaded yet, return true (will be lazy-loaded)
		return true
	end

	-- Load formatter modules
	local ruby = require("modules.tooling.format.ruby")
	local javascript = require("modules.tooling.format.javascript")
	local web = require("modules.tooling.format.web")
	local config_fmt = require("modules.tooling.format.config")
	local lua_fmt = require("modules.tooling.format.lua")
	local python = require("modules.tooling.format.python")
	local shell = require("modules.tooling.format.shell")

	-- Merge all formatter configs
	local formatter_configs = vim.tbl_extend(
		"force",
		ruby.get_formatter_configs(),
		javascript.get_formatter_configs(),
		shell.get_formatter_configs()
	)

	-- Configure formatters by filetype
	conform.setup({
		formatters_by_ft = {
			-- JavaScript/TypeScript
			javascript = javascript.get_formatters(),
			javascriptreact = javascript.get_formatters(),
			typescript = javascript.get_formatters(),
			typescriptreact = javascript.get_formatters(),

			-- Ruby/ERB
			ruby = ruby.get_formatters(),
			eruby = ruby.get_erb_formatters(),

			-- Web
			html = web.get_html_formatters(),
			css = web.get_css_formatters(),
			scss = web.get_scss_formatters(),
			less = web.get_less_formatters(),

			-- Config files
			yaml = config_fmt.get_yaml_formatters(),
			json = config_fmt.get_json_formatters(),
			jsonc = config_fmt.get_jsonc_formatters(),
			markdown = config_fmt.get_markdown_formatters(),

			-- Lua
			lua = lua_fmt.get_formatters(),

			-- Python
			python = python.get_formatters(),

			-- Shell
			sh = shell.get_formatters(),
			bash = shell.get_formatters(),

			-- All files: trim whitespace and newlines
			["*"] = { "trim_whitespace", "trim_newlines" },
		},

		-- Format on save
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},

		-- Formatter-specific options
		formatters = formatter_configs,
	})

	-- Add keymap for manual formatting
	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		conform.format({
			lsp_fallback = true,
			async = false,
			timeout_ms = 500,
		})
	end, { desc = "Format file or range (in visual mode)" })

	return true
end

return M
