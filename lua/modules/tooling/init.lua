--[[
Tooling Module
==============

Initialize development tools (database, REPL, HTTP client).
--]]

local M = {}

function M.setup()
  require('modules.tooling.database').setup()
  require('modules.tooling.repl').setup()
  require('modules.tooling.http').setup()
end

return M
