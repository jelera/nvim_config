# NeoVim IDE Configuration - AI Agent Context

> **Universal AI assistant context** for Claude Code, GitHub Copilot, Cursor, Aider, and other AI coding tools.

## Project Overview

A **production-ready, test-driven NeoVim IDE configuration** built from scratch with:
- **Pure Lua** configuration (no VimScript)
- **Test-Driven Development** with 786 passing tests
- **Modular architecture** with clean separation of concerns
- **Comprehensive tooling** for 7+ programming languages
- **Full IDE features**: LSP, DAP, testing, AI integration

**Status:** ✅ All 14 development phases complete, production-ready

## Technology Stack (2025)

### Core Tools
- **Plugin Manager:** `lazy.nvim` - Modern, fast, lazy-loading
- **LSP:** `nvim-lspconfig` + `mason.nvim` (9 language servers)
- **Completion:** `nvim-cmp` + `LuaSnip` + multiple sources
- **Syntax:** `nvim-treesitter` with text objects
- **Testing:** `neotest` with language-specific adapters
- **Debugging:** `nvim-dap` + `nvim-dap-ui` (4 languages)
- **Git:** `gitsigns`, `vim-fugitive`, `diffview`
- **AI:** `sidekick.nvim` (Copilot NES + AI terminal)

### Supported Languages
- Lua, TypeScript/JavaScript, Python, Ruby, Go, Rust, Bash, SQL, Markdown

## Architecture

### Directory Structure

```
nvimconfig/
├── AGENTS.md                    # This file - AI context
├── init.lua                     # Entry point
├── lua/
│   ├── nvim/                    # Core framework
│   │   ├── bootstrap.lua        # Plugin manager setup
│   │   ├── module_loader.lua    # Dynamic module loading
│   │   └── utils.lua            # Shared utilities
│   ├── modules/                 # Feature modules
│   │   ├── core/                # Vim settings (options, keymaps, autocmds)
│   │   ├── ui/                  # Visual (colorscheme, statusline, icons)
│   │   ├── treesitter/          # Syntax highlighting
│   │   ├── lsp/                 # Language servers
│   │   ├── completion/          # Auto-completion
│   │   ├── navigation/          # File navigation (Telescope, Tree)
│   │   ├── git/                 # Git integration
│   │   ├── debug/               # DAP debugging
│   │   ├── test/                # Testing framework
│   │   ├── ai/                  # AI integration
│   │   └── editor/              # Editor enhancements
│   └── spec/                    # Test suite (busted)
├── scripts/                     # Development scripts
└── docs/                        # Documentation
```

### Module Pattern

Every feature module follows this structure:

```lua
-- modules/<name>/init.lua (orchestrator)
local M = {}

function M.setup(config)
  local merged_config = require('nvim.utils').merge_config(defaults, config)
  -- Initialize module
  return true
end

return M
```

**Key principles:**
- `init.lua` orchestrates, delegates to sub-modules
- Configuration uses `utils.merge_config()` for deep merging
- Each module exports a `setup(config)` function
- Keep files under ~130 lines (split into sub-modules if larger)
- Plugin specs live in separate `plugins.lua` files

### LSP Server Organization

LSP servers are organized by language in `modules/lsp/servers/<language>/`:

```
modules/lsp/servers/
├── lua/
│   └── lua_ls.lua              # Lua language server config
├── javascript/
│   └── ts_ls.lua               # TypeScript/JavaScript server
├── python/
│   └── pyright.lua             # Python server
└── ...
```

Each server file exports:
```lua
return {
  settings = { ... },           # LSP-specific settings
  on_attach = function(...) end -- Optional attach handler
}
```

## Development Workflow

### Essential Commands

```bash
# Testing
./scripts/test.sh                    # Run all tests (786 tests)
./scripts/test.sh --tags=unit        # Unit tests only
./scripts/test.sh --tags=integration # Integration tests only

# Linting & Formatting
./scripts/lint-check.sh              # Lint staged files
./scripts/auto-fix.sh                # Fix formatting issues
./scripts/auto-fix.sh --check        # Check formatting (dry run)
./scripts/type-check.sh              # Type checking

# Pre-commit Hooks
./scripts/install-hooks.sh           # Install git hooks
```

### Test-Driven Development (TDD)

**Always write tests first:**

1. Create `*_spec.lua` in `spec/unit/` or `spec/integration/`
2. Use tags: `#unit` or `#integration`
3. Mock vim API via `spec_helper.lua`
4. Run tests with `./scripts/test.sh`

**Test structure:**
```lua
describe('modules.example #unit', function()
  before_each(function()
    package.loaded['modules.example'] = nil
  end)

  it('should do something', function()
    local module = require('modules.example')
    assert.is_true(module.setup({}))
  end)
end)
```

### Pre-commit Checks

Installed hooks run automatically on `git commit`:
1. **Lint checks** - luacheck, eslint, ruff, rubocop, markdownlint, shellcheck
2. **Type checks** - TypeScript, Python
3. **Format checks** - stylua, prettier, shfmt

**Bypass (not recommended):** `git commit --no-verify`

### CI/CD Workflows

**PR Checks** (`.github/workflows/lint-pr.yml`):
- Runs only when relevant files change (`.md`, `.sh`, `.ts`, `.js`, `.json`, `.lua`)
- Lints only changed files
- Checks formatting on changed files
- Fast feedback loop

**Full Lua Checks** (`.github/workflows/lint-and-type-check.yml`):
- Runs only when Lua files or configs change
- Full luacheck linting
- Full stylua format checking

**Tests** (`.github/workflows/test.yml`):
- Runs all 786 tests
- Ubuntu-based environment

