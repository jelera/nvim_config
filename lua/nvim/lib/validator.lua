--[[
Generic Validator
=================

Generic validation utilities for type checking, schema validation,
and field validation. Reusable across different validation contexts.

Functions:
- validate_type: Validate a value against a type
- validate_field: Validate a value against a field schema

Usage:
  local validator = require('nvim.lib.validator')

  -- Type validation
  local valid, err = validator.validate_type(value, 'string')

  -- Field validation
  local errors = {}
  validator.validate_field(value, field_schema, 'fieldName', errors)
--]]

local M = {}

-- Dependencies
local utils = require("nvim.lib.utils")

--[[
Validate a value against a type

Supported types:
- 'string', 'number', 'boolean', 'table', 'function' - Basic Lua types
- 'any' - Any type (always valid)
- 'array' - Table with sequential numeric keys starting from 1

@param value any: Value to validate
@param expected_type string: Expected type
@return boolean: true if valid
@return string|nil: Error message if invalid, nil otherwise
--]]
function M.validate_type(value, expected_type)
	-- Handle 'any' type (always valid)
	if expected_type == "any" then
		return true, nil
	end

	-- Handle 'array' type
	if expected_type == "array" then
		if utils.is_array(value) then
			return true, nil
		else
			return false, "Expected array, got " .. type(value)
		end
	end

	-- Basic type validation
	if type(value) == expected_type then
		return true, nil
	else
		return false, "Expected " .. expected_type .. ", got " .. type(value)
	end
end

--[[
Validate a value against a field schema

Field schema can include:
- type: Expected type ('string', 'number', 'boolean', 'table', 'function', 'any', 'array')
- required: Whether field is required
- fields: Nested schema (for type = 'table')
- items: Item schema (for type = 'array')
- validator: Custom validation function(value) -> boolean, error_msg

Errors are accumulated in the errors table with field paths as keys.

@param value any: Value to validate
@param field_schema table: Field schema definition
@param field_path string: Path to field (for error messages)
@param errors table: Table to accumulate errors (modified in place)
@return boolean: true if valid
--]]
-- luacheck: ignore 561
function M.validate_field(value, field_schema, field_path, errors)
	local field_type = field_schema.type

	-- Handle 'any' type (always valid)
	if field_type == "any" then
		return true
	end

	-- Handle 'array' type
	if field_type == "array" then
		if not utils.is_array(value) then
			errors[field_path] = "Expected array, got " .. type(value)
			return false
		end

		-- Validate array items if items schema provided
		if field_schema.items then
			local all_valid = true
			for i, item in ipairs(value) do
				local item_path = field_path .. "[" .. i .. "]"
				if not M.validate_field(item, field_schema.items, item_path, errors) then
					all_valid = false
				end
			end
			if not all_valid then
				return false
			end
		end

		return true
	end

	-- Basic type validation
	local type_valid, type_err = M.validate_type(value, field_type)
	if not type_valid then
		errors[field_path] = type_err
		return false
	end

	-- Handle nested table validation
	if field_type == "table" and field_schema.fields then
		local all_valid = true

		for nested_field_name, nested_field_schema in pairs(field_schema.fields) do
			local nested_path = field_path .. "." .. nested_field_name
			local nested_value = value[nested_field_name]

			-- Check if nested field is required
			if nested_field_schema.required and nested_value == nil then
				errors[nested_path] = "Required field is missing"
				all_valid = false
			end

			-- Validate nested field if present
			if nested_value ~= nil then
				if not M.validate_field(nested_value, nested_field_schema, nested_path, errors) then
					all_valid = false
				end
			end
		end

		if not all_valid then
			return false
		end
	end

	-- Custom validator
	if field_schema.validator then
		local valid, err_msg = field_schema.validator(value)
		if not valid then
			errors[field_path] = err_msg or "Custom validation failed"
			return false
		end
	end

	return true
end

return M
