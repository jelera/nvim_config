--[[
RSpec Adapter
=============

Neotest adapter for RSpec (Ruby testing framework).

Configuration options:
- rspec_cmd: Custom RSpec command (default: "bundle exec rspec")
- root_files: Files to identify project root (default: {".git", "Gemfile"})
- filter_dirs: Directories to ignore (default: {"node_modules", ".git"})
- transform_spec_path: Function to transform spec paths
- results_path: Custom results path for temporary files

Dependencies:
- olimorris/neotest-rspec

Example config:
```lua
{
  rspec_cmd = "bundle exec rspec",
  root_files = { ".git", "Gemfile", ".rspec" },
  filter_dirs = { "node_modules", ".git", "vendor" },
}
```
--]]

local M = {}

local default_config = {
  rspec_cmd = "bundle exec rspec",
  root_files = { ".git", "Gemfile" },
  filter_dirs = { "node_modules", ".git", "vendor" },
}

---Get RSpec adapter with custom configuration
---@param config? table Custom configuration options
---@return table|nil adapter The neotest adapter or nil
function M.get_adapter(config)
  local ok, neotest_rspec = pcall(require, 'neotest-rspec')
  if not ok then
    return nil
  end

  -- Merge with defaults
  local merged_config = vim.tbl_deep_extend('force', default_config, config or {})

  return neotest_rspec(merged_config)
end

return M
