--[[
Rails Configuration
===================

Load Rails projections for vim-rails.
--]]

local M = {}

function M.setup()
	-- Skip if vim global isn't available (test environment)
	if not vim or not vim.g then
		return
	end

	local projections = require("modules.frameworks.rails.projections")
	vim.g.rails_projections = projections
end

return M
