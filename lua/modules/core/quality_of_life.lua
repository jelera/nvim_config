-- Quality of Life Features
-- Ported from old vimrc Phase 6 features

local M = {}

function M.setup()
	-- Create autocommand group for QOL features
	local qol_group = vim.api.nvim_create_augroup("QualityOfLife", { clear = true })

	-- ============================================================================
	-- AUTO-CREATE PARENT DIRECTORIES ON SAVE
	-- ============================================================================
	-- Creates missing parent directories when saving a file
	-- From vimrc:1189-1199
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = qol_group,
		callback = function(args)
			local buftype = vim.bo[args.buf].buftype
			local file = args.file

			-- Only for normal files (not special buffers like help, terminal, etc)
			-- And not for special protocols (http://, ftp://, etc)
			if buftype == "" and not file:match("^%w+://") then
				local dir = vim.fn.fnamemodify(file, ":h")
				if vim.fn.isdirectory(dir) == 0 then
					vim.fn.mkdir(dir, "p")
				end
			end
		end,
		desc = "Auto-create parent directories on save",
	})

	-- ============================================================================
	-- SAVE ON FOCUS LOST
	-- ============================================================================
	-- Auto-save all buffers when losing focus
	-- From vimrc:1184
	vim.api.nvim_create_autocmd("FocusLost", {
		group = qol_group,
		callback = function()
			-- Use pcall to avoid errors if there are no files to save
			pcall(vim.cmd, "wa")
		end,
		desc = "Save all buffers on focus lost",
	})

	-- ============================================================================
	-- OPEN AT LAST EDIT POSITION
	-- ============================================================================
	-- Jump to the last known cursor position when opening a file
	-- From vimrc:1187
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = qol_group,
		callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			local line_count = vim.api.nvim_buf_line_count(0)

			-- If mark is valid and within file bounds, jump to it
			if mark[1] > 0 and mark[1] <= line_count then
				vim.api.nvim_win_set_cursor(0, mark)
			end
		end,
		desc = "Open file at last edit position",
	})

	-- ============================================================================
	-- HELP WINDOW SETUP
	-- ============================================================================
	-- Move help windows to the right and configure them nicely
	-- From vimrc:1172-1176
	vim.api.nvim_create_autocmd("FileType", {
		group = qol_group,
		pattern = "help",
		callback = function()
			-- Move window to far right
			vim.cmd("wincmd L")
			-- Set width to 83 columns
			vim.cmd("vertical resize 83")
			-- Disable line numbers, fix width, remove colorcolumn
			vim.opt_local.number = false
			vim.opt_local.winfixwidth = true
			vim.opt_local.colorcolumn = ""
		end,
		desc = "Setup help window layout",
	})

	-- ============================================================================
	-- CONFLICT MARKER HIGHLIGHTING
	-- ============================================================================
	-- Highlight Git conflict markers (<<<<<<< ======= >>>>>>>)
	-- From vimrc:744
	if vim.fn.matchadd then
		pcall(vim.fn.matchadd, "ErrorMsg", [[^\(<\|=\|>\)\{7\}\([^=].\+\)\?$]])
	end

	-- Jump to next conflict marker
	-- From vimrc:747
	vim.keymap.set("n", "<leader>c", [[/^\(<\|=\|>\)\{7\}\([^=].\+\)\?$<CR>]], {
		silent = true,
		desc = "Jump to next conflict marker",
	})

	-- ============================================================================
	-- PROBLEMATIC WHITESPACE HIGHLIGHTING
	-- ============================================================================
	-- Highlight spaces before tabs (mixed indentation)
	-- From vimrc:750-751
	if vim.api.nvim_set_hl then
		pcall(vim.api.nvim_set_hl, 0, "RedundantSpaces", {
			fg = "#fabd2f", -- Gruvbox orange
			bg = "#cc241d", -- Gruvbox red
			bold = true,
		})
	end
	if vim.fn.matchadd then
		pcall(vim.fn.matchadd, "RedundantSpaces", [[ \+\ze\t]])
	end

	-- Fix space highlighting in diff files
	-- From vimrc:1178-1181
	vim.api.nvim_create_autocmd("FileType", {
		group = qol_group,
		pattern = "diff",
		callback = function()
			-- Clear the RedundantSpaces highlight in diff files
			vim.api.nvim_set_hl(0, "RedundantSpaces", {})

			-- Add diff column highlighting instead
			vim.api.nvim_set_hl(0, "DiffCol", {
				bg = "#3c3836", -- Gruvbox bg1
				bold = true,
			})
			vim.fn.matchadd("DiffCol", [[^[ +-]\([+-]\)\@!]])
		end,
		desc = "Fix whitespace highlighting in diff files",
	})

	-- ============================================================================
	-- COMMENT BANNERS AND HORIZONTAL RULES
	-- ============================================================================
	-- Create horizontal rule lines and comment banners for different languages
	-- From vimrc:1151-1159

	-- Horizontal Rules (78 char long separator lines)
	local hr_mappings = {
		vim = [[0i""]]
			.. [[-----------------------------------------------------------------------]]
			.. [[//<ESC>]],
		javascript = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		typescript = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		javascriptreact = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		typescriptreact = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		php = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		c = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		cpp = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		css = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		scss = [[0i/**]]
			.. [[---------------------------------------------------------------------]]
			.. [[**/<ESC>]],
		python = [[0i##]]
			.. [[-----------------------------------------------------------------------]]
			.. [[//<ESC>]],
		perl = [[0i##---------------------------------------------------------------------------//<ESC>]],
		ruby = [[0i##---------------------------------------------------------------------------//<ESC>]],
		sh = [[0i##---------------------------------------------------------------------------//<ESC>]],
		zsh = [[0i##---------------------------------------------------------------------------//<ESC>]],
		conf = [[0i##---------------------------------------------------------------------------//<ESC>]],
	}

	-- Comment Banners (adds decorative comment box around text)
	local cb_mappings = {
		vim = [[I"     <ESC>A     "<ESC>yyp0lv$hhr-yykPjj]],
		python = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		perl = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		ruby = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		sh = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		zsh = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		conf = [[I#     <ESC>A     #<ESC>yyp0lv$hhr-yykPjj]],
		javascript = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		typescript = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		javascriptreact = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		typescriptreact = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		php = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		c = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		cpp = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		css = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
		scss = [[I/*     <ESC>A     */<ESC>yyp0llv$r-$hc$*/<ESC>yykPjj]],
	}

	-- Create autocmds for each filetype
	for filetype, mapping in pairs(hr_mappings) do
		vim.api.nvim_create_autocmd("FileType", {
			group = qol_group,
			pattern = filetype,
			callback = function()
				vim.keymap.set("n", "<leader>hr", mapping, {
					buffer = true,
					desc = "Insert horizontal rule",
				})
			end,
		})
	end

	for filetype, mapping in pairs(cb_mappings) do
		vim.api.nvim_create_autocmd("FileType", {
			group = qol_group,
			pattern = filetype,
			callback = function()
				vim.keymap.set("n", "<leader>cb", mapping, {
					buffer = true,
					desc = "Create comment banner",
				})
			end,
		})
	end

	return true
end

return M
