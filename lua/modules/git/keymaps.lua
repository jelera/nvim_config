--[[
Git Keymaps
===========

Defines all git-related key mappings.

Keymaps:
- <leader>gs - Git status
- <leader>gc - Git commit
- <leader>gp - Git push
- <leader>gl - Git pull
- <leader>gb - Git blame
- <leader>gd - Git diff
- <leader>gh - Preview hunk
- <leader>gH - Reset hunk
- <leader>gS - Stage hunk
- <leader>gR - Reset buffer
- ]h - Next hunk
- [h - Previous hunk

API:
- setup() - Setup git keymaps
--]]

local M = {}

---Setup git keymaps
---@return boolean success Whether setup succeeded
function M.setup()
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- Fugitive keymaps
	keymap("n", "<leader>gs", "<cmd>Git<cr>", vim.tbl_extend("force", opts, { desc = "Git status" }))
	local gc_opts = vim.tbl_extend("force", opts, { desc = "Git commit" })
	keymap("n", "<leader>gc", "<cmd>Git commit<cr>", gc_opts)
	local gp_opts = vim.tbl_extend("force", opts, { desc = "Git push" })
	keymap("n", "<leader>gp", "<cmd>Git push<cr>", gp_opts)
	local gl_opts = vim.tbl_extend("force", opts, { desc = "Git pull" })
	keymap("n", "<leader>gl", "<cmd>Git pull<cr>", gl_opts)
	local gb_opts = vim.tbl_extend("force", opts, { desc = "Git blame" })
	keymap("n", "<leader>gb", "<cmd>Git blame<cr>", gb_opts)
	local gd_opts = vim.tbl_extend("force", opts, { desc = "Git diff" })
	keymap("n", "<leader>gd", "<cmd>Git diff<cr>", gd_opts)

	-- Gitsigns keymaps (using gitsigns functions)
	keymap("n", "]h", function()
		if vim.wo.diff then
			return "]c"
		end
		vim.schedule(function()
			local ok, gitsigns = pcall(require, "gitsigns")
			if ok then
				gitsigns.next_hunk()
			end
		end)
		return "<Ignore>"
	end, vim.tbl_extend("force", opts, { expr = true, desc = "Next hunk" }))

	keymap("n", "[h", function()
		if vim.wo.diff then
			return "[c"
		end
		vim.schedule(function()
			local ok, gitsigns = pcall(require, "gitsigns")
			if ok then
				gitsigns.prev_hunk()
			end
		end)
		return "<Ignore>"
	end, vim.tbl_extend("force", opts, { expr = true, desc = "Previous hunk" }))

	keymap("n", "<leader>gh", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.preview_hunk()
		end
	end, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))

	keymap("n", "<leader>gH", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.reset_hunk()
		end
	end, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))

	keymap("n", "<leader>gS", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.stage_hunk()
		end
	end, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))

	keymap("v", "<leader>gS", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end
	end, vim.tbl_extend("force", opts, { desc = "Stage hunk (visual)" }))

	keymap("n", "<leader>gR", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.reset_buffer()
		end
	end, vim.tbl_extend("force", opts, { desc = "Reset buffer" }))

	keymap("n", "<leader>gB", function()
		local ok, gitsigns = pcall(require, "gitsigns")
		if ok then
			gitsigns.toggle_current_line_blame()
		end
	end, vim.tbl_extend("force", opts, { desc = "Toggle blame" }))

	-- Diffview keymaps
	local gdo_opts = vim.tbl_extend("force", opts, { desc = "Open diffview" })
	keymap("n", "<leader>gdo", "<cmd>DiffviewOpen<cr>", gdo_opts)
	local gdc_opts = vim.tbl_extend("force", opts, { desc = "Close diffview" })
	keymap("n", "<leader>gdc", "<cmd>DiffviewClose<cr>", gdc_opts)
	local gdt_opts = vim.tbl_extend("force", opts, { desc = "Toggle files" })
	keymap("n", "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", gdt_opts)
	local gdh_opts = vim.tbl_extend("force", opts, { desc = "File history" })
	keymap("n", "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", gdh_opts)
	keymap(
		"n",
		"<leader>gdf",
		"<cmd>DiffviewFileHistory %<cr>",
		vim.tbl_extend("force", opts, { desc = "Current file history" })
	)

	return true
end

return M
