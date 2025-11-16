# NeoVim IDE Configuration - AI Agent Context

> **Universal AI assistant context** for Claude Code, GitHub Copilot, Cursor, Aider, and other AI coding tools.

## Project Overview

A **production-ready, test-driven NeoVim IDE configuration** built from scratch with:

- **Pure Lua** configuration (no VimScript)
- **Test-Driven Development** with 811 passing tests
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

```text
nvim_config/
├── AGENTS.md                    # This file - AI context
├── init.lua                     # Entry point
├── lua/
│   ├── nvim/                    # Core framework
│   │   ├── core/                # Core systems
│   │   │   ├── module_loader.lua    # Dynamic module loading
│   │   │   ├── config_schema.lua    # Configuration validation
│   │   │   ├── event_bus.lua        # Event system
│   │   │   └── plugin_system.lua    # Plugin management
│   │   ├── lib/                 # Shared libraries
│   │   │   ├── utils.lua            # Utility functions
│   │   │   └── validator.lua        # Input validation
│   │   ├── init.lua             # Framework initialization
│   │   └── setup.lua            # Plugin manager setup (lazy.nvim)
│   ├── modules/                 # Feature modules
│   │   ├── core/                # Vim settings (options, keymaps, autocmds)
│   │   ├── ui/                  # Visual (colorscheme, statusline, icons)
│   │   ├── treesitter/          # Syntax highlighting
│   │   ├── lsp/                 # Language servers (15+ servers)
│   │   ├── completion/          # Auto-completion
│   │   ├── navigation/          # File navigation (Telescope, Tree)
│   │   ├── git/                 # Git integration
│   │   ├── debug/               # DAP debugging
│   │   ├── test/                # Testing framework
│   │   ├── ai/                  # AI integration
│   │   └── editor/              # Editor enhancements
│   └── spec/                    # Test suite (busted)
│       ├── unit/                # Unit tests (fast, isolated)
│       ├── integration/         # Integration tests
│       └── spec_helper.lua      # Test utilities and mocks
├── .busted                      # Busted test configuration
├── spec_helper.lua              # Lua path setup for tests
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

```text
modules/lsp/servers/
├── angular/        # Angular language server
├── bash/           # Bash language server
├── copilot/        # GitHub Copilot LSP
├── emmet/          # Emmet for HTML/CSS
├── go/             # Go language server
├── javascript/     # TypeScript/JavaScript (ts_ls)
├── json/           # JSON language server
├── lua/            # Lua language server (lua_ls)
├── markdown/       # Markdown language server
├── postgresql/     # PostgreSQL language server
├── python/         # Python language server (pyright)
├── ruby/           # Ruby language server (solargraph)
├── rust/           # Rust language server (rust_analyzer)
├── toml/           # TOML language server
└── yaml/           # YAML language server
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
# Testing (using busted directly - no wrapper scripts)
mise exec -- bash -c 'eval "$(luarocks path)" && busted'  # Run all 811 tests
busted --tags=unit                   # Unit tests only
busted --tags=integration            # Integration tests only
busted lua/spec/unit/<file>_spec.lua # Run specific test file
busted --coverage                    # Run with coverage

# Linting
luacheck lua/                        # Lint Lua code
stylua --check lua/                  # Check Lua formatting
stylua lua/                          # Fix Lua formatting

# Installation
./install.sh                         # Full installation
./install.sh -y                      # Auto-confirm all prompts
./install.sh --help                  # Show all options
```

### Test-Driven Development (TDD)

**Always write tests first:**

1. Create `*_spec.lua` in `lua/spec/unit/` or `lua/spec/integration/`
2. Use tags: `#unit` or `#integration`
3. Mock vim API via `spec.spec_helper`
4. Run tests with `busted` or via mise

**Test structure:**

```lua
describe('modules.example #unit', function()
  local spec_helper = require('spec.spec_helper')

  before_each(function()
    spec_helper.setup()  -- Sets up vim mocks
    package.loaded['modules.example'] = nil
  end)

  after_each(function()
    spec_helper.teardown()  -- Cleans up
  end)

  it('should do something', function()
    local module = require('modules.example')
    assert.is_true(module.setup({}))
  end)
end)
```

### Pre-commit Hooks

Uses **lefthook** for git hooks (`.git/hooks/pre-commit`). Configuration in
`lefthook.yml` runs quality checks on staged files before commits:

- Lua code with luacheck
- Lua formatting with stylua
- Shell scripts with shellcheck

**Bypass (not recommended):** `git commit --no-verify`

**Setup:** Hooks are installed automatically by lefthook during development

### CI/CD Workflows

**Lint Lua** (`.github/workflows/lint-lua.yml`):

- Triggers when: Lua files, `.luacheckrc`, `.stylua.toml`, or workflow file changes
- Runs: `luacheck lua/` and `stylua --check lua/`
- Uses: Minimal mise config (Lua + stylua only)

