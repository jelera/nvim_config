# Neovim IDE Framework

A modular, three-layer Neovim configuration providing a complete IDE experience (~22,000+ lines of Lua).

## Architecture

- **Framework Layer** (`lua/nvim/`): Core infrastructure with module loading, utilities, and validation
- **Module Layer** (`lua/modules/`): 13 feature modules (LSP, completion, treesitter, git, debug, etc.)
- **Bootstrap Layer** (`init.lua`): Orchestrates lazy.nvim plugin loading and module initialization

## Features

- Project-aware LSP with intelligent server activation
- Treesitter-powered syntax highlighting and text objects
- Advanced completion with snippet support
- Integrated testing and debugging
- Git integration with visual diff and blame
- AI assistance integration
- Framework-specific tooling (Rails, Angular)
- Quality of life improvements (auto-save, cursor restore, etc.)

## Installation

```bash
# Clone to Neovim config directory
git clone <repo-url> ~/.config/nvim

# Install dependencies
mise install

# Setup git hooks
lefthook install

# Launch Neovim (plugins install automatically)
nvim
```

## Development

```bash
# Run tests
busted                          # All tests
busted lua/spec/unit           # Unit tests only
busted --coverage              # With coverage

# Lint
luacheck lua/                  # Lua linting
prettier --check .             # JSON/YAML formatting
markdownlint .                 # Markdown linting

# Git workflow
git commit                     # Auto-runs pre-commit checks
```

## Module Structure

Each module follows a consistent pattern:

```text
lua/modules/mymodule/
├── init.lua        # Main setup orchestrator
├── plugins.lua     # Lazy.nvim plugin specs
├── config.lua      # Module configuration
└── keymaps.lua     # Keybindings (optional)
```

## Documentation

See [AGENTS.md](./AGENTS.md) for comprehensive development guidance, architecture patterns, testing conventions, and troubleshooting.

## Requirements

- Neovim >= 0.9.0
- [mise](https://mise.jdx.dev/) for dependency management
- [lefthook](https://github.com/evilmartians/lefthook) for git hooks
