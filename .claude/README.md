# Claude Code Configuration

> **Project Context:** See [`AGENTS.md`](../AGENTS.md) at repository root for
> complete architecture, patterns, and development guidelines.

## Hooks Configuration

This directory contains Claude Code hooks that automatically run code quality checks on file edits/writes.

### PostToolUse Hooks

**Lua Files** (`*.lua`):

- **luacheck** - Lints Lua code for errors and warnings
- **stylua --check** - Checks Lua code formatting

**Shell Scripts** (`*.sh`):

- **shellcheck** - Lints shell scripts for common issues and best practices

**JSON Files** (`*.json`):

- **eslint** (with eslint-plugin-jsonc) - Validates JSON syntax and formatting

**Markdown Files** (`*.md`):

- **markdownlint** - Checks GitHub Flavored Markdown style and syntax
- **eslint** (with eslint-plugin-markdown) - Lints code blocks within Markdown
- **prettier** - Verifies Markdown formatting consistency

## Supported Languages

| Language | Linter | Type Checker | Formatter |
|----------|--------|--------------|-----------|
| **Lua** | luacheck | LSP-based | stylua |
| **TypeScript/JS** | ESLint | tsc | Prettier |
| **Python** | ruff | mypy | ruff/black |
| **Ruby** | rubocop | - | rubocop |
| **Markdown** | markdownlint | - | prettier |
| **JSON** | prettier | - | prettier |
| **Shell** | shellcheck | - | shfmt |

## Auto-Fixing

To automatically fix formatting issues:

**Lua:**

```bash
stylua lua/                    # Format all Lua files
stylua path/to/file.lua        # Format specific file
```

**Shell:**

```bash
shfmt -w install.sh            # Format shell script (if shfmt installed)
```

**Markdown:**

```bash
prettier --write docs/          # Format all markdown in docs/
prettier --write README.md      # Format specific file
markdownlint --fix README.md   # Auto-fix some markdownlint issues
```

**JSON:**

```bash
prettier --write .eslintrc.json  # Format JSON files
```

## Disabling Hooks Temporarily

If you need to bypass the hooks for a specific operation, you can:

1. Comment out the hook temporarily in `settings.json`
2. Or fix the issues and re-run the Claude Code operation

## Integration with Other Systems

The same tools are used in:

- **Claude Code hooks**: Automatic validation on file edits (this config)
- **GitHub Actions**: `.github/workflows/lint-lua.yml` and `.github/workflows/lint-shell.yml`
- **Manual development**: Run `luacheck`, `stylua`, `shellcheck` directly

This ensures consistent code quality across all workflows.

## Troubleshooting

### Hook not running

1. Verify `.claude/settings.json` exists and is valid JSON
2. Ensure tools are installed: `mise install` or check individual tools:
   - `luacheck --version`
   - `stylua --version`
   - `shellcheck --version`

### False positives

1. Check configuration files (`.luacheckrc`, `.eslintrc.json`, etc.)
2. Adjust rules as needed for your project
3. Add ignore patterns for generated/third-party code

### Tool not found

Run the installation to install all required tools:

```bash
mise install                   # Install all dev tools
./install.sh                   # Install system packages
```

Or install specific tools:

```bash
luarocks install luacheck      # Lua linter
mise install cargo:stylua      # Lua formatter
brew install shellcheck        # Shell script linter (macOS)
```
