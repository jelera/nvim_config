--[[
Navigation Keymaps
==================

All navigation-related keymappings for Telescope, nvim-tree, and navigation.
Based on the keymaps from the original dotfiles vim configuration.

Telescope Mappings (FZF replacements):
- <C-p>g: Find all files
- <C-p>p: Find git files (project files)
- <C-p>h: Recent files (oldfiles)
- <C-p>b: Find buffers
- <C-p>c: Git commits
- <C-p>a: Command palette
- <leader>rg: Live grep
- <leader>ag: Grep word under cursor
- \: Quick live grep

Tree Mappings (NERDTree replacement):
- <C-t>: Toggle file explorer
- <C-B>t: Reveal current file in explorer
- <leader>e: Focus file tree
- <leader>tf: Find current file in tree
- <leader>tc: Collapse tree
- <leader>tr: Refresh tree

Extended Navigation:
- Buffer navigation: [b, ]b, <leader>bd, <leader>ba
- Window navigation: <C-hjkl>
- Window resizing: <C-arrows>
- Quickfix: ]q, [q, <leader>qo, <leader>qc
- Tabs: ]t, [t, <leader>tn, <leader>tc
- Location list: ]l, [l, <leader>lo, <leader>lc

Usage:
These keymaps are automatically loaded when navigation.setup() is called.
--]]

local M = {}

---Setup navigation keymaps
---@return boolean success Whether setup succeeded
function M.setup()
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- ==========================================================================
	-- TELESCOPE KEYMAPS (FZF replacements)
	-- ==========================================================================

	-- Main navigation shortcuts (preserved from FZF setup)
	keymap("n", "<C-p>g", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
	keymap("n", "<C-p>p", "<cmd>Telescope git_files<cr>", { desc = "Find git files" })
	keymap("n", "<C-p>h", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
	keymap("n", "<C-p>b", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
	keymap("n", "<C-p>c", "<cmd>Telescope git_commits<cr>", { desc = "Find commits" })
	keymap("n", "<C-p>a", "<cmd>Telescope commands<cr>", { desc = "Command palette" })

	-- Live search mappings
	keymap("n", "<leader>rg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
	keymap("n", "<leader>ag", "<cmd>Telescope grep_string<cr>", { desc = "Grep word under cursor" })
	keymap("n", "\\", "<cmd>Telescope live_grep<cr>", { desc = "Quick live grep" })

	-- Extended Telescope features
	keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
	keymap("n", "<leader>fm", "<cmd>Telescope man_pages<cr>", { desc = "Man pages" })
	keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Show keymaps" })

	-- Git-specific Telescope commands
	keymap("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git branches" })
	keymap("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git status" })

	-- ==========================================================================
	-- NVIM-TREE KEYMAPS (NERDTree replacement)
	-- ==========================================================================

	-- Main tree toggle (preserved from NERDTree)
	keymap("n", "<C-t>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
	keymap("n", "<C-B>t", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in explorer" })

	-- Additional tree commands
	keymap("n", "<leader>e", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file tree" })
	keymap("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { desc = "Find current file in tree" })
	keymap("n", "<leader>tc", "<cmd>NvimTreeCollapse<cr>", { desc = "Collapse tree" })
	keymap("n", "<leader>tr", "<cmd>NvimTreeRefresh<cr>", { desc = "Refresh tree" })

	-- ==========================================================================
	-- BUFFER NAVIGATION
	-- ==========================================================================

	-- Quick buffer switching
	keymap("n", "[b", ":bprevious<CR>", opts)
	keymap("n", "]b", ":bnext<CR>", opts)
	keymap("n", "<leader>bd", ":bdelete<CR>", opts)
	keymap("n", "<leader>ba", ":%bdelete<CR>", opts)

	-- ==========================================================================
	-- WINDOW NAVIGATION
	-- ==========================================================================

	-- Navigate between windows
	keymap("n", "<C-h>", "<C-w>h", opts)
	keymap("n", "<C-j>", "<C-w>j", opts)
	keymap("n", "<C-k>", "<C-w>k", opts)
	keymap("n", "<C-l>", "<C-w>l", opts)

	-- Window resizing
	keymap("n", "<C-Up>", ":resize -2<CR>", opts)
	keymap("n", "<C-Down>", ":resize +2<CR>", opts)
	keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
	keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

	-- ==========================================================================
	-- QUICKFIX LIST NAVIGATION
	-- ==========================================================================

	keymap("n", "]q", ":cnext<CR>", opts)
	keymap("n", "[q", ":cprev<CR>", opts)
	keymap("n", "<leader>qo", ":copen<CR>", opts)
	keymap("n", "<leader>qc", ":cclose<CR>", opts)

	-- ==========================================================================
	-- TAB NAVIGATION
	-- ==========================================================================

	keymap("n", "<leader>tn", ":tabnew<CR>", opts)
	keymap("n", "<leader>tcc", ":tabclose<CR>", opts)
	keymap("n", "]t", ":tabnext<CR>", opts)
	keymap("n", "[t", ":tabprev<CR>", opts)

	-- ==========================================================================
	-- LOCATION LIST NAVIGATION
	-- ==========================================================================

	keymap("n", "]l", ":lnext<CR>", opts)
	keymap("n", "[l", ":lprev<CR>", opts)
	keymap("n", "<leader>lo", ":lopen<CR>", opts)
	keymap("n", "<leader>lc", ":lclose<CR>", opts)

	return true
end

return M
