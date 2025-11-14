--[[
Auto-pairs Configuration
=========================

Configures nvim-autopairs for automatic bracket/quote pairing.

Features:
- Auto-insert closing brackets, quotes, etc.
- TreeSitter integration for smarter pairing
- nvim-cmp integration for completion
- Fast wrap feature (Alt + e)

Dependencies:
- windwp/nvim-autopairs

API:
- setup(config) - Configure autopairs
--]]

local M = {}

---Default configuration for autopairs
local default_config = {
	check_ts = true, -- Enable TreeSitter integration
	ts_config = {
		lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
		javascript = { "template_string" },
		java = false, -- Don't check treesitter on java
	},
	disable_filetype = { "TelescopePrompt", "vim" },
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = [=[[%'%"%)%>%]%)%}%,]]=],
		end_key = "$",
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		check_comma = true,
		highlight = "Search",
		highlight_grey = "Comment",
	},
}

---Setup autopairs with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Try to load autopairs plugin
	local ok, autopairs = pcall(require, "nvim-autopairs")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup autopairs
	local setup_ok, err = pcall(autopairs.setup, merged_config)
	if not setup_ok then
		vim.notify(string.format("Failed to setup autopairs: %s", err), vim.log.levels.ERROR)
		return false
	end

	-- Integration with nvim-cmp (if available)
	local cmp_ok, cmp = pcall(require, "cmp")
	if cmp_ok then
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end

	return true
end

return M
