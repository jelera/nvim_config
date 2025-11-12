--[[
Validator Unit Tests
====================

Unit tests for generic validation utilities used for type checking,
schema validation, and field validation.

Test Categories:
1. Type validation (string, number, boolean, table, function, any, array)
2. Field validation against field schema
3. Required field validation
4. Custom validators
5. Error message generation
6. Nested validation

Uses standard luassert syntax.
--]]

local spec_helper = require('spec.spec_helper')

describe('lib.validator #unit', function()
  local validator
  local utils

  before_each(function()
    spec_helper.setup()
    package.loaded['nvim.lib.validator'] = nil
    package.loaded['nvim.lib.utils'] = nil
    validator = require('nvim.lib.validator')
    utils = require('nvim.lib.utils')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should load validator module', function()
      assert.is_not_nil(validator)
      assert.is_table(validator)
    end)

    it('should have validate_type function', function()
      assert.is_function(validator.validate_type)
    end)

    it('should have validate_field function', function()
      assert.is_function(validator.validate_field)
    end)
  end)

  describe('validate_type()', function()
    it('should validate string type', function()
      assert.is_true(validator.validate_type('hello', 'string'))
      assert.is_false(validator.validate_type(123, 'string'))
    end)

    it('should validate number type', function()
      assert.is_true(validator.validate_type(42, 'number'))
      assert.is_true(validator.validate_type(3.14, 'number'))
      assert.is_false(validator.validate_type('42', 'number'))
    end)

    it('should validate boolean type', function()
      assert.is_true(validator.validate_type(true, 'boolean'))
      assert.is_true(validator.validate_type(false, 'boolean'))
      assert.is_false(validator.validate_type(1, 'boolean'))
      assert.is_false(validator.validate_type('true', 'boolean'))
    end)

    it('should validate table type', function()
      assert.is_true(validator.validate_type({}, 'table'))
      assert.is_true(validator.validate_type({ a = 1 }, 'table'))
      assert.is_false(validator.validate_type('table', 'table'))
    end)

    it('should validate function type', function()
      assert.is_true(validator.validate_type(function() end, 'function'))
      assert.is_false(validator.validate_type('function', 'function'))
    end)

    it('should validate any type (always true)', function()
      assert.is_true(validator.validate_type('string', 'any'))
      assert.is_true(validator.validate_type(123, 'any'))
      assert.is_true(validator.validate_type(true, 'any'))
      assert.is_true(validator.validate_type({}, 'any'))
      assert.is_true(validator.validate_type(function() end, 'any'))
      assert.is_true(validator.validate_type(nil, 'any'))
    end)

    it('should validate array type', function()
      assert.is_true(validator.validate_type({ 1, 2, 3 }, 'array'))
      assert.is_true(validator.validate_type({}, 'array'))
      assert.is_false(validator.validate_type({ a = 1 }, 'array'))
      assert.is_false(validator.validate_type('array', 'array'))
    end)

    it('should handle nil values', function()
      assert.is_false(validator.validate_type(nil, 'string'))
      assert.is_false(validator.validate_type(nil, 'number'))
      assert.is_false(validator.validate_type(nil, 'table'))
      assert.is_true(validator.validate_type(nil, 'any'))
    end)

    it('should return error message for invalid types', function()
      local valid, err = validator.validate_type(123, 'string')
      assert.is_false(valid)
      assert.is_string(err)
      assert.is_not_nil(err:match('string'))
      assert.is_not_nil(err:match('number'))
    end)

    it('should return nil error for valid types', function()
      local valid, err = validator.validate_type('hello', 'string')
      assert.is_true(valid)
      assert.is_nil(err)
    end)
  end)

  describe('validate_field()', function()
    it('should validate basic string field', function()
      local field_schema = { type = 'string' }
      local errors = {}

      assert.is_true(validator.validate_field('hello', field_schema, 'fieldName', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail on invalid string field', function()
      local field_schema = { type = 'string' }
      local errors = {}

      assert.is_false(validator.validate_field(123, field_schema, 'fieldName', errors))
      assert.is_not_nil(errors.fieldName)
    end)

    it('should validate basic number field', function()
      local field_schema = { type = 'number' }
      local errors = {}

      assert.is_true(validator.validate_field(42, field_schema, 'count', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should validate basic boolean field', function()
      local field_schema = { type = 'boolean' }
      local errors = {}

      assert.is_true(validator.validate_field(true, field_schema, 'enabled', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should validate any type field', function()
      local field_schema = { type = 'any' }
      local errors = {}

      assert.is_true(validator.validate_field('string', field_schema, 'value', errors))
      assert.is_true(validator.validate_field(123, field_schema, 'value', errors))
      assert.is_true(validator.validate_field(true, field_schema, 'value', errors))
    end)

    it('should validate array field', function()
      local field_schema = { type = 'array' }
      local errors = {}

      assert.is_true(validator.validate_field({ 1, 2, 3 }, field_schema, 'items', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail on invalid array field', function()
      local field_schema = { type = 'array' }
      local errors = {}

      assert.is_false(validator.validate_field({ a = 1 }, field_schema, 'items', errors))
      assert.is_not_nil(errors.items)
    end)

    it('should validate array items', function()
      local field_schema = {
        type = 'array',
        items = { type = 'string' }
      }
      local errors = {}

      assert.is_true(validator.validate_field({ 'a', 'b', 'c' }, field_schema, 'tags', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail on invalid array items', function()
      local field_schema = {
        type = 'array',
        items = { type = 'string' }
      }
      local errors = {}

      assert.is_false(validator.validate_field({ 'a', 123, 'c' }, field_schema, 'tags', errors))
      assert.is_not_nil(errors['tags[2]'])
    end)

    it('should validate nested table fields', function()
      local field_schema = {
        type = 'table',
        fields = {
          name = { type = 'string' },
          age = { type = 'number' }
        }
      }
      local errors = {}
      local value = { name = 'Alice', age = 30 }

      assert.is_true(validator.validate_field(value, field_schema, 'user', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail on invalid nested field type', function()
      local field_schema = {
        type = 'table',
        fields = {
          name = { type = 'string' },
          age = { type = 'number' }
        }
      }
      local errors = {}
      local value = { name = 123, age = 30 }

      assert.is_false(validator.validate_field(value, field_schema, 'user', errors))
      assert.is_not_nil(errors['user.name'])
    end)

    it('should validate required nested fields', function()
      local field_schema = {
        type = 'table',
        fields = {
          name = { type = 'string', required = true },
          age = { type = 'number', required = false }
        }
      }
      local errors = {}
      local value = { name = 'Alice' }

      assert.is_true(validator.validate_field(value, field_schema, 'user', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail on missing required nested field', function()
      local field_schema = {
        type = 'table',
        fields = {
          name = { type = 'string', required = true },
          age = { type = 'number' }
        }
      }
      local errors = {}
      local value = { age = 30 }

      assert.is_false(validator.validate_field(value, field_schema, 'user', errors))
      assert.is_not_nil(errors['user.name'])
    end)

    it('should run custom validator', function()
      local field_schema = {
        type = 'number',
        validator = function(value)
          return value > 0, 'Must be positive'
        end
      }
      local errors = {}

      assert.is_true(validator.validate_field(10, field_schema, 'count', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should fail custom validator', function()
      local field_schema = {
        type = 'number',
        validator = function(value)
          return value > 0, 'Must be positive'
        end
      }
      local errors = {}

      assert.is_false(validator.validate_field(-5, field_schema, 'count', errors))
      assert.is_not_nil(errors.count)
      assert.is_not_nil(errors.count:match('positive'))
    end)

    it('should run custom validator with generic error message', function()
      local field_schema = {
        type = 'string',
        validator = function(value)
          return value:match('@') ~= nil
        end
      }
      local errors = {}

      assert.is_false(validator.validate_field('invalid', field_schema, 'email', errors))
      assert.is_not_nil(errors.email)
    end)

    it('should validate deeply nested structures', function()
      local field_schema = {
        type = 'table',
        fields = {
          user = {
            type = 'table',
            fields = {
              address = {
                type = 'table',
                fields = {
                  city = { type = 'string' }
                }
              }
            }
          }
        }
      }
      local errors = {}
      local value = {
        user = {
          address = {
            city = 'Springfield'
          }
        }
      }

      assert.is_true(validator.validate_field(value, field_schema, 'data', errors))
      assert.is_true(utils.is_empty(errors))
    end)

    it('should accumulate multiple errors', function()
      local field_schema = {
        type = 'table',
        fields = {
          name = { type = 'string' },
          age = { type = 'number' }
        }
      }
      local errors = {}
      local value = { name = 123, age = 'thirty' }

      assert.is_false(validator.validate_field(value, field_schema, 'user', errors))
      assert.is_not_nil(errors['user.name'])
      assert.is_not_nil(errors['user.age'])
    end)
  end)
end)
