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
  -- Use debugpy adapter (installed via Mason)
  dap.adapters.python = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
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
  -- Use ruby-debug-ide adapter
  dap.adapters.ruby = {
    type = 'executable',
    command = 'ruby-debug-ide',
    args = { '--host', '127.0.0.1', '--port', '${port}' },
  }

  -- Ruby configurations
  dap.configurations.ruby = {
    {
      type = 'ruby',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
      programArgs = {},
      useBundler = true,
    },
    {
      type = 'ruby',
      request = 'attach',
      name = 'Attach',
      remoteHost = '127.0.0.1',
      remotePort = '1234',
      remoteWorkspaceRoot = '${workspaceFolder}',
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
    ruby = 'ruby-debug-ide',
    lua = 'local-lua-debugger-vscode',
  }

  for _, adapter_name in ipairs(adapters) do
    local package_name = adapter_map[adapter_name]
    if package_name then
      local package = mason_registry.get_package(package_name)
      if not package:is_installed() then
        vim.notify(
          string.format('Installing debug adapter: %s', package_name),
          vim.log.levels.INFO
        )
        package:install()
      end
    end
  end
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

  -- Auto-install common adapters
  if merged_config.auto_install and #merged_config.auto_install > 0 then
    install_adapters(merged_config.auto_install)
  end

  -- Setup lazy-install for less common adapters
  if merged_config.lazy_install and #merged_config.lazy_install > 0 then
    setup_lazy_install(merged_config.lazy_install)
  end

  return true
end

return M
