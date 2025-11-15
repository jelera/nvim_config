--[[
Angular Language Server Configuration
======================================

Custom configuration for angularls (Angular Language Service).

Angular LS provides Angular-specific features like component/template navigation,
completions, and diagnostics.

Returns a table that gets merged with default LSP settings.
--]]

return {
	-- Angular LS works best with TypeScript projects
	-- It requires @angular/language-service to be installed in the project
	root_dir = function(fname)
		local util = require("lspconfig.util")
		local root_pattern = util.root_pattern("angular.json", ".angular", "nx.json")
		return root_pattern(fname) or util.find_git_ancestor(fname)
	end,

	settings = {
		angular = {
			-- Enable strict mode for better type checking
			strictTemplates = true,
		},
	},
}
