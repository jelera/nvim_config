--[[
Database Configuration
======================

nvim-dbee setup for database management.
--]]

local M = {}

function M.setup()
	local ok, dbee = pcall(require, "dbee")
	if not ok then
		return
	end

	dbee.setup({
		sources = {
			require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
			require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "/dbee/connections.json"),
		},
	})
end

return M