## Code Conventions

### Configuration Merging

**Always use** `utils.merge_config()` for deep merging:
```lua
local utils = require('nvim.utils')
local merged = utils.merge_config(default_config, user_config)
```

**Never** manually merge tables with `vim.tbl_deep_extend()`.

### Module Loading

Use `module_loader` for dynamic loading with error handling:
```lua
local loader = require('nvim.core.module_loader')
local success = loader.load('modules.lsp')
```

### File Size Limits

- Keep modules under ~130 lines
- Split larger modules into focused sub-files (like LSP does)
- Use `init.lua` as orchestrator, delegate to sub-modules

### Error Handling

- Framework modules return boolean success indicators
- User-facing modules should gracefully degrade if dependencies missing
- Use `vim.notify()` for user-facing errors

### Plugin Specifications

Define in separate `plugins.lua` files using lazy.nvim format:
```lua
return {
  {
    'plugin/name',
    dependencies = { 'other/plugin' },
    config = function()
      -- Setup
    end
  }
}
```

## Language-Specific Setup

### Adding New LSP Servers

1. Create `modules/lsp/servers/<language>/<server_name>.lua`
2. Export server configuration:
   ```lua
   return {
     settings = { ... },
     on_attach = function(client, bufnr) end
   }
   ```
3. Add to `ensure_installed` in `modules/lsp/config.lua`
4. Write integration test in `spec/integration/modules/lsp_spec.lua`

### Linters & Formatters

**Installed via `install.sh`:**
- **TypeScript/JS:** eslint, prettier
- **Python:** ruff, mypy, black
- **Ruby:** rubocop (+ performance, rspec extensions)
- **Lua:** luacheck, stylua
- **Markdown:** markdownlint-cli, prettier
- **JSON:** prettier
- **Shell:** shellcheck, shfmt

**Configuration files:**
- `.luacheckrc` - Lua linter config
- `.stylua.toml` - Lua formatter config
- `.eslintrc.json` - TypeScript/JS linter
- `.prettierrc` - TypeScript/JS/JSON/Markdown formatter
- `pyproject.toml` - Python tools config

## Project State

**Completed Phases (14/14):**
1. ✅ Foundation & TDD Infrastructure (310 tests)
2. ✅ Core Module (170 tests)
3. ✅ UI & Visual (11 tests)
4. ✅ TreeSitter (37 tests)
5. ✅ LSP System (47 tests)
6. ✅ Completion (33 tests)
7. ✅ Navigation & Search (57 tests)
8. ✅ Git Integration (21 tests)
9. ✅ Debugging/DAP (30 tests)
10. ✅ Testing Framework (30 tests)
11. ✅ AI Integration (18 tests)
12. ✅ Editor Enhancements (22 tests)
13. ✅ Documentation & Polish
14. ✅ CI/CD & Distribution

**Total:** 786 tests, 100% pass rate

**Current Focus:** Maintenance and bug fixes

## Common Patterns

### Loading a Module

```lua
local core = require('modules.core')
core.setup({
  line_numbers = true,
  relative_numbers = true
})
```

### Adding Keymaps

```lua
-- In modules/<name>/keymaps.lua
local map = vim.keymap.set

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { desc = 'Go to definition' })
```

### Creating Autocommands

```lua
-- In modules/<name>/autocmds.lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function()
    vim.opt_local.shiftwidth = 2
  end
})
```

## Troubleshooting

### Tests Failing
1. Check busted is installed: `luarocks list | grep busted`
2. Run specific test: `./scripts/test.sh lua/spec/unit/<file>_spec.lua`
3. Check test tags: Tests should have `#unit` or `#integration`

### LSP Not Attaching
1. Check Mason: `:Mason` in NeoVim
2. Verify server installed: `:LspInfo`
3. Check server config in `modules/lsp/servers/<language>/`

### Linting Errors
1. Run lint manually: `./scripts/lint-check.sh`
2. Auto-fix: `./scripts/auto-fix.sh`
3. Check tool installed: `which luacheck`, `which eslint`, etc.

## Key Files Reference

- `init.lua` - Entry point, bootstraps framework
- `lua/nvim/bootstrap.lua` - Plugin manager setup
- `lua/modules/*/init.lua` - Module orchestrators
- `lua/modules/lsp/servers/` - LSP server configs
- `scripts/test.sh` - Test runner
- `scripts/lint-check.sh` - Linting tool
- `scripts/auto-fix.sh` - Auto-formatter
- `scripts/install-hooks.sh` - Git hook installer
- `.luacheckrc` - Lua linter configuration
- `.stylua.toml` - Lua formatter configuration

## Documentation

- `README.md` - User guide and quick start
- `docs/KEYMAPS.md` - Complete keymap reference
- `docs/ARCHITECTURE.md` - Design and module system
- `docs/TROUBLESHOOTING.md` - Common issues and solutions
- `docs/DEVELOPMENT_HISTORY.md` - Historical development context (see CLAUDE.md)
- `TESTING.md` - Testing guide and best practices

## Notes for AI Assistants

- This is a **working, production-ready** configuration (not a work-in-progress)
- All code follows **strict TDD** - write tests before implementation
- Maintain the **modular architecture** - don't create monolithic files
- Use **existing utilities** (`utils.merge_config`, `module_loader`)
- Keep **file sizes small** (~130 lines max)
- Follow **naming conventions** (snake_case for files, functions)
- Tests must use **tags** (`#unit` or `#integration`)
- **Never** break existing tests - maintain 100% pass rate

---

*This file follows the [agents.md](https://agents.md) standard for universal AI assistant compatibility.*
