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
- merge_config: Merge user configuration with defaults
- is_git_conflict_state: Check if git is in rebase/merge/cherry-pick state
- should_attach_lsp: Check if LSP should attach to a buffer

Usage:
  local utils = require('nvim.lib.utils')

  local copy = utils.deep_copy(original)
  local merged = utils.deep_merge(defaults, user_config)

  if utils.is_array(value) then
    print('It is an array!')
  end

  if utils.is_git_conflict_state() then
    print('Git conflict in progress!')
  end

  if utils.should_attach_lsp(bufnr) then
    -- Attach LSP to this buffer
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
	if type(orig) ~= "table" then
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
		local is_table_merge = type(v) == "table"
			and type(result[k]) == "table"
			and not M.is_array(v)
			and not M.is_array(result[k])
		if is_table_merge then
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
	if type(value) ~= "table" then
		return false
	end

	local count = 0
	for k, _ in pairs(value) do
		count = count + 1
		if type(k) ~= "number" or k ~= count then
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
	if type(tbl) ~= "table" then
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

--[[
Merge user configuration with defaults

Helper function to merge user-provided configuration with default values.
Creates a deep copy of defaults and merges user config on top, ensuring
neither input table is mutated.

This is a common pattern across modules for configuration management.

@param defaults table: Default configuration
@param user_config table|nil: User-provided configuration (optional)
@return table: Merged configuration (new table)
--]]
function M.merge_config(defaults, user_config)
	if not user_config then
		return M.deep_copy(defaults)
	end

	local merged = M.deep_copy(defaults)
	return M.deep_merge(merged, user_config)
end

--[[
Check if git is currently in a rebase or merge state

Detects whether the current working directory is in the middle of:
- git rebase (interactive or non-interactive)
- git merge
- git cherry-pick

This is useful for disabling LSP servers that might fail when
parsing files with conflict markers.

@return boolean: true if in rebase/merge/cherry-pick state
--]]
function M.is_git_conflict_state()
	-- Check if vim.fn API is available (for test compatibility)
	if not vim.fn or not vim.fn.isdirectory or not vim.fn.filereadable then
		return false
	end

	-- Check for rebase in progress
	-- luacheck: ignore
	if vim.fn.isdirectory(".git/rebase-merge") == 1 or vim.fn.isdirectory(".git/rebase-apply") == 1 then
		return true
	end

	-- Check for merge in progress
	if vim.fn.filereadable(".git/MERGE_HEAD") == 1 then
		return true
	end

	-- Check for cherry-pick in progress
	if vim.fn.filereadable(".git/CHERRY_PICK_HEAD") == 1 then
		return true
	end

	return false
end

--[[
Check if a buffer should have LSP attached

LSP should only attach to normal file buffers, not:
- Special buffer types (terminal, quickfix, help, etc.)
- Git-related buffers (commit messages, rebase, fugitive)
- Plugin UI buffers (telescope, nvim-tree, lazy, mason, etc.)
- Test output buffers (neotest)

@param bufnr number: Buffer number to check
@return boolean: true if LSP should attach, false otherwise
--]]
function M.should_attach_lsp(bufnr)
	-- Get buffer properties
	local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
	local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	-- Skip non-file buffers (terminal, quickfix, help, etc.)
	-- Empty buftype = normal file buffer
	if buftype ~= "" then
		return false
	end

	-- Skip git-related filetypes
	local git_filetypes = {
		"gitcommit",
		"gitrebase",
		"gitconfig",
		"git", -- fugitive buffers
		"fugitive",
		"fugitiveblame",
	}
	for _, ft in ipairs(git_filetypes) do
		if filetype == ft then
			return false
		end
	end

	-- Skip test output and plugin UI filetypes
	local special_filetypes = {
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"TelescopePrompt",
		"TelescopeResults",
		"NvimTree",
		"neo-tree",
		"lazy",
		"mason",
		"lspinfo",
		"null-ls-info",
		"help",
		"man",
		"qf", -- quickfix
	}
	for _, ft in ipairs(special_filetypes) do
		if filetype == ft then
			return false
		end
	end

	-- Skip buffers with special name patterns
	-- These catch plugin buffers that might not have special filetypes
	local skip_patterns = {
		"^fugitive://", -- Fugitive buffers
		"^term://", -- Terminal buffers
		"^%[.*%]$", -- Buffers with names like [No Name], [Command Line]
		"%.git/", -- Files inside .git directory
	}
	for _, pattern in ipairs(skip_patterns) do
		if bufname:match(pattern) then
			return false
		end
	end

	return true
end

return M
