# AGENTS.md

This file provides guidance to AI coding agents (including Claude Code) when working with code in this repository.

## Project Overview

This is a modular, framework-based Neovim configuration built as a complete IDE (~22,000+ lines of Lua). The architecture follows a three-layer design:

1. **Framework Layer** (`lua/nvim/`): Core infrastructure providing module loading, utilities, and validation
2. **Module Layer** (`lua/modules/`): 13 domain-specific feature modules (ui, completion, lsp, git, test, debug, etc.)
3. **Bootstrap Layer** (`init.lua`): Entry point that orchestrates lazy.nvim plugin loading and module initialization

## Development Commands

### Environment Setup

```bash
mise install          # Install all dependencies (languages, linters, formatters, LSPs)
lefthook install      # Setup git hooks for pre-commit checks
```

### Testing

```bash
# Fast TDD workflow (unit tests only)
busted lua/spec/unit

# All tests (unit + integration)
busted

# Specific test file
busted lua/spec/unit/nvim/core/module_loader_spec.lua

# With coverage
busted --coverage

# Useful flags
busted --no-shuffle              # Disable randomization for debugging
busted --seed=1234567890         # Reproduce specific test order
busted --tags=unit               # Run only unit tests
busted --exclude-tags=integration # Skip slow integration tests
```

Test files mirror source structure:

- Implementation: `lua/nvim/core/module_loader.lua`
- Tests: `lua/spec/unit/nvim/core/module_loader_spec.lua`

### Linting

```bash
luacheck --config .luacheckrc lua/   # Lint all Lua code
luacheck lua/nvim/                   # Lint specific directory
prettier --check .                   # Check JSON/YAML formatting
markdownlint .                       # Lint markdown files
shellcheck install.sh                # Lint shell scripts
```

### Git Workflow

```bash
git commit                # Runs lefthook pre-commit checks automatically
git commit --no-verify    # Skip hooks if needed
```

Pre-commit hooks run (in parallel):

- `luacheck` on .lua files
- `prettier` on JSON/YAML (auto-fixes)
- `markdownlint` on .md files
- `shellcheck` on .sh files
- `check-jsonschema` for workflow/config validation

### CI Pipeline (GitHub Actions)

Four workflows run sequentially:

1. **Lint Lua** → 2. **Lint Shell** → 3. **Validate Schemas** → 4. **Run Tests**

Tests only run after all three lint workflows pass. If tests fail, check the CI output and fix issues locally before pushing.

## Architecture Patterns

### Module Pattern

Every module follows this contract:

```lua
-- lua/modules/mymodule/init.lua
local M = {}

function M.setup(config)
  config = config or {}
  -- Initialize submodules
  -- Use pcall() for graceful failure
  -- Return boolean success
  return true
end

return M
```

Each module typically contains:

- `init.lua`: Main setup orchestrator
- `plugins.lua`: Lazy.nvim plugin specifications
- `config.lua`: Module-specific configuration
- `keymaps.lua`: Keybindings (if applicable)
- Subdirectories for complex features (e.g., `lsp/servers/`)

### Plugin Loading Strategy

Plugins are loaded via lazy.nvim with strategic timing:

1. **Immediate**: UI module (colorscheme to prevent flash)
2. **Event-based**: Completion (`InsertEnter`), LSP (`BufReadPre/BufNewFile`)
3. **Priority modules** (via `vim.schedule`): ui, tooling, completion, treesitter, navigation, git, editor
4. **Deferred modules** (100ms delay): ai, test, debug, frameworks

See `init.lua:27-40` for module load order.

### Configuration Merging

Use the framework's `deep_merge` utility for combining configs:

```lua
local utils = require('nvim.lib.utils')
local merged = utils.deep_merge(default_config, user_config)
```

### Error Handling

- Use `pcall()` for all plugin loading and module initialization
- Use `vim.notify()` with appropriate log levels for user feedback
- Non-blocking failures: modules continue if optional features fail

### Testing Conventions

- **Unit tests**: `lua/spec/unit/` - Fast, isolated, mock vim API
- **Integration tests**: `lua/spec/integration/` - Test component interactions
- Tag all tests: `describe('module_name #unit', ...)` or `describe('... #integration', ...)`
- Use `lua/spec/spec_helper.lua` for comprehensive vim API mocking
- Tests shuffle by default to catch interdependencies

