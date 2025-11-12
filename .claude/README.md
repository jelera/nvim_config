# Claude Code Hooks Configuration

This directory contains Claude Code hooks configuration that automatically runs code quality checks when files are edited or written through Claude Code.

## Configured Hooks

### PostToolUse: Edit|Write

When Claude Code edits or writes files, the following checks run automatically:

1. **Lint Check** (`scripts/lint-check.sh`)
   - Validates code style and quality
   - Exit code 2 blocks the operation if linting fails

2. **Type Check** (`scripts/type-check.sh`)
   - Validates static types for typed languages
   - Exit code 2 blocks the operation if type errors found

## Supported Languages

| Language | Linter | Type Checker | Formatter |
|----------|--------|--------------|-----------|
| **Lua** | luacheck | LSP-based | stylua |
| **TypeScript/JS** | ESLint | tsc | Prettier |
| **Python** | ruff | mypy | ruff/black |
| **Ruby** | rubocop | - | rubocop |
| **Go** | golangci-lint | go build | gofmt |
| **Rust** | cargo clippy | cargo check | cargo fmt |
| **Markdown** | markdownlint | - | markdownlint |

## ESLint + Prettier Integration

The project is configured to use ESLint and Prettier together without conflicts:

- **`.eslintrc.json`**: Extends `plugin:prettier/recommended`
- **`.prettierrc`**: Defines formatting rules (100 char line length, 2 spaces, etc.)
- ESLint handles code quality, Prettier handles formatting
- Both tools respect each other's domain

## GitHub-Friendly Configuration

All configurations follow GitHub conventions and best practices:

- **Line endings**: LF (Unix-style)
- **Indentation**: 2 spaces
- **Line length**: 100-120 characters
- **Markdown**: Supports GitHub-flavored Markdown (details, summary, etc.)

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
