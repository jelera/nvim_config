--[[
Folding Module
==============

Custom fold text using treesitter for intelligent display.

Features:
- Treesitter-aware fold text
- Node type detection with icons (hybrid nerd fonts + emojis)
- Clean formatting with line counts
- Fallback for non-treesitter buffers

Dependencies:
- nvim-treesitter (optional but recommended)

Usage:
```lua
local folding = require('modules.editor.folding')
folding.setup()
```

API:
- setup(config) - Initialize folding with optional config
- get_fold_text() - Get the fold text for current fold
--]]

local M = {}

---Icon mappings for different node types
---Mixed: Nerd fonts for most, emojis for describe/class/import
local type_icons = {
	-- Functions & Methods (nerd fonts)
	function_declaration = "󰊕", -- nf-md-function
	function_definition = "󰊕",
	arrow_function = "󰊕",
	method_definition = "", -- nf-md-function_variant
	function_item = "󰊕",
	["function"] = "󰊕", -- quoted because 'function' is a Lua keyword

	-- Classes & Objects (EMOJI)
	class_declaration = "📦",
	class_definition = "📦",
	class = "📦",
	interface_declaration = "📦",
	interface = "📦",
	struct = "📦",
	struct_item = "📦",

	-- Variables & Constants (nerd fonts)
	variable_declaration = "", -- nf-md-variable
	const_declaration = "", -- nf-md-lock
	let_declaration = "",

	-- Control Flow (nerd fonts)
	if_statement = "", -- nf-md-call_split
	else_clause = "",
	for_statement = "󰑖", -- nf-md-repeat
	while_statement = "󰑖",
	loop_statement = "󰑖",
	switch_statement = "󰘬", -- nf-md-swap_horizontal
	match_expression = "󰘬",

	-- Try/Catch (nerd fonts)
	try_statement = "󰀪", -- nf-md-alert_circle
	catch_clause = "󰀪",

	-- Arrays & Objects (nerd fonts)
	array = "", -- nf-md-code_brackets
	object = "", -- nf-md-code_braces
	table_constructor = "",
	list = "",

	-- Comments & Documentation (nerd fonts)
	comment = "", -- nf-md-comment
	block_comment = "",
	line_comment = "",
	doc_comment = "", -- nf-md-comment_text

	-- Imports & Exports (EMOJI)
	import_statement = "📥",
	import_from_statement = "📥",
	import_declaration = "📥",
	export_statement = "📤",
	require_call = "📥",
	use_declaration = "📥",

	-- Tests (EMOJI)
	describe_block = "🧪",
	it_block = "🧪",
	test = "🧪",

	-- Blocks (nerd fonts)
	block = "", -- nf-md-code_braces
	do_block = "",
	body = "",

	-- Markup (nerd fonts)
	heading = "", -- nf-md-format_header_pound
	code_block = "", -- nf-md-code_tags

	-- Default
	default = "▸",
}

---Pattern mappings for node type detection
local pattern_mappings = {
	{ patterns = { "function", "method" }, icon_key = "function_declaration" },
	{ patterns = { "class", "interface", "struct" }, icon_key = "class_declaration" },
	{ patterns = { "if", "for", "while", "loop" }, icon_key = "if_statement" },
	{ patterns = { "import", "require", "use" }, icon_key = "import_statement" },
	{ patterns = { "export" }, icon_key = "export_statement" },
	{ patterns = { "describe", "test", "it_block" }, icon_key = "test" },
	{ patterns = { "block", "body" }, icon_key = "block" },
	{ patterns = { "comment" }, icon_key = "comment" },
}

---Get icon for a node type
---@param node_type string The treesitter node type
---@return string icon The icon for the node type
local function get_node_icon(node_type)
	-- Try exact match first
	local icon = type_icons[node_type]
	if icon then
		return icon
	end

	-- Pattern matching using lookup table
	for _, mapping in ipairs(pattern_mappings) do
		for _, pattern in ipairs(mapping.patterns) do
			if node_type:match(pattern) then
				return type_icons[mapping.icon_key]
			end
		end
	end

	return type_icons.default
end

---Get fold text for current fold (medium complexity)
---Uses treesitter to detect node types and format intelligently
---@return string fold_text The formatted fold text
function M.get_fold_text()
	local line = vim.fn.getline(vim.v.foldstart)
	local line_count = vim.v.foldend - vim.v.foldstart + 1

	-- Try to get treesitter node
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = 0,
		pos = { vim.v.foldstart - 1, 0 },
	})

	if ok and node then
		local node_type = node:type()

		-- Get first line of node text (often the signature/declaration)
		local text_ok, node_text = pcall(vim.treesitter.get_node_text, node, 0)
		if text_ok then
			local first_line = node_text:match("^([^\n]*)")
			if first_line then
				-- Clean up whitespace
				first_line = first_line:gsub("^%s+", ""):gsub("%s+$", "")

				-- Get icon based on node type
				local icon = get_node_icon(node_type)

				return string.format("%s %s [%d lines]", icon, first_line, line_count)
			end
		end
	end

	-- Fallback: clean up the line text manually
	local text = line:gsub("^%s+", ""):gsub("%s+$", "")

	-- Remove common comment characters
	text = text:gsub("^[-/]+%s*", "") -- Remove //, --, etc.
	text = text:gsub("^[#]+%s*", "") -- Remove #
	text = text:gsub("^[*]+%s*", "") -- Remove *

	return string.format("▸ %s [%d lines]", text, line_count)
end

---Setup folding configuration
---@param config table|nil Optional configuration
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Set the fold text function globally
	vim.opt.foldtext = "v:lua.require('modules.editor.folding').get_fold_text()"

	-- Optional: set additional fold options if provided
	if config.fillchars then
		vim.opt.fillchars:append({ fold = config.fillchars })
	else
		-- Default: use a subtle character for fold lines
		vim.opt.fillchars:append({ fold = " " })
	end

	-- Optional: configure fold column
	if config.foldcolumn then
		vim.opt.foldcolumn = config.foldcolumn
	end

	return true
end

return M
