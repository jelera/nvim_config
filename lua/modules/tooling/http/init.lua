--[[
HTTP Client Configuration
==========================

rest.nvim setup for API testing.
--]]

local M = {}

function M.setup()
  local ok, rest = pcall(require, 'rest-nvim')
  if not ok then
    return
  end

  rest.setup({
    result = {
      split_horizontal = false,
      split_in_place = false,
      skip_ssl_verification = false,
      show_url = true,
      show_http_info = true,
      show_headers = true,
      formatters = {
        json = 'jq',
        html = function(body)
          return vim.fn.system({ 'tidy', '-i', '-q', '-' }, body)
        end,
      },
    },
    jump_to_request = false,
    env_file = '.env',
    custom_dynamic_variables = {},
    yank_dry_run = true,
  })

  -- Keymaps for .http files
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'http',
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      vim.keymap.set('n', '<leader>hr', '<Plug>RestNvim', { buffer = bufnr, desc = 'Run HTTP request' })
      vim.keymap.set('n', '<leader>hp', '<Plug>RestNvimPreview', { buffer = bufnr, desc = 'Preview HTTP request' })
      vim.keymap.set('n', '<leader>hl', '<Plug>RestNvimLast', { buffer = bufnr, desc = 'Rerun last HTTP request' })
    end,
  })
end

return M
