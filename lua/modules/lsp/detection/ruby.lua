--[[
Ruby Project Detection
=======================

Detects Ruby/Rails project configuration to determine appropriate LSP servers.

Detection rules:
- Rails projects → solargraph + rubocop (or standardrb if in Gemfile)
- Non-Rails Ruby → ruby_lsp + rubocop
- Checks Gemfile for:
  - standardrb (alternative to rubocop)
  - rubocop-rails (Rails-specific cops)
  - rubocop-rspec (RSpec-specific cops)

Returns:
- is_rails: boolean
- use_standardrb: boolean
- has_rubocop_rails: boolean
- has_rubocop_rspec: boolean
- lsp_server: 'solargraph' or 'ruby_lsp'
- formatter: 'rubocop' or 'standardrb'
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

---Check if file contains pattern
---@param filepath string Path to file
---@param pattern string Pattern to search for
---@return boolean
local function _file_contains(filepath, pattern) -- luacheck: ignore 211
	local content = read_file(filepath)
	if not content then
		return false
	end
	return content:find(pattern, 1, true) ~= nil -- plain text search
end

---Detect if project is a Rails application
---@return boolean
local function is_rails_project()
	local rails_indicators = {
		"config/application.rb",
		"config/environment.rb",
	}

	for _, indicator in ipairs(rails_indicators) do
		if vim.fn.filereadable(indicator) == 1 then
			return true
		end
	end

	-- Also check for app/ and config/ directories together
	if vim.fn.isdirectory("app") == 1 and vim.fn.isdirectory("config") == 1 then
		return true
	end

	return false
end

---Parse Gemfile for rubocop-related gems
---@return table gems { standard: boolean, rubocop_rails: boolean, rubocop_rspec: boolean }
local function parse_gemfile()
	local gems = {
		standard = false,
		rubocop_rails = false,
		rubocop_rspec = false,
	}

	local gemfile = find_file_upward("Gemfile")
	if not gemfile then
		return gems
	end

	local content = read_file(gemfile)
	if not content then
		return gems
	end

	-- Check for each gem
	local has_standard = content:find("gem [\"']standard[\"']")
		or content:find('gem "standard"')
		or content:find("gem 'standard'")
	if has_standard then
		gems.standard = true
	end

	if content:find("rubocop%-rails") then
		gems.rubocop_rails = true
	end

	if content:find("rubocop%-rspec") then
		gems.rubocop_rspec = true
	end

	return gems
end

---Detect Ruby project configuration
---@return table config Project config with is_rails, use_standardrb, has_rubocop_rails, lsp_server, etc.
function M.detect()
	local is_rails = is_rails_project()
	local gems = parse_gemfile()

	-- Check for .standard.yml config file
	local has_standard_config = vim.fn.filereadable(".standard.yml") == 1

	local use_standardrb = gems.standard or has_standard_config

	local config = {
		is_rails = is_rails,
		use_standardrb = use_standardrb,
		has_rubocop_rails = gems.rubocop_rails,
		has_rubocop_rspec = gems.rubocop_rspec,
		lsp_server = is_rails and "solargraph" or "ruby_lsp",
		formatter = use_standardrb and "standardrb" or "rubocop",
		servers = {},
	}

	-- Build list of servers to enable
	table.insert(config.servers, config.lsp_server)
	table.insert(config.servers, config.formatter)

	return config
end

return M
