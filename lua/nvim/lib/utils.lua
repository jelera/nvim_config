--[[
Core Utilities
===============

Shared utility functions used across the core framework.

Functions:
- deep_copy: Deep copy tables and values
- deep_merge: Deep merge two tables
- is_array: Check if a table is an array (sequential integer keys)
- is_empty: Check if a table is empty
- table_keys: Get all keys from a table
- table_size: Get the number of entries in a table

Usage:
  local utils = require('nvim.lib.utils')

  local copy = utils.deep_copy(original)
  local merged = utils.deep_merge(defaults, user_config)

  if utils.is_array(value) then
    print('It is an array!')
  end
--]]

local M = {}

--[[
Deep copy a value (including nested tables)

Recursively copies tables to create completely independent copies.
Non-table values (primitives, functions) are returned as-is.

@param orig any: Value to copy
@return any: Deep copy of the value
--]]
function M.deep_copy(orig)
  if type(orig) ~= 'table' then
    return orig
  end

  local copy = {}
  for k, v in pairs(orig) do
    copy[k] = M.deep_copy(v)
  end
  return copy
end

--[[
Deep merge two tables (target takes precedence over source)

Recursively merges nested tables. For conflicting non-table values,
target value overrides source value. Creates a new table without
modifying inputs.

@param source table: Source table (defaults/base)
@param target table: Target table (overrides)
@return table: Merged table (new table, doesn't modify inputs)
--]]
function M.deep_merge(source, target)
  local result = M.deep_copy(source)

  for k, v in pairs(target) do
    if type(v) == 'table' and type(result[k]) == 'table' and not M.is_array(v) and not M.is_array(result[k]) then
      -- Recursively merge nested tables (but not arrays)
      result[k] = M.deep_merge(result[k], v)
    else
      -- Override with target value (for primitives, arrays, and mismatched types)
      result[k] = M.deep_copy(v)
    end
  end

  return result
end

--[[
Check if a value is an array (sequential integer keys starting from 1)

Arrays must have:
- Only numeric keys
- Keys starting at 1
- No gaps in sequence

@param value any: Value to check
@return boolean: true if value is an array
--]]
function M.is_array(value)
  if type(value) ~= 'table' then
    return false
  end

  local count = 0
  for k, _ in pairs(value) do
    count = count + 1
    if type(k) ~= 'number' or k ~= count then
      return false
    end
  end

  return true
end

--[[
Check if a table is empty

Non-table values are considered "empty" and return true.

@param tbl any: Value to check
@return boolean: true if table is empty or value is not a table
--]]
function M.is_empty(tbl)
  if type(tbl) ~= 'table' then
    return true
  end
  return next(tbl) == nil
end

--[[
Get all keys from a table

Returns an array of all keys (both string and numeric).
Order is not guaranteed.

@param tbl table: Table to extract keys from
@return table: Array of keys
--]]
function M.table_keys(tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

--[[
Get the size of a table (number of key-value pairs)

Counts all top-level entries in the table.

@param tbl table: Table to measure
@return number: Number of entries in table
--]]
function M.table_size(tbl)
  local count = 0
  for _, _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

return M
