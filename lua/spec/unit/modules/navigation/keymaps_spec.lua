--[[
Navigation Keymaps Unit Tests
==============================

Unit tests for navigation keymap configuration.
Tests that all keymaps from the dotfiles are properly set up.
--]]

describe('modules.navigation.keymaps #unit', function()
  local spec_helper = require('spec.spec_helper')
  local keymaps

  before_each(function()
    spec_helper.setup()

    -- Reset module cache
    package.loaded['modules.navigation.keymaps'] = nil

    -- Track keymap calls
    _G._test_keymaps = {}

    -- Mock vim.keymap.set
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

    keymaps = require('modules.navigation.keymaps')
  end)

  after_each(function()
    spec_helper.teardown()
    _G._test_keymaps = nil

    -- Clear package cache
    package.loaded['modules.navigation.keymaps'] = nil
  end)

  describe('Module structure', function()
    it('should have a setup function', function()
      assert.is_function(keymaps.setup)
    end)
  end)

  describe('setup()', function()
    it('should return true on successful setup', function()
      local result = keymaps.setup()
      assert.is_true(result)
    end)

    it('should set up keymaps', function()
      keymaps.setup()
      assert.is_true(#_G._test_keymaps > 0)
    end)
  end)

  describe('Telescope keymaps', function()
    before_each(function()
      keymaps.setup()
    end)

    it('should set <C-p>g for find_files', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-p>g' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-p>p for git_files', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-p>p' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-p>h for oldfiles', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-p>h' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-p>b for buffers', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-p>b' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <leader>rg for live_grep', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>rg' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set \\ for quick live_grep', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '\\' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)

  describe('Tree keymaps', function()
    before_each(function()
      keymaps.setup()
    end)

    it('should set <C-t> for tree toggle', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-t>' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-B>t for find file in tree', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-B>t' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <leader>e for tree focus', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<leader>e' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)

  describe('Buffer navigation keymaps', function()
    before_each(function()
      keymaps.setup()
    end)

    it('should set ]b for next buffer', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == ']b' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set [b for previous buffer', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '[b' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)

  describe('Window navigation keymaps', function()
    before_each(function()
      keymaps.setup()
    end)

    it('should set <C-h> for left window', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-h>' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-j> for bottom window', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-j>' and km.mode == 'n' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-k> for top window', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-k>' and km.mode == 'n' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)

    it('should set <C-l> for right window', function()
      local found = false
      for _, km in ipairs(_G._test_keymaps) do
        if km.lhs == '<C-l>' then
          found = true
          break
        end
      end
      assert.is_true(found)
    end)
  end)
end)
