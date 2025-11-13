--[[
Editor Keymaps
==============

Defines all editor-related key mappings.

Session Management Keymaps:
- <leader>sr - Restore last session
- <leader>ss - Stop session (don't save on exit)
- <leader>sl - Load session for current directory

Project Management Keymaps:
- <leader>fp - Find projects (Telescope)

Note: Most editor features use their own default keymaps:
- Autopairs: <M-e> for fast wrap (configured in autopairs.lua)
- Surround: ys, ds, cs (configured in surround.lua)
- Comment: gcc, gbc, gc, gb (configured in comment.lua)

API:
- setup() - Setup editor keymaps
--]]

local M = {}

---Setup editor keymaps
---@return boolean success Whether setup succeeded
function M.setup()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Session management keymaps
  keymap('n', '<leader>sr', function()
    local ok, persistence = pcall(require, 'persistence')
    if ok then
      persistence.load({ last = true })
    end
  end, vim.tbl_extend('force', opts, { desc = 'Editor: Restore last session' }))

  keymap('n', '<leader>sl', function()
    local ok, persistence = pcall(require, 'persistence')
    if ok then
      persistence.load()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Editor: Load session for cwd' }))

  keymap('n', '<leader>ss', function()
    local ok, persistence = pcall(require, 'persistence')
    if ok then
      persistence.stop()
    end
  end, vim.tbl_extend('force', opts, { desc = 'Editor: Stop session (don\'t save)' }))

  -- Project management keymaps
  keymap('n', '<leader>fp', function()
    local telescope_ok, telescope = pcall(require, 'telescope')
    if telescope_ok then
      pcall(function()
        telescope.extensions.projects.projects({})
      end)
    end
  end, vim.tbl_extend('force', opts, { desc = 'Editor: Find projects' }))

  return true
end

return M
