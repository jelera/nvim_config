--[[
Tooling Module
==============

Initialize development tools (database, REPL, HTTP client, linting).

Note: All tooling plugins are now self-configuring via plugin specs.
They load on-demand when their respective commands/filetypes/events are triggered:
- Database (nvim-dbee): Loads on `:Dbee` command
- REPL (iron.nvim): Loads on commands or <leader>r* keymaps
- HTTP (rest.nvim): Loads on .http filetype
- Linting (nvim-lint): Loads on BufReadPost/BufNewFile events
--]]

local M = {}

function M.setup()
	-- All tools are now self-configuring via plugin specs
	-- Nothing to do at startup for performance optimization
	return true
end

return M
