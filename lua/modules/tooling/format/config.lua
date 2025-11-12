--[[
Config File Formatting (YAML, JSON, Markdown)
==============================================

Uses prettier for consistent formatting across config files.
--]]

local M = {}

---Get formatters for YAML files
---@return table formatters List of formatters
function M.get_yaml_formatters()
	return { "prettier" }
end

---Get formatters for JSON files
---@return table formatters List of formatters
function M.get_json_formatters()
	return { "prettier" }
end

---Get formatters for JSONC files
---@return table formatters List of formatters
function M.get_jsonc_formatters()
	return { "prettier" }
end

---Get formatters for Markdown files
---@return table formatters List of formatters
function M.get_markdown_formatters()
	return { "prettier" }
end

return M
