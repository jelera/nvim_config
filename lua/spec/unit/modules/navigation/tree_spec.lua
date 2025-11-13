--[[
Tree Module Unit Tests
=======================

Unit tests for nvim-tree file explorer configuration.
--]]

describe('modules.navigation.tree #unit', function()
  local spec_helper = require('spec.spec_helper')
  local tree

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.navigation.tree'] = nil
    package.loaded['nvim-tree'] = nil
    package.loaded['nvim-tree.api'] = nil

    -- Track nvim-tree setup calls
    _G._test_tree_setup_called = false
    _G._test_tree_config = nil

    -- Mock nvim-tree
    package.preload['nvim-tree'] = function()
      return {
        setup = function(config)
          _G._test_tree_setup_called = true
          _G._test_tree_config = config
        end,
      }
    end

    -- Mock nvim-tree.api
    package.preload['nvim-tree.api'] = function()
      return {
        tree = {
          toggle = function() end,
          find_file = function() end,
          focus = function() end,
          collapse_all = function() end,
          reload = function() end,
        },
        fs = {
          create = function() end,
          remove = function() end,
          rename = function() end,
          copy = function() end,
        },
      }
    end

    tree = require('modules.navigation.tree')
  end)

  after_each(function()
    spec_helper.teardown()
    _G._test_tree_setup_called = nil
    _G._test_tree_config = nil

    -- Clear package cache
    package.loaded['modules.navigation.tree'] = nil
    package.loaded['nvim-tree'] = nil
    package.loaded['nvim-tree.api'] = nil
    package.preload['nvim-tree'] = nil
    package.preload['nvim-tree.api'] = nil
  end)

  describe('Module structure', function()
    it('should have a setup function', function()
      assert.is_function(tree.setup)
    end)

    it('should have a get_api function', function()
      assert.is_function(tree.get_api)
    end)
  end)

  describe('setup()', function()
    it('should return true on successful setup', function()
      local result = tree.setup()
      assert.is_true(result)
    end)

    it('should call nvim-tree.setup', function()
      tree.setup()
      assert.is_true(_G._test_tree_setup_called)
    end)

    it('should accept empty config', function()
      local result = tree.setup({})
      assert.is_true(result)
    end)

    it('should accept nil config', function()
      local result = tree.setup(nil)
      assert.is_true(result)
    end)

    it('should disable netrw', function()
      tree.setup()
      assert.is_true(vim.g.loaded_netrw == 1)
      assert.is_true(vim.g.loaded_netrwPlugin == 1)
    end)
  end)

  describe('Configuration', function()
    it('should configure renderer', function()
      tree.setup()
      assert.is_not_nil(_G._test_tree_config)
      assert.is_not_nil(_G._test_tree_config.renderer)
    end)

    it('should configure view', function()
      tree.setup()
      assert.is_not_nil(_G._test_tree_config.view)
    end)

    it('should configure filters', function()
      tree.setup()
      assert.is_not_nil(_G._test_tree_config.filters)
    end)

    it('should configure git integration', function()
      tree.setup()
      assert.is_not_nil(_G._test_tree_config.git)
    end)

    it('should configure actions', function()
      tree.setup()
      assert.is_not_nil(_G._test_tree_config.actions)
    end)
  end)

  describe('get_api()', function()
    it('should return api after successful setup', function()
      tree.setup()
      local api = tree.get_api()
      assert.is_not_nil(api)
      assert.is_not_nil(api.tree)
      assert.is_function(api.tree.toggle)
    end)
  end)

  describe('Graceful degradation', function()
    it('should return false when nvim-tree is not available', function()
      package.loaded['modules.navigation.tree'] = nil
      package.loaded['nvim-tree'] = nil
      package.preload['nvim-tree'] = nil

      local tree_module = require('modules.navigation.tree')
      local result = tree_module.setup()

      assert.is_false(result)
    end)
  end)
end)
