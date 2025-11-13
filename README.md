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
- **System packages**: Git, luarocks, ripgrep, fd, lazygit, bat, delta, eza, fzf, gh, jq, tree, shellcheck, shfmt
- **Linters & Formatters**:
  - TypeScript/JavaScript: eslint, prettier
  - Python: ruff, mypy, black
  - Ruby: rubocop (+ performance, rspec extensions)
  - Lua: stylua
  - Markdown: markdownlint-cli, prettier
  - JSON: prettier
  - Shell: shellcheck, shfmt
- **AI Tools**: aider-chat (AI pair programming)
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

## Development Workflow

### Pre-commit Hooks

Automatically check code quality before commits:

```bash
# Install git hooks
./scripts/install-hooks.sh
```

The pre-commit hook runs:
1. **Lint checks** - luacheck, eslint, ruff, rubocop, markdownlint, shellcheck
2. **Type checks** - TypeScript, Python
3. **Format checks** - stylua, prettier, shfmt

**Auto-fix formatting issues:**
```bash
./scripts/auto-fix.sh          # Fix staged files
./scripts/auto-fix.sh --all    # Fix all files
./scripts/auto-fix.sh --check  # Dry run (check only)
```

**Manual linting:**
```bash
./scripts/lint-check.sh        # Lint staged files
./scripts/type-check.sh        # Type check staged files
```

**Bypass hook (not recommended):**
```bash
git commit --no-verify
```

### Testing

```bash
# Run all tests
./scripts/test.sh

# Run by tag
./scripts/test.sh --tags=integration

# Run specific module
./scripts/test.sh lua/spec/integration/modules/lsp_spec.lua
```

See [TESTING.md](TESTING.md) for detailed testing guide.

### CI/CD

Automated checks run on every PR (only when relevant files change):

**PR Checks** (`.github/workflows/lint-pr.yml`):
- Triggers only when code files change (`.md`, `.sh`, `.ts`, `.js`, `.json`, `.lua`)
- Lints only changed files (Markdown, Shell, TS/JS, Lua)
- Checks formatting on changed files (JSON, TS/JS, Shell, Lua)
- Fast feedback on incremental changes

**Full Lua Checks** (`.github/workflows/lint-and-type-check.yml`):
- Triggers only when Lua files or config change (`.lua`, `.luacheckrc`, `.stylua.toml`)
- Full Lua linting with luacheck
- Full Lua format checking with stylua
- Runs on push to main and PRs

**Tests** (`.github/workflows/test.yml`):
- Runs full test suite (786 tests)
- Ubuntu-based CI environment
- Runs on all PRs and pushes to main

## AI Assistant Support

This project supports multiple AI coding assistants through the **[agents.md](https://agents.md) standard**:

**Supported Tools:**
- ✅ **Claude Code** - Auto-reads `AGENTS.md`, configured hooks in `.claude/`
- ✅ **GitHub Copilot** - Reads `.github/copilot-instructions.md` (references `AGENTS.md`)
- ✅ **Cursor** - Auto-reads `AGENTS.md`
- ✅ **Aider** - Pre-installed! Configured via `.aider.conf.yml` to read `AGENTS.md`
- ✅ **OpenAI Codex, Gemini CLI, Zed** - All support `AGENTS.md`

**Using Aider:**
```bash
aider               # Start Aider (auto-reads AGENTS.md for context)
aider --help        # See all options
```

**Context Files:**
- `AGENTS.md` - Universal AI context (architecture, patterns, workflows)
- `docs/DEVELOPMENT_HISTORY.md` - Historical development context (former `CLAUDE.md`)

See [`AGENTS.md`](AGENTS.md) for complete project context and development guidelines.

## Documentation

- [AGENTS.md](AGENTS.md) - AI assistant context and development guidelines
- [KEYMAPS.md](docs/KEYMAPS.md) - Complete keymap reference
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Design and module system
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues
- [TESTING.md](TESTING.md) - Testing guide
- [DEVELOPMENT_HISTORY.md](docs/DEVELOPMENT_HISTORY.md) - Development history

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
