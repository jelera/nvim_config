--[[
Framework Plugins
=================

Framework-specific plugins for Rails and Angular development.
--]]

return {
	-- Rails: Navigation and commands
	{
		"tpope/vim-rails",
		ft = { "ruby", "eruby", "haml", "slim" },
		cmd = { "Rails", "A", "R", "Emodel", "Econtroller", "Eview" },
	},

	-- Rails: Bundler integration
	{
		"tpope/vim-bundler",
		ft = { "ruby", "eruby" },
		cmd = { "Bundler", "Bopen", "Bsplit", "Btabedit" },
	},

	-- Rails: Rake task integration
	{
		"tpope/vim-rake",
		ft = { "ruby", "eruby" },
		cmd = { "Rake" },
	},
}
