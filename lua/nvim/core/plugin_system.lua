--[[
Plugin System
=============

Manages plugin registration, loading, configuration, and lifecycle.

Features:
- Plugin registration with metadata
- Dependency resolution (including nested dependencies)
- Lazy loading support (event, cmd, ft-based)
- Lifecycle events (before_load, loaded, configured, error)
- Plugin querying and listing
- Error handling and circular dependency detection

Usage:
  local plugin_system = require('nvim.core.plugin_system')

  -- Register a plugin
  plugin_system.register('telescope', {
    description = 'Fuzzy finder',
    dependencies = { 'plenary' },
    config = function()
      require('telescope').setup({})
    end,
    lazy = true,
    event = 'VeryLazy'
  })

  -- Load a plugin (loads dependencies first)
  plugin_system.load('telescope')

  -- Query plugin info
  local plugin = plugin_system.get('telescope')

  -- List all plugins
  local all_plugins = plugin_system.list()
  local loaded_only = plugin_system.list({ loaded = true })
--]]

local M = {}

-- Dependencies
local event_bus = require('nvim.core.event_bus')
local utils = require('nvim.lib.utils')

-- Internal state
M._plugins = {}  -- { plugin_name = plugin_spec }

--[[
Validate plugin configuration

@param name string: Plugin name
@param config table|nil: Plugin configuration
@return boolean: true if valid, false otherwise
--]]
local function validate_plugin_config(name, config)
  -- Name validation
  if not name or type(name) ~= 'string' or name == '' then
    return false
  end

  -- Config validation
  if config == nil then
    return false
  end

  if type(config) ~= 'table' then
    return false
  end

  -- Dependencies validation
  if config.dependencies ~= nil then
    if type(config.dependencies) ~= 'table' then
      return false
    end
  end

  return true
end

--[[
Detect circular dependencies in plugin dependency graph

@param plugin_name string: Name of the plugin to check
@param visited table: Table tracking visited plugins
@param stack table: Current dependency chain
@return boolean: true if circular dependency detected
--]]
local function has_circular_dependency(plugin_name, visited, stack)
  if stack[plugin_name] then
    return true  -- Found cycle
  end

  if visited[plugin_name] then
    return false  -- Already checked this branch
  end

  local plugin = M._plugins[plugin_name]
  if not plugin or not plugin.dependencies then
    return false
  end

  -- Mark as visiting
  stack[plugin_name] = true

  -- Check all dependencies
  for _, dep in ipairs(plugin.dependencies) do
    if has_circular_dependency(dep, visited, stack) then
      return true
    end
  end

  -- Mark as visited, remove from stack
  visited[plugin_name] = true
  stack[plugin_name] = nil

  return false
end

--[[
Load plugin dependencies recursively

@param plugin_name string: Name of the plugin whose dependencies to load
@return boolean: true if all dependencies loaded successfully
--]]
local function load_dependencies(plugin_name)
  local plugin = M._plugins[plugin_name]

  if not plugin or not plugin.dependencies then
    return true
  end

  for _, dep_name in ipairs(plugin.dependencies) do
    -- Check if dependency exists
    if not M._plugins[dep_name] then
      return false
    end

    -- Load dependency (will recursively load its dependencies)
    local success = M.load(dep_name)
    if not success then
      return false
    end
  end

  return true
end

--[[
Register a plugin

@param name string: Plugin name (must be unique)
@param config table: Plugin configuration
  - description string: Plugin description
  - author string: Plugin author
  - version string: Plugin version
  - url string: Plugin URL
  - dependencies table: List of plugin dependencies
  - config function: Configuration function to run on load
  - lazy boolean: Whether plugin should be lazy-loaded
  - event string: Event to trigger lazy load
  - cmd string: Command to trigger lazy load
  - ft table: File types to trigger lazy load
@return boolean: true if registration successful, false otherwise
--]]
function M.register(name, config)
  -- Validate inputs
  if not validate_plugin_config(name, config) then
    return false
  end

  -- Check for duplicates
  if M._plugins[name] then
    return false
  end

  -- Create plugin spec
  local plugin = {
    name = name,
    description = config.description,
    author = config.author,
    version = config.version,
    url = config.url,
    dependencies = config.dependencies or {},
    config = config.config,
    lazy = config.lazy or false,
    event = config.event,
    cmd = config.cmd,
    ft = config.ft,
    loaded = false,
  }

  M._plugins[name] = plugin
  return true
end

--[[
Load a plugin (and its dependencies)

@param name string: Plugin name
@return boolean: true if load successful, false otherwise
--]]
function M.load(name)
  local plugin = M._plugins[name]

  -- Check if plugin exists
  if not plugin then
    return false
  end

  -- Don't reload already loaded plugins
  if plugin.loaded then
    return true
  end

  -- Check for circular dependencies
  if has_circular_dependency(name, {}, {}) then
    return false
  end

  -- Load dependencies first
  local deps_loaded = load_dependencies(name)
  if not deps_loaded then
    return false
  end

  -- Emit before_load event
  event_bus.emit('plugin:before_load', { name = name })

  -- Emit loaded event
  event_bus.emit('plugin:loaded', { name = name })

  -- Run config function if provided
  if plugin.config then
    -- Validate config is a function
    if type(plugin.config) ~= 'function' then
      return false
    end

    -- Call config with error handling
    local success, err = pcall(plugin.config)
    if not success then
      -- Emit error event
      event_bus.emit('plugin:error', {
        name = name,
        error = err,
      })
      return false
    end

    -- Emit configured event
    event_bus.emit('plugin:configured', { name = name })
  end

  -- Mark as loaded
  plugin.loaded = true

  return true
end

--[[
Get plugin information

@param name string: Plugin name
@return table|nil: Plugin spec (deep copy) or nil if not found
--]]
function M.get(name)
  local plugin = M._plugins[name]
  if not plugin then
    return nil
  end

  -- Return a deep copy to prevent external modifications
  return utils.deep_copy(plugin)
end

--[[
List all plugins

@param filter table|nil: Optional filter criteria
  - loaded boolean: Filter by loaded status
  - lazy boolean: Filter by lazy status
@return table: Array of plugin specs (deep copies)
--]]
function M.list(filter)
  filter = filter or {}
  local result = {}

  for _, plugin in pairs(M._plugins) do
    local include = true

    -- Apply filters
    if filter.loaded ~= nil then
      if plugin.loaded ~= filter.loaded then
        include = false
      end
    end

    if filter.lazy ~= nil then
      if plugin.lazy ~= filter.lazy then
        include = false
      end
    end

    if include then
      table.insert(result, utils.deep_copy(plugin))
    end
  end

  return result
end

--[[
Unregister a plugin

@param name string: Plugin name
@return boolean: true if unregistration successful, false otherwise
--]]
function M.unregister(name)
  local plugin = M._plugins[name]

  -- Check if plugin exists
  if not plugin then
    return false
  end

  -- Don't allow unregistering loaded plugins
  if plugin.loaded then
    return false
  end

  M._plugins[name] = nil
  return true
end

return M
