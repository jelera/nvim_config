--[[
Jest Adapter
============

Neotest adapter for Jest (JavaScript/TypeScript testing framework).
Uses default configuration.

Dependencies:
- nvim-neotest/neotest-jest
--]]

local M = {}

function M.get_adapter()
  local ok, adapter = pcall(require, 'neotest-jest')
  if not ok then
    return nil
  end

  return adapter({
    jestCommand = 'npm test --',
    env = { CI = true },
    cwd = function()
      return vim.fn.getcwd()
    end,
  })
end

return M
