--[[
Ruby Debug Adapter
==================

DAP adapter for Ruby debugging using rdbg (debug gem).
--]]

local M = {}

function M.setup(dap)
  -- Find rdbg from mise or system
  local function find_rdbg()
    local mise_rdbg = vim.fn.system('mise which rdbg 2>/dev/null'):gsub('%s+$', '')
    if vim.fn.executable(mise_rdbg) == 1 then
      return mise_rdbg
    end
    if vim.fn.executable('rdbg') == 1 then
      return 'rdbg'
    end
    return nil
  end

  local rdbg_cmd = find_rdbg()
  if not rdbg_cmd then
    vim.notify('rdbg not found. Install with: gem install debug', vim.log.levels.WARN)
    return
  end

  dap.adapters.ruby = {
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = {
      command = rdbg_cmd,
      args = { '-O', '--host', '127.0.0.1', '--port', '${port}', '-c', '--' },
    },
  }

  dap.configurations.ruby = {
    {
      type = 'ruby',
      request = 'launch',
      name = 'Launch file',
      command = rdbg_cmd,
      script = '${file}',
    },
    {
      type = 'ruby',
      request = 'attach',
      name = 'Attach',
      localfs = true,
    },
  }
end

return M
