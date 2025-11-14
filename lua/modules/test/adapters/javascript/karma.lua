--[[
Karma Adapter
=============

Neotest adapter for Karma (Angular testing framework) via vim-test.
Uses default configuration.

Dependencies:
- nvim-neotest/neotest-vim-test
- vim-test/vim-test
--]]

local M = {}

function M.get_adapter()
  local ok, adapter = pcall(require, 'neotest-vim-test')
  if not ok then
    return nil
  end

  return adapter({
    ignore_file_types = { 'python', 'vim', 'lua', 'ruby' },
  })
end

return M
