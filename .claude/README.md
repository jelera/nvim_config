# Claude Code Configuration

> **Project Context:** See [`AGENTS.md`](../AGENTS.md) at repository root for complete architecture, patterns, and development guidelines.

## Hooks Configuration

This directory contains Claude Code hooks that automatically run code quality checks on file edits/writes.

### PostToolUse: Edit|Write

Configured checks:

1. **Lint Check** (`scripts/lint-check.sh`) - Blocks on linting errors
2. **Type Check** (`scripts/type-check.sh`) - Blocks on type errors

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

To automatically fix issues (not run by hooks):

```bash
# Fix specific file
./scripts/auto-fix.sh path/to/file.lua

# Fix all staged files
./scripts/auto-fix.sh

# Fix all files in project
./scripts/auto-fix.sh --all

# Dry run (check what would be fixed)
./scripts/auto-fix.sh --check
```

## Disabling Hooks Temporarily

If you need to bypass the hooks for a specific operation, you can:

1. Comment out the hook temporarily in `settings.json`
2. Or fix the issues and re-run the Claude Code operation

## Integration with Other Systems

These same scripts are used in:

- **Git pre-commit hooks**: `scripts/pre-commit-hook.sh`
- **GitHub Actions**: `.github/workflows/lint-and-type-check.yml`
- **Manual development**: Run scripts directly

This ensures consistent code quality across all workflows.

## Troubleshooting

### Hook not running

1. Verify `.claude/settings.json` exists and is valid JSON
2. Check scripts are executable: `chmod +x scripts/*.sh`
3. Ensure tools are installed: `./install.sh`

### False positives

1. Check configuration files (`.luacheckrc`, `.eslintrc.json`, etc.)
2. Adjust rules as needed for your project
3. Add ignore patterns for generated/third-party code

### Tool not found

Run the installation script to install all required tools:

```bash
./install.sh
```

Or install specific tools manually (see `scripts/README.md`).
