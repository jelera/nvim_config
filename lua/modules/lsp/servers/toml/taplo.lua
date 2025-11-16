--[[
Taplo TOML Language Server Configuration
=========================================

Provides schema validation and editing support for TOML files.

Features:
- Schema validation for Cargo.toml, pyproject.toml, taplo.toml, mise.toml
- TOML syntax validation and diagnostics
- Auto-completion based on schemas
- Formatting with configurable options
- Hover documentation

Returns a table that gets merged with default LSP settings.
--]]

return {
	-- Enable for TOML files
	filetypes = { "toml" },

	settings = {
		evenBetterToml = {
			-- Schema validation
			schema = {
				enabled = true,
				-- Use SchemaStore for common TOML files
				catalogs = {
					"https://www.schemastore.org/api/json/catalog.json",
				},
				-- Explicit schema associations for specific files
				associations = {
					["mise%.toml"] = "https://mise.jdx.dev/schema/mise.json",
					["%.mise%.toml"] = "https://mise.jdx.dev/schema/mise.json",
					["%.mise/config%.toml"] = "https://mise.jdx.dev/schema/mise.json",
					["mise-tasks/.*%.toml"] = "https://mise.jdx.dev/schema/mise-task.json",
				},
			},

			-- Formatting options
			formatter = {
				-- Align entries in arrays
				alignEntries = false,
				-- Align comments
				alignComments = true,
				-- Array trailing comma
				arrayTrailingComma = true,
				-- Array auto expand
				arrayAutoExpand = true,
				-- Array auto collapse
				arrayAutoCollapse = true,
				-- Compact arrays
				compactArrays = true,
				-- Compact inline tables
				compactInlineTables = false,
				-- Column width
				columnWidth = 80,
				-- Indent tables
				indentTables = false,
				-- Indent entries
				indentEntries = false,
				-- Trailing newline
				trailingNewline = true,
				-- Reorder keys
				reorderKeys = false,
				-- Allowed blank lines
				allowedBlankLines = 2,
				-- CRLF line endings
				crlf = false,
			},

			-- Completion settings
			completion = {
				-- Max completion results
				maxResults = 50,
			},

			-- Validation settings
			validation = {
				-- Enable validation
				enabled = true,
			},
		},
	},
}
