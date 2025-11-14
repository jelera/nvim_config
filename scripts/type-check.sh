#!/bin/bash
#
# Type Check Script
# =================
# Performs static type checking for statically-typed languages.
#
# Usage:
#   ./scripts/type-check.sh "$CLAUDE_TOOL_INPUT"  # From Claude Code hooks
#   ./scripts/type-check.sh path/to/file.ts       # Direct file check
#   ./scripts/type-check.sh                        # Check all staged files (for git hooks)
#
# Exit codes:
#   0 - Success (type check passed)
#   2 - Blocking error (type check failed, should block commit/operation)
#   1 - Non-blocking error (type checker not found, file skipped)
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
	if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
		echo -e "${BLUE}🔍 Type checking staged files...${NC}"
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

# Track if any type checks failed
TYPE_CHECK_FAILED=0

# Track if we need to run project-wide checks
NEEDS_TS_CHECK=false
NEEDS_RUST_CHECK=false
NEEDS_GO_CHECK=false

# Function to check TypeScript files
check_typescript_project() {
	if ! command -v tsc &>/dev/null; then
		echo -e "${YELLOW}⚠️  tsc not found. Install with: npm install -g typescript${NC}"
		return 0
	fi

	# Find tsconfig.json
	local tsconfig=""
	if [ -f "tsconfig.json" ]; then
		tsconfig="tsconfig.json"
	elif [ -f "../tsconfig.json" ]; then
		tsconfig="../tsconfig.json"
	else
		echo -e "${YELLOW}⚠️  tsconfig.json not found${NC}"
		return 0
	fi

	echo -e "${BLUE}🔍 Running TypeScript type check (project-wide)...${NC}"

	# Run tsc in no-emit mode (type check only)
	if tsc --noEmit --pretty 2>&1; then
		echo -e "${GREEN}✅ TypeScript type check passed${NC}"
		return 0
	else
		echo -e "${RED}❌ TypeScript type check failed${NC}"
		return 2
	fi
}

# Function to check Rust project
check_rust_project() {
	if ! command -v cargo &>/dev/null; then
		echo -e "${YELLOW}⚠️  cargo not found. Install from: https://rustup.rs/${NC}"
		return 0
	fi

	echo -e "${BLUE}🔍 Running Rust type check (cargo check)...${NC}"

	if cargo check --all-targets --all-features 2>&1; then
		echo -e "${GREEN}✅ Rust type check passed${NC}"
		return 0
	else
		echo -e "${RED}❌ Rust type check failed${NC}"
		return 2
	fi
}

# Function to check Go project
check_go_project() {
	if ! command -v go &>/dev/null; then
		echo -e "${YELLOW}⚠️  go not found. Install from: https://go.dev/doc/install${NC}"
		return 0
	fi

	echo -e "${BLUE}🔍 Running Go type check (go build)...${NC}"

	if go build -o /dev/null ./... 2>&1; then
		echo -e "${GREEN}✅ Go type check passed${NC}"
		return 0
	else
		echo -e "${RED}❌ Go type check failed${NC}"
		return 2
	fi
}

# Function to check Python files with mypy
check_python_file() {
	local file="$1"

	if ! command -v mypy &>/dev/null; then
		echo -e "${YELLOW}⚠️  mypy not found. Install with: pip install mypy${NC}"
		return 0
	fi

	echo -e "${BLUE}🔍 Running mypy on $file...${NC}"

	if mypy "$file" 2>&1; then
		echo -e "${GREEN}✅ Python type check passed: $file${NC}"
		return 0
	else
		echo -e "${RED}❌ Python type check failed: $file${NC}"
		return 2
	fi
}

# Scan files to determine which checks to run
for file in $STAGED_FILES; do
	# Skip if file doesn't exist (could be deleted)
	if [ ! -f "$file" ]; then
		continue
	fi

	# Determine file type
	case "$file" in
	*.ts | *.tsx)
		NEEDS_TS_CHECK=true
		;;
	*.rs)
		NEEDS_RUST_CHECK=true
		;;
	*.go)
		NEEDS_GO_CHECK=true
		;;
	*.py)
		# Python: check individual files with mypy
		if ! check_python_file "$file"; then
			TYPE_CHECK_FAILED=2
		fi
		;;
	*.lua)
		# Lua: No built-in type checker (would need teal or similar)
		# Rely on luacheck for basic validation
		echo -e "${BLUE}ℹ️  Lua type checking via LSP in editor (consider using teal for static typing)${NC}"
		;;
	*)
		# Other file types: skip
		continue
		;;
	esac
done

# Run project-wide checks if needed
if [ "$NEEDS_TS_CHECK" = true ]; then
	if ! check_typescript_project; then
		TYPE_CHECK_FAILED=2
	fi
fi

if [ "$NEEDS_RUST_CHECK" = true ]; then
	if ! check_rust_project; then
		TYPE_CHECK_FAILED=2
	fi
fi

if [ "$NEEDS_GO_CHECK" = true ]; then
	if ! check_go_project; then
		TYPE_CHECK_FAILED=2
	fi
fi

# Exit with appropriate code
if [ $TYPE_CHECK_FAILED -eq 2 ]; then
	echo -e "${RED}❌ Type checks failed. Please fix the type errors above.${NC}"
	exit 2
else
	echo -e "${GREEN}✅ All type checks passed${NC}"
	exit 0
fi
