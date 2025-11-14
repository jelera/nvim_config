--[[
NeoVim IDE Framework Bootstrap
================================

This file serves as the entry point for Neovim and initializes the
NeoVim IDE framework.
--]]

-- Bootstrap the nvim framework
local nvim = require("nvim")

-- Configure PATH to include mise-managed tools
-- This ensures Mason and other plugins can find tools like go, node, etc.
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(mise_shims) == 1 then
	vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end

-- Collect all plugin specifications from modules
local plugins = {}

-- Load plugin specs from each module that has plugins
-- Order optimized for startup performance:
-- 1. Essential modules (ui for colorscheme, core functionality)
-- 2. Frequently used modules (completion, treesitter, navigation, git, editor)
-- 3. Heavy/optional modules (test, debug, frameworks, ai)
local module_names = {
	"ui",        -- Load first: colorscheme needed immediately
	"tooling",   -- Lightweight: just returns true (plugins self-configure)
	"completion",-- Essential: completion setup
	"treesitter",-- Essential: syntax highlighting
	"navigation",-- Frequently used: telescope, file tree
	"git",       -- Frequently used: git signs, fugitive
	"editor",    -- Frequently used: autopairs, surround, comments
	"lsp",       -- Now lazy-loaded, kept in list for plugin specs
	"ai",        -- Optional: AI assistance
	"test",      -- Heavy: testing framework (rarely used at startup)
	"debug",     -- Heavy: debugging (rarely used at startup)
	"frameworks",-- Heavy: Rails/Angular specific (rarely used at startup)
}

for _, module_name in ipairs(module_names) do
	local ok, module_plugins = pcall(require, "modules." .. module_name .. ".plugins")
	if ok then
		vim.list_extend(plugins, module_plugins)
	end
end

-- Initialize core modules first (options, keymaps, autocmds, commands)
-- These don't depend on plugins
require("modules.core").setup()

-- Initialize the framework with plugins
-- Pass plugins directly as the spec for lazy.nvim
nvim.setup({
	spec = plugins,
	-- Configure lazy.nvim to initialize our modules after plugins load
	install = {
		missing = true,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Initialize modules after plugins are loaded
-- Use vim.schedule to defer until after lazy.nvim completes
-- Note: LSP module now self-configures when plugins load (BufReadPre/BufNewFile)
vim.schedule(function()
	-- Priority modules: load immediately (essential for editor functionality)
	local priority_modules = { "ui", "tooling", "completion", "treesitter", "navigation", "git", "editor" }

	for _, module_name in ipairs(priority_modules) do
		local ok, module = pcall(require, "modules." .. module_name)
		if ok and module.setup then
			local setup_ok, setup_err = pcall(module.setup)
			if not setup_ok then
				vim.notify(string.format("Failed to setup %s module: %s", module_name, setup_err), vim.log.levels.WARN)
			end
		end
	end

	-- Deferred modules: load 100ms later (optional/heavy features)
	-- These are test, debug, frameworks, ai - rarely needed at startup
	vim.defer_fn(function()
		local deferred_modules = { "ai", "test", "debug", "frameworks" }

		for _, module_name in ipairs(deferred_modules) do
			local ok, module = pcall(require, "modules." .. module_name)
			if ok and module.setup then
				local setup_ok, setup_err = pcall(module.setup)
				if not setup_ok then
					vim.notify(string.format("Failed to setup %s module: %s", module_name, setup_err), vim.log.levels.WARN)
				end
			end
		end
	end, 100) -- Delay 100ms
end)
