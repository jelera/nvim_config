# NeoVim IDE Configuration

Modern, IDE-like NeoVim configuration built with TDD and modular architecture.

## Features

✅ **12 Complete Modules** | **811 Tests Passing** | **100% Success Rate**

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

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true; gh repo clone jelera/nvim_config ~/.config/nvim && cd ~/.config/nvim && ./install.sh -y
```

**Interactive (with confirmation prompts):**

```bash
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true; gh repo clone jelera/nvim_config ~/.config/nvim && cd ~/.config/nvim && ./install.sh
```

The one-liner automatically:

- Backs up existing `~/.config/nvim` to `~/.config/nvim.backup.TIMESTAMP`
- Clones this repo directly to `~/.config/nvim`
- Runs the full installation script
- Installs all dependencies and tools via mise
- Clears NeoVim cache for a clean slate

The `-y` flag auto-confirms all prompts for a completely hands-off installation.

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

**via mise** (.mise.toml):

- **Language Runtimes**: Node.js, Python, Ruby, Lua, LuaJIT, Go, Rust
- **Node.js packages**: neovim, tree-sitter-cli, eslint, typescript, prettier, markdownlint-cli, etc.
- **Python packages** (pipx): pynvim, debugpy, ruff, mypy, black, aider-chat
- **Ruby gems**: neovim, solargraph, debug, rubocop (+ extensions), standardrb
- **Rust tools** (cargo): stylua, git-delta, eza

**via system package manager** (brew/apt):

- **System tools**: Git, luarocks, ripgrep, fd, lazygit, bat, fzf, gh, jq, tree, shellcheck, shfmt
- **Lua packages** (luarocks): busted, luacheck (for testing)
- **Nerd Fonts**: Hack, JetBrains Mono, Fira Code (optional, auto-installed)

**Other:**

- **NeoVim config**: Creates symlink from `~/.config/nvim` to installation directory

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

**Tests** (`.github/workflows/test.yml`):

- Uses inline mise configuration (minimal) - only installs Lua/LuaJIT and stylua
- Runs full test suite (811 tests) with busted
- Ubuntu-based CI environment
- Runs on all PRs and pushes to main
- Fast: Avoids installing Node, Python, Ruby, Go, Rust (saves ~2-3 minutes per run)

**Lint and Format Lua** (`.github/workflows/lint-lua.yml`):

- Triggers only when Lua files change (`.lua`, `.luacheckrc`, `.stylua.toml`)
- Lints all Lua code with luacheck
- Checks formatting with stylua --check
- Uses minimal mise profile (Lua + stylua only)
- Fast feedback on code quality

**Lint Shell Scripts** (`.github/workflows/lint-shell.yml`):

- Triggers only when shell scripts change (`**.sh`)
- Lints with shellcheck (severity: warning)
- Checks all `.sh` files in the repository
- Quick validation of shell script quality

**Lint JSON Files** (`.github/workflows/lint-json.yml`):

- Triggers only when JSON files change (`**.json`, `.eslintrc.json`)
- Lints with ESLint + eslint-plugin-jsonc
- Validates JSON syntax, indentation, and formatting
- Uses mise to install Node.js and ESLint tools

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
- [PERFORMANCE.md](PERFORMANCE.md) - Performance optimization plan
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues
- [TESTING.md](TESTING.md) - Testing guide
- [DEVELOPMENT_HISTORY.md](docs/DEVELOPMENT_HISTORY.md) - Development history

## Architecture

Modular design with each feature as a self-contained module:

```text
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

- **Startup: 62ms average** (37% faster than baseline, best run: 45ms)
- 811 tests run in <1 second
- Lazy loading for 90%+ of plugins with smart event triggers
- Profile with `:ProfileStartup`, `:BenchmarkStartup`, or `:ProfilePlugins`

**Profiling Commands:**

```vim
:ProfileStartup           " Detailed startup analysis
:BenchmarkStartup [runs]  " Run benchmarks (default: 5 runs)
:ProfilePlugins           " Open lazy.nvim profiler
```

See [PERFORMANCE.md](PERFORMANCE.md) for complete optimization journey and strategies.

## Project Status

🎉 **ALL 14 PHASES COMPLETE** 🎉

✅ Production ready with full test coverage, documentation, and CI/CD

See [CLAUDE.md](CLAUDE.md) for complete development history.

## License

MIT
