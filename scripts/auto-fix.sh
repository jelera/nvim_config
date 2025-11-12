#!/bin/bash
#
# Auto-Fix Script
# ===============
# Automatically fixes linting and formatting issues using formatters and auto-fixers.
#
# Usage:
#   ./scripts/auto-fix.sh                        # Fix all staged files (for git hooks)
#   ./scripts/auto-fix.sh path/to/file.lua       # Fix specific file
#   ./scripts/auto-fix.sh --all                  # Fix all files in project
#   ./scripts/auto-fix.sh --check                # Check what would be fixed (dry run)
#
# Exit codes:
#   0 - Success (fixes applied or nothing to fix)
#   1 - Error (fixer not found or fix failed)
#
# Can be used in:
#   - Manual development workflow
#   - Git pre-commit hooks (optional)
#   - CI/CD pipelines (to verify code is formatted)
#
# Note: This script modifies files in place. Always commit your work first!
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Options
CHECK_ONLY=false
FIX_ALL=false

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --check)
      CHECK_ONLY=true
      shift
      ;;
    --all)
      FIX_ALL=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Determine file paths
FILE_PATHS=()

if [ "$FIX_ALL" = true ]; then
  # Find all source files
  echo -e "${BLUE}🔍 Finding all source files...${NC}"
  while IFS= read -r -d '' file; do
    FILE_PATHS+=("$file")
  done < <(find . -type f \( -name "*.lua" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" -o -name "*.md" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -print0)
elif [ $# -eq 0 ]; then
  # No arguments: fix all staged git files
  if command -v git &> /dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${BLUE}🔍 Finding staged files...${NC}"
    while IFS= read -r file; do
      [ -f "$file" ] && FILE_PATHS+=("$file")
    done < <(git diff --cached --name-only --diff-filter=ACM)

    if [ ${#FILE_PATHS[@]} -eq 0 ]; then
      echo -e "${YELLOW}⚠️  No staged files to fix${NC}"
      exit 0
    fi
  else
    echo -e "${YELLOW}⚠️  Not a git repository and no file specified${NC}"
    exit 0
  fi
else
  # Specific file(s) provided
  for arg in "$@"; do
    [ -f "$arg" ] && FILE_PATHS+=("$arg")
  done
fi

if [ ${#FILE_PATHS[@]} -eq 0 ]; then
  echo -e "${YELLOW}⚠️  No files to fix${NC}"
  exit 0
fi

echo -e "${BLUE}📝 Found ${#FILE_PATHS[@]} file(s) to process${NC}"

# Track if any fixes failed
FIX_FAILED=0
FILES_FIXED=0

# Function to fix Lua files
fix_lua() {
  local file="$1"

  # Lua doesn't have a standard auto-formatter like stylua yet in our setup
  # We can use luacheck with --fix flag if available
  if ! command -v stylua &> /dev/null; then
    echo -e "${YELLOW}⚠️  stylua not found (Lua formatter). Install with: cargo install stylua${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Formatting $file with stylua...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if stylua --check "$file" 2>&1; then
      echo -e "${GREEN}✅ Already formatted: $file${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would format: $file${NC}"
      return 0
    fi
  else
    if stylua "$file" 2>&1; then
      echo -e "${GREEN}✅ Formatted: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${RED}❌ Failed to format: $file${NC}"
      return 1
    fi
  fi
}

# Function to fix TypeScript/JavaScript files
fix_typescript() {
  local file="$1"

  if ! command -v prettier &> /dev/null; then
    echo -e "${YELLOW}⚠️  prettier not found. Install with: npm install -g prettier${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Formatting $file with Prettier...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if prettier --check "$file" 2>&1; then
      echo -e "${GREEN}✅ Already formatted: $file${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would format: $file${NC}"
      return 0
    fi
  else
    if prettier --write "$file" 2>&1; then
      echo -e "${GREEN}✅ Formatted: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${RED}❌ Failed to format: $file${NC}"
      return 1
    fi
  fi

  # Also run ESLint --fix if available
  if command -v eslint &> /dev/null && [ "$CHECK_ONLY" = false ]; then
    echo -e "${BLUE}🔧 Running ESLint --fix on $file...${NC}"
    if eslint --fix "$file" 2>&1; then
      echo -e "${GREEN}✅ ESLint fixes applied: $file${NC}"
    fi
  fi
}

# Function to fix Python files
fix_python() {
  local file="$1"

  # Use ruff for both linting and formatting
  if ! command -v ruff &> /dev/null; then
    echo -e "${YELLOW}⚠️  ruff not found. Install with: pip install ruff${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Formatting $file with ruff...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if ruff format --check "$file" 2>&1; then
      echo -e "${GREEN}✅ Already formatted: $file${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would format: $file${NC}"
      return 0
    fi
  else
    # Format with ruff
    if ruff format "$file" 2>&1; then
      echo -e "${GREEN}✅ Formatted: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
    fi

    # Fix linting issues
    if ruff check --fix "$file" 2>&1; then
      echo -e "${GREEN}✅ Linting fixes applied: $file${NC}"
    fi
    return 0
  fi
}

# Function to fix Ruby files
fix_ruby() {
  local file="$1"

  if ! command -v rubocop &> /dev/null; then
    echo -e "${YELLOW}⚠️  rubocop not found. Install with: gem install rubocop${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Fixing $file with rubocop...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if rubocop "$file" 2>&1; then
      echo -e "${GREEN}✅ No issues: $file${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would fix: $file${NC}"
      return 0
    fi
  else
    if rubocop --autocorrect "$file" 2>&1; then
      echo -e "${GREEN}✅ Fixed: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${RED}❌ Failed to fix: $file${NC}"
      return 1
    fi
  fi
}

# Function to fix Go files
fix_go() {
  local file="$1"

  if ! command -v gofmt &> /dev/null; then
    echo -e "${YELLOW}⚠️  gofmt not found. Install Go from: https://go.dev/doc/install${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Formatting $file with gofmt...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if gofmt -l "$file" | grep -q .; then
      echo -e "${YELLOW}⚠️  Would format: $file${NC}"
      return 0
    else
      echo -e "${GREEN}✅ Already formatted: $file${NC}"
      return 0
    fi
  else
    if gofmt -w "$file" 2>&1; then
      echo -e "${GREEN}✅ Formatted: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${RED}❌ Failed to format: $file${NC}"
      return 1
    fi
  fi
}

# Function to fix Rust files
fix_rust() {
  if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}⚠️  cargo not found. Install from: https://rustup.rs/${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Formatting Rust code with cargo fmt...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if cargo fmt -- --check 2>&1; then
      echo -e "${GREEN}✅ Already formatted${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would format Rust files${NC}"
      return 0
    fi
  else
    if cargo fmt 2>&1; then
      echo -e "${GREEN}✅ Formatted Rust files${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${RED}❌ Failed to format Rust files${NC}"
      return 1
    fi
  fi
}

# Function to fix Markdown files
fix_markdown() {
  local file="$1"

  if ! command -v markdownlint &> /dev/null; then
    echo -e "${YELLOW}⚠️  markdownlint not found. Install with: npm install -g markdownlint-cli${NC}"
    return 0
  fi

  echo -e "${BLUE}🔧 Fixing $file with markdownlint...${NC}"

  if [ "$CHECK_ONLY" = true ]; then
    if markdownlint "$file" 2>&1; then
      echo -e "${GREEN}✅ No issues: $file${NC}"
      return 0
    else
      echo -e "${YELLOW}⚠️  Would fix: $file${NC}"
      return 0
    fi
  else
    if markdownlint --fix "$file" 2>&1; then
      echo -e "${GREEN}✅ Fixed: $file${NC}"
      FILES_FIXED=$((FILES_FIXED + 1))
      return 0
    else
      echo -e "${YELLOW}⚠️  Some issues couldn't be auto-fixed: $file${NC}"
      return 0
    fi
  fi
}

# Track Rust files separately (need to run cargo fmt once for all)
RUST_FILES=()

# Process each file
for file in "${FILE_PATHS[@]}"; do
  # Determine file type and run appropriate fixer
  case "$file" in
    *.lua)
      if ! fix_lua "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *.ts|*.tsx|*.js|*.jsx)
      if ! fix_typescript "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *.py)
      if ! fix_python "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *.rb)
      if ! fix_ruby "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *.go)
      if ! fix_go "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *.rs)
      RUST_FILES+=("$file")
      ;;
    *.md)
      if ! fix_markdown "$file"; then
        FIX_FAILED=1
      fi
      ;;
    *)
      # Unknown file type, skip
      continue
      ;;
  esac
done

# Format all Rust files at once
if [ ${#RUST_FILES[@]} -gt 0 ]; then
  if ! fix_rust; then
    FIX_FAILED=1
  fi
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"

if [ "$CHECK_ONLY" = true ]; then
  echo -e "${BLUE}📋 Check complete${NC}"
else
  if [ $FIX_FAILED -eq 0 ]; then
    if [ $FILES_FIXED -gt 0 ]; then
      echo -e "${GREEN}✅ Successfully fixed $FILES_FIXED file(s)${NC}"
    else
      echo -e "${GREEN}✅ All files already properly formatted${NC}"
    fi
  else
    echo -e "${RED}❌ Some fixes failed. Please review the errors above.${NC}"
  fi
fi

echo -e "${BLUE}═══════════════════════════════════════${NC}"

exit $FIX_FAILED
