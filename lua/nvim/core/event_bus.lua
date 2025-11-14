--[[
Event Bus
==========

Provides pub/sub messaging system for inter-module communication.

Features:
- Event subscription with callbacks
- Event emission with data payload
- Priority-based callback execution
- One-time subscriptions (once option)
- Subscription management (unsubscribe, clear)
- Error handling (callbacks errors don't stop other callbacks)

Usage:
  local event_bus = require('nvim.core.event_bus')

  -- Subscribe to an event
  local subscription_id = event_bus.on('user_login', function(data)
    print('User logged in:', data.username)
  end)

  -- Emit an event
  event_bus.emit('user_login', { username = 'alice' })

  -- Unsubscribe
  event_bus.off(subscription_id)

  -- One-time subscription
  event_bus.on('init', callback, { once = true })

  -- Priority-based execution (higher priority runs first)
  event_bus.on('startup', callback, { priority = 10 })
--]]

local M = {}

-- Internal state
M._subscriptions = {} -- { event_name = { [id] = subscription } }
M._next_id = 1 -- Auto-incrementing subscription ID

--[[
Subscribe to an event

@param event_name string: Event name to subscribe to
@param callback function: Function to call when event is emitted
@param opts table|nil: Optional configuration
  - once boolean: Only call callback once, then auto-unsubscribe
  - priority number: Higher priority callbacks run first (default: 0)
@return number: Subscription ID (use with off() to unsubscribe)
@raises error: If event_name is not a string or callback is not a function
--]]
function M.on(event_name, callback, opts)
	opts = opts or {}

	-- Validate parameters
	if not event_name or type(event_name) ~= "string" or event_name == "" then
		error("Event name must be a non-empty string", 2)
	end

	if not callback or type(callback) ~= "function" then
		error("Callback must be a function", 2)
	end

	-- Initialize subscriptions for this event if needed
	if not M._subscriptions[event_name] then
		M._subscriptions[event_name] = {}
	end

	-- Create subscription
	local subscription_id = M._next_id
	M._next_id = M._next_id + 1

	local subscription = {
		id = subscription_id,
		callback = callback,
		once = opts.once or false,
		priority = opts.priority or 0,
	}

	M._subscriptions[event_name][subscription_id] = subscription

	return subscription_id
end

--[[
Emit an event, calling all subscribed callbacks

Callbacks are executed in priority order (highest first).
If a callback throws an error, it is caught and logged, and
execution continues with remaining callbacks.

@param event_name string: Event name to emit
@param data any: Data to pass to callbacks (optional)
--]]
function M.emit(event_name, data)
	-- Get subscriptions for this event
	local subscriptions = M._subscriptions[event_name]
	if not subscriptions then
		return -- No subscribers, nothing to do
	end

	-- Convert to array and sort by priority (highest first)
	local callbacks = {}
	for _, subscription in pairs(subscriptions) do
		table.insert(callbacks, subscription)
	end

	table.sort(callbacks, function(a, b)
		return a.priority > b.priority
	end)

	-- Execute callbacks in priority order
	local to_remove = {}
	for _, subscription in ipairs(callbacks) do
		-- Execute callback with error handling
		local success, err = pcall(subscription.callback, data)

		if not success then
			-- Log error but continue with other callbacks
			vim.notify(string.format('Error in event callback for "%s": %s', event_name, err), vim.log.levels.ERROR)
		end

		-- Mark for removal if it's a one-time subscription
		if subscription.once then
			table.insert(to_remove, subscription.id)
		end
	end

	-- Remove one-time subscriptions
	for _, id in ipairs(to_remove) do
		M._subscriptions[event_name][id] = nil
	end
end

--[[
Unsubscribe from an event

Can be called with either:
- subscription_id (number): Unsubscribe specific callback
- event_name (string): Unsubscribe all callbacks for event

@param identifier number|string: Subscription ID or event name
--]]
function M.off(identifier)
	if type(identifier) == "number" then
		-- Unsubscribe by ID
		for _event_name, subscriptions in pairs(M._subscriptions) do
			if subscriptions[identifier] then
				subscriptions[identifier] = nil
				return
			end
		end
	elseif type(identifier) == "string" then
		-- Unsubscribe all for event
		M._subscriptions[identifier] = nil
	end
end

--[[
Clear subscriptions

Can be called with either:
- No arguments: Clear all subscriptions
- event_name (string): Clear subscriptions for specific event

@param event_name string|nil: Optional event name to clear
--]]
function M.clear(event_name)
	if event_name then
		-- Clear specific event
		M._subscriptions[event_name] = nil
	else
		-- Clear all events
		M._subscriptions = {}
	end
end

--[[
Get subscribers for introspection

@param event_name string|nil: Event name to get subscribers for
@return table: List of subscribers or all subscriptions
  - If event_name provided: returns array of subscriptions
  - If no event_name: returns table of { event_name = subscriptions }
--]]
function M.get_subscribers(event_name)
	if event_name then
		-- Return list of subscriptions for specific event
		local subscriptions = M._subscriptions[event_name] or {}
		local result = {}
		for _, subscription in pairs(subscriptions) do
			table.insert(result, subscription)
		end
		return result
	else
		-- Return all subscriptions grouped by event
		return M._subscriptions
	end
end

return M
