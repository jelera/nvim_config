--[[
Tooling Module
==============

Initialize development tools (database, REPL, HTTP client, linting).
--]]

local M = {}

function M.setup()
	require("modules.tooling.database").setup()
	require("modules.tooling.repl").setup()
	require("modules.tooling.http").setup()
	require("modules.tooling.lint").setup()
end

return M
