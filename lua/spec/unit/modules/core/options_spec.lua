--[[
Options Unit Tests
==================

Unit tests for the core options module that handles vim settings.

Test Categories:
1. Module structure and API
2. Option setting (vim.opt)
3. Global variables (vim.g)
4. Option validation
5. User configuration override
6. Category-based options

Uses standard luassert syntax with #unit tag.
--]]

local spec_helper = require('spec.spec_helper')

describe('modules.core.options #unit', function()
  local options

  before_each(function()
    spec_helper.setup()
    package.loaded['modules.core.options'] = nil
    options = require('modules.core.options')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('module structure', function()
    it('should load options module', function()
      assert.is_not_nil(options)
      assert.is_table(options)
    end)

    it('should have setup function', function()
      assert.is_function(options.setup)
    end)

    it('should have get_defaults function', function()
      assert.is_function(options.get_defaults)
    end)

    it('should have apply function', function()
      assert.is_function(options.apply)
    end)
  end)

  describe('get_defaults()', function()
    it('should return default options table', function()
      local defaults = options.get_defaults()
      assert.is_table(defaults)
    end)

    it('should include general settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.general)
      assert.is_table(defaults.general)
    end)

    it('should include UI settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.ui)
      assert.is_table(defaults.ui)
    end)

    it('should include editing settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.editing)
      assert.is_table(defaults.editing)
    end)

    it('should include search settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.search)
      assert.is_table(defaults.search)
    end)

    it('should include performance settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.performance)
      assert.is_table(defaults.performance)
    end)

    it('should include file settings', function()
      local defaults = options.get_defaults()
      assert.is_not_nil(defaults.files)
      assert.is_table(defaults.files)
    end)
  end)

  describe('default values', function()
    local defaults

    before_each(function()
      defaults = options.get_defaults()
    end)

    -- General settings
    it('should enable mouse support by default', function()
      assert.equals('a', defaults.general.mouse)
    end)

    it('should set encoding to utf-8 by default', function()
      assert.equals('utf-8', defaults.general.encoding)
    end)

    it('should use system clipboard by default', function()
      assert.equals('unnamedplus', defaults.general.clipboard)
    end)

    -- UI settings
    it('should show line numbers by default', function()
      assert.is_true(defaults.ui.number)
    end)

    it('should show relative line numbers by default', function()
      assert.is_true(defaults.ui.relativenumber)
    end)

    it('should show signcolumn by default', function()
      assert.equals('yes', defaults.ui.signcolumn)
    end)

    it('should set colorcolumn to 80 by default', function()
      assert.equals('80', defaults.ui.colorcolumn)
    end)

    -- Editing settings
    it('should expand tabs by default', function()
      assert.is_true(defaults.editing.expandtab)
    end)

    it('should set shiftwidth to 2 by default', function()
      assert.equals(2, defaults.editing.shiftwidth)
    end)

    it('should set tabstop to 2 by default', function()
      assert.equals(2, defaults.editing.tabstop)
    end)

    it('should enable autoindent by default', function()
      assert.is_true(defaults.editing.autoindent)
    end)

    it('should enable smartindent by default', function()
      assert.is_true(defaults.editing.smartindent)
    end)

    -- Search settings
    it('should enable ignorecase by default', function()
      assert.is_true(defaults.search.ignorecase)
    end)

    it('should enable smartcase by default', function()
      assert.is_true(defaults.search.smartcase)
    end)

    it('should enable hlsearch by default', function()
      assert.is_true(defaults.search.hlsearch)
    end)

    it('should enable incsearch by default', function()
      assert.is_true(defaults.search.incsearch)
    end)

    -- Performance settings
    it('should set updatetime to 300ms by default', function()
      assert.equals(300, defaults.performance.updatetime)
    end)

    it('should set timeoutlen to 500ms by default', function()
      assert.equals(500, defaults.performance.timeoutlen)
    end)

    -- File settings
    it('should disable backup by default', function()
      assert.is_false(defaults.files.backup)
    end)

    it('should disable writebackup by default', function()
      assert.is_false(defaults.files.writebackup)
    end)

    it('should disable swapfile by default', function()
      assert.is_false(defaults.files.swapfile)
    end)

    it('should enable undofile by default', function()
      assert.is_true(defaults.files.undofile)
    end)
  end)

  describe('apply()', function()
    it('should apply vim options without error', function()
      local test_options = {
        general = { mouse = 'a' },
        ui = { number = true },
      }

      local success = options.apply(test_options)
      assert.is_true(success)
    end)

    it('should set vim.opt values', function()
      local test_options = {
        ui = { number = true, relativenumber = false },
      }

      options.apply(test_options)

      assert.is_true(vim.opt.number._value)
      assert.is_false(vim.opt.relativenumber._value)
    end)

    it('should handle string options', function()
      local test_options = {
        general = { encoding = 'utf-8' },
      }

      options.apply(test_options)

      assert.equals('utf-8', vim.opt.encoding._value)
    end)

    it('should handle number options', function()
      local test_options = {
        editing = { shiftwidth = 4, tabstop = 4 },
      }

      options.apply(test_options)

      assert.equals(4, vim.opt.shiftwidth._value)
      assert.equals(4, vim.opt.tabstop._value)
    end)

    it('should handle boolean options', function()
      local test_options = {
        files = { backup = false, undofile = true },
      }

      options.apply(test_options)

      assert.is_false(vim.opt.backup._value)
      assert.is_true(vim.opt.undofile._value)
    end)

    it('should apply all categories', function()
      local test_options = {
        general = { mouse = 'a' },
        ui = { number = true },
        editing = { expandtab = true },
        search = { ignorecase = true },
        performance = { updatetime = 300 },
        files = { undofile = true },
      }

      local success = options.apply(test_options)
      assert.is_true(success)

      -- Verify each category was applied
      assert.equals('a', vim.opt.mouse._value)
      assert.is_true(vim.opt.number._value)
      assert.is_true(vim.opt.expandtab._value)
      assert.is_true(vim.opt.ignorecase._value)
      assert.equals(300, vim.opt.updatetime._value)
      assert.is_true(vim.opt.undofile._value)
    end)

    it('should handle empty options gracefully', function()
      local success = options.apply({})
      assert.is_true(success)
    end)

    it('should handle nil options gracefully', function()
      local success = options.apply(nil)
      assert.is_true(success)
    end)

    it('should return false on error', function()
      -- Mock vim.opt to throw error on assignment
      local original_opt = vim.opt
      vim.opt = setmetatable({}, {
        __newindex = function()
          error('Test error')
        end,
      })

      local success = options.apply({ general = { mouse = 'a' } })
      assert.is_false(success)

      vim.opt = original_opt
    end)
  end)

  describe('setup()', function()
    it('should initialize with default config', function()
      local success = options.setup()
      assert.is_true(success)
    end)

    it('should apply default options when no config provided', function()
      options.setup()

      -- Check some defaults were applied
      assert.equals('a', vim.opt.mouse._value)
      assert.is_true(vim.opt.number._value)
      assert.is_true(vim.opt.expandtab._value)
    end)

    it('should merge user config with defaults', function()
      local user_config = {
        ui = {
          number = false,  -- Override default
          relativenumber = false,  -- Override default
        },
        editing = {
          shiftwidth = 4,  -- Override default (2)
        },
      }

      options.setup(user_config)

      -- User overrides applied
      assert.is_false(vim.opt.number._value)
      assert.is_false(vim.opt.relativenumber._value)
      assert.equals(4, vim.opt.shiftwidth._value)

      -- Other defaults still applied
      assert.equals('a', vim.opt.mouse._value)
      assert.is_true(vim.opt.expandtab._value)
    end)

    it('should preserve unspecified defaults when merging', function()
      local user_config = {
        ui = { number = false },  -- Only override number
      }

      options.setup(user_config)

      -- User override
      assert.is_false(vim.opt.number._value)

      -- Other UI defaults preserved
      assert.is_true(vim.opt.relativenumber._value)
      assert.equals('yes', vim.opt.signcolumn._value)
    end)

    it('should return false if setup fails', function()
      -- Mock apply to fail
      local original_apply = options.apply
      options.apply = function()
        return false
      end

      local success = options.setup()
      assert.is_false(success)

      options.apply = original_apply
    end)
  end)

  describe('option categories', function()
    it('should organize options into logical categories', function()
      local defaults = options.get_defaults()

      -- Verify category structure
      assert.is_table(defaults.general)
      assert.is_table(defaults.ui)
      assert.is_table(defaults.editing)
      assert.is_table(defaults.search)
      assert.is_table(defaults.performance)
      assert.is_table(defaults.files)
    end)

    it('should have non-empty categories', function()
      local defaults = options.get_defaults()
      local utils = require('nvim.lib.utils')

      assert.is_false(utils.is_empty(defaults.general))
      assert.is_false(utils.is_empty(defaults.ui))
      assert.is_false(utils.is_empty(defaults.editing))
      assert.is_false(utils.is_empty(defaults.search))
      assert.is_false(utils.is_empty(defaults.performance))
      assert.is_false(utils.is_empty(defaults.files))
    end)
  end)
end)
