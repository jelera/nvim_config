--[[
JavaScript/TypeScript Formatting
=================================

Uses ESLint with prettier integration.

Projects should have:
- eslint-config-prettier (disables conflicting ESLint rules)
- eslint-plugin-prettier (runs prettier as an ESLint rule)

This ensures no conflicts between prettier and eslint.

Prefers eslint_d (daemon mode, much faster) but falls back to eslint.
--]]

local M = {}

---Get formatters for JavaScript/TypeScript files
---Tries eslint_d first (faster), falls back to eslint
---@return table formatters List of formatters
function M.get_formatters()
	-- Check if eslint_d is available
	if vim.fn.executable("eslint_d") == 1 then
		return { "eslint_d" }
	else
		return { "eslint" }
	end
end

---Get formatter configurations
---@return table configs Formatter configurations
function M.get_formatter_configs()
	return {
		-- eslint_d is faster than eslint (daemon mode, keeps ESLint running in background)
		eslint_d = {
			command = "eslint_d",
			args = { "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
			stdin = true,
		},
		-- Regular eslint fallback
		eslint = {
			command = "eslint",
			args = { "--fix", "--stdin", "--stdin-filename", "$FILENAME" },
			stdin = true,
		},
	}
end

return M
