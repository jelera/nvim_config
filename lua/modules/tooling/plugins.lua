--[[
Tooling Plugins
===============

Cross-cutting development tools: database, REPL, HTTP client, projectionist.
--]]

return {
	-- Database UI (Lua-based) - lazy-loads on command
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			require("dbee").install()
		end,
		cmd = { "Dbee" },
		config = function()
			-- Auto-configure when plugin loads
			local ok, dbee = pcall(require, "dbee")
			if ok then
				dbee.setup({
					sources = {
						require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
						require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "/dbee/connections.json"),
					},
				})
			end
		end,
	},

	-- REPL manager (Lua-based) - lazy-loads on command/keys
	{
		"Vigemus/iron.nvim",
		cmd = { "IronRepl", "IronFocus", "IronSend" },
		keys = {
			{ "<leader>rs", mode = { "n", "x" }, desc = "Send to REPL" },
			{ "<leader>rl", desc = "Send line to REPL" },
			{ "<leader>rf", desc = "Send file to REPL" },
		},
		config = function()
			-- Auto-configure when plugin loads
			local ok, iron = pcall(require, "iron.core")
			if ok then
				iron.setup({
					config = {
						repl_definition = {
							ruby = {
								command = function()
									local rails_root = vim.fn.findfile("config/environment.rb", ".;")
									if rails_root ~= "" then
										return { "rails", "console" }
									else
										return { "irb" }
									end
								end,
							},
							javascript = { command = { "node" } },
							typescript = { command = { "ts-node" } },
						},
						repl_open_cmd = require("iron.view").split.vertical.botright(80),
					},
					keymaps = {
						send_motion = "<leader>rs",
						visual_send = "<leader>rs",
						send_line = "<leader>rl",
						send_until_cursor = "<leader>ru",
						send_mark = "<leader>rm",
						cr = "<leader>r<cr>",
						interrupt = "<leader>r<space>",
						exit = "<leader>rq",
						clear = "<leader>rc",
					},
					highlight = { italic = true },
				})
			end
		end,
	},

	-- HTTP client (Lua-based) - lazy-loads on .http files
	{
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			-- Auto-configure when plugin loads
			local ok, rest = pcall(require, "rest-nvim")
			if ok then
				rest.setup({
					result = {
						split_horizontal = false,
						split_in_place = false,
						skip_ssl_verification = false,
						show_url = true,
						show_http_info = true,
						show_headers = true,
						formatters = {
							json = "jq",
							html = function(body)
								return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
							end,
						},
					},
					jump_to_request = false,
					env_file = ".env",
					custom_dynamic_variables = {},
					yank_dry_run = true,
				})

				-- Keymaps for .http files
				vim.api.nvim_create_autocmd("FileType", {
					pattern = "http",
					callback = function()
						local bufnr = vim.api.nvim_get_current_buf()
						vim.keymap.set("n", "<leader>hr", "<Plug>RestNvim", { buffer = bufnr, desc = "Run HTTP request" })
						vim.keymap.set("n", "<leader>hp", "<Plug>RestNvimPreview", { buffer = bufnr, desc = "Preview HTTP request" })
						vim.keymap.set("n", "<leader>hl", "<Plug>RestNvimLast", { buffer = bufnr, desc = "Rerun last HTTP request" })
					end,
				})
			end
		end,
	},

	-- Project navigation (VimScript but configurable via Lua)
	{
		"tpope/vim-projectionist",
		lazy = false, -- Load early for project detection
		config = false, -- Configured by frameworks module
	},

	-- .env file support
	{
		"tpope/vim-dotenv",
		ft = { "ruby", "eruby", "javascript", "typescript" },
	},

	-- Linting (for tools without LSP support)
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Auto-configure when plugin loads
			local ok, lint = pcall(require, "lint")
			if ok then
				lint.linters_by_ft = {
					yaml = function()
						-- Only run actionlint for GitHub Actions workflow files
						local filename = vim.fn.expand("%:p")
						if filename:match("%.github/workflows/") then
							return { "actionlint" }
						end
						return {}
					end,
					markdown = { "codespell" },
					gitcommit = { "gitlint" },
					make = { "checkmake" },
					text = { "codespell" },
				}

				-- Create autocommand to run linters
				vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
					group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
					callback = function()
						local linters = lint.linters_by_ft[vim.bo.filetype]
						if linters then
							if type(linters) == "function" then
								linters = linters()
							end
							if linters and #linters > 0 then
								lint.try_lint()
							end
						end
					end,
					desc = "Run nvim-lint linters",
				})
			end
		end,
	},
}
