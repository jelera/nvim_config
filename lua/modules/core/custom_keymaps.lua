--[[
Custom Keymaps Module
=====================

Custom keymaps ported from old vimrc configuration.
These extend the core keymaps with workflow-specific mappings.

Categories:
- Utility: Helper functions (syntax inspection, whitespace cleanup, documentation)
- Clipboard: System clipboard integration (cut, copy, smart paste)
- Spelling: Spell checking controls

Note: Telescope and Neotest keymaps are in their respective plugin modules:
- Telescope: lua/modules/navigation/keymaps.lua
- Neotest: lua/modules/test/keymaps.lua

Usage:
```lua
require('modules.core.custom_keymaps').setup()
```
--]]

local M = {}

---Show syntax highlighting groups under cursor
---Useful for debugging colorscheme and treesitter highlighting
local function show_syntax_groups()
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	local syn_ids = vim.fn.synstack(line, col)

	if #syn_ids == 0 then
		print("No syntax groups at cursor")
		return
	end

	local groups = {}
	for _, id in ipairs(syn_ids) do
		table.insert(groups, vim.fn.synIDattr(id, "name"))
	end

	print("Syntax groups: " .. table.concat(groups, " > "))
end

---Strip trailing whitespace from entire file
---Preserves cursor position and search register
local function strip_trailing_whitespace()
	local save_cursor = vim.fn.getpos(".")
	local old_query = vim.fn.getreg("/")

	-- Remove trailing whitespace
	vim.cmd([[%s/\s\+$//e]])

	-- Restore cursor and search register
	vim.fn.setpos(".", save_cursor)
	vim.fn.setreg("/", old_query)

	print("Stripped trailing whitespace")
end

---Setup custom keymaps
---@return boolean success Whether setup succeeded
function M.setup()
	local keymap = vim.keymap.set

	-- ============================================================================
	-- Utility Mappings
	-- ============================================================================

	-- Show syntax highlighting groups under cursor (for debugging colorschemes)
	keymap("n", "<leader>syn", show_syntax_groups, {
		noremap = true,
		silent = true,
		desc = "Show syntax groups",
	})

	-- Strip trailing whitespace
	keymap("n", "<leader>nw", strip_trailing_whitespace, {
		noremap = true,
		silent = true,
		desc = "Strip trailing whitespace",
	})

	-- Documentation headers (underline with = or -)
	keymap("n", "<leader>h1", "yypVr=o<Esc>", {
		noremap = true,
		desc = "Create H1 header (=== underline)",
	})
	keymap("n", "<leader>h2", "yypVr-o<Esc>", {
		noremap = true,
		desc = "Create H2 header (--- underline)",
	})

	-- ============================================================================
	-- Clipboard Mappings (System Clipboard Integration)
	-- ============================================================================

	-- Cut to system clipboard (visual mode)
	keymap("v", "<C-X>", '"+x', { noremap = true, desc = "Cut to system clipboard" })

	-- Copy to system clipboard (visual mode)
	keymap("v", "<C-C>", '"+y', { noremap = true, desc = "Copy to system clipboard" })

	-- Smart paste from system clipboard with auto-indent
	keymap("n", "<leader>v", "\"+P=']", { noremap = true, desc = "Paste from clipboard with indent" })

	-- ============================================================================
	-- Spell Checking
	-- ============================================================================

	-- Toggle spell checking
	keymap("n", "<leader>spl", ":setlocal spell!<CR>", {
		noremap = true,
		silent = true,
		desc = "Toggle spell check",
	})

	-- Note: Telescope and Neotest keymaps are configured in their respective modules
	-- - Telescope keymaps: lua/modules/navigation/keymaps.lua
	-- - Neotest keymaps: lua/modules/test/keymaps.lua
	-- This avoids warnings about plugins not being loaded during core initialization

	return true
end

return M