**Lint Shell** (`.github/workflows/lint-shell.yml`):

- Triggers when: Shell scripts (`*.sh`) change
- Runs: `shellcheck` with severity=warning
- Quick validation of shell script quality

**Validate Schemas** (`.github/workflows/validate-schemas.yml`):

- Validates JSON and YAML configuration schemas
- Ensures config files are well-formed

**Tests** (`.github/workflows/test.yml`):

- Triggers: After Lint Lua, Lint Shell, and Validate Schemas workflows complete successfully
- Runs: All 811 tests with busted
- Uses: Minimal mise config (Lua 5.1.5 + LuaJIT 2.1)
- Ubuntu-based environment

## Code Conventions

### Configuration Merging

**Always use** `utils.merge_config()` for deep merging:

```lua
local utils = require('nvim.lib.utils')
local merged = utils.merge_config(default_config, user_config)
```

**Note:** `utils` is located at `nvim.lib.utils`, not directly in `nvim.utils`.

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

**Total:** 811 tests, 100% pass rate

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
2. Check Lua path setup: `spec_helper.lua` should exist at project root
3. Run specific test: `busted lua/spec/unit/<file>_spec.lua`
4. Check test tags: Tests should have `#unit` or `#integration`
5. Verify mise environment: `mise exec -- lua -v`

### LSP Not Attaching

1. Check Mason: `:Mason` in NeoVim
2. Verify server installed: `:LspInfo`
3. Check server config in `modules/lsp/servers/<language>/`
4. View LSP logs: `:LspLog`

### Linting Errors

1. Run lint manually: `luacheck lua/`
2. Check formatting: `stylua --check lua/`
3. Auto-fix formatting: `stylua lua/`
4. Check tool installed: `which luacheck`, `which stylua`, etc.

## Key Files Reference

- `init.lua` - Entry point, bootstraps framework
- `lua/nvim/setup.lua` - Plugin manager setup (lazy.nvim)
- `lua/nvim/init.lua` - Framework initialization
- `lua/nvim/core/module_loader.lua` - Dynamic module loading
- `lua/nvim/lib/utils.lua` - Utility functions
- `lua/modules/*/init.lua` - Module orchestrators
- `lua/modules/lsp/servers/` - LSP server configs (15+ languages)
- `lua/spec/spec_helper.lua` - Test utilities and vim mocks
- `spec_helper.lua` - Lua path setup for tests (project root)
- `.busted` - Busted test runner configuration
- `.luacheckrc` - Lua linter configuration
- `.stylua.toml` - Lua formatter configuration
- `.mise.toml` - Development environment configuration
- `lefthook.yml` - Git hooks configuration (pre-commit)
- `install.sh` - Installation script

## Documentation

- `README.md` - User guide, installation, and quick start
- `AGENTS.md` - This file - Universal AI assistant context
- `TESTING.md` - Testing guide and best practices
- `VIMRC_MIGRATION.md` - Migration guide from traditional vimrc
- `docs/KEYMAPS.md` - Complete keymap reference
- `docs/ARCHITECTURE.md` - Design and module system
- `docs/TROUBLESHOOTING.md` - Common issues and solutions

## Notes for AI Assistants

- This is a **working, production-ready** configuration (not a work-in-progress)
- All code follows **strict TDD** - write tests before implementation
- Maintain the **modular architecture** - don't create monolithic files
- Use **existing utilities** (`utils.merge_config`, `module_loader`)
- Keep **file sizes small** (~130 lines max)
- Follow **naming conventions** (snake_case for files, functions)
- Tests must use **tags** (`#unit` or `#integration`)
- **Never** break existing tests - maintain 100% pass rate

### Performance Guidelines

- **Always lazy-load plugins** - Use `event`, `cmd`, `keys`, or `ft` triggers
- **Never use `lazy = false`** unless absolutely necessary (colorscheme, critical plugins)
- **Prefer deferred loading** - Use `vim.schedule()` or `vim.defer_fn()` for non-critical setup
- **Profile changes** - Use `:Lazy profile` in NeoVim to measure plugin load times
- **Target: <100ms startup** - Current average: 62ms (best: 45ms)
- **Common lazy-loading patterns:**
  - UI components: `event = 'UIEnter'` or `event = 'VeryLazy'`
  - File operations: `event = 'BufReadPost'` or `event = 'BufNewFile'`
  - Insert mode: `event = 'InsertEnter'`
  - Language-specific: `ft = { 'lua', 'javascript', ... }`
  - Commands: `cmd = { 'CommandName' }`
  - Keymaps: `keys = { '<leader>x', ... }`

---

*This file follows the [agents.md](https://agents.md) standard for universal AI assistant compatibility.*
