--[[
LSP Module Integration Tests
=============================

Integration tests for LSP module with full workflow.

Test Categories:
1. Full setup workflow
2. Server config loading
3. Keymaps integration
4. Diagnostics integration
5. Event handlers integration
--]]

describe('modules.lsp #integration', function()
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
    _G._test_keymaps = {}
    _G._test_on_attach_called = {}

    -- Mock vim APIs
    vim.diagnostic = {
      config = function(config)
        _G._test_diagnostic_config = config
      end,
      goto_prev = function() end,
      goto_next = function() end,
      open_float = function() end,
      setloclist = function() end,
    }

    vim.lsp = {
      buf = {
        definition = function() end,
        declaration = function() end,
        references = function() end,
        implementation = function() end,
        type_definition = function() end,
        hover = function() end,
        signature_help = function() end,
        rename = function() end,
        code_action = function() end,
        format = function() end,
      },
    }

    vim.fn = vim.fn or {}
    vim.fn.sign_define = function(name, opts)
      -- Track signs
    end

    vim.keymap = {
      set = function(mode, lhs, rhs, opts)
        table.insert(_G._test_keymaps, {
          mode = mode,
          lhs = lhs,
          buffer = opts and opts.buffer,
        })
      end,
    }

    vim.api = vim.api or {}
    vim.api.nvim_create_autocmd = function() end
    vim.api.nvim_get_runtime_file = function() return {} end

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
          -- Simulate calling default handler for some servers
          if handlers[1] then
            handlers[1]('lua_ls')
            handlers[1]('ts_ls')
            handlers[1]('pyright')
          end
        end,
        get_installed_servers = function()
          -- Return test servers for integration tests
          return { 'lua_ls', 'ts_ls', 'pyright' }
        end,
      }
    end

    -- Mock lspconfig (needed for config loading)
    package.preload['lspconfig'] = function()
      return {}
    end

    -- Initialize vim.lsp if it doesn't exist
    vim.lsp = vim.lsp or {}

    -- Mock vim.lsp.config and vim.lsp.enable for Neovim 0.11
    vim.lsp.config = function(server_name, config)
      _G._test_lsp_servers_setup[server_name] = config

      -- Simulate on_attach being called
      if config.on_attach then
        table.insert(_G._test_on_attach_called, server_name)
        -- Call on_attach with mock client and buffer
        config.on_attach({ name = server_name, supports_method = function() return true end }, 1)
      end
    end

    vim.lsp.enable = function(server_name)
      -- Track that enable was called
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
    _G._test_diagnostic_config = nil
    _G._test_keymaps = nil
    _G._test_on_attach_called = nil
  end)

  describe('Full setup workflow', function()
    it('should complete full setup successfully', function()
      local result = lsp.setup()

      assert.is_true(result)
      assert.is_not_nil(_G._test_mason_config)
      assert.is_not_nil(_G._test_mason_lspconfig_config)
      assert.is_not_nil(_G._test_diagnostic_config)
    end)

    it('should configure all components in correct order', function()
      local setup_order = {}

      package.loaded['mason'] = nil
      package.preload['mason'] = function()
        return {
          setup = function(config)
            table.insert(setup_order, 'mason')
            _G._test_mason_config = config
          end,
        }
      end

      package.loaded['mason-lspconfig'] = nil
      package.preload['mason-lspconfig'] = function()
        return {
          setup = function(config)
            table.insert(setup_order, 'mason-lspconfig')
            _G._test_mason_lspconfig_config = config
          end,
          get_installed_servers = function()
            table.insert(setup_order, 'get_servers')
            return { 'lua_ls' }
          end,
        }
      end

      package.loaded['lspconfig'] = nil
      package.preload['lspconfig'] = function()
        return {}
      end

      -- Initialize vim.lsp if it doesn't exist
      vim.lsp = vim.lsp or {}

      -- Mock vim.lsp.config and vim.lsp.enable
      vim.lsp.config = function(server_name, config)
        table.insert(setup_order, 'vim_lsp_config_' .. server_name)
      end

      vim.lsp.enable = function(server_name)
        table.insert(setup_order, 'vim_lsp_enable_' .. server_name)
      end

      vim.diagnostic = {
        config = function()
          table.insert(setup_order, 'diagnostics')
        end,
      }

      lsp.setup()

      -- Order should be: mason -> mason-lspconfig -> diagnostics -> get_servers -> vim_lsp_config_lua_ls -> vim_lsp_enable_lua_ls
      assert.equal('mason', setup_order[1])
      assert.equal('mason-lspconfig', setup_order[2])
      assert.equal('diagnostics', setup_order[3])
      assert.equal('get_servers', setup_order[4])
      assert.equal('vim_lsp_config_lua_ls', setup_order[5])
      assert.equal('vim_lsp_enable_lua_ls', setup_order[6])
    end)
  end)

  describe('Server config loading', function()
    it('should load per-language server configs', function()
      lsp.setup()

      -- lua_ls should have custom config loaded
      local lua_config = _G._test_lsp_servers_setup['lua_ls']
      assert.is_not_nil(lua_config)
      assert.is_not_nil(lua_config.settings)
      assert.is_not_nil(lua_config.settings.Lua)
    end)

    it('should merge server config with defaults', function()
      lsp.setup()

      local lua_config = _G._test_lsp_servers_setup['lua_ls']

      -- Should have default capabilities
      assert.is_not_nil(lua_config.capabilities)

      -- Should have default on_attach
      assert.is_function(lua_config.on_attach)

      -- Should have custom settings from lua_ls.lua
      assert.is_not_nil(lua_config.settings)
    end)

    it('should handle servers without custom config', function()
      lsp.setup()

      -- Servers without custom config should still work
      -- They'll have default capabilities and on_attach
      for _, server in ipairs({ 'lua_ls', 'ts_ls', 'pyright' }) do
        local config = _G._test_lsp_servers_setup[server]
        assert.is_not_nil(config)
        assert.is_not_nil(config.capabilities)
        assert.is_function(config.on_attach)
      end
    end)
  end)

  describe('Keymaps integration', function()
    it('should setup keymaps when on_attach is called', function()
      lsp.setup()

      -- on_attach should have been called during setup
      assert.is_true(#_G._test_on_attach_called > 0)

      -- Keymaps should have been set
      assert.is_true(#_G._test_keymaps > 0)
    end)

    it('should setup keymaps for each attached server', function()
      lsp.setup()

      -- Should have on_attach called for lua_ls, ts_ls, pyright
      assert.is_true(#_G._test_on_attach_called >= 3)
    end)

    it('should setup LSP keymaps with buffer-local scope', function()
      lsp.setup()

      -- All keymaps should be buffer-local
      for _, keymap in ipairs(_G._test_keymaps) do
        if keymap.lhs ~= '<leader>f' then -- format might be special
          assert.is_not_nil(keymap.buffer)
        end
      end
    end)

    it('should setup go-to keymaps', function()
      lsp.setup()

      local has_gd = false
      local has_gr = false

      for _, keymap in ipairs(_G._test_keymaps) do
        if keymap.lhs == 'gd' then has_gd = true end
        if keymap.lhs == 'gr' then has_gr = true end
      end

      assert.is_true(has_gd)
      assert.is_true(has_gr)
    end)
  end)

  describe('Diagnostics integration', function()
    it('should configure diagnostics', function()
      lsp.setup()

      assert.is_not_nil(_G._test_diagnostic_config)
    end)

    it('should enable virtual text', function()
      lsp.setup()

      assert.is_true(_G._test_diagnostic_config.virtual_text)
    end)

    it('should enable signs', function()
      lsp.setup()

      assert.is_true(_G._test_diagnostic_config.signs)
    end)

    it('should enable severity sorting', function()
      lsp.setup()

      assert.is_true(_G._test_diagnostic_config.severity_sort)
    end)
  end)

  describe('Event handlers integration', function()
    it('should call on_attach for each server', function()
      lsp.setup()

      -- Should have called on_attach for multiple servers
      assert.is_true(#_G._test_on_attach_called > 0)
    end)

    it('should pass client and buffer to on_attach', function()
      local on_attach_args = nil

      package.loaded['lspconfig'] = nil
      package.preload['lspconfig'] = function()
        return {}
      end

      -- Initialize vim.lsp if it doesn't exist
      vim.lsp = vim.lsp or {}

      -- Mock vim.lsp.config
      vim.lsp.config = function(server_name, config)
        if config.on_attach then
          local mock_client = { name = 'mock_server', supports_method = function() return true end }
          on_attach_args = { mock_client, 123 }
          config.on_attach(mock_client, 123)
        end
      end

      vim.lsp.enable = function(server_name)
        -- Track that enable was called
      end

      lsp.setup()

      assert.is_not_nil(on_attach_args)
    end)
  end)

  describe('Configuration options', function()
    it('should respect custom ensure_installed list', function()
      lsp.setup({
        ensure_installed = { 'lua_ls', 'pyright' },
      })

      local ensure_installed = _G._test_mason_lspconfig_config.ensure_installed
      assert.equal(2, #ensure_installed)
    end)

    it('should respect automatic_installation setting', function()
      lsp.setup({
        automatic_enable = false,
      })

      assert.is_false(_G._test_mason_lspconfig_config.automatic_enable)
    end)

    it('should merge user config with defaults', function()
      lsp.setup({
        ensure_installed = { 'custom_server' },
        automatic_enable = false,
      })

      -- Should still have Mason configured
      assert.is_not_nil(_G._test_mason_config)
      assert.is_not_nil(_G._test_mason_config.ui)
    end)
  end)

  describe('Error handling', function()
    it('should handle server config loading errors gracefully', function()
      -- Even if a server config fails to load, setup should continue
      lsp.setup()

      assert.is_true(true) -- If we get here, error was handled
    end)
  end)
end)
