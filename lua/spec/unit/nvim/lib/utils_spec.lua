--[[
Utils Unit Tests
================

Unit tests for shared utility functions used across the framework.

Test Categories:
1. deep_copy - Deep copying values and tables
2. deep_merge - Merging tables with precedence
3. is_array - Array detection
4. is_empty - Empty table detection
5. table_keys - Key extraction
6. table_size - Table size calculation

Uses standard luassert syntax.
--]]

local spec_helper = require('spec.spec_helper')

describe('lib.utils #unit', function()
  local utils

  before_each(function()
    spec_helper.setup()
    package.loaded['nvim.lib.utils'] = nil
    utils = require('nvim.lib.utils')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should load utils module', function()
      assert.is_not_nil(utils)
      assert.is_table(utils)
    end)

    it('should have deep_copy function', function()
      assert.is_function(utils.deep_copy)
    end)

    it('should have deep_merge function', function()
      assert.is_function(utils.deep_merge)
    end)

    it('should have is_array function', function()
      assert.is_function(utils.is_array)
    end)

    it('should have is_empty function', function()
      assert.is_function(utils.is_empty)
    end)

    it('should have table_keys function', function()
      assert.is_function(utils.table_keys)
    end)

    it('should have table_size function', function()
      assert.is_function(utils.table_size)
    end)
  end)

  describe('deep_copy()', function()
    it('should copy primitive values', function()
      assert.equals(42, utils.deep_copy(42))
      assert.equals('hello', utils.deep_copy('hello'))
      assert.equals(true, utils.deep_copy(true))
      assert.equals(false, utils.deep_copy(false))
    end)

    it('should copy nil', function()
      assert.is_nil(utils.deep_copy(nil))
    end)

    it('should copy simple tables', function()
      local original = { a = 1, b = 2, c = 3 }
      local copy = utils.deep_copy(original)

      assert.equals(1, copy.a)
      assert.equals(2, copy.b)
      assert.equals(3, copy.c)
    end)

    it('should create independent copies', function()
      local original = { value = 10 }
      local copy = utils.deep_copy(original)

      copy.value = 20

      assert.equals(10, original.value)
      assert.equals(20, copy.value)
    end)

    it('should copy nested tables', function()
      local original = {
        level1 = {
          level2 = {
            level3 = 'deep'
          }
        }
      }
      local copy = utils.deep_copy(original)

      assert.equals('deep', copy.level1.level2.level3)

      -- Modify copy shouldn't affect original
      copy.level1.level2.level3 = 'modified'
      assert.equals('deep', original.level1.level2.level3)
    end)

    it('should copy arrays', function()
      local original = { 'a', 'b', 'c' }
      local copy = utils.deep_copy(original)

      assert.equals(3, #copy)
      assert.equals('a', copy[1])
      assert.equals('b', copy[2])
      assert.equals('c', copy[3])
    end)

    it('should copy mixed tables', function()
      local original = {
        name = 'test',
        items = { 1, 2, 3 },
        config = { enabled = true }
      }
      local copy = utils.deep_copy(original)

      assert.equals('test', copy.name)
      assert.equals(3, #copy.items)
      assert.is_true(copy.config.enabled)

      -- Verify independence
      copy.items[1] = 999
      assert.equals(1, original.items[1])
    end)

    it('should copy empty tables', function()
      local original = {}
      local copy = utils.deep_copy(original)

      assert.is_table(copy)
      assert.equals(0, #copy)
    end)

    it('should handle functions', function()
      local fn = function() return 42 end
      local copy = utils.deep_copy(fn)

      assert.is_function(copy)
      assert.equals(fn, copy)  -- Functions are not deep copied, same reference
    end)

    it('should copy tables with function values', function()
      local original = {
        name = 'test',
        callback = function() return 'called' end
      }
      local copy = utils.deep_copy(original)

      assert.equals('test', copy.name)
      assert.is_function(copy.callback)
      assert.equals('called', copy.callback())
    end)
  end)

  describe('deep_merge()', function()
    it('should merge simple tables', function()
      local source = { a = 1, b = 2 }
      local target = { b = 20, c = 3 }
      local merged = utils.deep_merge(source, target)

      assert.equals(1, merged.a)   -- From source
      assert.equals(20, merged.b)  -- From target (override)
      assert.equals(3, merged.c)   -- From target
    end)

    it('should not modify input tables', function()
      local source = { a = 1 }
      local target = { b = 2 }
      local merged = utils.deep_merge(source, target)

      merged.c = 3

      assert.is_nil(source.c)
      assert.is_nil(target.c)
    end)

    it('should merge nested tables', function()
      local source = {
        server = {
          host = 'localhost',
          port = 3000
        }
      }
      local target = {
        server = {
          port = 8080
        }
      }
      local merged = utils.deep_merge(source, target)

      assert.equals('localhost', merged.server.host)  -- From source
      assert.equals(8080, merged.server.port)         -- From target (override)
    end)

    it('should merge deeply nested tables', function()
      local source = {
        level1 = {
          level2 = {
            a = 1,
            b = 2
          }
        }
      }
      local target = {
        level1 = {
          level2 = {
            b = 20,
            c = 3
          }
        }
      }
      local merged = utils.deep_merge(source, target)

      assert.equals(1, merged.level1.level2.a)
      assert.equals(20, merged.level1.level2.b)
      assert.equals(3, merged.level1.level2.c)
    end)

    it('should override non-table values with table values', function()
      local source = { value = 'string' }
      local target = { value = { nested = true } }
      local merged = utils.deep_merge(source, target)

      assert.is_table(merged.value)
      assert.is_true(merged.value.nested)
    end)

    it('should override table values with non-table values', function()
      local source = { value = { nested = true } }
      local target = { value = 'string' }
      local merged = utils.deep_merge(source, target)

      assert.equals('string', merged.value)
    end)

    it('should handle empty source', function()
      local source = {}
      local target = { a = 1, b = 2 }
      local merged = utils.deep_merge(source, target)

      assert.equals(1, merged.a)
      assert.equals(2, merged.b)
    end)

    it('should handle empty target', function()
      local source = { a = 1, b = 2 }
      local target = {}
      local merged = utils.deep_merge(source, target)

      assert.equals(1, merged.a)
      assert.equals(2, merged.b)
    end)

    it('should merge arrays (target replaces source)', function()
      local source = { items = { 1, 2, 3 } }
      local target = { items = { 4, 5 } }
      local merged = utils.deep_merge(source, target)

      -- Arrays are replaced, not merged element-by-element
      assert.equals(2, #merged.items)
      assert.equals(4, merged.items[1])
      assert.equals(5, merged.items[2])
    end)
  end)

  describe('is_array()', function()
    it('should return true for sequential arrays', function()
      assert.is_true(utils.is_array({ 1, 2, 3 }))
      assert.is_true(utils.is_array({ 'a', 'b', 'c' }))
      assert.is_true(utils.is_array({ true, false, true }))
    end)

    it('should return true for empty array', function()
      assert.is_true(utils.is_array({}))
    end)

    it('should return false for tables with string keys', function()
      assert.is_false(utils.is_array({ a = 1, b = 2 }))
      assert.is_false(utils.is_array({ name = 'test' }))
    end)

    it('should return false for tables with mixed keys', function()
      assert.is_false(utils.is_array({ 1, 2, name = 'test' }))
      assert.is_false(utils.is_array({ [1] = 'a', [3] = 'c' }))  -- Non-sequential
    end)

    it('should return false for tables with gaps', function()
      assert.is_false(utils.is_array({ [1] = 'a', [2] = 'b', [4] = 'd' }))
    end)

    it('should return false for non-sequential numeric keys', function()
      assert.is_false(utils.is_array({ [5] = 'a', [6] = 'b' }))  -- Doesn't start at 1
    end)

    it('should return false for non-tables', function()
      assert.is_false(utils.is_array('string'))
      assert.is_false(utils.is_array(42))
      assert.is_false(utils.is_array(true))
      assert.is_false(utils.is_array(nil))
      assert.is_false(utils.is_array(function() end))
    end)

    it('should handle single element arrays', function()
      assert.is_true(utils.is_array({ 'single' }))
      assert.is_true(utils.is_array({ 1 }))
    end)
  end)

  describe('is_empty()', function()
    it('should return true for empty tables', function()
      assert.is_true(utils.is_empty({}))
    end)

    it('should return false for non-empty tables', function()
      assert.is_false(utils.is_empty({ a = 1 }))
      assert.is_false(utils.is_empty({ 1, 2, 3 }))
    end)

    it('should return true for non-tables', function()
      assert.is_true(utils.is_empty('string'))
      assert.is_true(utils.is_empty(42))
      assert.is_true(utils.is_empty(true))
      assert.is_true(utils.is_empty(nil))
    end)

    it('should handle tables with nil values', function()
      local tbl = { a = nil, b = nil }
      -- In Lua, tables with only nil values are effectively empty
      assert.is_true(utils.is_empty(tbl))
    end)
  end)

  describe('table_keys()', function()
    it('should return empty array for empty table', function()
      local keys = utils.table_keys({})
      assert.is_table(keys)
      assert.equals(0, #keys)
    end)

    it('should return all string keys', function()
      local keys = utils.table_keys({ a = 1, b = 2, c = 3 })
      assert.equals(3, #keys)

      -- Sort for consistent testing
      table.sort(keys)
      assert.equals('a', keys[1])
      assert.equals('b', keys[2])
      assert.equals('c', keys[3])
    end)

    it('should return numeric keys for arrays', function()
      local keys = utils.table_keys({ 'x', 'y', 'z' })
      assert.equals(3, #keys)

      table.sort(keys)
      assert.equals(1, keys[1])
      assert.equals(2, keys[2])
      assert.equals(3, keys[3])
    end)

    it('should return mixed keys', function()
      local keys = utils.table_keys({ 'a', 'b', name = 'test', count = 5 })
      assert.equals(4, #keys)
    end)

    it('should handle nested tables (only top-level keys)', function()
      local keys = utils.table_keys({
        level1 = { level2 = 'value' },
        other = 'value'
      })
      assert.equals(2, #keys)
    end)
  end)

  describe('table_size()', function()
    it('should return 0 for empty table', function()
      assert.equals(0, utils.table_size({}))
    end)

    it('should count string keys', function()
      assert.equals(3, utils.table_size({ a = 1, b = 2, c = 3 }))
    end)

    it('should count array elements', function()
      assert.equals(3, utils.table_size({ 'a', 'b', 'c' }))
    end)

    it('should count mixed keys', function()
      assert.equals(4, utils.table_size({ 'a', 'b', name = 'test', count = 5 }))
    end)

    it('should only count top-level entries', function()
      local tbl = {
        nested = { a = 1, b = 2, c = 3 },
        other = 'value'
      }
      assert.equals(2, utils.table_size(tbl))
    end)

    it('should handle single entry', function()
      assert.equals(1, utils.table_size({ key = 'value' }))
    end)
  end)

  describe('merge_config()', function()
    it('should exist as a function', function()
      assert.is_function(utils.merge_config)
    end)

    it('should return deep copy of defaults when user_config is nil', function()
      local defaults = { a = 1, b = { c = 2 } }
      local result = utils.merge_config(defaults, nil)

      assert.equals(1, result.a)
      assert.equals(2, result.b.c)

      -- Should be a copy, not the same table
      result.a = 999
      assert.equals(1, defaults.a)
    end)

    it('should return deep copy of defaults when user_config is not provided', function()
      local defaults = { a = 1, b = 2 }
      local result = utils.merge_config(defaults)

      assert.equals(1, result.a)
      assert.equals(2, result.b)
    end)

    it('should merge user config with defaults', function()
      local defaults = { a = 1, b = 2, c = 3 }
      local user = { b = 99, d = 4 }
      local result = utils.merge_config(defaults, user)

      assert.equals(1, result.a) -- from defaults
      assert.equals(99, result.b) -- overridden by user
      assert.equals(3, result.c) -- from defaults
      assert.equals(4, result.d) -- from user
    end)

    it('should deep merge nested tables', function()
      local defaults = {
        ui = { theme = 'dark', font = 'mono' },
        lsp = { enabled = true },
      }
      local user = {
        ui = { theme = 'light' },
        extra = 'value',
      }
      local result = utils.merge_config(defaults, user)

      assert.equals('light', result.ui.theme) -- overridden
      assert.equals('mono', result.ui.font) -- from defaults
      assert.is_true(result.lsp.enabled) -- from defaults
      assert.equals('value', result.extra) -- from user
    end)

    it('should not mutate defaults', function()
      local defaults = { a = 1, b = { c = 2 } }
      local user = { a = 999, b = { c = 888, d = 777 } }

      utils.merge_config(defaults, user)

      assert.equals(1, defaults.a)
      assert.equals(2, defaults.b.c)
      assert.is_nil(defaults.b.d)
    end)

    it('should not mutate user config', function()
      local defaults = { a = 1 }
      local user = { b = 2 }

      utils.merge_config(defaults, user)

      assert.is_nil(user.a)
      assert.equals(2, user.b)
    end)

    it('should handle empty defaults', function()
      local defaults = {}
      local user = { a = 1, b = 2 }
      local result = utils.merge_config(defaults, user)

      assert.equals(1, result.a)
      assert.equals(2, result.b)
    end)

    it('should handle empty user config', function()
      local defaults = { a = 1, b = 2 }
      local user = {}
      local result = utils.merge_config(defaults, user)

      assert.equals(1, result.a)
      assert.equals(2, result.b)
    end)

    it('should replace arrays not merge them', function()
      local defaults = { items = { 1, 2, 3 } }
      local user = { items = { 4, 5 } }
      local result = utils.merge_config(defaults, user)

      assert.equals(2, #result.items)
      assert.equals(4, result.items[1])
      assert.equals(5, result.items[2])
    end)
  end)
end)
