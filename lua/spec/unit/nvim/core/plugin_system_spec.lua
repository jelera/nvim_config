--[[
Plugin System Unit Tests
=========================

Unit tests for the plugin system that manages plugin registration, loading,
configuration, and lifecycle management.

Test Categories:
1. Plugin registration
2. Plugin loading (integration with module_loader)
3. Dependency resolution
4. Lazy loading support
5. Lifecycle events (integration with event_bus)
6. Plugin configuration
7. Error handling

Uses standard luassert syntax with simple patterns (counters, direct assertions).
--]]

local spec_helper = require('spec.spec_helper')

describe('plugin_system #unit', function()
  local plugin_system
  local event_bus
  local module_loader

  before_each(function()
    spec_helper.setup()
    -- Clear any previously loaded modules
    package.loaded['nvim.core.plugin_system'] = nil
    package.loaded['nvim.core.event_bus'] = nil
    package.loaded['nvim.core.module_loader'] = nil

    -- Load dependencies
    event_bus = require('nvim.core.event_bus')
    module_loader = require('nvim.core.module_loader')
    plugin_system = require('nvim.core.plugin_system')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should create a plugin system instance', function()
      assert.is_not_nil(plugin_system)
      assert.is_table(plugin_system)
    end)

    it('should have a register method for registering plugins', function()
      assert.is_function(plugin_system.register)
    end)

    it('should have a load method for loading plugins', function()
      assert.is_function(plugin_system.load)
    end)

    it('should have a get method for retrieving plugin info', function()
      assert.is_function(plugin_system.get)
    end)

    it('should have a list method for listing all plugins', function()
      assert.is_function(plugin_system.list)
    end)

    it('should have an unregister method for removing plugins', function()
      assert.is_function(plugin_system.unregister)
    end)
  end)

  describe('register()', function()
    it('should register a simple plugin without dependencies', function()
      local success = plugin_system.register('test_plugin', {
        description = 'A test plugin'
      })

      assert.is_true(success)

      local plugin = plugin_system.get('test_plugin')
      assert.is_not_nil(plugin)
      assert.equals('test_plugin', plugin.name)
      assert.equals('A test plugin', plugin.description)
    end)

    it('should register a plugin with configuration', function()
      local config_fn = function() end

      local success = plugin_system.register('configured_plugin', {
        config = config_fn
      })

      assert.is_true(success)

      local plugin = plugin_system.get('configured_plugin')
      assert.equals(config_fn, plugin.config)
    end)

    it('should register a plugin with dependencies', function()
      local success = plugin_system.register('dependent_plugin', {
        dependencies = { 'dep1', 'dep2' }
      })

      assert.is_true(success)

      local plugin = plugin_system.get('dependent_plugin')
      assert.is_table(plugin.dependencies)
      assert.equals(2, #plugin.dependencies)
      assert.equals('dep1', plugin.dependencies[1])
      assert.equals('dep2', plugin.dependencies[2])
    end)

    it('should register a plugin with lazy loading', function()
      local success = plugin_system.register('lazy_plugin', {
        lazy = true,
        event = 'VeryLazy'
      })

      assert.is_true(success)

      local plugin = plugin_system.get('lazy_plugin')
      assert.is_true(plugin.lazy)
      assert.equals('VeryLazy', plugin.event)
    end)

    it('should fail to register a plugin without a name', function()
      local success = plugin_system.register(nil, {})
      assert.is_false(success)
    end)

    it('should fail to register a plugin with an empty name', function()
      local success = plugin_system.register('', {})
      assert.is_false(success)
    end)

    it('should fail to register a duplicate plugin', function()
      plugin_system.register('duplicate', {})
      local success = plugin_system.register('duplicate', {})
      assert.is_false(success)
    end)

    it('should store plugin metadata correctly', function()
      plugin_system.register('metadata_plugin', {
        description = 'Test plugin',
        author = 'Test Author',
        version = '1.0.0',
        url = 'https://github.com/test/plugin'
      })

      local plugin = plugin_system.get('metadata_plugin')
      assert.equals('Test plugin', plugin.description)
      assert.equals('Test Author', plugin.author)
      assert.equals('1.0.0', plugin.version)
      assert.equals('https://github.com/test/plugin', plugin.url)
    end)
  end)

  describe('load()', function()
    it('should load a registered plugin without dependencies', function()
      plugin_system.register('simple_plugin', {
        config = function() end
      })

      local success = plugin_system.load('simple_plugin')
      assert.is_true(success)

      local plugin = plugin_system.get('simple_plugin')
      assert.is_true(plugin.loaded)
    end)

    it('should fail to load an unregistered plugin', function()
      local success = plugin_system.load('nonexistent_plugin')
      assert.is_false(success)
    end)

    it('should not reload an already loaded plugin', function()
      local load_count = 0
      plugin_system.register('already_loaded', {
        config = function() load_count = load_count + 1 end
      })

      plugin_system.load('already_loaded')
      plugin_system.load('already_loaded')

      assert.equals(1, load_count)
    end)

    it('should call plugin config function during load', function()
      local config_called = false
      plugin_system.register('config_plugin', {
        config = function() config_called = true end
      })

      plugin_system.load('config_plugin')
      assert.is_true(config_called)
    end)

    it('should handle plugin config errors gracefully', function()
      plugin_system.register('error_plugin', {
        config = function() error('Config error') end
      })

      -- Should not throw error, but return false
      local success = plugin_system.load('error_plugin')
      assert.is_false(success)

      local plugin = plugin_system.get('error_plugin')
      assert.is_false(plugin.loaded)
    end)
  end)

  describe('dependency resolution', function()
    it('should load dependencies before the plugin', function()
      local load_order = {}

      plugin_system.register('dep1', {
        config = function() table.insert(load_order, 'dep1') end
      })

      plugin_system.register('dep2', {
        config = function() table.insert(load_order, 'dep2') end
      })

      plugin_system.register('main_plugin', {
        dependencies = { 'dep1', 'dep2' },
        config = function() table.insert(load_order, 'main_plugin') end
      })

      plugin_system.load('main_plugin')

      assert.equals(3, #load_order)
      -- Dependencies should be loaded first
      assert.is_true(load_order[1] == 'dep1' or load_order[1] == 'dep2')
      assert.is_true(load_order[2] == 'dep1' or load_order[2] == 'dep2')
      assert.equals('main_plugin', load_order[3])
    end)

    it('should handle nested dependencies', function()
      local load_order = {}

      plugin_system.register('base', {
        config = function() table.insert(load_order, 'base') end
      })

      plugin_system.register('middle', {
        dependencies = { 'base' },
        config = function() table.insert(load_order, 'middle') end
      })

      plugin_system.register('top', {
        dependencies = { 'middle' },
        config = function() table.insert(load_order, 'top') end
      })

      plugin_system.load('top')

      assert.equals(3, #load_order)
      assert.equals('base', load_order[1])
      assert.equals('middle', load_order[2])
      assert.equals('top', load_order[3])
    end)

    it('should fail if a dependency is not registered', function()
      plugin_system.register('has_missing_dep', {
        dependencies = { 'missing_dep' }
      })

      local success = plugin_system.load('has_missing_dep')
      assert.is_false(success)
    end)

    it('should detect circular dependencies', function()
      plugin_system.register('plugin_a', {
        dependencies = { 'plugin_b' }
      })

      plugin_system.register('plugin_b', {
        dependencies = { 'plugin_a' }
      })

      local success = plugin_system.load('plugin_a')
      assert.is_false(success)
    end)

    it('should not load a plugin if any dependency fails to load', function()
      plugin_system.register('failing_dep', {
        config = function() error('Dependency error') end
      })

      plugin_system.register('dependent', {
        dependencies = { 'failing_dep' }
      })

      local success = plugin_system.load('dependent')
      assert.is_false(success)

      local dependent = plugin_system.get('dependent')
      assert.is_false(dependent.loaded)
    end)
  end)

  describe('lazy loading', function()
    it('should mark a lazy plugin as lazy', function()
      plugin_system.register('lazy_plugin', {
        lazy = true
      })

      local plugin = plugin_system.get('lazy_plugin')
      assert.is_true(plugin.lazy)
    end)

    it('should not auto-load lazy plugins', function()
      local loaded = false
      plugin_system.register('lazy_plugin', {
        lazy = true,
        config = function() loaded = true end
      })

      -- Lazy plugins should not be loaded automatically
      assert.is_false(loaded)
    end)

    it('should support event-based lazy loading', function()
      plugin_system.register('event_lazy', {
        lazy = true,
        event = 'BufEnter'
      })

      local plugin = plugin_system.get('event_lazy')
      assert.equals('BufEnter', plugin.event)
    end)

    it('should support command-based lazy loading', function()
      plugin_system.register('cmd_lazy', {
        lazy = true,
        cmd = 'MyCommand'
      })

      local plugin = plugin_system.get('cmd_lazy')
      assert.equals('MyCommand', plugin.cmd)
    end)

    it('should support filetype-based lazy loading', function()
      plugin_system.register('ft_lazy', {
        lazy = true,
        ft = { 'lua', 'vim' }
      })

      local plugin = plugin_system.get('ft_lazy')
      assert.is_table(plugin.ft)
      assert.equals(2, #plugin.ft)
    end)
  end)

  describe('lifecycle events', function()
    it('should emit plugin:before_load event before loading', function()
      local event_data = nil
      event_bus.on('plugin:before_load', function(data)
        event_data = data
      end)

      plugin_system.register('test_plugin', {})
      plugin_system.load('test_plugin')

      assert.is_not_nil(event_data)
      assert.equals('test_plugin', event_data.name)
    end)

    it('should emit plugin:loaded event after loading', function()
      local event_data = nil
      event_bus.on('plugin:loaded', function(data)
        event_data = data
      end)

      plugin_system.register('test_plugin', {})
      plugin_system.load('test_plugin')

      assert.is_not_nil(event_data)
      assert.equals('test_plugin', event_data.name)
    end)

    it('should emit plugin:configured event after configuration', function()
      local event_data = nil
      event_bus.on('plugin:configured', function(data)
        event_data = data
      end)

      plugin_system.register('test_plugin', {
        config = function() end
      })
      plugin_system.load('test_plugin')

      assert.is_not_nil(event_data)
      assert.equals('test_plugin', event_data.name)
    end)

    it('should emit plugin:error event on loading error', function()
      local event_data = nil
      event_bus.on('plugin:error', function(data)
        event_data = data
      end)

      plugin_system.register('error_plugin', {
        config = function() error('Test error') end
      })
      plugin_system.load('error_plugin')

      assert.is_not_nil(event_data)
      assert.equals('error_plugin', event_data.name)
      assert.is_not_nil(event_data.error)
    end)

    it('should emit events in correct order', function()
      local events = {}

      event_bus.on('plugin:before_load', function(data)
        table.insert(events, 'before_load')
      end)

      event_bus.on('plugin:loaded', function(data)
        table.insert(events, 'loaded')
      end)

      event_bus.on('plugin:configured', function(data)
        table.insert(events, 'configured')
      end)

      plugin_system.register('test_plugin', {
        config = function() end
      })
      plugin_system.load('test_plugin')

      assert.equals(3, #events)
      assert.equals('before_load', events[1])
      assert.equals('loaded', events[2])
      assert.equals('configured', events[3])
    end)
  end)

  describe('get()', function()
    it('should return plugin info for registered plugin', function()
      plugin_system.register('test_plugin', {
        description = 'Test'
      })

      local plugin = plugin_system.get('test_plugin')
      assert.is_not_nil(plugin)
      assert.equals('test_plugin', plugin.name)
    end)

    it('should return nil for unregistered plugin', function()
      local plugin = plugin_system.get('nonexistent')
      assert.is_nil(plugin)
    end)

    it('should return a copy of plugin data, not the original', function()
      plugin_system.register('test_plugin', {})

      local plugin1 = plugin_system.get('test_plugin')
      local plugin2 = plugin_system.get('test_plugin')

      -- Modifying one should not affect the other
      plugin1.modified = true
      assert.is_nil(plugin2.modified)
    end)
  end)

  describe('list()', function()
    it('should return an empty table when no plugins are registered', function()
      local plugins = plugin_system.list()
      assert.is_table(plugins)
      assert.equals(0, #plugins)
    end)

    it('should return all registered plugins', function()
      plugin_system.register('plugin1', {})
      plugin_system.register('plugin2', {})
      plugin_system.register('plugin3', {})

      local plugins = plugin_system.list()
      assert.equals(3, #plugins)
    end)

    it('should include plugin loaded status', function()
      plugin_system.register('loaded_plugin', {})
      plugin_system.register('unloaded_plugin', {})
      plugin_system.load('loaded_plugin')

      local plugins = plugin_system.list()

      local loaded = nil
      local unloaded = nil
      for _, p in ipairs(plugins) do
        if p.name == 'loaded_plugin' then
          loaded = p
        elseif p.name == 'unloaded_plugin' then
          unloaded = p
        end
      end

      assert.is_true(loaded.loaded)
      assert.is_false(unloaded.loaded)
    end)

    it('should support filtering by loaded status', function()
      plugin_system.register('loaded1', {})
      plugin_system.register('loaded2', {})
      plugin_system.register('unloaded', {})
      plugin_system.load('loaded1')
      plugin_system.load('loaded2')

      local loaded_plugins = plugin_system.list({ loaded = true })
      assert.equals(2, #loaded_plugins)
    end)

    it('should support filtering by lazy status', function()
      plugin_system.register('eager1', { lazy = false })
      plugin_system.register('lazy1', { lazy = true })
      plugin_system.register('lazy2', { lazy = true })

      local lazy_plugins = plugin_system.list({ lazy = true })
      assert.equals(2, #lazy_plugins)
    end)
  end)

  describe('unregister()', function()
    it('should unregister a plugin', function()
      plugin_system.register('test_plugin', {})

      local success = plugin_system.unregister('test_plugin')
      assert.is_true(success)

      local plugin = plugin_system.get('test_plugin')
      assert.is_nil(plugin)
    end)

    it('should fail to unregister a non-existent plugin', function()
      local success = plugin_system.unregister('nonexistent')
      assert.is_false(success)
    end)

    it('should not allow unregistering a loaded plugin', function()
      plugin_system.register('loaded_plugin', {})
      plugin_system.load('loaded_plugin')

      local success = plugin_system.unregister('loaded_plugin')
      assert.is_false(success)

      -- Plugin should still exist
      local plugin = plugin_system.get('loaded_plugin')
      assert.is_not_nil(plugin)
    end)
  end)

  describe('error handling', function()
    it('should handle nil config gracefully', function()
      local success = plugin_system.register('nil_config', nil)
      assert.is_false(success)
    end)

    it('should handle invalid config type', function()
      local success = plugin_system.register('invalid_config', 'not a table')
      assert.is_false(success)
    end)

    it('should handle invalid dependencies type', function()
      local success = plugin_system.register('invalid_deps', {
        dependencies = 'not a table'
      })
      assert.is_false(success)
    end)

    it('should handle invalid config function', function()
      plugin_system.register('invalid_config_fn', {
        config = 'not a function'
      })

      -- Should fail to load
      local success = plugin_system.load('invalid_config_fn')
      assert.is_false(success)
    end)
  end)
end)
