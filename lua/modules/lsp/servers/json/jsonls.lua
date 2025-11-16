--[[
JSON Language Server Configuration
===================================

Provides schema validation for JSON files using SchemaStore.

Features:
- Automatic schema detection for common config files (package.json, tsconfig.json, etc.)
- JSON validation and diagnostics
- Auto-completion based on schemas
- Hover documentation

Returns a table that gets merged with default LSP settings.
--]]

return {
	-- Enable for JSON files
	filetypes = { "json", "jsonc" },

	settings = {
		json = {
			-- Enable SchemaStore.org catalog for automatic schema detection
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },

			-- Format settings
			format = {
				enable = true,
			},
		},
	},

	-- Ensure proper initialization
	init_options = {
		provideFormatter = true,
	},
}
