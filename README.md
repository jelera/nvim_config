# NeoVim IDE Configuration

A modern, test-driven NeoVim configuration built from scratch with modular architecture.

## Status

**665 tests passing** | **7 phases complete** | **Phase 8 next**

### Completed Features
- ✅ Core Framework (module loader, event bus, plugin system)
- ✅ Vim Configuration (options, keymaps, autocmds, commands)
- ✅ UI & Theming (gruvbox, lualine, icons, indent guides)
- ✅ TreeSitter (syntax highlighting, code folding, text objects)
- ✅ LSP Support (9 language servers via Mason)
- ✅ Completion (nvim-cmp with LSP, snippets, buffer, path, cmdline)
- ✅ Navigation (Telescope fuzzy finder, nvim-tree explorer, keymaps)

### Next
- ⏳ Git Integration (gitsigns + fugitive + diffview)

## Quick Start

```bash
# Clone repository
git clone <repo-url> ~/.config/nvim

# Install dependencies
./install.sh

# Start NeoVim (plugins auto-install)
nvim
```

## Architecture

```
lua/
├── nvim/                    # Core Framework
│   ├── core/               # Module loader, event bus, plugin system
│   └── lib/                # Shared utilities and validators
│
├── modules/                 # Feature Modules
│   ├── core/               # Vim configuration
│   ├── ui/                 # UI & theming
│   ├── treesitter/         # Syntax highlighting
│   ├── lsp/                # Language servers
│   ├── completion/         # Auto-completion & snippets
│   └── navigation/         # Fuzzy finder & file explorer
│
└── spec/                    # Test Suite (busted)
    ├── unit/               # Unit tests
    └── integration/        # Integration tests
```

## Language Server Support

Pre-configured LSP servers for:
- **Lua** (lua_ls) - NeoVim-specific settings
- **TypeScript/JavaScript** (ts_ls) - With inlay hints
- **Python** (pyright)
- **Ruby** (solargraph)
- **Go** (gopls)
- **Rust** (rust_analyzer)
- **Bash** (bashls)
- **SQL** (sqlls)
- **Markdown** (marksman)

Add more servers via `lua/modules/lsp/servers/<language>/`

## Testing

```bash
# Run all tests
./scripts/test.sh

# Run unit tests only
./scripts/test.sh --tags=unit

# Run specific test file
./scripts/test.sh lua/spec/integration/modules/lsp_spec.lua
```

## Key Features

- **Test-Driven**: Every feature has comprehensive test coverage
- **Modular**: Small, focused modules (~130 lines max)
- **Extensible**: Easy to add new language servers and features
- **Graceful Degradation**: Works even if plugins are missing
- **Fast**: Lazy loading and optimized startup time

## Requirements

- NeoVim 0.10.2+
- Lua 5.1 (LuaJIT)
- Git 2.30+
- Node.js 18+ (for LSP servers)
- Luarocks (for testing)

### Optional
- ripgrep (faster search)
- fd (faster file finding)
- Nerd Font (icons)

## Documentation

- `CLAUDE.md` - Complete development plan and context
- `SESSION_STATUS.md` - Current progress tracking
- `TESTING.md` - Testing guide and conventions

## License

MIT
