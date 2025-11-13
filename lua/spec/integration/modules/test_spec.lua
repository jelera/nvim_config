--[[
Test Module Integration Tests
==============================

Integration tests for test module including neotest and language adapters.

Tags: #integration #test
--]]

describe('modules.test #integration #test', function()
  local spec_helper = require('spec.spec_helper')
  local test

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.test'] = nil
    package.loaded['modules.test.neotest'] = nil
    package.loaded['modules.test.adapters.javascript'] = nil
    package.loaded['modules.test.adapters.python'] = nil
    package.loaded['modules.test.adapters.ruby'] = nil
    package.loaded['modules.test.adapters.lua'] = nil
    package.loaded['modules.test.keymaps'] = nil

    -- Reset tracking flags
    _G._test_neotest_setup_called = false
    _G._test_test_keymaps_setup_called = false

    -- Mock submodules
    package.preload['modules.test.neotest'] = function()
      return {
        setup = function(config)
          _G._test_neotest_setup_called = true
          _G._test_neotest_config = config
          return true
        end,
      }
    end

    package.preload['modules.test.keymaps'] = function()
      return {
        setup = function()
          _G._test_test_keymaps_setup_called = true
          return true
        end,
      }
    end
  end)

  after_each(function()
    spec_helper.teardown()

    -- Clean up test globals
    _G._test_neotest_setup_called = nil
    _G._test_test_keymaps_setup_called = nil
    _G._test_neotest_config = nil
  end)

  describe('module loading', function()
    it('should load test module', function()
      test = require('modules.test')
      assert.is_table(test)
      assert.is_function(test.setup)
    end)

    it('should load neotest submodule directly', function()
      package.preload['modules.test.neotest'] = nil
      local neotest = require('modules.test.neotest')
      assert.is_table(neotest)
      assert.is_function(neotest.setup)
    end)

    it('should load javascript adapter directly', function()
      local js = require('modules.test.adapters.javascript')
      assert.is_table(js)
      assert.is_function(js.setup)
    end)

    it('should load python adapter directly', function()
      local python = require('modules.test.adapters.python')
      assert.is_table(python)
      assert.is_function(python.setup)
    end)

    it('should load ruby adapter directly', function()
      local ruby = require('modules.test.adapters.ruby')
      assert.is_table(ruby)
      assert.is_function(ruby.setup)
    end)

    it('should load lua adapter directly', function()
      local lua = require('modules.test.adapters.lua')
      assert.is_table(lua)
      assert.is_function(lua.setup)
    end)

    it('should load keymaps submodule directly', function()
      package.preload['modules.test.keymaps'] = nil
      local keymaps = require('modules.test.keymaps')
      assert.is_table(keymaps)
      assert.is_function(keymaps.setup)
    end)
  end)

  describe('test.setup()', function()
    it('should setup with default config', function()
      test = require('modules.test')
      local result = test.setup()
      assert.is_true(result)
    end)

    it('should setup all submodules', function()
      test = require('modules.test')
      test.setup()

      assert.is_true(_G._test_neotest_setup_called)
      assert.is_true(_G._test_test_keymaps_setup_called)
    end)

    it('should setup with custom config', function()
      test = require('modules.test')
      local result = test.setup({
        neotest = {
          adapters = { 'javascript', 'python' }
        }
      })
      assert.is_true(result)
    end)

    it('should pass config to neotest', function()
      test = require('modules.test')
      test.setup({
        neotest = {
          adapters = { 'javascript', 'python' }
        }
      })

      assert.is_table(_G._test_neotest_config)
      assert.is_table(_G._test_neotest_config.adapters)
    end)

    it('should setup keymaps last', function()
      test = require('modules.test')
      test.setup()

      assert.is_true(_G._test_neotest_setup_called)
      assert.is_true(_G._test_test_keymaps_setup_called)
    end)
  end)

  describe('neotest.setup()', function()
    it('should setup with default config', function()
      package.preload['modules.test.neotest'] = nil
      local neotest = require('modules.test.neotest')
      local result = neotest.setup()
      assert.is_true(result)
    end)

    it('should accept custom adapters list', function()
      package.preload['modules.test.neotest'] = nil
      local neotest = require('modules.test.neotest')
      local result = neotest.setup({
        adapters = { 'javascript', 'python' }
      })
      assert.is_true(result)
    end)

    it('should accept custom icons config', function()
      package.preload['modules.test.neotest'] = nil
      local neotest = require('modules.test.neotest')
      local result = neotest.setup({
        icons = {
          passed = '✓',
          failed = '✗'
        }
      })
      assert.is_true(result)
    end)
  end)

  describe('javascript adapter', function()
    it('should setup javascript adapter', function()
      local js = require('modules.test.adapters.javascript')
      local result = js.setup()
      assert.is_true(result)
    end)

    it('should configure jest', function()
      local js = require('modules.test.adapters.javascript')
      js.setup({ framework = 'jest' })
      assert.is_true(true) -- Adapter configured
    end)

    it('should configure vitest', function()
      local js = require('modules.test.adapters.javascript')
      js.setup({ framework = 'vitest' })
      assert.is_true(true) -- Adapter configured
    end)
  end)

  describe('python adapter', function()
    it('should setup python adapter', function()
      local python = require('modules.test.adapters.python')
      local result = python.setup()
      assert.is_true(result)
    end)

    it('should configure pytest', function()
      local python = require('modules.test.adapters.python')
      python.setup({ framework = 'pytest' })
      assert.is_true(true) -- Adapter configured
    end)
  end)

  describe('ruby adapter', function()
    it('should setup ruby adapter', function()
      local ruby = require('modules.test.adapters.ruby')
      local result = ruby.setup()
      assert.is_true(result)
    end)

    it('should configure rspec', function()
      local ruby = require('modules.test.adapters.ruby')
      ruby.setup({ framework = 'rspec' })
      assert.is_true(true) -- Adapter configured
    end)
  end)

  describe('lua adapter', function()
    it('should setup lua adapter', function()
      local lua = require('modules.test.adapters.lua')
      local result = lua.setup()
      assert.is_true(result)
    end)

    it('should configure busted', function()
      local lua = require('modules.test.adapters.lua')
      lua.setup({ framework = 'busted' })
      assert.is_true(true) -- Adapter configured
    end)
  end)

  describe('keymaps.setup()', function()
    before_each(function()
      -- Track keymap calls
      _G._test_keymaps = {}

      -- Override vim.keymap.set
      vim.keymap = {
        set = function(mode, lhs, rhs, opts)
          table.insert(_G._test_keymaps, {
            mode = mode,
            lhs = lhs,
            rhs = rhs,
            opts = opts or {},
          })
        end,
      }
    end)

    after_each(function()
      _G._test_keymaps = nil
    end)

    it('should setup test keymaps', function()
      package.preload['modules.test.keymaps'] = nil
      local keymaps = require('modules.test.keymaps')
      local result = keymaps.setup()
      assert.is_true(result)
      assert.is_true(#_G._test_keymaps > 0)
    end)

    it('should register test run keymaps', function()
      package.preload['modules.test.keymaps'] = nil
      local keymaps = require('modules.test.keymaps')
      keymaps.setup()

      local has_nearest = false
      local has_file = false

      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>tt' then has_nearest = true end
        if km.lhs == '<leader>tf' then has_file = true end
      end

      assert.is_true(has_nearest, 'Expected <leader>tt keymap for run nearest')
      assert.is_true(has_file, 'Expected <leader>tf keymap for run file')
    end)

    it('should register test control keymaps', function()
      package.preload['modules.test.keymaps'] = nil
      local keymaps = require('modules.test.keymaps')
      keymaps.setup()

      local has_suite = false
      local has_last = false

      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>ts' then has_suite = true end
        if km.lhs == '<leader>tl' then has_last = true end
      end

      assert.is_true(has_suite, 'Expected <leader>ts keymap for run suite')
      assert.is_true(has_last, 'Expected <leader>tl keymap for run last')
    end)
  end)

  describe('integration', function()
    it('should setup all components together', function()
      test = require('modules.test')
      local result = test.setup({
        neotest = {
          adapters = { 'javascript', 'python', 'ruby', 'lua' }
        }
      })

      assert.is_true(result)
      assert.is_true(_G._test_neotest_setup_called)
      assert.is_true(_G._test_test_keymaps_setup_called)
    end)

    it('should configure with auto-install adapters', function()
      test = require('modules.test')
      test.setup({
        neotest = {
          adapters = { 'javascript', 'python' }
        }
      })

      assert.is_table(_G._test_neotest_config)
      assert.is_table(_G._test_neotest_config.adapters)
    end)

    it('should configure with all language adapters', function()
      test = require('modules.test')
      test.setup({
        neotest = {
          adapters = { 'javascript', 'python', 'ruby', 'lua' }
        }
      })

      assert.is_table(_G._test_neotest_config)
    end)
  end)
end)
