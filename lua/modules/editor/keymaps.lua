--[[
Editor Keymaps
==============

Defines all editor-related key mappings migrated from vimrc.

General Keymaps:
- <leader><space> - Clear search highlighting
- <Space> - Toggle foldings
- >, <, = (visual) - Indent without unselecting
- <leader>syn - Show syntax highlighting groups

Editing Keymaps:
- <leader>nw - Strip trailing whitespace
- <leader>h1, <leader>h2 - Documentation headers

Copy/Paste Keymaps:
- <C-X> (visual) - Cut to system clipboard
- <C-C> (visual) - Copy to system clipboard
- <leader>v - Smart paste and indent

Spell Checking:
- <leader>spl - Toggle spell checking

Session Management Keymaps:
- <leader>sr - Restore last session
- <leader>ss - Stop session (don't save on exit)
- <leader>sl - Load session for current directory

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

  -- ============================================================================
  -- General Keymaps
  -- ============================================================================

  -- Clear search highlighting
  keymap('n', '<leader><space>', '<cmd>nohlsearch<CR>',
    vim.tbl_extend('force', opts, { desc = 'Editor: Clear search highlighting' }))

  -- Toggle foldings with space bar
  keymap('n', '<Space>', 'za',
    vim.tbl_extend('force', opts, { desc = 'Editor: Toggle fold' }))

  -- Indent visual selected code without unselecting
  keymap('v', '>', '>gv',
    vim.tbl_extend('force', opts, { desc = 'Editor: Indent right' }))
  keymap('v', '<', '<gv',
    vim.tbl_extend('force', opts, { desc = 'Editor: Indent left' }))
  keymap('v', '=', '=gv',
    vim.tbl_extend('force', opts, { desc = 'Editor: Auto indent' }))

  -- Show syntax highlighting groups for word under cursor
  keymap('n', '<leader>syn', function()
    local result = vim.treesitter.get_captures_at_cursor(0)
    if #result == 0 then
      -- Fallback to synstack for non-treesitter
      local line = vim.fn.line('.')
      local col = vim.fn.col('.')
      local stack = vim.fn.synstack(line, col)
      result = vim.tbl_map(function(id)
        return vim.fn.synIDattr(id, 'name')
      end, stack)
    end
    print(vim.inspect(result))
  end, vim.tbl_extend('force', opts, { desc = 'Editor: Show syntax groups' }))

  -- ============================================================================
  -- Editing Keymaps
  -- ============================================================================

  -- Strip trailing whitespace
  keymap('n', '<leader>nw', [[:%s/\s\+$//e<CR>:let @/=''<CR>]],
    vim.tbl_extend('force', opts, { desc = 'Editor: Strip trailing whitespace' }))

  -- Documentation writing and formatting
  keymap('n', '<leader>h1', 'yypVr=o',
    vim.tbl_extend('force', opts, { desc = 'Editor: Create H1 header' }))
  keymap('n', '<leader>h2', 'yypVr-o',
    vim.tbl_extend('force', opts, { desc = 'Editor: Create H2 header' }))

  -- ============================================================================
  -- Copy, Cut, Paste Keymaps
  -- ============================================================================

  -- CTRL-X is cut to system clipboard
  keymap('v', '<C-X>', '"+x',
    vim.tbl_extend('force', opts, { desc = 'Editor: Cut to clipboard' }))

  -- CTRL-C is copy to system clipboard
  keymap('v', '<C-C>', '"+y',
    vim.tbl_extend('force', opts, { desc = 'Editor: Copy to clipboard' }))

  -- Smart paste from system clipboard and indent automatically
  keymap('n', '<leader>v', '"+P=\']',
    vim.tbl_extend('force', opts, { desc = 'Editor: Paste and indent' }))

  -- ============================================================================
  -- Spell Checking Keymaps
  -- ============================================================================

  -- Toggle spell checking
  keymap('n', '<leader>spl', '<cmd>setlocal spell!<CR>',
    vim.tbl_extend('force', opts, { desc = 'Editor: Toggle spell check' }))

  -- ============================================================================
  -- Session Management Keymaps
  -- ============================================================================

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

  return true
end

return M
