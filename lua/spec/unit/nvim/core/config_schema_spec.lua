--[[
Config Schema Unit Tests
=========================

Unit tests for the configuration schema system that validates user configurations,
provides defaults, and merges configurations safely.

Test Categories:
1. Schema definition and registration
2. Type validation (string, number, boolean, table, function, any)
3. Required vs optional fields
4. Default values
5. Nested schema validation
6. Array/list validation
7. Custom validators
8. Config merging (user config + defaults)
9. Error reporting
10. Schema querying

Uses standard luassert syntax with simple patterns.
--]]

local spec_helper = require('spec.spec_helper')

describe('config_schema #unit', function()
  local config_schema

  before_each(function()
    spec_helper.setup()
    -- Clear any previously loaded module
    package.loaded['nvim.core.config_schema'] = nil
    config_schema = require('nvim.core.config_schema')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should create a config schema instance', function()
      assert.is_not_nil(config_schema)
      assert.is_table(config_schema)
    end)

    it('should have a define method for defining schemas', function()
      assert.is_function(config_schema.define)
    end)

    it('should have a validate method for validating configs', function()
      assert.is_function(config_schema.validate)
    end)

    it('should have a merge method for merging configs', function()
      assert.is_function(config_schema.merge)
    end)

    it('should have a get method for retrieving schemas', function()
      assert.is_function(config_schema.get)
    end)

    it('should have an apply_defaults method', function()
      assert.is_function(config_schema.apply_defaults)
    end)
  end)

  describe('define()', function()
    it('should define a simple schema', function()
      local success = config_schema.define('test_schema', {
        name = { type = 'string', required = true },
        age = { type = 'number', required = false },
      })

      assert.is_true(success)

      local schema = config_schema.get('test_schema')
      assert.is_not_nil(schema)
    end)

    it('should fail to define a schema without a name', function()
      local success = config_schema.define(nil, {})
      assert.is_false(success)
    end)

    it('should fail to define a schema with empty name', function()
      local success = config_schema.define('', {})
      assert.is_false(success)
    end)

    it('should fail to define a schema without fields', function()
      local success = config_schema.define('no_fields', nil)
      assert.is_false(success)
    end)

    it('should fail to define a duplicate schema', function()
      config_schema.define('duplicate', { field = { type = 'string' } })
      local success = config_schema.define('duplicate', { field = { type = 'string' } })
      assert.is_false(success)
    end)

    it('should define a schema with default values', function()
      local success = config_schema.define('with_defaults', {
        name = { type = 'string', default = 'unnamed' },
        count = { type = 'number', default = 0 },
      })

      assert.is_true(success)
    end)

    it('should define a schema with nested fields', function()
      local success = config_schema.define('nested', {
        user = {
          type = 'table',
          fields = {
            name = { type = 'string' },
            email = { type = 'string' },
          },
        },
      })

      assert.is_true(success)
    end)

    it('should define a schema with array fields', function()
      local success = config_schema.define('with_array', {
        tags = {
          type = 'array',
          items = { type = 'string' },
        },
      })

      assert.is_true(success)
    end)

    it('should define a schema with custom validator', function()
      local success = config_schema.define('custom_validator', {
        port = {
          type = 'number',
          validator = function(value)
            return value >= 1 and value <= 65535
          end,
        },
      })

      assert.is_true(success)
    end)
  end)

  describe('validate() - basic types', function()
    before_each(function()
      config_schema.define('basic_types', {
        str = { type = 'string' },
        num = { type = 'number' },
        bool = { type = 'boolean' },
        tbl = { type = 'table' },
        fn = { type = 'function' },
        any = { type = 'any' },
      })
    end)

    it('should validate correct string type', function()
      local valid, errors = config_schema.validate('basic_types', {
        str = 'hello',
      })
      assert.is_true(valid)
      assert.is_nil(errors)
    end)

    it('should reject invalid string type', function()
      local valid, errors = config_schema.validate('basic_types', {
        str = 123,
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
      assert.is_not_nil(errors.str)
    end)

    it('should validate correct number type', function()
      local valid = config_schema.validate('basic_types', {
        num = 42,
      })
      assert.is_true(valid)
    end)

    it('should reject invalid number type', function()
      local valid = config_schema.validate('basic_types', {
        num = 'not a number',
      })
      assert.is_false(valid)
    end)

    it('should validate correct boolean type', function()
      local valid = config_schema.validate('basic_types', {
        bool = true,
      })
      assert.is_true(valid)
    end)

    it('should reject invalid boolean type', function()
      local valid = config_schema.validate('basic_types', {
        bool = 1,
      })
      assert.is_false(valid)
    end)

    it('should validate correct table type', function()
      local valid = config_schema.validate('basic_types', {
        tbl = { key = 'value' },
      })
      assert.is_true(valid)
    end)

    it('should reject invalid table type', function()
      local valid = config_schema.validate('basic_types', {
        tbl = 'not a table',
      })
      assert.is_false(valid)
    end)

    it('should validate correct function type', function()
      local valid = config_schema.validate('basic_types', {
        fn = function() end,
      })
      assert.is_true(valid)
    end)

    it('should reject invalid function type', function()
      local valid = config_schema.validate('basic_types', {
        fn = 'not a function',
      })
      assert.is_false(valid)
    end)

    it('should accept any type for "any" field', function()
      assert.is_true(config_schema.validate('basic_types', { any = 'string' }))
      assert.is_true(config_schema.validate('basic_types', { any = 123 }))
      assert.is_true(config_schema.validate('basic_types', { any = true }))
      assert.is_true(config_schema.validate('basic_types', { any = {} }))
      assert.is_true(config_schema.validate('basic_types', { any = function() end }))
    end)
  end)

  describe('validate() - required fields', function()
    before_each(function()
      config_schema.define('required_test', {
        required_field = { type = 'string', required = true },
        optional_field = { type = 'string', required = false },
      })
    end)

    it('should validate when required field is present', function()
      local valid = config_schema.validate('required_test', {
        required_field = 'present',
      })
      assert.is_true(valid)
    end)

    it('should reject when required field is missing', function()
      local valid, errors = config_schema.validate('required_test', {
        optional_field = 'present',
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
      assert.is_not_nil(errors.required_field)
    end)

    it('should validate when optional field is missing', function()
      local valid = config_schema.validate('required_test', {
        required_field = 'present',
      })
      assert.is_true(valid)
    end)

    it('should validate when both fields are present', function()
      local valid = config_schema.validate('required_test', {
        required_field = 'present',
        optional_field = 'also present',
      })
      assert.is_true(valid)
    end)
  end)

  describe('validate() - nested schemas', function()
    before_each(function()
      config_schema.define('nested_test', {
        user = {
          type = 'table',
          required = true,
          fields = {
            name = { type = 'string', required = true },
            age = { type = 'number', required = false },
            address = {
              type = 'table',
              fields = {
                street = { type = 'string' },
                city = { type = 'string' },
              },
            },
          },
        },
      })
    end)

    it('should validate correct nested structure', function()
      local valid = config_schema.validate('nested_test', {
        user = {
          name = 'Alice',
          age = 30,
        },
      })
      assert.is_true(valid)
    end)

    it('should reject invalid nested field type', function()
      local valid, errors = config_schema.validate('nested_test', {
        user = {
          name = 123,  -- Should be string
        },
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
    end)

    it('should reject missing required nested field', function()
      local valid, errors = config_schema.validate('nested_test', {
        user = {
          age = 30,  -- Missing required 'name'
        },
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
    end)

    it('should validate deeply nested structures', function()
      local valid = config_schema.validate('nested_test', {
        user = {
          name = 'Alice',
          address = {
            street = '123 Main St',
            city = 'Springfield',
          },
        },
      })
      assert.is_true(valid)
    end)
  end)

  describe('validate() - arrays', function()
    before_each(function()
      config_schema.define('array_test', {
        tags = {
          type = 'array',
          items = { type = 'string' },
        },
        numbers = {
          type = 'array',
          items = { type = 'number' },
        },
      })
    end)

    it('should validate correct array of strings', function()
      local valid = config_schema.validate('array_test', {
        tags = { 'tag1', 'tag2', 'tag3' },
      })
      assert.is_true(valid)
    end)

    it('should reject array with wrong item type', function()
      local valid = config_schema.validate('array_test', {
        tags = { 'tag1', 123, 'tag3' },  -- 123 is not a string
      })
      assert.is_false(valid)
    end)

    it('should validate empty array', function()
      local valid = config_schema.validate('array_test', {
        tags = {},
      })
      assert.is_true(valid)
    end)

    it('should reject non-array for array field', function()
      local valid = config_schema.validate('array_test', {
        tags = 'not an array',
      })
      assert.is_false(valid)
    end)

    it('should validate array of numbers', function()
      local valid = config_schema.validate('array_test', {
        numbers = { 1, 2, 3, 4, 5 },
      })
      assert.is_true(valid)
    end)
  end)

  describe('validate() - custom validators', function()
    before_each(function()
      config_schema.define('custom_validator_test', {
        port = {
          type = 'number',
          validator = function(value)
            return value >= 1 and value <= 65535, 'Port must be between 1 and 65535'
          end,
        },
        email = {
          type = 'string',
          validator = function(value)
            return value:match('@') ~= nil, 'Email must contain @'
          end,
        },
      })
    end)

    it('should validate when custom validator passes', function()
      local valid = config_schema.validate('custom_validator_test', {
        port = 8080,
      })
      assert.is_true(valid)
    end)

    it('should reject when custom validator fails', function()
      local valid, errors = config_schema.validate('custom_validator_test', {
        port = 99999,  -- Out of range
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
      assert.is_not_nil(errors.port)
    end)

    it('should validate string with custom validator', function()
      local valid = config_schema.validate('custom_validator_test', {
        email = 'user@example.com',
      })
      assert.is_true(valid)
    end)

    it('should reject string failing custom validator', function()
      local valid, errors = config_schema.validate('custom_validator_test', {
        email = 'invalid-email',
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
    end)
  end)

  describe('apply_defaults()', function()
    before_each(function()
      config_schema.define('defaults_test', {
        name = { type = 'string', default = 'unnamed' },
        count = { type = 'number', default = 0 },
        enabled = { type = 'boolean', default = true },
        options = { type = 'table', default = {} },
      })
    end)

    it('should apply default for missing field', function()
      local config = config_schema.apply_defaults('defaults_test', {})
      assert.equals('unnamed', config.name)
      assert.equals(0, config.count)
      assert.equals(true, config.enabled)
    end)

    it('should not override provided values', function()
      local config = config_schema.apply_defaults('defaults_test', {
        name = 'custom',
        count = 10,
      })
      assert.equals('custom', config.name)
      assert.equals(10, config.count)
      assert.equals(true, config.enabled)  -- Still gets default
    end)

    it('should return empty table for non-existent schema', function()
      local config = config_schema.apply_defaults('nonexistent', { key = 'value' })
      assert.is_table(config)
    end)

    it('should handle nested defaults', function()
      config_schema.define('nested_defaults', {
        server = {
          type = 'table',
          default = {},
          fields = {
            host = { type = 'string', default = 'localhost' },
            port = { type = 'number', default = 3000 },
          },
        },
      })

      local config = config_schema.apply_defaults('nested_defaults', {})
      assert.is_table(config.server)
      assert.equals('localhost', config.server.host)
      assert.equals(3000, config.server.port)
    end)
  end)

  describe('merge()', function()
    before_each(function()
      config_schema.define('merge_test', {
        name = { type = 'string', default = 'default_name' },
        count = { type = 'number', default = 10 },
        enabled = { type = 'boolean', default = false },
      })
    end)

    it('should merge user config with defaults', function()
      local merged = config_schema.merge('merge_test', { name = 'custom' })
      assert.equals('custom', merged.name)
      assert.equals(10, merged.count)
      assert.equals(false, merged.enabled)
    end)

    it('should override all defaults when provided', function()
      local merged = config_schema.merge('merge_test', {
        name = 'custom',
        count = 20,
        enabled = true,
      })
      assert.equals('custom', merged.name)
      assert.equals(20, merged.count)
      assert.equals(true, merged.enabled)
    end)

    it('should return only defaults when user config is empty', function()
      local merged = config_schema.merge('merge_test', {})
      assert.equals('default_name', merged.name)
      assert.equals(10, merged.count)
      assert.equals(false, merged.enabled)
    end)

    it('should handle nested merging', function()
      config_schema.define('nested_merge', {
        server = {
          type = 'table',
          default = { host = 'localhost', port = 3000 },
          fields = {
            host = { type = 'string' },
            port = { type = 'number' },
          },
        },
      })

      local merged = config_schema.merge('nested_merge', {
        server = { port = 8080 },
      })
      assert.equals('localhost', merged.server.host)
      assert.equals(8080, merged.server.port)
    end)
  end)

  describe('get()', function()
    it('should return schema for defined schema', function()
      config_schema.define('get_test', {
        field = { type = 'string' },
      })

      local schema = config_schema.get('get_test')
      assert.is_not_nil(schema)
      assert.is_table(schema)
    end)

    it('should return nil for undefined schema', function()
      local schema = config_schema.get('nonexistent')
      assert.is_nil(schema)
    end)

    it('should return a copy to prevent external modifications', function()
      config_schema.define('copy_test', {
        field = { type = 'string' },
      })

      local schema1 = config_schema.get('copy_test')
      local schema2 = config_schema.get('copy_test')

      schema1.modified = true
      assert.is_nil(schema2.modified)
    end)
  end)

  describe('error handling', function()
    it('should fail to validate with non-existent schema', function()
      local valid, errors = config_schema.validate('nonexistent', {})
      assert.is_false(valid)
      assert.is_not_nil(errors)
    end)

    it('should provide detailed error messages', function()
      config_schema.define('error_test', {
        name = { type = 'string', required = true },
      })

      local valid, errors = config_schema.validate('error_test', {
        name = 123,
      })
      assert.is_false(valid)
      assert.is_not_nil(errors)
      assert.is_string(errors.name)
    end)

    it('should handle nil config gracefully', function()
      config_schema.define('nil_test', {
        field = { type = 'string' },
      })

      local valid, errors = config_schema.validate('nil_test', nil)
      assert.is_false(valid)
      assert.is_not_nil(errors)
    end)

    it('should handle invalid schema definition gracefully', function()
      local success = config_schema.define('invalid', {
        field = { type = 'invalid_type' },
      })
      -- Should still succeed but validation might have issues
      assert.is_true(success)
    end)
  end)
end)
