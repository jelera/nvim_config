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

## Installation

### Quick Start (One-liner)

**Fully automated (recommended):**

Using curl:
```bash
curl -fsSL https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash -s -- -y
```

Using wget:
```bash
wget -qO- https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash -s -- -y
```

**Interactive (with confirmation prompts):**

Using curl:
```bash
curl -fsSL https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash
```

Using wget:
```bash
wget -qO- https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash
```

The quick-start script safely handles existing configurations by:
- Checking for existing `~/.config/nvim` before cloning
- Prompting for confirmation if config exists
- Creating automatic timestamped backups
- Running the full installation

The `-y` flag auto-confirms all prompts for a completely hands-off installation.

**Alternative: Using GitHub CLI (gh):**
```bash
# Clone to temporary location, then run installer
gh repo clone jelera/nvim_config /tmp/nvim_config && cd /tmp/nvim_config && ./install.sh
```

### Manual Installation

If you prefer to clone to a custom location:

```bash
# Clone repository to custom location
git clone https://github.com/jelera/nvim_config.git ~/my-nvim-config
cd ~/my-nvim-config

# Run installer (requires mise: https://mise.jdx.dev/)
# This will create a symlink from ~/.config/nvim to this directory
./install.sh

# Or skip prompts:
./install.sh -y
```

**What it installs:**
- **Development tools** (via mise): NeoVim, Node.js, Python, Ruby, Lua, Go, Rust
- **System packages**: Git, luarocks, ripgrep, fd, lazygit, bat, delta, eza, fzf, gh, jq, tree
- **Language packages**: npm packages, pip packages, Ruby gems, Cargo tools (stylua, delta, eza)
- **Nerd Fonts**: Hack, JetBrains Mono, Fira Code (installed by default)
- **NeoVim config**: Creates symlink to `~/.config/nvim`

**Supported platforms:**
- macOS + Homebrew
- Ubuntu 24.04 LTS + Homebrew or apt
- Ubuntu 22.04 LTS + Homebrew or apt

**Options:**
```bash
./install.sh --help              # Show all options
./install.sh -y                  # Auto-confirm all prompts
./install.sh --skip-optional     # Skip optional tools and fonts
./install.sh --verify-only       # Check what's installed
./install.sh --use-homebrew      # Force Homebrew (Linux)
./install.sh --use-apt           # Force apt (Ubuntu)
```

## Requirements

**Required:**
- NeoVim 0.10.2+
- Git 2.30+
- Node.js 18+ (for LSP servers)
- Python 3.9+ (for Python LSP)
- Lua 5.1 (bundled with NeoVim)
- luarocks (Lua package manager)

**Optional but recommended:**
- ripgrep (faster Telescope search)
- fd (faster file finding)
- lazygit (Git TUI)
- bat (better cat with syntax highlighting)
- delta (better git diffs)
- eza (better ls)
- fzf (fuzzy finder)
- gh (GitHub CLI)
- Nerd Font (icons display)

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

🎉 **ALL 14 PHASES COMPLETE** 🎉

✅ Production ready with full test coverage, documentation, and CI/CD

See [CLAUDE.md](CLAUDE.md) for complete development history.

## License

MIT
