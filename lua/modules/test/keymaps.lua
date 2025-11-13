--[[
Test Keymaps
============

Defines all testing-related key mappings.

Keymaps:
- <leader>tt - Run nearest test
- <leader>tf - Run file tests
- <leader>ts - Run test suite
- <leader>tl - Run last test
- <leader>td - Debug test
- <leader>to - Toggle test output
- <leader>tc - Show test summary

API:
- setup() - Setup test keymaps
--]]

local M = {}

---Setup test keymaps
---@return boolean success Whether setup succeeded
function M.setup()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Run tests
  keymap('n', '<leader>tt', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.run()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Run nearest' }))

  keymap('n', '<leader>tf', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.run(vim.fn.expand('%'))
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Run file' }))

  keymap('n', '<leader>ts', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.run(vim.fn.getcwd())
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Run suite' }))

  keymap('n', '<leader>tl', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.run_last()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Run last' }))

  -- Debug test
  keymap('n', '<leader>td', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.run({ strategy = 'dap' })
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Debug nearest' }))

  -- Test output
  keymap('n', '<leader>to', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.output.open({ enter = true })
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Toggle output' }))

  keymap('n', '<leader>tO', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.output_panel.toggle()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Toggle output panel' }))

  -- Test summary
  keymap('n', '<leader>tc', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.summary.toggle()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Toggle summary' }))

  -- Stop tests
  keymap('n', '<leader>tS', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.stop()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Stop' }))

  -- Attach to nearest test
  keymap('n', '<leader>ta', function()
    local ok, neotest = pcall(require, 'neotest')
    if ok then
      neotest.run.attach()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Test: Attach' }))

  return true
end

return M
