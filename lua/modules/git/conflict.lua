--[[
Git Conflict Resolution Configuration
======================================

Configures neogit and diffview for enhanced merge conflict resolution.

Features:
- Auto-detect git conflict state (rebase/merge/cherry-pick)
- Lazy-load neogit and diffview during conflicts
- Conflict-specific keymaps and commands
- Integration between neogit and diffview for 3-way merge

Dependencies:
- NeogitOrg/neogit
- sindrets/diffview.nvim

API:
- setup(config) - Configure conflict resolution tools
- detect_and_load() - Check for conflicts and load tools
--]]

local M = {}

local utils = require("nvim.lib.utils")

---Default configuration for neogit
local default_neogit_config = {
	-- Integration with diffview for merge editor
	integrations = {
		diffview = true,
		telescope = true,
	},
	-- Disable auto-refresh during conflicts for performance
	disable_commit_confirmation = false,
	disable_builtin_notifications = false,
	-- Use telescope for selections
	use_telescope = true,
	-- Git command options
	git_services = {
		["github.com"] = {
			pull_request = "https://github.com/${owner}/${repository}/pull/${pull_request}",
			tree = "https://github.com/${owner}/${repository}/tree/${branch_name}",
			commit = "https://github.com/${owner}/${repository}/commit/${commit_hash}",
		},
		["gitlab.com"] = {
			pull_request = "https://gitlab.com/${owner}/${repository}/-/merge_requests/${pull_request}",
			tree = "https://gitlab.com/${owner}/${repository}/-/tree/${branch_name}",
			commit = "https://gitlab.com/${owner}/${repository}/-/commit/${commit_hash}",
		},
	},
	-- Status mappings
	mappings = {
		status = {
			-- Neogit doesn't support custom commands in mappings
			-- Use Neogit's built-in diff command instead
			-- To use Diffview, call it separately with :DiffviewOpen
		},
	},
}

---Setup neogit with configuration
---@param config? table Configuration options
---@return boolean success Whether setup succeeded
local function setup_neogit(config)
	local merged_config = vim.tbl_deep_extend("force", default_neogit_config, config or {})

	-- Try to load neogit plugin
	local ok, neogit = pcall(require, "neogit")
	if not ok then
		-- Plugin not loaded yet (will be lazy-loaded), return true
		return true
	end

	-- Setup neogit
	local setup_ok, err = pcall(neogit.setup, merged_config)
	if not setup_ok then
		vim.notify(string.format("Failed to setup neogit: %s", err), vim.log.levels.ERROR)
		return false
	end

	return true
end

---Detect git conflict state and trigger plugin loading
---@return boolean in_conflict Whether in conflict state
function M.detect_and_load()
	if not utils.is_git_conflict_state() then
		return false
	end

	-- Trigger the GitConflictDetected event to lazy-load plugins
	vim.api.nvim_exec_autocmds("User", { pattern = "GitConflictDetected" })

	-- Show notification with helpful instructions
	vim.notify(
		"Git conflict detected!\n\n"
			.. "Conflict resolution tools loaded:\n"
			.. "• <leader>gg - Open Neogit status\n"
			.. "• <leader>gm - Open 3-way merge view\n"
			.. "• ]x / [x - Navigate conflicts\n\n"
			.. "LSP disabled until conflicts resolved.",
		vim.log.levels.WARN,
		{ title = "Git Conflict Mode" }
	)

	return true
end

---Setup conflict resolution configuration
---@param config? table Configuration options
---@param config.neogit? table Neogit configuration overrides
---@return boolean success Whether setup succeeded
function M.setup(config)
	config = config or {}

	-- Setup neogit
	local neogit_ok = setup_neogit(config.neogit or {})
	if not neogit_ok then
		vim.notify("Failed to setup neogit for conflict resolution.", vim.log.levels.WARN)
		return false
	end

	-- Create autocommands for conflict detection
	local augroup = vim.api.nvim_create_augroup("GitConflictDetection", { clear = true })

	-- Check on VimEnter
	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		callback = function()
			vim.schedule(function()
				M.detect_and_load()
			end)
		end,
		desc = "Detect git conflicts on startup",
	})

	-- Check when focus is gained (useful for long-running rebases)
	vim.api.nvim_create_autocmd("FocusGained", {
		group = augroup,
		callback = function()
			vim.schedule(function()
				M.detect_and_load()
			end)
		end,
		desc = "Detect git conflicts on focus",
	})

	return true
end

return M
