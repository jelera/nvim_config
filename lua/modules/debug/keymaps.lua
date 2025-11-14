--[[
Debug Keymaps
=============

Defines all debugging-related key mappings.

Keymaps:
- <F5> - Continue / Start debugging
- <F10> - Step over
- <F11> - Step into
- <F12> - Step out
- <leader>db - Toggle breakpoint
- <leader>dB - Set conditional breakpoint
- <leader>dr - Open REPL
- <leader>dl - Run last configuration
- <leader>dt - Terminate session
- <leader>du - Toggle UI

API:
- setup() - Setup debug keymaps
--]]

local M = {}

---Setup debug keymaps
---@return boolean success Whether setup succeeded
function M.setup()
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- F-key mappings (standard debug keys)
	keymap("n", "<F5>", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.continue()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Continue" }))

	keymap("n", "<F10>", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.step_over()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Step over" }))

	keymap("n", "<F11>", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.step_into()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Step into" }))

	keymap("n", "<F12>", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.step_out()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Step out" }))

	-- Leader-d mappings (debug commands)
	keymap("n", "<leader>db", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.toggle_breakpoint()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Toggle breakpoint" }))

	keymap("n", "<leader>dB", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			local condition = vim.fn.input("Breakpoint condition: ")
			dap.set_breakpoint(condition)
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Conditional breakpoint" }))

	keymap("n", "<leader>dr", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.repl.open()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Open REPL" }))

	keymap("n", "<leader>dl", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.run_last()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Run last" }))

	keymap("n", "<leader>dt", function()
		local ok, dap = pcall(require, "dap")
		if ok then
			dap.terminate()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Terminate" }))

	keymap("n", "<leader>du", function()
		local ok, dapui = pcall(require, "dapui")
		if ok then
			dapui.toggle()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Toggle UI" }))

	-- Additional debug keymaps
	keymap("n", "<leader>dh", function()
		local ok, dap_widgets = pcall(require, "dap.ui.widgets")
		if ok then
			dap_widgets.hover()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Hover" }))

	keymap("n", "<leader>dp", function()
		local ok, dap_widgets = pcall(require, "dap.ui.widgets")
		if ok then
			dap_widgets.preview()
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Preview" }))

	keymap("n", "<leader>df", function()
		local ok, dap_widgets = pcall(require, "dap.ui.widgets")
		if ok then
			local widgets = dap_widgets
			widgets.centered_float(widgets.frames)
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Frames" }))

	keymap("n", "<leader>ds", function()
		local ok, dap_widgets = pcall(require, "dap.ui.widgets")
		if ok then
			local widgets = dap_widgets
			widgets.centered_float(widgets.scopes)
		end
	end, vim.tbl_extend("force", opts, { desc = "Debug: Scopes" }))

	return true
end

return M
