--[[
Python Debug Adapter
====================

DAP adapter for Python debugging using debugpy.
--]]

local M = {}

function M.setup(dap)
  local mason_debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
  local python_cmd = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or 'python3'

  dap.adapters.python = {
    type = 'executable',
    command = python_cmd,
    args = { '-m', 'debugpy.adapter' },
  }

  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      pythonPath = function()
        local venv = os.getenv('VIRTUAL_ENV')
        if venv then
          return venv .. '/bin/python'
        end
        return '/usr/bin/python3'
      end,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'Attach remote',
      connect = function()
        local host = vim.fn.input('Host [127.0.0.1]: ')
        host = host ~= '' and host or '127.0.0.1'
        local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
        return { host = host, port = port }
      end,
    },
  }
end

return M
