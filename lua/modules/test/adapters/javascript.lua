--[[
JavaScript/TypeScript Test Adapter
===================================

Wraps test adapters for JavaScript and TypeScript testing.

Supports:
- Jest (via neotest-jest) - Native neotest adapter
- Karma (via neotest-vim-test) - Bridges to vim-test's karma runner

Dependencies:
- nvim-neotest/neotest-jest
- nvim-neotest/neotest-vim-test
- vim-test/vim-test (for karma support)

API:
- setup(config) - Configure adapters
- get_adapter() - Get neotest adapter instances
--]]

local M = {}

local adapters = {}

---Setup JavaScript test adapters
---@param config? table Configuration options (unused, uses defaults)
---@return boolean success Whether setup succeeded
function M.setup(_config)
	_config = _config or {}

	-- Try to load neotest-jest adapter
	local jest_ok, neotest_jest = pcall(require, "neotest-jest")
	if jest_ok then
		table.insert(
			adapters,
			neotest_jest({
				jestCommand = "npm test --",
				jestConfigFile = "custom.jest.config.ts",
				env = { CI = true },
				cwd = function()
					return vim.fn.getcwd()
				end,
			})
		)
	end

	-- Try to load neotest-vim-test adapter (for Karma)
	local vim_test_ok, neotest_vim_test = pcall(require, "neotest-vim-test")
	if vim_test_ok then
		table.insert(
			adapters,
			neotest_vim_test({
				ignore_file_types = { "python", "vim", "lua", "ruby" },
			})
		)
	end

	-- If neither loaded, return true (lazy-loaded)
	if not jest_ok and not vim_test_ok then
		return true
	end

	return true
end

---Get the neotest adapter instances
---@return table adapters List of neotest adapters
function M.get_adapter()
	return adapters
end

return M
