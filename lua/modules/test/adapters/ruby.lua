--[[
Ruby Test Adapter
=================

Wraps neotest-rspec for Ruby testing.

Supports:
- RSpec

Dependencies:
- olimorris/neotest-rspec

API:
- setup(config) - Configure adapter
- get_adapter() - Get neotest adapter instance
--]]

local M = {}

local adapter = nil

---Setup Ruby test adapter
---@param config? table Configuration options (unused, uses neotest-rspec defaults)
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Try to load neotest-rspec adapter
  local ok, neotest_rspec = pcall(require, 'neotest-rspec')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Store adapter instance (neotest-rspec works out of the box with defaults)
  adapter = neotest_rspec

  return true
end

---Get the neotest adapter instance
---@return table|nil adapter The neotest adapter or nil
function M.get_adapter()
  return adapter
end

return M
