--[[
Frameworks Module
=================

Initialize framework-specific configurations (Rails, Angular).
--]]

local M = {}

function M.setup()
	-- Setup Rails projections
	require("modules.frameworks.rails").setup()

	-- Setup Angular projections
	require("modules.frameworks.angular").setup()

	return true
end

return M