### Project-Aware LSP

LSP servers activate based on project type detection:

- Ruby projects (Gemfile present): Solargraph or ruby_lsp
- JavaScript projects (package.json): typescript-language-server or tsserver
- Language-agnostic: Lua, Python, Bash, etc. always enabled

See `lua/modules/lsp/init.lua` for detection logic.

### Code Style

- **Files**: snake_case (e.g., `module_loader.lua`)
- **Functions**: snake_case (e.g., `deep_merge()`)
- **Private fields**: underscore prefix (e.g., `M._loaded_modules`)
- **Constants**: UPPER_CASE (e.g., `LAZY_REPO`)
- **Line length**: 100 chars (code), 120 chars (strings/comments)
- **Complexity**: Max 15 cyclomatic complexity (10 for framework core)
- **Documentation**: LuaDoc-style with `@param`, `@return` annotations

## AI Agent Code Quality Requirements

When writing code, AI agents (including Claude Code) MUST:

1. **Follow Linting Rules**: All code must pass `luacheck` and `shellcheck` validation
   - Luacheck config: `.luacheckrc` (enforces line length, complexity, unused vars, etc.)
   - Shell scripts must pass shellcheck with no errors
   - Hooks are configured to block code with linting errors

2. **Write Clean, Idiomatic Code**:
   - No unused variables or functions
   - No undefined global variables
   - Proper error handling with `pcall()` for external operations
   - Use `vim.notify()` for user feedback with appropriate log levels

3. **Maintain Consistency**:
   - Match existing code patterns in the module you're modifying
   - Use the project's established conventions (see Code Style above)
   - Follow the Module Pattern for new modules

4. **Test Considerations**:
   - Ensure code is testable (pure functions, dependency injection)
   - Consider edge cases and error conditions
   - Don't break existing tests

5. **Documentation**:
   - Add LuaDoc comments for public functions
   - Include `@param` and `@return` annotations
   - Document non-obvious behavior or complex logic

6. **Security & Performance**:
   - Avoid command injection vulnerabilities
   - Use proper escaping for shell commands
   - Minimize blocking operations on main thread
   - Use vim.schedule() for deferred work

**Important**: If linting errors occur after writing code, they MUST be fixed immediately. The hooks will block and provide feedback - address all issues before proceeding.

## Adding a New Module

1. Create directory: `lua/modules/mymodule/`
2. Create files:
   - `init.lua` with `setup(config)` function
   - `plugins.lua` returning lazy.nvim specs
   - Additional files as needed (config, keymaps, etc.)
3. Add module name to `init.lua:27-40` module list
4. Create tests: `lua/spec/unit/modules/mymodule/`
5. Test locally: `busted lua/spec/unit/modules/mymodule/`

## Key Framework Components

### Module Loader (`lua/nvim/core/module_loader.lua`)

- Dynamic module loading with caching
- Loads from `lua/modules/` directory
- Used internally by framework

### Utils (`lua/nvim/lib/utils.lua`)

- `deep_merge(target, source)`: Recursively merge tables
- `deep_copy(tbl)`: Deep copy tables
- `is_array(tbl)`: Array detection
- Other table utilities

### Validator (`lua/nvim/lib/validator.lua`)

- Type validation functions
- Schema validation
- Used for config validation

## Quality of Life Features

The `modules/core/quality_of_life.lua` module provides:

- Auto-save on focus lost or buffer leave
- Return to last cursor position on file open
- Auto-create parent directories on save

## Troubleshooting

### Tests Failing in Shuffle Mode

1. Note the seed value from output
2. Reproduce: `busted --seed=<noted-seed>`
3. Debug: `busted --no-shuffle`

### Luacheck Errors

- Check `.luacheckrc` for rules
- Framework core (`lua/nvim/`) has stricter rules (complexity 10)
- Modules (`lua/modules/`) allow complexity up to 15
- Tests allow longer lines (120 chars)

### Plugin Not Loading

- Check `init.lua` module load order
- Verify plugin spec in `plugins.lua` has correct lazy-loading events
- Check for pcall errors: `vim.notify` messages or `:checkhealth`

### LSP Not Starting

- Verify project detection in `lua/modules/lsp/init.lua`
- Check if project type markers exist (Gemfile, package.json, etc.)
- Run `:LspInfo` to see active/available servers
