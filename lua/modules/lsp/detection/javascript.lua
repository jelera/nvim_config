--[[
JavaScript/TypeScript Project Detection
========================================

Detects JS/TS/Node/Angular project configuration to determine appropriate LSP servers.

Detection rules:
- Always use ts_ls for TypeScript/JavaScript
- Angular projects → add angularls
- Check package.json for:
  - standard → use standardjs
  - eslint → use eslint (default)
  - prettier → note for config integration
  - eslint-config-prettier → ensures no conflicts between eslint and prettier

Returns:
- is_angular: boolean
- use_standard: boolean
- use_eslint: boolean
- use_prettier: boolean
- has_eslint_config_prettier: boolean
- needs_prettier_config: boolean (true if using eslint+prettier without config)
- servers: string[] (list of servers to enable)
--]]

local M = {}

---Find file in current directory or ancestors
---@param filename string Filename to search for
---@return string|nil path Full path if found, nil otherwise
local function find_file_upward(filename)
	-- Check if vim.fn API is available (for test compatibility)
	if not vim.fn or not vim.fn.getcwd or not vim.fn.findfile then
		return nil
	end

	local current_dir = vim.fn.getcwd()
	local path = vim.fn.findfile(filename, current_dir .. ";")
	if path ~= "" then
		return vim.fn.fnamemodify(path, ":p")
	end
	return nil
end

---Read file contents
---@param filepath string Path to file
---@return string|nil content File contents or nil if error
local function read_file(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

---Detect if project is Angular
---@return boolean
local function is_angular_project()
	-- Check for angular.json
	if vim.fn.filereadable("angular.json") == 1 then
		return true
	end

	-- Check for .angular directory
	if vim.fn.isdirectory(".angular") == 1 then
		return true
	end

	return false
end

---Parse package.json dependencies
---@return table config { has_standard: boolean, has_eslint: boolean, has_prettier: boolean, has_eslint_config_prettier: boolean }
local function parse_package_json()
	local config = {
		has_standard = false,
		has_eslint = false,
		has_prettier = false,
		has_eslint_config_prettier = false,
	}

	local package_json = find_file_upward("package.json")
	if not package_json then
		return config
	end

	local content = read_file(package_json)
	if not content then
		return config
	end

	-- Simple pattern matching (not full JSON parse)
	-- Check in both dependencies and devDependencies sections
	if content:find('"standard"') or content:find('"@standard/') or content:find('"ts%-standard"') then
		config.has_standard = true
	end

	if content:find('"eslint"') or content:find('"@eslint/') then
		config.has_eslint = true
	end

	if content:find('"prettier"') then
		config.has_prettier = true
	end

	-- Check for eslint-config-prettier to prevent conflicts
	if content:find('"eslint%-config%-prettier"') then
		config.has_eslint_config_prettier = true
	end

	return config
end

---Detect JavaScript/TypeScript project configuration
---@return table config { is_angular: boolean, use_standard: boolean, use_eslint: boolean, use_prettier: boolean, has_eslint_config_prettier: boolean, needs_prettier_config: boolean, servers: string[] }
function M.detect()
	local is_angular = is_angular_project()
	local pkg_config = parse_package_json()

	-- Check if using both eslint and prettier without proper config
	local needs_prettier_config = pkg_config.has_eslint
		and pkg_config.has_prettier
		and not pkg_config.has_eslint_config_prettier

	local config = {
		is_angular = is_angular,
		use_standard = pkg_config.has_standard,
		use_eslint = pkg_config.has_eslint or not pkg_config.has_standard, -- default to eslint
		use_prettier = pkg_config.has_prettier,
		has_eslint_config_prettier = pkg_config.has_eslint_config_prettier,
		needs_prettier_config = needs_prettier_config,
		servers = {},
	}

	-- Always include ts_ls
	table.insert(config.servers, "ts_ls")

	-- Add Angular language server for Angular projects
	if config.is_angular then
		table.insert(config.servers, "angularls")
	end

	-- Add linter
	-- Note: Standard.js is not an LSP server, so we use ESLint for all projects
	-- Projects using Standard can configure ESLint with eslint-config-standard
	if config.use_eslint or config.use_standard then
		table.insert(config.servers, "eslint")
	end

	-- Warn if using both eslint and prettier without proper config
	if config.needs_prettier_config then
		vim.notify(
			"Using ESLint + Prettier without eslint-config-prettier. Install it to avoid conflicts:\n"
				.. "npm install --save-dev eslint-config-prettier",
			vim.log.levels.WARN,
			{ title = "LSP Detection" }
		)
	end

	-- Warn if using standard without proper ESLint config
	if config.use_standard and not config.use_eslint then
		vim.notify(
			"Using Standard.js. For LSP support, install ESLint with Standard config:\n"
				.. "npm install --save-dev eslint eslint-config-standard\n"
				.. 'Create .eslintrc.json: {"extends": "standard"}',
			vim.log.levels.INFO,
			{ title = "LSP Detection" }
		)
	end

	return config
end

return M
