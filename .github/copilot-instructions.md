# Copilot Instructions - NeoVim Configuration

## Architecture Overview

This is a **test-driven, modular NeoVim configuration** built from scratch with a custom framework. The
project follows a strict TDD approach with 575+ passing tests and is organized into distinct phases.

### Core Framework (`lua/nvim/`)

- **`nvim/init.lua`** - Main framework entry point with `setup()` API
- **`nvim/core/module_loader.lua`** - Dynamic module loading with caching and dependency tracking
- **`nvim/core/event_bus.lua`** - Event-driven architecture for module communication
- **`nvim/core/plugin_system.lua`** - Extension hooks and plugin management
- **`nvim/lib/utils.lua`** - Shared utilities including `merge_config()` function

### Feature Modules (`lua/modules/`)

Each module follows the pattern: `init.lua` (orchestrator), `config.lua` (defaults), `plugins.lua` (lazy.nvim specs).

## Critical Patterns

### Module Structure

Every feature module has:

```lua
-- Module API with setup() function
function M.setup(config)
  local merged_config = utils.merge_config(default_config, config)
  -- initialization logic
end

-- Expose sub-modules for direct access
M.options = require('modules.core.options')
```

### LSP Server Organization

LSP servers live in `modules/lsp/servers/<language>/` with this structure:

- Each language gets its own directory (`lua/`, `javascript/`, etc.)
- Server config files named after LSP server (`lua_ls.lua`, `ts_ls.lua`)
- Settings include NeoVim-specific optimizations (workspace.library for Lua)

### Testing Approach

- **Unit tests**: `spec/unit/` - Mock vim API via `spec_helper.lua`
- **Integration tests**: `spec/integration/` - Test module interactions
- All tests use `#unit` or `#integration` tags for filtering
- Use `./scripts/test.sh --tags=unit` for focused testing

## Development Workflow

### Essential Commands

```bash
./scripts/test.sh                    # Run all tests
./scripts/test.sh --tags=unit        # Unit tests only
./scripts/lint-check.sh             # Luacheck linting
./scripts/type-check.sh             # Type checking (informational for Lua)
```

### Adding New Language Servers

1. Create `modules/lsp/servers/<language>/<server_name>.lua`
2. Export server configuration with LSP settings
3. Add to `ensure_installed` in `modules/lsp/config.lua`
4. Write integration test in `spec/integration/modules/lsp_spec.lua`

### Test-First Development

Always write failing tests first:

1. Create `*_spec.lua` file in appropriate `spec/unit/` or `spec/integration/`
2. Use `spec_helper.setup()` and `spec_helper.teardown()` in test hooks
3. Mock vim API is automatically available via `spec_helper.lua`

## Key Conventions

### Configuration Merging

Use `utils.merge_config(defaults, user_config)` - never manual table merging.

### Module Loading

Use `require('nvim.core.module_loader').load()` for dynamic loading with error handling.

### File Size Limits

Keep modules under ~130 lines. Split larger modules into focused sub-files like LSP does.

### Plugin Specifications

Define in separate `plugins.lua` files, not inline. Use lazy.nvim's declarative format with proper dependencies.

### Error Handling

Framework modules return boolean success indicators. User-facing modules should gracefully degrade if dependencies missing.

## Project State

**Current Phase**: Completion System (nvim-cmp + LuaSnip)
**Previous Phases**: Core Framework, UI, TreeSitter, LSP (all complete)
**Test Coverage**: 575 tests, 100% passing rate

The codebase is production-ready for phases 1-5. New development should maintain TDD discipline and modular architecture.
