--[[
Pyright Language Server Configuration
======================================

Custom configuration for pyright (Python Language Server).

Fast type checker for Python with good defaults.

Returns a table that gets merged with default LSP settings.
--]]

return {
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- off, basic, strict
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
			},
		},
	},
}
