--[[
Lint Module
===========

Provides linting for languages/tools that don't have LSP support or need
specialized linting (e.g., security checks).

Strategy:
- Only use nvim-lint when LSP doesn't provide equivalent functionality
- LSP servers are preferred for language-specific linting
- nvim-lint is for specialized tools (security, workflows, etc.)

Linters:
- actionlint: GitHub Actions workflow files (.github/workflows/*.yml)
- codespell: Spell checking for markdown, text, and comments
- gitlint: Git commit message linting
- checkmake: Makefile linting

Note: gitleaks is intentionally NOT included as it requires special setup
and is better run in CI/pre-commit hooks due to performance.
--]]

local M = {}

---Setup linting with nvim-lint
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(_config)
	_config = _config or {}

	-- Try to load nvim-lint
	local ok, lint = pcall(require, "lint")
	if not ok then
		-- Plugin not loaded yet, return true (will be lazy-loaded)
		return true
	end

	-- Configure linters by filetype
	-- Only include linters for cases where LSP doesn't provide coverage
	lint.linters_by_ft = {
		-- GitHub Actions workflows (no LSP equivalent for actionlint's checks)
		yaml = function()
			-- Only run actionlint for GitHub Actions workflow files
			local filename = vim.fn.expand("%:p")
			if filename:match("%.github/workflows/") then
				return { "actionlint" }
			end
			return {}
		end,

		-- Markdown - spell checking (marksman LSP doesn't do spell checking)
		markdown = { "codespell" },

		-- Git commits
		gitcommit = { "gitlint" },

		-- Makefiles
		make = { "checkmake" },

		-- Text files (no LSP)
		text = { "codespell" },
	}

	-- Create autocommand to run linters
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
		callback = function()
			-- Only lint if there's a linter configured for this filetype
			local linters = lint.linters_by_ft[vim.bo.filetype]
			if linters then
				-- Handle function-based linter selection
				if type(linters) == "function" then
					linters = linters()
				end

				-- Only run if linters were returned
				if linters and #linters > 0 then
					lint.try_lint()
				end
			end
		end,
		desc = "Run nvim-lint linters",
	})

	return true
end

return M
