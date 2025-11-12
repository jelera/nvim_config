--[[
Python Formatting
=================

Uses black for code formatting and isort for import sorting.
--]]

local M = {}

---Get formatters for Python files
---@return table formatters List of formatters
function M.get_formatters()
	return { "isort", "black" }
end

return M
