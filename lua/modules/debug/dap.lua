--[[
Core DAP Configuration
=======================

Configures nvim-dap with breakpoints, signs, and virtual text.

Features:
- Breakpoint signs and highlighting
- Virtual text for variable values
- Session management
- REPL configuration

Dependencies:
- mfussenegger/nvim-dap
- theHamsta/nvim-dap-virtual-text

API:
- setup(config) - Configure core DAP
--]]

local M = {}

---Default configuration for DAP
local default_config = {
	-- Signs configuration
	signs = {
		breakpoint = {
			text = "●",
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "DapBreakpoint",
		},
		breakpoint_condition = {
			text = "◆",
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "DapBreakpoint",
		},
		breakpoint_rejected = {
			text = "○",
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "DapBreakpoint",
		},
		log_point = {
			text = "◆",
			texthl = "DapLogPoint",
			linehl = "",
			numhl = "DapLogPoint",
		},
		stopped = {
			text = "→",
			texthl = "DapStopped",
			linehl = "DapStoppedLine",
			numhl = "DapStopped",
		},
	},
	-- Virtual text configuration
	virtual_text = true,
	virtual_text_config = {
		enabled = true,
		enabled_commands = true,
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		show_stop_reason = true,
		commented = false,
		only_first_definition = true,
		all_references = false,
		filter_references_pattern = "<module",
		virt_text_pos = "eol",
		all_frames = false,
		virt_lines = false,
		virt_text_win_col = nil,
	},
}

---Setup core DAP with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
function M.setup(config)
	-- Merge with defaults
	local merged_config = vim.tbl_deep_extend("force", default_config, config or {})

	-- Try to load nvim-dap plugin
	local ok, _dap = pcall(require, "dap")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup signs
	for sign_type, sign_config in pairs(merged_config.signs) do
		local name = "Dap" .. sign_type:gsub("^%l", string.upper):gsub("_(%l)", string.upper)
		vim.fn.sign_define(name, sign_config)
	end

	-- Setup virtual text if enabled
	if merged_config.virtual_text then
		local vt_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
		if vt_ok then
			dap_virtual_text.setup(merged_config.virtual_text_config)
		end
	end

	return true
end

return M
