--[[
Ruby Formatting
===============

Smart Ruby formatter selection:
- If standardrb is in Gemfile: use standardrb
- Otherwise: use rubocop

Also handles ERB templates.
--]]

local M = {}

---Check if a gem is in the Gemfile
---@param gem_name string The gem name to look for
---@return boolean found Whether the gem was found
local function gem_in_gemfile(gem_name)
	local gemfile = vim.fn.findfile("Gemfile", ".;")
	if gemfile == "" then
		return false
	end

	local content = vim.fn.readfile(gemfile)
	for _, line in ipairs(content) do
		if line:match("gem%s+['\"]" .. gem_name .. "['\"]") then
			return true
		end
	end
	return false
end

---Get the appropriate Ruby formatter
---@return string formatter The formatter to use
function M.get_ruby_formatter()
	if gem_in_gemfile("standard") or gem_in_gemfile("standardrb") then
		return "standardrb"
	else
		return "rubocop"
	end
end

---Get formatters for Ruby files
---@return table formatters List of formatters
function M.get_formatters()
	return { M.get_ruby_formatter() }
end

---Get formatters for ERB files
---@return table formatters List of formatters
function M.get_erb_formatters()
	-- Try erb-format first, fallback to htmlbeautifier
	return { "erb_format" }
end

---Get formatter configurations
---@return table configs Formatter configurations
function M.get_formatter_configs()
	return {
		standardrb = {
			command = "standardrb",
			args = { "--fix", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" },
			stdin = true,
		},
		rubocop = {
			command = "rubocop",
			args = { "--auto-correct", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" },
			stdin = true,
		},
		erb_format = {
			command = "erb-formatter",
			args = { "--stdin" },
			stdin = true,
		},
	}
end

return M
