--[[
Init Unit Tests
===============

Unit tests for the main framework entry point that provides
the user-facing API for initializing the framework.

Test Categories:
1. Module structure
2. Framework initialization
3. Configuration handling
4. Version information
5. Module access

Uses standard luassert syntax.
--]]

local spec_helper = require('spec.spec_helper')

describe('nvim.init #unit', function()
  local nvim_init

  before_each(function()
    spec_helper.setup()
    package.loaded['nvim'] = nil
    nvim_init = require('nvim')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('module structure', function()
    it('should load init module', function()
      assert.is_not_nil(nvim_init)
      assert.is_table(nvim_init)
    end)

    it('should have setup function', function()
      assert.is_function(nvim_init.setup)
    end)

    it('should have version information', function()
      assert.is_not_nil(nvim_init.version)
      assert.is_string(nvim_init.version)
    end)

    it('should expose core modules', function()
      assert.is_table(nvim_init.core)
    end)

    it('should expose lib modules', function()
      assert.is_table(nvim_init.lib)
    end)
  end)

  describe('core module access', function()
    it('should provide access to module_loader', function()
      assert.is_not_nil(nvim_init.core.module_loader)
    end)

    it('should provide access to event_bus', function()
      assert.is_not_nil(nvim_init.core.event_bus)
    end)

    it('should provide access to plugin_system', function()
      assert.is_not_nil(nvim_init.core.plugin_system)
    end)

    it('should provide access to config_schema', function()
      assert.is_not_nil(nvim_init.core.config_schema)
    end)
  end)

  describe('lib module access', function()
    it('should provide access to utils', function()
      assert.is_not_nil(nvim_init.lib.utils)
    end)

    it('should provide access to validator', function()
      assert.is_not_nil(nvim_init.lib.validator)
    end)
  end)

  describe('setup()', function()
    it('should initialize framework with default config', function()
      -- Mock setup.init
      local setup_module = require('nvim.setup')
      local original_init = setup_module.init
      local init_called = false

      setup_module.init = function()
        init_called = true
        return true
      end

      local success = nvim_init.setup()

      assert.is_true(init_called)
      assert.is_true(success)

      setup_module.init = original_init
    end)

    it('should pass config to setup.init', function()
      local setup_module = require('nvim.setup')
      local original_init = setup_module.init
      local passed_config = nil

      setup_module.init = function(config)
        passed_config = config
        return true
      end

      local test_config = { plugins = { 'test' } }
      nvim_init.setup(test_config)

      assert.is_not_nil(passed_config)
      assert.equals(test_config, passed_config)

      setup_module.init = original_init
    end)

    it('should return false if setup fails', function()
      local setup_module = require('nvim.setup')
      local original_init = setup_module.init

      setup_module.init = function()
        return false
      end

      local success = nvim_init.setup()
      assert.is_false(success)

      setup_module.init = original_init
    end)

    it('should handle setup errors gracefully', function()
      local setup_module = require('nvim.setup')
      local original_init = setup_module.init

      setup_module.init = function()
        error('Setup error')
      end

      local success = nvim_init.setup()
      assert.is_false(success)

      setup_module.init = original_init
    end)
  end)

  describe('version', function()
    it('should follow semantic versioning', function()
      local version = nvim_init.version
      -- Should match format: major.minor.patch
      assert.is_not_nil(version:match('%d+%.%d+%.%d+'))
    end)
  end)
end)
