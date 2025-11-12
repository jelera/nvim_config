--[[
Web Formatting (HTML, CSS, SCSS, Less)
=======================================

Uses prettier for consistent formatting across web files.
No ESLint conflicts since these are not JS files.
--]]

local M = {}

---Get formatters for HTML files
---@return table formatters List of formatters
function M.get_html_formatters()
	return { "prettier" }
end

---Get formatters for CSS files
---@return table formatters List of formatters
function M.get_css_formatters()
	return { "prettier" }
end

---Get formatters for SCSS files
---@return table formatters List of formatters
function M.get_scss_formatters()
	return { "prettier" }
end

---Get formatters for Less files
---@return table formatters List of formatters
function M.get_less_formatters()
	return { "prettier" }
end

return M
