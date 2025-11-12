--[[
Completion Configuration
=========================

Configures nvim-cmp completion engine with sources, keymaps, and formatting.

Features:
- Multiple completion sources (LSP, snippets, buffer, path)
- Command-line completion (search and commands)
- Menu formatting with source labels
- Super-tab keymaps for completion navigation
- Smart completion behavior

API:
- setup(config) - Initialize nvim-cmp with configuration

Usage:
```lua
local completion = require('modules.completion.completion')
completion.setup()
```
--]]

local M = {}

---Setup nvim-cmp completion
---@param config? table Optional configuration (for future extensibility)
---@return boolean success Whether setup succeeded
function M.setup(_config)
	_config = _config or {}

	-- Load nvim-cmp
	local ok, cmp = pcall(require, "cmp")
	if not ok then
		vim.notify("nvim-cmp not found. Completion disabled.", vim.log.levels.WARN)
		return false
	end

	-- Get LuaSnip (for snippet expansion)
	local snippets = require("modules.completion.snippets")
	local luasnip = snippets.get_luasnip()

	-- Configure nvim-cmp
	cmp.setup({
		-- Snippet engine
		snippet = {
			expand = function(args)
				if luasnip then
					return luasnip.lsp_expand(args.body)
				end
			end,
		},

		-- Completion sources (priority order)
		sources = cmp.config.sources({
			{ name = "nvim_lsp" }, -- LSP completions (highest priority)
			{ name = "luasnip" }, -- Snippet completions
		}, {
			{ name = "buffer" }, -- Buffer word completions
			{ name = "path" }, -- Filesystem path completions
		}),

		-- Keymaps
		mapping = cmp.mapping.preset.insert({
			["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion
			["<C-e>"] = cmp.mapping.abort(), -- Close completion
			["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection

			-- Tab for completion navigation
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip and luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),

			-- Shift-Tab for previous item
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip and luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),

			-- Ctrl+n/p for completion navigation
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
		}),

		-- Menu formatting
		formatting = {
			format = function(entry, vim_item)
				-- Add source name
				vim_item.menu = ({
					nvim_lsp = "[LSP]",
					luasnip = "[Snippet]",
					buffer = "[Buffer]",
					path = "[Path]",
				})[entry.source.name]
				return vim_item
			end,
		},

		-- Completion behavior
		completion = {
			completeopt = "menu,menuone,noinsert",
		},
	})

	-- Command-line completion
	-- Try both old and new nvim-cmp cmdline APIs for compatibility
	local cmdline_setup_fn = cmp.setup_cmdline or (cmp.setup and cmp.setup.cmdline)

	if cmdline_setup_fn then
		-- `/` and `?` for search
		local search_ok = pcall(cmdline_setup_fn, { "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- `:` for commands
		local cmd_ok = pcall(cmdline_setup_fn, ":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})

		if not (search_ok and cmd_ok) then
			vim.notify("Command-line completion setup had issues", vim.log.levels.DEBUG)
		end
	end

	return true
end

return M
