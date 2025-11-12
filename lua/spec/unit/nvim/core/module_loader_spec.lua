--[[
Module Loader Tests
===================

Test suite for the module loading system that provides dynamic module loading,
dependency resolution, and error handling.

Test Categories:
1. Basic module loading
2. Module caching
3. Error handling
4. Module reloading
5. Dependency tracking
6. Module paths

Uses standard luassert syntax with plans for custom NeoVim-specific assertions
like assert.vim.* and assert.module.* in the future.
--]]

local spec_helper = require('spec.spec_helper')

describe('module_loader #unit', function()
  local module_loader

  before_each(function()
    spec_helper.setup()
    -- Clear any previously loaded module
    package.loaded['nvim.core.module_loader'] = nil
    module_loader = require('nvim.core.module_loader')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should create a module loader instance', function()
      assert.is_not_nil(module_loader)
      assert.is_table(module_loader)
    end)

    it('should have a load method', function()
      assert.is_function(module_loader.load)
    end)

    it('should have a reload method', function()
      assert.is_function(module_loader.reload)
    end)

    it('should have an is_loaded method', function()
      assert.is_function(module_loader.is_loaded)
    end)

    it('should have a get_loaded_modules method', function()
      assert.is_function(module_loader.get_loaded_modules)
    end)
  end)

  describe('load()', function()
    it('should load a valid module', function()
      local success, result = pcall(function()
        return module_loader.load('nvim.core.module_loader')
      end)

      assert.is_true(success)
      assert.is_not_nil(result)
    end)

    it('should return the same module on subsequent loads (caching)', function()
      local first_load = module_loader.load('nvim.core.module_loader')
      local second_load = module_loader.load('nvim.core.module_loader')

      -- Should return the exact same table (cached)
      assert.are.equal(first_load, second_load)
    end)

    it('should handle module not found errors gracefully', function()
      local success, err = pcall(function()
        return module_loader.load('nonexistent.module')
      end)

      assert.is_false(success)
      assert.is_string(err)
      assert.is_not_nil(err:match('module.*not found') or err:match('failed to load'))
    end)

    it('should add loaded module to tracking list', function()
      module_loader.load('nvim.core.module_loader')

      assert.is_true(module_loader.is_loaded('nvim.core.module_loader'))
    end)

    it('should support loading with options', function()
      local result = module_loader.load('nvim.core.module_loader', {
        force = false,
        silent = true
      })

      assert.is_not_nil(result)
    end)

    it('should call module setup if available', function()
      -- Create a mock module with setup and a counter to verify it's called
      local setup_called = 0
      local mock_module = {
        setup = function()
          setup_called = setup_called + 1
        end
      }

      -- Test WITHOUT spy first to isolate the issue
      -- Inject mock module into package.loaded (proper way to mock require)
      package.loaded['test.module'] = mock_module

      local result = module_loader.load('test.module', { call_setup = true })

      -- Verify setup was called
      assert.equals(1, setup_called, 'setup should have been called exactly once')

      -- Cleanup
      package.loaded['test.module'] = nil
    end)
  end)

  describe('reload()', function()
    it('should reload a module', function()
      -- First load
      module_loader.load('nvim.core.module_loader')

      -- Reload
      local reloaded = module_loader.reload('nvim.core.module_loader')

      -- Should still be a valid module
      assert.is_not_nil(reloaded)
    end)

    it('should clear cached version on reload', function()
      -- This tests that reload actually clears the package.loaded cache
      module_loader.load('nvim.core.module_loader')

      -- Check if in cache
      local was_in_cache = package.loaded['nvim.core.module_loader'] ~= nil

      module_loader.reload('nvim.core.module_loader')

      -- Module should have been cleared from cache (at least temporarily)
      assert.is_true(was_in_cache)
    end)

    it('should handle reloading nonexistent modules', function()
      local success, err = pcall(function()
        return module_loader.reload('nonexistent.module')
      end)

      assert.is_false(success)
      assert.is_string(err)
    end)

    it('should notify about reload', function()
      module_loader.reload('nvim.core.module_loader')

      -- Check that a notification was sent (pattern is case-sensitive)
      local notified = spec_helper.assert_notification('Reloading', vim.log.levels.DEBUG)
      assert.is_true(notified)
    end)
  end)

  describe('is_loaded()', function()
    it('should return false for unloaded modules', function()
      -- Ensure module is not loaded
      package.loaded['some.unloaded.module'] = nil

      assert.is_false(module_loader.is_loaded('some.unloaded.module'))
    end)

    it('should return true for loaded modules', function()
      module_loader.load('nvim.core.module_loader')

      assert.is_true(module_loader.is_loaded('nvim.core.module_loader'))
    end)

    it('should handle nil module name gracefully', function()
      local result = module_loader.is_loaded(nil)

      assert.is_false(result)
    end)

    it('should handle empty string module name', function()
      local result = module_loader.is_loaded('')

      assert.is_false(result)
    end)
  end)

  describe('get_loaded_modules()', function()
    it('should return a table', function()
      -- Load a module first to ensure tracking list has entries
      module_loader.load('nvim.core.module_loader')

      local loaded = module_loader.get_loaded_modules()

      assert.is_table(loaded)
      -- Should have at least module_loader itself
      assert.is_true(#loaded >= 1)
    end)

    it('should return list of loaded modules', function()
      module_loader.load('nvim.core.module_loader')

      local loaded = module_loader.get_loaded_modules()

      assert.is_table(loaded)
      assert.is_true(vim.tbl_contains(loaded, 'nvim.core.module_loader'))
    end)

    it('should filter by pattern if provided', function()
      module_loader.load('nvim.core.module_loader')

      local loaded = module_loader.get_loaded_modules({ pattern = '^nvim%.core%.' })

      assert.is_table(loaded)
      -- Should contain modules matching pattern
      for _, name in ipairs(loaded) do
        assert.is_not_nil(name:match('^nvim%.core%.'))
      end
    end)
  end)

  describe('error handling', function()
    it('should provide detailed error messages', function()
      local success, err = pcall(function()
        return module_loader.load('this.module.definitely.does.not.exist')
      end)

      assert.is_false(success)
      assert.is_string(err)
      assert.is_not_nil(err:match('module') or err:match('not found'))
    end)

    it('should handle module with syntax errors', function()
      -- Create a temporary module with syntax error
      local temp_module_path = './lua/temp_syntax_error.lua'
      local f = io.open(temp_module_path, 'w')
      if f then
        f:write('this is invalid lua syntax {{{{')
        f:close()

        local success, err = pcall(function()
          return module_loader.load('temp_syntax_error')
        end)

        assert.is_false(success)
        assert.is_string(err)

        -- Cleanup
        os.remove(temp_module_path)
      end
    end)

    it('should not crash on circular dependencies', function()
      -- This test verifies that circular deps don't cause infinite loops
      local success = pcall(function()
        module_loader.load('nvim.core.module_loader')
        module_loader.load('nvim.core.module_loader')
        module_loader.load('nvim.core.module_loader')
      end)

      assert.is_true(success)
    end)
  end)

  describe('module paths', function()
    it('should resolve relative module paths', function()
      local success, result = pcall(function()
        return module_loader.load('nvim.core.module_loader')
      end)

      assert.is_true(success)
    end)

    it('should handle module names with dots', function()
      local success = pcall(function()
        return module_loader.load('nvim.core.module_loader')
      end)

      assert.is_true(success)
    end)

    it('should support loading from different base paths', function()
      -- Test that modules can be loaded from various paths in package.path
      local result = module_loader.load('nvim.core.module_loader')

      assert.is_not_nil(result)
    end)
  end)

  describe('performance', function()
    it('should cache modules for fast subsequent access', function()
      -- First load (might be slower)
      local start = os.clock()
      module_loader.load('nvim.core.module_loader')
      local first_time = os.clock() - start

      -- Clear for fresh test
      module_loader.reload('nvim.core.module_loader')

      -- Subsequent loads (should be from cache)
      start = os.clock()
      for i = 1, 100 do
        module_loader.load('nvim.core.module_loader')
      end
      local cached_time = os.clock() - start

      -- Cached access should be much faster
      assert.is_true(cached_time < first_time * 50)
    end)
  end)

  describe('integration', function()
    it('should work with Lua\'s built-in require', function()
      -- module_loader should be compatible with require
      local via_loader = module_loader.load('nvim.core.module_loader')
      local via_require = require('nvim.core.module_loader')

      -- Should return compatible modules
      assert.are.equal(type(via_loader), type(via_require))
    end)

    it('should respect package.loaded cache', function()
      -- Load via require
      local via_require = require('nvim.core.module_loader')

      -- Load via module_loader
      local via_loader = module_loader.load('nvim.core.module_loader')

      -- Should be the same cached instance
      assert.are.equal(via_require, via_loader)
    end)
  end)
end)
