--[[
Neotest Core Configuration
===========================

Configures neotest with language adapters using sensible defaults.

Features:
- Language adapter loading
- Neotest uses its built-in defaults for UI, icons, etc.

Dependencies:
- nvim-neotest/neotest

API:
- setup(config) - Configure neotest
--]]

local M = {}

---Load language adapter
---@param language string Language name
---@return table|nil adapter The neotest adapter or nil if not found
local function load_adapter(language)
	local adapter_module = "modules.test.adapters." .. language
	local ok, adapter = pcall(require, adapter_module)
	if not ok then
		vim.notify(string.format("Failed to load test adapter for %s", language), vim.log.levels.WARN)
		return nil
	end

	-- Get the actual neotest adapter from our wrapper
	local setup_ok = adapter.setup()
	if not setup_ok then
		return nil
	end

	return adapter.get_adapter()
end

---Setup neotest with configuration
---@param config? table Configuration options
---@param config.adapters? table List of language adapters to enable
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Try to load neotest plugin
	local ok, neotest = pcall(require, "neotest")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Load language adapters
	local adapters = {}
	local languages = config.adapters or { "javascript", "python", "ruby", "lua" }

	for _, language in ipairs(languages) do
		local adapter = load_adapter(language)
		if adapter then
			-- Some adapters return multiple adapters (e.g., javascript returns jest + vim-test)
			if type(adapter) == "table" and #adapter > 0 and type(adapter[1]) == "table" then
				-- It's a list of adapters
				for _, a in ipairs(adapter) do
					table.insert(adapters, a)
				end
			else
				-- It's a single adapter
				table.insert(adapters, adapter)
			end
		end
	end

	-- Setup neotest with adapters (use neotest's defaults for everything else)
	local setup_ok, err = pcall(neotest.setup, { adapters = adapters })
	if not setup_ok then
		vim.notify(string.format("Failed to setup neotest: %s", err), vim.log.levels.ERROR)
		return false
	end

	return true
end

return M
