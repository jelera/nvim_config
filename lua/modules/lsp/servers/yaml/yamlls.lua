--[[
YAML Language Server Configuration
===================================

Provides schema validation for YAML files using SchemaStore.

Features:
- Automatic schema detection for common YAML config files
  (GitHub workflows, docker-compose, Kubernetes, etc.)
- YAML validation and diagnostics
- Auto-completion based on schemas
- Hover documentation

Returns a table that gets merged with default LSP settings.
--]]

return {
	-- Enable for YAML files
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },

	settings = {
		yaml = {
			-- Enable SchemaStore.org catalog for automatic schema detection
			schemaStore = {
				-- Enable built-in SchemaStore support
				enable = true,
				-- Fallback URL for schema retrieval
				url = "https://www.schemastore.org/api/json/catalog.json",
			},

			-- Additional schemas for common files
			schemas = require("schemastore").yaml.schemas(),

			-- Validation settings
			validate = true,

			-- Hover documentation
			hover = true,

			-- Completion settings
			completion = true,

			-- Format settings
			format = {
				enable = true,
				singleQuote = false,
				bracketSpacing = true,
			},

			-- Customize tags for Kubernetes, docker-compose, etc.
			customTags = {
				"!reference sequence", -- GitLab CI
			},
		},

		redhat = {
			telemetry = {
				enabled = false,
			},
		},
	},
}
