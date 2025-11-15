# Architecture Overview

## Design Philosophy

This NeoVim configuration follows three core principles:

1. **Modular**: Each feature is a self-contained module
2. **Testable**: TDD approach with integration tests
3. **Simple**: Use plugin defaults, avoid over-engineering

## Project Structure

```text
nvimconfig/
├── init.lua              # Entry point
├── lua/
│   ├── nvim/            # Framework (module loading, events)
│   ├── config/          # User configuration
│   ├── modules/         # Feature modules
│   └── spec/            # Tests
└── docs/                # Documentation
```

## Module System

### Module Pattern

Every module follows the same structure:

```text
modules/<name>/
├── init.lua          # Orchestrator - calls submodules
├── <feature>.lua     # Feature implementation
├── keymaps.lua       # Key mappings
└── plugins.lua       # Plugin specs for lazy.nvim
```

### Example: LSP Module

```lua
-- modules/lsp/init.lua
function M.setup(config)
  require('modules.lsp.mason').setup(config.mason)
  require('modules.lsp.config').setup(config.servers)
  require('modules.lsp.keymaps').setup()
  return true
end
```

**Key points:**

- Init.lua is just an orchestrator
- Each submodule is independent
- Configuration merged with sensible defaults
- Returns `true` on success

## Plugin Loading

Uses `lazy.nvim` with lazy loading:

```lua
-- modules/<name>/plugins.lua
return {
  {
    'plugin/name',
    event = 'VeryLazy',  -- Load when idle
    config = false,      -- Configured by module
  }
}
```

**Strategy:**

- Plugins load on-demand (events, keys, commands)
- Modules configure plugins, not plugin specs
- No duplicate configuration

## Module Loading Order

```text
1. Framework (nvim/)
2. Core (options, keymaps, autocmds)
3. UI (colorscheme, statusline)
4. TreeSitter
5. LSP
6. Completion
7. Navigation
8. Git
9. Debug
10. Test
11. AI
12. Editor
```

Each module can assume previous modules are loaded.

## Testing Strategy

**Integration tests only** - no unit tests.

```lua
-- Test pattern
describe('modules.<name>', function()
  before_each(function()
    spec_helper.setup()  -- Mock vim APIs
    package.loaded['modules.<name>'] = nil
  end)

  it('should setup with default config', function()
    local module = require('modules.<name>')
    assert.is_true(module.setup())
  end)
end)
```

**Why integration tests:**

- Tests real behavior, not implementation
- Faster to write and maintain
- Better coverage with fewer tests

## Configuration Flow

```text
User config → Module defaults → Plugin setup
```

```lua
-- User provides minimal config
require('modules.lsp').setup({
  servers = { lua_ls = {} }
})

-- Module merges with defaults
local merged = vim.tbl_deep_extend('force', defaults, user_config)

-- Plugin gets final config
lspconfig.lua_ls.setup(merged)
```

## Key Design Decisions

### 1. Simple Orchestrators

Modules don't manage state - they just call setup functions.

❌ **Don't:**

```lua
local state = { enabled = false }
function M.enable() state.enabled = true end
```

✅ **Do:**

```lua
function M.setup(config)
  require('plugin').setup(config)
  return true
end
```

### 2. Plugin Defaults

Don't override unless necessary.

❌ **Don't:**

```lua
require('plugin').setup({
  option1 = value1,  -- Default value
  option2 = value2,  -- Default value
  option3 = value3,  -- Custom value
})
```

✅ **Do:**

```lua
require('plugin').setup({
  option3 = value3,  -- Only custom value
})
```

### 3. Lazy Loading

Load on-demand, not at startup.

❌ **Don't:**

```lua
{ 'plugin/name', lazy = false }
```

✅ **Do:**

```lua
{ 'plugin/name', event = 'VeryLazy' }
{ 'plugin/name', keys = '<leader>x' }
{ 'plugin/name', ft = 'python' }
```

### 4. Config in Modules

Plugin specs should not contain configuration.

❌ **Don't:**

```lua
-- plugins.lua
{
  'plugin/name',
  config = function()
    require('plugin').setup({ ... })
  end
}
```

✅ **Do:**

```lua
-- plugins.lua
{ 'plugin/name', config = false }

-- init.lua
require('plugin').setup({ ... })
```

## Adding a New Module

1. Create directory: `modules/newmodule/`
2. Write integration test: `spec/integration/modules/newmodule_spec.lua`
3. Implement:
   - `init.lua` - orchestrator
   - `feature.lua` - implementation
   - `keymaps.lua` - key mappings
   - `plugins.lua` - plugin specs
4. Run tests: `./scripts/test.sh`
5. Use in config: `require('modules.newmodule').setup()`

## Performance Tips

- Startup target: <100ms
- Use `:Lazy profile` to find slow plugins
- Use `event = 'VeryLazy'` for non-critical plugins
- Disable features for large files (>1MB)
- Reduce LSP workspace folders

## Further Reading

- [TESTING.md](../TESTING.md) - Testing guide
- [KEYMAPS.md](./KEYMAPS.md) - All keybindings
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
