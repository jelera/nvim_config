--[[
Lua Test Adapter
================

Wraps neotest-busted for Lua testing.

Supports:
- Busted

Dependencies:
- nvim-neotest/neotest-busted

API:
- setup(config) - Configure adapter
- get_adapter() - Get neotest adapter instance
--]]

local M = {}

local adapter = nil

---Setup Lua test adapter
---@param config? table Configuration options (unused, uses neotest-busted defaults)
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Try to load neotest-busted adapter
  local ok, neotest_busted = pcall(require, 'neotest-busted')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Store adapter instance (neotest-busted works out of the box with defaults)
  adapter = neotest_busted

  return true
end

---Get the neotest adapter instance
---@return table|nil adapter The neotest adapter or nil
function M.get_adapter()
  return adapter
end

return M
