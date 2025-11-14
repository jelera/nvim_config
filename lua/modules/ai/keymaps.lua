--[[
AI Keymaps
==========

Defines all AI-related key mappings for sidekick.nvim.

Keymaps:
- <leader>aa - Accept NES suggestion
- <leader>an - Next NES hunk
- <leader>ap - Previous NES hunk
- <leader>ar - Reject NES suggestion
- <leader>at - Open AI terminal
- <leader>ac - AI chat (send selection)
- <leader>as - AI terminal with selection
- <leader>aq - Close AI terminal

API:
- setup() - Setup AI keymaps
--]]

local M = {}

---Setup AI keymaps
---@return boolean success Whether setup succeeded
function M.setup()
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- NES (Next Edit Suggestions) keymaps
	keymap("n", "<leader>aa", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.nes then
			sidekick.nes.accept()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Accept NES suggestion" }))

	keymap("n", "<leader>an", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.nes then
			sidekick.nes.next()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Next NES hunk" }))

	keymap("n", "<leader>ap", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.nes then
			sidekick.nes.prev()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Previous NES hunk" }))

	keymap("n", "<leader>ar", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.nes then
			sidekick.nes.reject()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Reject NES suggestion" }))

	-- AI Terminal keymaps
	keymap("n", "<leader>at", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.terminal then
			sidekick.terminal.open()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Open terminal" }))

	keymap("n", "<leader>ac", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.terminal then
			sidekick.terminal.chat()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Chat" }))

	keymap("v", "<leader>as", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.terminal then
			sidekick.terminal.send_selection()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Send selection" }))

	keymap("n", "<leader>aq", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok and sidekick.terminal then
			sidekick.terminal.close()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Close terminal" }))

	-- Additional AI commands
	keymap("n", "<leader>ai", function()
		local ok, sidekick = pcall(require, "sidekick")
		if ok then
			sidekick.toggle()
		end
	end, vim.tbl_extend("force", opts, { desc = "AI: Toggle sidekick" }))

	return true
end

return M
