--[[
Python Test Adapter
===================

Wraps neotest-python for Python testing.

Supports:
- Pytest
- Unittest

Dependencies:
- nvim-neotest/neotest-python

API:
- setup(config) - Configure adapter
- get_adapter() - Get neotest adapter instance
--]]

local M = {}

local adapter = nil

---Setup Python test adapter
---@param config? table Configuration options (unused, uses neotest-python defaults)
---@return boolean success Whether setup succeeded
function M.setup(config)
  config = config or {}

  -- Try to load neotest-python adapter
  local ok, neotest_python = pcall(require, 'neotest-python')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Store adapter instance (neotest-python works out of the box with defaults)
  adapter = neotest_python

  return true
end

---Get the neotest adapter instance
---@return table|nil adapter The neotest adapter or nil
function M.get_adapter()
  return adapter
end

return M
