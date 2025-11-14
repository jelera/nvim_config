--[[
Debug Adapters Configuration
=============================

Configures language-specific debug adapters for nvim-dap.

Supported Languages:
- JavaScript/TypeScript (vscode-js-debug) - Auto-install
- Python (debugpy) - Auto-install
- Ruby (ruby-debug-ide) - Lazy-install
- Lua (local-lua-debugger-vscode) - Lazy-install

Auto-install: Adapters installed on module setup
Lazy-install: Adapters installed when filetype is first opened

Dependencies:
- mfussenegger/nvim-dap
- Mason for adapter installation

API:
- setup(config) - Configure debug adapters
--]]

local M = {}

---Default configuration
local default_config = {
  -- Adapters to auto-install on setup
  auto_install = { 'javascript', 'python' },
  -- Adapters to lazy-install on filetype open
  lazy_install = { 'ruby', 'lua' },
  -- All supported languages
  languages = { 'javascript', 'typescript', 'python', 'ruby', 'lua' }
}

---Configure JavaScript/TypeScript adapter
---@param dap table nvim-dap module
local function setup_javascript(dap)
  -- Use vscode-js-debug adapter (installed via Mason)
  dap.adapters['pwa-node'] = {
    type = 'server',
    host = 'localhost',
    port = '${port}',
    executable = {
      command = 'node',
      args = {
        vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
        '${port}'
      }
    }
  }

  -- Configurations for JavaScript
  dap.configurations.javascript = {
    {
      type = 'pwa-node',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'pwa-node',
      request = 'attach',
      name = 'Attach',
      processId = require('dap.utils').pick_process,
      cwd = '${workspaceFolder}',
    }
  }

  -- TypeScript uses the same config
  dap.configurations.typescript = dap.configurations.javascript
end

---Configure Python adapter
---@param dap table nvim-dap module
local function setup_python(dap)
  -- Use debugpy adapter (installed via Mason or system)
  local mason_debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
  local python_cmd = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or 'python3'

  dap.adapters.python = {
    type = 'executable',
    command = python_cmd,
    args = { '-m', 'debugpy.adapter' },
  }

  -- Python configurations
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

---Configure Ruby adapter
---@param dap table nvim-dap module
local function setup_ruby(dap)
  -- Use rdbg (ruby/debug) - the modern Ruby debugger
  -- Try to find rdbg from mise, then fall back to system
  local function find_rdbg()
    -- Try mise's rdbg
    local mise_rdbg = vim.fn.system('mise which rdbg 2>/dev/null'):gsub('%s+$', '')
    if vim.fn.executable(mise_rdbg) == 1 then
      return mise_rdbg
    end
    -- Fall back to system rdbg
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

  -- Ruby configurations
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

---Configure Lua adapter
---@param dap table nvim-dap module
local function setup_lua(dap)
  -- Use local-lua-debugger-vscode adapter
  dap.adapters['local-lua'] = {
    type = 'executable',
    command = 'node',
    args = {
      vim.fn.stdpath('data') .. '/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.js'
    },
    enrich_config = function(config, on_config)
      if not config['extensionPath'] then
        local c = vim.deepcopy(config)
        c.extensionPath = vim.fn.stdpath('data') .. '/mason/packages/local-lua-debugger-vscode/'
        on_config(c)
      else
        on_config(config)
      end
    end,
  }

  -- Lua configurations
  dap.configurations.lua = {
    {
      type = 'local-lua',
      request = 'launch',
      name = 'Launch file',
      cwd = '${workspaceFolder}',
      program = {
        lua = 'lua',
        file = '${file}',
      },
    },
  }
end

---Install adapters via Mason
---@param adapters table List of adapter names to install
local function install_adapters(adapters)
  local mason_ok, mason_registry = pcall(require, 'mason-registry')
  if not mason_ok then
    return
  end

  local adapter_map = {
    javascript = 'js-debug-adapter',
    typescript = 'js-debug-adapter',
    python = 'debugpy',
    -- Ruby uses rdbg (installed via gem, not Mason)
    lua = 'local-lua-debugger-vscode',
  }

  -- Ensure Mason registry is refreshed and ready
  mason_registry.refresh(function()
    for _, adapter_name in ipairs(adapters) do
      local package_name = adapter_map[adapter_name]
      if package_name then
        -- Use pcall to handle package not found errors gracefully
        local ok, package = pcall(function()
          return mason_registry.get_package(package_name)
        end)
        if ok and package then
        if not package:is_installed() then
          vim.notify(
            string.format('Installing debug adapter: %s', package_name),
            vim.log.levels.INFO
          )
          local install_ok, install_err = pcall(function()
            package:install()
          end)
          if not install_ok then
            vim.notify(
              string.format('Failed to install %s: %s', package_name, install_err),
              vim.log.levels.WARN
            )
          end
        end
      else
        vim.notify(
          string.format('Debug adapter package "%s" not found in Mason registry', package_name),
          vim.log.levels.DEBUG
        )
      end
    end
    end
  end)
end

---Setup lazy-install for filetype-specific adapters
---@param adapters table List of adapter names to lazy-install
local function setup_lazy_install(adapters)
  local filetype_map = {
    ruby = { 'ruby' },
    lua = { 'lua' },
  }

  for _, adapter_name in ipairs(adapters) do
    local filetypes = filetype_map[adapter_name]
    if filetypes then
      local group = vim.api.nvim_create_augroup('DebugAdapterLazyInstall_' .. adapter_name, { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = filetypes,
        once = true,
        callback = function()
          install_adapters({ adapter_name })
        end,
      })
    end
  end
end

---Setup debug adapters with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  -- Try to load nvim-dap plugin
  local ok, dap = pcall(require, 'dap')
  if not ok then
    -- Plugin not loaded yet (will be lazy-loaded), return true
    return true
  end

  -- Setup adapters for all configured languages
  local languages = merged_config.languages or default_config.languages
  for _, lang in ipairs(languages) do
    if lang == 'javascript' or lang == 'typescript' then
      setup_javascript(dap)
    elseif lang == 'python' then
      setup_python(dap)
    elseif lang == 'ruby' then
      setup_ruby(dap)
    elseif lang == 'lua' then
      setup_lua(dap)
    end
  end

  -- Auto-install common adapters (deferred to ensure Mason is ready)
  if merged_config.auto_install and #merged_config.auto_install > 0 then
    vim.defer_fn(function()
      install_adapters(merged_config.auto_install)
    end, 500)
  end

  -- Setup lazy-install for less common adapters
  if merged_config.lazy_install and #merged_config.lazy_install > 0 then
    setup_lazy_install(merged_config.lazy_install)
  end

  return true
end

return M
