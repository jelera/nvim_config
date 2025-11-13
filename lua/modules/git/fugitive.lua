--[[
Fugitive Configuration
======================

Configures vim-fugitive for git command integration.

Fugitive is a VimL plugin that works out of the box. This module just
ensures it's loaded and available.

Features:
- :Git command for all git operations
- :Gstatus, :Gcommit, :Gpush, etc.
- Merge conflict resolution
- Git blame integration

Dependencies:
- tpope/vim-fugitive

API:
- setup(config) - Initialize fugitive
--]]

local M = {}

---Setup fugitive
---@param config? table Configuration options (currently unused)
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Fugitive is a VimL plugin that works automatically once loaded
  -- No additional configuration needed, it works out of the box
  return true
end

return M
