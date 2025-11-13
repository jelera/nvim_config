--[[
LSP Module Tests (Smoke Tests)
===============================

Basic smoke tests for the LSP module.

Test Categories:
1. Module structure
2. setup() with defaults
3. setup() with custom config
4. Graceful degradation
--]]

describe('modules.lsp #unit', function()
  local spec_helper = require('spec.spec_helper')
  local lsp

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.lsp'] = nil
    package.loaded['modules.lsp.init'] = nil
    package.loaded['modules.lsp.config'] = nil
    package.loaded['modules.lsp.event_handlers'] = nil
    package.loaded['modules.lsp.keymaps'] = nil
    package.loaded['modules.lsp.diagnostics'] = nil
    package.loaded['mason'] = nil
    package.loaded['mason-lspconfig'] = nil
    package.loaded['lspconfig'] = nil

    -- Track configuration
    _G._test_mason_config = nil
    _G._test_mason_lspconfig_config = nil
    _G._test_lsp_servers_setup = {}
    _G._test_diagnostic_config = nil

    -- Mock vim.diagnostic
    vim.diagnostic = {
      config = function(config)
        _G._test_diagnostic_config = config
      end,
    }

    -- Mock vim.fn.sign_define
    vim.fn = vim.fn or {}
    vim.fn.sign_define = function(name, opts)
      -- Just track it was called
    end

    -- Mock vim.keymap
    vim.keymap = {
      set = function() end,
    }

    -- Mock vim.api for autocommands
    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end

    -- Mock Mason
    package.preload['mason'] = function()
      return {
        setup = function(config)
          _G._test_mason_config = config
        end,
      }
    end

    -- Mock mason-lspconfig
    package.preload['mason-lspconfig'] = function()
      return {
        setup = function(config)
          _G._test_mason_lspconfig_config = config
        end,
        setup_handlers = function(handlers)
          _G._test_mason_lspconfig_handlers = handlers
        end,
      }
    end

    -- Mock lspconfig
    package.preload['lspconfig'] = function()
      return setmetatable({}, {
        __index = function(_, server_name)
          return {
            setup = function(config)
              _G._test_lsp_servers_setup[server_name] = config
            end,
          }
        end,
      })
    end

    -- Mock cmp_nvim_lsp
    package.preload['cmp_nvim_lsp'] = function()
      return {
        default_capabilities = function()
          return { textDocument = { completion = { completionItem = {} } } }
        end,
      }
    end

    lsp = require('modules.lsp')
  end)

  after_each(function()
    spec_helper.teardown()
    _G._test_mason_config = nil
    _G._test_mason_lspconfig_config = nil
    _G._test_lsp_servers_setup = nil
    _G._test_mason_lspconfig_handlers = nil
    _G._test_diagnostic_config = nil
  end)

  describe('Module structure', function()
    it('should load without errors', function()
      assert.is_not_nil(lsp)
      assert.is_table(lsp)
    end)

    it('should have setup function', function()
      assert.is_function(lsp.setup)
    end)
  end)

  describe('setup() with defaults', function()
    it('should return true on success', function()
      local result = lsp.setup()
      assert.is_true(result)
    end)

    it('should configure Mason', function()
      lsp.setup()
      assert.is_not_nil(_G._test_mason_config)
    end)

    it('should configure mason-lspconfig', function()
      lsp.setup()
      assert.is_not_nil(_G._test_mason_lspconfig_config)
    end)

    it('should auto-install core servers', function()
      lsp.setup()

      local ensure_installed = _G._test_mason_lspconfig_config.ensure_installed
      assert.is_table(ensure_installed)

      -- Check for core servers
      local has_lua_ls = false
      local has_ts_ls = false
      local has_pyright = false

      for _, server in ipairs(ensure_installed) do
        if server == 'lua_ls' then
          has_lua_ls = true
        end
        if server == 'ts_ls' then
          has_ts_ls = true
        end
        if server == 'pyright' then
          has_pyright = true
        end
      end

      assert.is_true(has_lua_ls)
      assert.is_true(has_ts_ls)
      assert.is_true(has_pyright)
    end)

    it('should enable automatic installation', function()
      lsp.setup()
      assert.is_true(_G._test_mason_lspconfig_config.automatic_installation)
    end)
  end)

  describe('setup() with custom config', function()
    it('should accept empty config', function()
      local result = lsp.setup({})
      assert.is_true(result)
    end)

    it('should allow custom ensure_installed list', function()
      lsp.setup({
        ensure_installed = { 'lua_ls', 'pyright' },
      })

      local ensure_installed = _G._test_mason_lspconfig_config.ensure_installed
      assert.equal(2, #ensure_installed)
    end)

    it('should allow disabling automatic_installation', function()
      lsp.setup({
        automatic_installation = false,
      })

      assert.is_false(_G._test_mason_lspconfig_config.automatic_installation)
    end)

    it('should merge custom config with defaults', function()
      lsp.setup({
        ensure_installed = { 'custom_server' },
      })

      -- Should still configure Mason
      assert.is_not_nil(_G._test_mason_config)
      assert.is_not_nil(_G._test_mason_lspconfig_config)
    end)
  end)

  describe('Graceful degradation', function()
    it('should return false when Mason not available', function()
      package.loaded['mason'] = nil
      package.preload['mason'] = function()
        error('not found')
      end

      local result = lsp.setup()
      assert.is_false(result)
    end)

    it('should return false when mason-lspconfig not available', function()
      package.loaded['mason-lspconfig'] = nil
      package.preload['mason-lspconfig'] = function()
        error('not found')
      end

      local result = lsp.setup()
      assert.is_false(result)
    end)

    it('should return false when lspconfig not available', function()
      package.loaded['lspconfig'] = nil
      package.preload['lspconfig'] = function()
        error('not found')
      end

      local result = lsp.setup()
      assert.is_false(result)
    end)

    it('should handle configuration errors', function()
      package.loaded['mason'] = nil
      package.preload['mason'] = function()
        return {
          setup = function()
            error('Configuration error')
          end,
        }
      end

      local result = lsp.setup()
      assert.is_false(result)
    end)
  end)

  describe('Default configuration', function()
    it('should include all core servers', function()
      lsp.setup()

      local servers = _G._test_mason_lspconfig_config.ensure_installed

      -- Core servers that should be auto-installed
      local expected_servers = {
        'lua_ls',
        'ts_ls',
        'pyright',
        'solargraph',
        'bashls',
        'sqlls',
        'marksman',
      }

      for _, expected in ipairs(expected_servers) do
        local found = false
        for _, server in ipairs(servers) do
          if server == expected then
            found = true
            break
          end
        end
        assert.is_true(found, 'Expected server ' .. expected .. ' to be in ensure_installed')
      end
    end)

    it('should configure Mason UI settings', function()
      lsp.setup()

      assert.is_not_nil(_G._test_mason_config.ui)
    end)
  end)

  describe('LSP capabilities', function()
    it('should configure completion capabilities', function()
      lsp.setup()

      -- Handler should be set for default server setup
      assert.is_not_nil(_G._test_mason_lspconfig_handlers)
    end)
  end)
end)
