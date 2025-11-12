# Development Scripts

This directory contains reusable scripts for code quality checks that work across multiple contexts: Claude Code hooks, git hooks, CI/CD pipelines, and manual development.

## Available Scripts

### 🔍 lint-check.sh
Runs appropriate linters on code files based on their extension.

**Supported languages:**
- **Lua**: luacheck
- **TypeScript/JavaScript**: eslint (with Prettier integration)
- **Python**: ruff
- **Ruby**: rubocop
- **Go**: golangci-lint
- **Rust**: cargo clippy
- **Markdown**: markdownlint

**Usage:**
```bash
# Check specific file
./scripts/lint-check.sh path/to/file.lua

# Check all staged git files
./scripts/lint-check.sh

# From Claude Code hooks (automatic)
# Configured in .claude/settings.json
```

### 🔍 type-check.sh
Performs static type checking for statically-typed languages.

**Supported languages:**
- **TypeScript**: tsc --noEmit
- **Python**: mypy
- **Rust**: cargo check
- **Go**: go build
- **Lua**: Informational only (consider teal for static typing)

**Usage:**
```bash
# Check specific file
./scripts/type-check.sh path/to/file.ts

# Check all staged git files
./scripts/type-check.sh

# From Claude Code hooks (automatic)
# Configured in .claude/settings.json
```

### 🔧 auto-fix.sh
Automatically fixes linting and formatting issues using formatters and auto-fixers.

**Supported formatters:**
- **Lua**: stylua
- **TypeScript/JavaScript**: Prettier + ESLint --fix
- **Python**: ruff format + ruff check --fix
- **Ruby**: rubocop --autocorrect
- **Go**: gofmt
- **Rust**: cargo fmt
- **Markdown**: markdownlint --fix

**Usage:**
```bash
# Fix specific file
./scripts/auto-fix.sh path/to/file.lua

# Fix all staged git files
./scripts/auto-fix.sh

# Fix all files in project
./scripts/auto-fix.sh --all

# Check what would be fixed (dry run)
./scripts/auto-fix.sh --check
```

**Note**: This script modifies files in place. Always commit your work first!

### 🪝 pre-commit-hook.sh
Git pre-commit hook that runs both lint and type checks before allowing commits.

**Installation:**
```bash
# Install as git hook
ln -sf ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit

# Or run manually
./scripts/pre-commit-hook.sh
```

**Bypass (when needed):**
```bash
git commit --no-verify
```

## Integration Points

### 1. Claude Code Hooks
**Location**: `.claude/settings.json`

These scripts automatically run when you Edit or Write files through Claude Code, providing immediate feedback on code quality.

**Configuration:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/lint-check.sh \"$CLAUDE_TOOL_INPUT\"",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/type-check.sh \"$CLAUDE_TOOL_INPUT\"",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### 2. Git Hooks
**Location**: `.git/hooks/pre-commit` (symlinked from `scripts/pre-commit-hook.sh`)

Automatically checks all staged files before each commit.

**Install:**
```bash
ln -sf ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
```

### 3. CI/CD (GitHub Actions)
**Location**: `.github/workflows/lint-and-type-check.yml`

Runs on every push and pull request to main/develop branches.

**Features:**
- Installs all necessary tools via mise
- Runs lint checks
- Runs type checks
- Runs tests with coverage
- Uploads coverage reports

### 4. Manual Development
Run scripts directly during development:

```bash
# Quick lint check before committing
./scripts/lint-check.sh

# Type check your changes
./scripts/type-check.sh

# Full pre-commit validation
./scripts/pre-commit-hook.sh
```

## Exit Codes

All scripts use consistent exit codes:

- **0**: Success - All checks passed
- **2**: Blocking error - Checks failed, should block operation
- **1**: Non-blocking error - Tool not found, file skipped

This makes them work seamlessly with:
- Claude Code hooks (exit 2 blocks the operation)
- Git hooks (non-zero exits prevent commits)
- CI/CD pipelines (non-zero exits fail the build)

## Installing Required Tools

All tools can be installed automatically via `./install.sh`, or manually as shown below:

### Lua
```bash
# Linter
luarocks install luacheck

# Formatter (via cargo)
cargo install stylua
```

### TypeScript/JavaScript
```bash
# Linter and type checker with Prettier integration
npm install -g eslint typescript \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  prettier \
  eslint-config-prettier \
  eslint-plugin-prettier
```

**ESLint + Prettier Integration**:
The configuration ensures ESLint and Prettier work together without conflicts:
- `.eslintrc.json` uses `plugin:prettier/recommended`
- ESLint defers formatting rules to Prettier
- Both tools run automatically during lint and auto-fix

### Python
```bash
# Linter, formatter, and type checker
pip install ruff mypy black
```

### Ruby
```bash
gem install rubocop
```

### Go
```bash
# Linter (gofmt is included with Go)
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
```

### Rust
```bash
# Included with cargo
rustup component add clippy
```

### Markdown
```bash
npm install -g markdownlint-cli
```

## Customization

### Adding New Languages

1. **Edit lint-check.sh**:
   ```bash
   check_newlang() {
     local file="$1"
     # Add your linter logic here
   }

   # Add to file processing
   *.newext)
     check_newlang "$file"
     ;;
   ```

2. **Edit type-check.sh**:
   ```bash
   check_newlang_project() {
     # Add your type checker logic here
   }
   ```

3. **Update this README** with the new language support.

### Adjusting Strictness

Edit the individual linter/type checker commands in the scripts to adjust flags:

```bash
# More strict
luacheck "$file" --std max --max-line-length 80

# Less strict
luacheck "$file" --ignore 212 213
```

## Troubleshooting

### Scripts not executing in Claude Code

1. Check `.claude/settings.json` exists and is valid JSON
2. Verify scripts are executable: `chmod +x scripts/*.sh`
3. Check script paths use `$CLAUDE_PROJECT_DIR`

### Git hook not running

1. Ensure symlink is correct: `ls -la .git/hooks/pre-commit`
2. Make sure hook is executable: `chmod +x .git/hooks/pre-commit`
3. Test manually: `./scripts/pre-commit-hook.sh`

### Linter/Type checker not found

1. Install the required tool (see "Installing Required Tools" above)
2. Verify it's in PATH: `which luacheck` (or appropriate tool)
3. Scripts will show warning but not fail if tools are missing

### CI/CD failures

1. Check GitHub Actions logs for specific errors
2. Verify mise installs all required tools
3. Test scripts locally first: `./scripts/lint-check.sh && ./scripts/type-check.sh`

## Philosophy

These scripts embody several principles:

1. **Reusability**: One script, multiple contexts
2. **Fail Fast**: Catch issues early in development
3. **Flexibility**: Graceful degradation when tools are missing
4. **Clarity**: Clear, colored output with helpful messages
5. **Standards**: Consistent exit codes and behavior

By integrating quality checks at every level (Claude Code, git, CI/CD), we ensure high code quality without manual intervention.
