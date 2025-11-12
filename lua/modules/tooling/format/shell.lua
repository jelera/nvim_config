--[[
Shell Script Formatting
========================

Uses shfmt for consistent shell script formatting.
--]]

local M = {}

---Get formatters for shell scripts
---@return table formatters List of formatters
function M.get_formatters()
	return { "shfmt" }
end

---Get formatter configurations
---@return table configs Formatter configurations
function M.get_formatter_configs()
	return {
		shfmt = {
			command = "shfmt",
			-- 2 space indent, binary ops at line start,
			-- switch cases indent, redirect followed by space
			args = { "-i", "2", "-bn", "-ci", "-sr" },
			stdin = true,
		},
	}
end

return M
