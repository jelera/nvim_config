--[[
REPL Configuration
==================

iron.nvim setup for Rails console, Node REPL, and Angular CLI.
--]]

local M = {}

function M.setup()
  local ok, iron = pcall(require, 'iron.core')
  if not ok then
    return
  end

  iron.setup({
    config = {
      -- REPL definitions
      repl_definition = {
        ruby = {
          -- Rails console if in Rails project, otherwise irb
          command = function()
            local rails_root = vim.fn.findfile('config/environment.rb', '.;')
            if rails_root ~= '' then
              return { 'rails', 'console' }
            else
              return { 'irb' }
            end
          end,
        },
        javascript = {
          command = { 'node' },
        },
        typescript = {
          command = { 'ts-node' },
        },
      },

      -- REPL open behavior
      repl_open_cmd = require('iron.view').split.vertical.botright(80),
    },

    -- Keymaps
    keymaps = {
      send_motion = '<leader>rs',
      visual_send = '<leader>rs',
      send_line = '<leader>rl',
      send_until_cursor = '<leader>ru',
      send_mark = '<leader>rm',
      cr = '<leader>r<cr>',
      interrupt = '<leader>r<space>',
      exit = '<leader>rq',
      clear = '<leader>rc',
    },

    -- Highlight
    highlight = {
      italic = true,
    },
  })
end

return M
