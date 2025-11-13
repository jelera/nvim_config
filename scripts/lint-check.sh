#!/bin/bash
#
# Lint Check Script
# =================
# Checks code quality for modified files using appropriate linters.
#
# Usage:
#   ./scripts/lint-check.sh "$CLAUDE_TOOL_INPUT"  # From Claude Code hooks
#   ./scripts/lint-check.sh path/to/file.lua      # Direct file check
#   ./scripts/lint-check.sh                        # Check all staged files (for git hooks)
#
# Exit codes:
#   0 - Success (lint passed)
#   2 - Blocking error (lint failed, should block commit/operation)
#   1 - Non-blocking error (linter not found, file skipped)
#
# Can be used in:
#   - Claude Code hooks (.claude/settings.json)
#   - Git pre-commit hooks
#   - CI/CD pipelines (GitHub Actions, GitLab CI, etc.)
#   - Manual development workflow
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine file path
FILE_PATH=""

if [ $# -eq 0 ]; then
  # No arguments: check all staged git files
  if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${BLUE}🔍 Checking staged files...${NC}"
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)
    if [ -z "$STAGED_FILES" ]; then
      echo -e "${YELLOW}⚠️  No staged files to check${NC}"
      exit 0
    fi
  else
    echo -e "${YELLOW}⚠️  Not a git repository and no file specified${NC}"
    exit 0
  fi
elif [ $# -eq 1 ]; then
  # Check if argument is JSON (from Claude Code) or a file path
  if echo "$1" | grep -q '"file_path"'; then
    # Extract file path from JSON
    FILE_PATH=$(echo "$1" | grep -o '"file_path":\s*"[^"]*"' | sed 's/"file_path":\s*"\([^"]*\)"/\1/')
    if [ -z "$FILE_PATH" ]; then
      # Could be new_string for Edit tool - try to extract from that
      exit 0
    fi
  else
    # Direct file path argument
    FILE_PATH="$1"
  fi
  STAGED_FILES="$FILE_PATH"
else
  # Multiple file arguments
  STAGED_FILES="$*"
fi

# Track if any lints failed
LINT_FAILED=0

# Function to check Lua files
check_lua() {
  local file="$1"

  if ! command -v luacheck &> /dev/null; then
    echo -e "${YELLOW}⚠️  luacheck not found. Install with: luarocks install luacheck${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running luacheck on $file...${NC}"

  if luacheck "$file" 2>&1; then
    echo -e "${GREEN}✅ Lua lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Lua lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check TypeScript/JavaScript files
check_typescript() {
  local file="$1"

  if ! command -v eslint &> /dev/null; then
    echo -e "${YELLOW}⚠️  eslint not found. Install with: npm install -g eslint${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running eslint on $file...${NC}"

  if eslint "$file" 2>&1; then
    echo -e "${GREEN}✅ TypeScript/JS lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ TypeScript/JS lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check Python files
check_python() {
  local file="$1"

  if ! command -v ruff &> /dev/null; then
    echo -e "${YELLOW}⚠️  ruff not found. Install with: pip install ruff${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running ruff on $file...${NC}"

  if ruff check "$file" 2>&1; then
    echo -e "${GREEN}✅ Python lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Python lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check Ruby files
check_ruby() {
  local file="$1"

  if ! command -v rubocop &> /dev/null; then
    echo -e "${YELLOW}⚠️  rubocop not found. Install with: gem install rubocop${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running rubocop on $file...${NC}"

  if rubocop "$file" 2>&1; then
    echo -e "${GREEN}✅ Ruby lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Ruby lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check Go files
check_go() {
  local file="$1"

  if ! command -v golangci-lint &> /dev/null; then
    echo -e "${YELLOW}⚠️  golangci-lint not found. Install from: https://golangci-lint.run/usage/install/${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running golangci-lint on $file...${NC}"

  if golangci-lint run "$file" 2>&1; then
    echo -e "${GREEN}✅ Go lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Go lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check Rust files
check_rust() {
  local file="$1"

  if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}⚠️  cargo not found. Install from: https://rustup.rs/${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running cargo clippy...${NC}"

  # Note: clippy runs on the whole project, not individual files
  if cargo clippy --all-targets --all-features -- -D warnings 2>&1; then
    echo -e "${GREEN}✅ Rust lint check passed${NC}"
    return 0
  else
    echo -e "${RED}❌ Rust lint check failed${NC}"
    return 2
  fi
}

# Function to check Markdown files
check_markdown() {
  local file="$1"

  if ! command -v markdownlint &> /dev/null; then
    echo -e "${YELLOW}⚠️  markdownlint not found. Install with: npm install -g markdownlint-cli${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running markdownlint on $file...${NC}"

  if markdownlint "$file" 2>&1; then
    echo -e "${GREEN}✅ Markdown lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Markdown lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check Shell script files
check_shell() {
  local file="$1"

  if ! command -v shellcheck &> /dev/null; then
    echo -e "${YELLOW}⚠️  shellcheck not found. Install with: brew install shellcheck (macOS) or apt install shellcheck (Ubuntu)${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Running shellcheck on $file...${NC}"

  if shellcheck "$file" 2>&1; then
    echo -e "${GREEN}✅ Shell script lint check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ Shell script lint check failed: $file${NC}"
    return 2
  fi
}

# Function to check JSON files (format check with prettier)
check_json() {
  local file="$1"

  if ! command -v prettier &> /dev/null; then
    echo -e "${YELLOW}⚠️  prettier not found. Install with: npm install -g prettier${NC}"
    return 0
  fi

  echo -e "${BLUE}🔍 Checking JSON format with prettier on $file...${NC}"

  if prettier --check "$file" 2>&1; then
    echo -e "${GREEN}✅ JSON format check passed: $file${NC}"
    return 0
  else
    echo -e "${RED}❌ JSON format check failed: $file (run prettier --write to fix)${NC}"
    return 2
  fi
}

# Process each file
for file in $STAGED_FILES; do
  # Skip if file doesn't exist (could be deleted)
  if [ ! -f "$file" ]; then
    continue
  fi

  # Determine file type and run appropriate linter
  case "$file" in
    *.lua)
      if ! check_lua "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.ts|*.tsx|*.js|*.jsx)
      if ! check_typescript "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.py)
      if ! check_python "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.rb)
      if ! check_ruby "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.go)
      if ! check_go "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.rs)
      if ! check_rust "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.md)
      if ! check_markdown "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.sh)
      if ! check_shell "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *.json)
      if ! check_json "$file"; then
        LINT_FAILED=2
      fi
      ;;
    *)
      # Unknown file type, skip
      continue
      ;;
  esac
done

# Exit with appropriate code
if [ $LINT_FAILED -eq 2 ]; then
  echo -e "${RED}❌ Lint checks failed. Please fix the issues above.${NC}"
  exit 2
else
  echo -e "${GREEN}✅ All lint checks passed${NC}"
  exit 0
fi
