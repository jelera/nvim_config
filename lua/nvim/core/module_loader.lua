--[[
Module Loader
=============

Provides dynamic module loading with caching, dependency tracking, and error handling.

Features:
- Module loading with automatic caching
- Module reloading (clears cache)
- Track loaded modules
- Optional setup() function calling
- Detailed error messages

Usage:
  local module_loader = require('nvim.core.module_loader')

  -- Load a module
  local my_module = module_loader.load('nvim.lsp.servers')

  -- Reload a module
  module_loader.reload('nvim.lsp.servers')

  -- Check if module is loaded
  if module_loader.is_loaded('nvim.lsp.servers') then
    -- ...
  end

  -- Get all loaded modules
  local modules = module_loader.get_loaded_modules()
--]]

local M = {}

-- Track modules loaded through this loader
M._loaded_modules = {}

--[[
Load a module with optional configuration

@param name string: Module name (e.g., 'nvim.core.options')
@param opts table|nil: Optional configuration
  - force boolean: Force reload even if cached
  - silent boolean: Suppress notifications
  - call_setup boolean: Call module.setup() if available
@return any: The loaded module
@raises error: If module cannot be loaded
--]]
function M.load(name, opts) -- luacheck: ignore 561
	opts = opts or {}

	-- Validate module name
	if not name or type(name) ~= "string" or name == "" then
		error("Module name must be a non-empty string", 2)
	end

	-- Force reload if requested
	if opts.force then
		package.loaded[name] = nil
	end

	-- Attempt to load the module
	local success, result = pcall(require, name)

	if not success then
		local err_msg = string.format('Failed to load module "%s": %s', name, result)
		error(err_msg, 2)
	end

	-- Track the loaded module
	if not vim.tbl_contains(M._loaded_modules, name) then
		table.insert(M._loaded_modules, name)
	end

	-- Call setup if requested and available
	if opts.call_setup and type(result) == "table" and type(result.setup) == "function" then
		result.setup()
	end

	-- Notify about successful load (debug level)
	if not opts.silent then
		vim.notify(string.format("Module loaded: %s", name), vim.log.levels.DEBUG)
	end

	return result
end

--[[
Reload a module by clearing its cache and loading it again

@param name string: Module name to reload
@param opts table|nil: Optional configuration (same as load)
@return any: The reloaded module
@raises error: If module cannot be reloaded
--]]
function M.reload(name, opts)
	opts = opts or {}

	-- Validate module name
	if not name or type(name) ~= "string" or name == "" then
		error("Module name must be a non-empty string", 2)
	end

	-- Clear from package cache
	package.loaded[name] = nil

	-- Notify about reload
	if not opts.silent then
		vim.notify(string.format("Reloading module: %s", name), vim.log.levels.DEBUG)
	end

	-- Load the module again
	return M.load(name, opts)
end

--[[
Check if a module has been loaded

@param name string: Module name to check
@return boolean: True if module is loaded, false otherwise
--]]
function M.is_loaded(name)
	-- Handle invalid input
	if not name or type(name) ~= "string" or name == "" then
		return false
	end

	-- Check if in Lua's package.loaded cache
	return package.loaded[name] ~= nil
end

--[[
Get list of loaded modules

@param opts table|nil: Optional configuration
  - pattern string: Lua pattern to filter module names
@return table: List of loaded module names
--]]
function M.get_loaded_modules(opts)
	opts = opts or {}

	local modules = {}

	-- If pattern is provided, filter by it
	if opts.pattern then
		for name, _ in pairs(package.loaded) do
			if type(name) == "string" and name:match(opts.pattern) then
				table.insert(modules, name)
			end
		end
	else
		-- Return a copy of our tracked modules
		for _, name in ipairs(M._loaded_modules) do
			table.insert(modules, name)
		end
	end

	return modules
end

return M
