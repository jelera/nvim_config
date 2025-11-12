--[[
Git Commit Message Configuration
=================================

Configures git commit messages and fugitive buffers for a better commit experience.

Features:
- Spell checking for commit messages
- Proper text width and color column (72 chars)
- Format options for automatic formatting
- No line numbers in git buffers
- Optional 'par' formatter support

Ported from old vimrc (lines 376-387)
--]]

local M = {}

function M.setup()
	-- Create autocommand group for git commit settings
	local git_commit_group = vim.api.nvim_create_augroup("GitCommit", { clear = true })

	-- ============================================================================
	-- FUGITIVE BUFFERS
	-- ============================================================================
	-- Disable line numbers in fugitive status buffers
	vim.api.nvim_create_autocmd("FileType", {
		group = git_commit_group,
		pattern = "fugitive",
		callback = function()
			vim.opt_local.number = false
		end,
		desc = "Disable line numbers in fugitive buffers",
	})

	-- ============================================================================
	-- GIT COMMIT MESSAGES
	-- ============================================================================
	vim.api.nvim_create_autocmd("FileType", {
		group = git_commit_group,
		pattern = "gitcommit",
		callback = function()
			-- Disable line numbers
			vim.opt_local.number = false

			-- Enable spell checking for commit messages
			vim.opt_local.spell = true

			-- Set textwidth to 72 characters (git best practice)
			vim.opt_local.textwidth = 72

			-- Add visual guide at column 72
			vim.opt_local.colorcolumn = "72"

			-- Format options for commit messages:
			-- t = Auto-wrap text using textwidth
			-- n = Recognize numbered lists when formatting
			-- Add these to existing formatoptions
			-- Remove 'l' (long lines not broken in insert mode)
			vim.opt_local.formatoptions:append("tn")
			vim.opt_local.formatoptions:remove("l")

			-- If 'par' text formatter is available, use it for formatting
			-- par is a paragraph reformatter that produces better results
			-- Install with: brew install par (macOS) or apt-get install par (Linux)
			if vim.fn.executable("par") == 1 then
				vim.opt_local.formatprg = "par -w72"
			end
		end,
		desc = "Configure git commit message editing",
	})

	return true
end

return M
