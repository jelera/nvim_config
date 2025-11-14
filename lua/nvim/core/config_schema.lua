--[[
Config Schema
=============

Provides configuration validation, type checking, defaults, and merging.

Features:
- Schema definition with type constraints
- Type validation (string, number, boolean, table, function, any, array)
- Required vs optional fields
- Default values (including nested)
- Nested schema validation
- Array/list validation with item types
- Custom validators with error messages
- Configuration merging (user config + defaults)
- Detailed error reporting

Usage:
  local config_schema = require('nvim.core.config_schema')

  -- Define a schema
  config_schema.define('lsp', {
    enabled = { type = 'boolean', default = true },
    servers = {
      type = 'array',
      items = { type = 'string' },
      default = { 'lua_ls', 'tsserver' },
    },
    timeout = {
      type = 'number',
      default = 5000,
      validator = function(value)
        return value > 0, 'Timeout must be positive'
      end,
    },
  })

  -- Validate configuration
  local valid, errors = config_schema.validate('lsp', {
    enabled = true,
    servers = { 'lua_ls' },
    timeout = 10000,
  })

  -- Merge with defaults
  local config = config_schema.merge('lsp', { enabled = false })
  -- Returns: { enabled = false, servers = { 'lua_ls', 'tsserver' }, timeout = 5000 }
--]]

local M = {}

-- Dependencies
local utils = require("nvim.lib.utils")
local validator = require("nvim.lib.validator")

-- Internal state
M._schemas = {} -- { schema_name = schema_definition }

--[[
Apply default values to a configuration recursively

@param schema_def table: Schema definition
@param config table: User configuration
@return table: Configuration with defaults applied
--]]
local function apply_defaults_recursive(schema_def, config)
	local result = utils.deep_copy(config)

	for field_name, field_schema in pairs(schema_def) do
		if result[field_name] == nil and field_schema.default ~= nil then
			result[field_name] = utils.deep_copy(field_schema.default)
		end

		-- Apply defaults to nested fields
		if field_schema.type == "table" and field_schema.fields and result[field_name] then
			result[field_name] = apply_defaults_recursive(field_schema.fields, result[field_name])
		end
	end

	return result
end

--[[
Define a configuration schema

@param name string: Schema name (must be unique)
@param schema_def table: Schema definition
  Each field can have:
    - type string: Field type ('string', 'number', 'boolean', 'table', 'function', 'any', 'array')
    - required boolean: Whether field is required
    - default any: Default value
    - fields table: Nested schema (for type = 'table')
    - items table: Item schema (for type = 'array')
    - validator function: Custom validation function(value) -> boolean, error_msg
@return boolean: true if definition successful, false otherwise
--]]
function M.define(name, schema_def)
	-- Validate inputs
	if not name or type(name) ~= "string" or name == "" then
		return false
	end

	if not schema_def or type(schema_def) ~= "table" then
		return false
	end

	-- Check for duplicates
	if M._schemas[name] then
		return false
	end

	M._schemas[name] = utils.deep_copy(schema_def)
	return true
end

--[[
Validate a configuration against a schema

@param schema_name string: Name of the schema to validate against
@param config table: Configuration to validate
@return boolean: true if valid, false otherwise
@return table|nil: Table of errors (field_path -> error_message) if invalid
--]]
function M.validate(schema_name, config)
	local schema_def = M._schemas[schema_name]

	-- Check if schema exists
	if not schema_def then
		return false, { _schema = "Schema not found: " .. tostring(schema_name) }
	end

	-- Check if config is a table
	if not config or type(config) ~= "table" then
		return false, { _config = "Config must be a table" }
	end

	local errors = {}

	-- Validate each field in schema
	for field_name, field_schema in pairs(schema_def) do
		local value = config[field_name]

		-- Check if required field is present
		if field_schema.required and value == nil then
			errors[field_name] = "Required field is missing"
		end

		-- Validate field if present
		if value ~= nil then
			validator.validate_field(value, field_schema, field_name, errors)
		end
	end

	-- Return validation result
	if utils.is_empty(errors) then
		return true, nil
	else
		return false, errors
	end
end

--[[
Apply default values to a configuration

@param schema_name string: Name of the schema
@param config table: User configuration
@return table: Configuration with defaults applied
--]]
function M.apply_defaults(schema_name, config)
	local schema_def = M._schemas[schema_name]

	if not schema_def then
		return utils.deep_copy(config) or {}
	end

	config = config or {}
	return apply_defaults_recursive(schema_def, config)
end

--[[
Merge user configuration with schema defaults

@param schema_name string: Name of the schema
@param user_config table: User configuration
@return table: Merged configuration (user config overrides defaults)
--]]
function M.merge(schema_name, user_config)
	local schema_def = M._schemas[schema_name]

	if not schema_def then
		return utils.deep_copy(user_config) or {}
	end

	-- First, create a config with all defaults
	local defaults = {}
	for field_name, field_schema in pairs(schema_def) do
		if field_schema.default ~= nil then
			defaults[field_name] = utils.deep_copy(field_schema.default)
		end
	end

	-- Then merge user config on top
	user_config = user_config or {}
	return utils.deep_merge(defaults, user_config)
end

--[[
Get a schema definition

@param name string: Schema name
@return table|nil: Schema definition (deep copy) or nil if not found
--]]
function M.get(name)
	local schema_def = M._schemas[name]
	if not schema_def then
		return nil
	end
	return utils.deep_copy(schema_def)
end

return M
