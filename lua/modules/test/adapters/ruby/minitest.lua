--[[
Minitest Adapter
================

Neotest adapter for Minitest (Ruby testing framework).
Uses default configuration.

Dependencies:
- zidhuss/neotest-minitest
--]]

local M = {}

function M.get_adapter()
  local ok, adapter = pcall(require, 'neotest-minitest')
  if not ok then
    return nil
  end
  return adapter
end

return M
