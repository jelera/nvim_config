--[[
Lua Formatting
==============

Uses stylua for consistent Lua formatting.
--]]

local M = {}

---Get formatters for Lua files
---@return table formatters List of formatters
function M.get_formatters()
	return { "stylua" }
end

return M
