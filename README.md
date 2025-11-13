# NeoVim IDE Configuration

Modern, IDE-like NeoVim configuration built with TDD and modular architecture.

## Features

✅ **12 Complete Modules** | **786 Tests Passing** | **100% Success Rate**

- **Core**: Vim options, keymaps, autocmds, commands
- **UI**: Colorscheme, statusline, icons, indent guides, notifications
- **TreeSitter**: Syntax highlighting, folding, text objects
- **LSP**: 9 language servers with Mason
- **Completion**: nvim-cmp with LSP, snippets, buffer, path, cmdline
- **Navigation**: Telescope fuzzy finder + nvim-tree explorer
- **Git**: Gitsigns, fugitive, diffview
- **Debug**: DAP with 4 language adapters (JS/TS, Python, Ruby, Lua)
- **Testing**: Neotest with Jest, Karma, pytest, RSpec
- **AI**: Sidekick.nvim (Copilot NES + AI terminal)
- **Editor**: Auto-pairs, surround, comment, project, session management

## Quick Start

```bash
# Clone repository
git clone <repo-url> ~/.config/nvim

# Start NeoVim (plugins auto-install)
nvim

# Check health
:checkhealth
```

## Requirements

- NeoVim 0.10.2+
- Git 2.30+
- Node.js 18+ (for LSP servers)

**Optional:**
- ripgrep (faster search)
- fd (faster file finding)
- Nerd Font (icons)

## Key Bindings

Leader key: `,`

**Quick Reference:**
- `<C-p>g` - Find files
- `<leader>rg` - Live grep
- `<C-t>` - Toggle file tree
- `gd` - Go to definition
- `<leader>ca` - Code actions
- `gcc` - Toggle comment
- `<leader>gs` - Git status
- See [docs/KEYMAPS.md](docs/KEYMAPS.md) for complete reference

## Language Support

Pre-configured LSP servers:
- Lua (lua_ls)
- TypeScript/JavaScript (ts_ls)
- Python (pyright)
- Ruby (solargraph)
- Go (gopls)
- Rust (rust_analyzer)
- Bash (bashls)
- SQL (sqlls)
- Markdown (marksman)

**Auto-install:** Servers install automatically on first file open.

## Testing

```bash
# Run all tests
./scripts/test.sh

# Run by tag
./scripts/test.sh --tags=integration

# Run specific module
./scripts/test.sh lua/spec/integration/modules/lsp_spec.lua
```

See [TESTING.md](TESTING.md) for detailed testing guide.

## Documentation

- [KEYMAPS.md](docs/KEYMAPS.md) - Complete keymap reference
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Design and module system
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues
- [TESTING.md](TESTING.md) - Testing guide
- [CLAUDE.md](CLAUDE.md) - Development plan (for future sessions)

## Architecture

Modular design with each feature as a self-contained module:

```
modules/<name>/
├── init.lua          # Orchestrator
├── <feature>.lua     # Implementation
├── keymaps.lua       # Key mappings
└── plugins.lua       # Plugin specs
```

**Key principles:**
- Test-Driven Development (TDD)
- Simple orchestrators (no state management)
- Use plugin defaults
- Lazy loading for performance
- Integration tests only

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

## Performance

- Startup: <100ms target
- 786 tests run in <1 second
- Lazy loading for all non-critical plugins
- Profile with `:Lazy profile`

## Project Status

### Phase 12 (Current)
✅ Editor Enhancements - Complete

### Next
📋 Phase 13: Documentation & Polish (in progress)
📋 Phase 14: CI/CD & Distribution

See [CLAUDE.md](CLAUDE.md) for complete development plan.

## License

MIT
