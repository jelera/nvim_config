--[[
Ruby LSP Configuration
=======================

Custom configuration for ruby_lsp (Official Ruby Language Server).

Ruby LSP is the official language server from Shopify, providing:
- Fast go-to-definition
- Accurate completion
- Code actions
- Hover documentation

Best used for non-Rails Ruby projects.

Returns a table that gets merged with default LSP settings.
--]]

return {
	settings = {
		-- Ruby LSP automatically detects project configuration
		-- No special settings needed for most cases
	},
}
