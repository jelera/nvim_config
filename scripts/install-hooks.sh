#!/bin/bash
#
# Install Git Hooks
# =================
# Installs git hooks for the NeoVim IDE configuration project.
#
# Usage:
#   ./scripts/install-hooks.sh
#
# This script will:
#   1. Check if .git directory exists
#   2. Create .git/hooks directory if needed
#   3. Symlink pre-commit-hook.sh to .git/hooks/pre-commit
#   4. Make the hook executable
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Installing Git Hooks...${NC}\n"

# Get project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -z "$PROJECT_ROOT" ]; then
	echo -e "${RED}❌ Error: Not a git repository${NC}"
	echo -e "${YELLOW}Run this script from inside the git repository${NC}"
	exit 1
fi

cd "$PROJECT_ROOT"

# Check if .git directory exists
if [ ! -d ".git" ]; then
	echo -e "${RED}❌ Error: .git directory not found${NC}"
	exit 1
fi

# Create hooks directory if it doesn't exist
if [ ! -d ".git/hooks" ]; then
	echo -e "${YELLOW}Creating .git/hooks directory...${NC}"
	mkdir -p ".git/hooks"
fi

# Install pre-commit hook
HOOK_SOURCE="$PROJECT_ROOT/scripts/pre-commit-hook.sh"
HOOK_TARGET="$PROJECT_ROOT/.git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
	echo -e "${RED}❌ Error: pre-commit-hook.sh not found at $HOOK_SOURCE${NC}"
	exit 1
fi

# Check if hook already exists
if [ -f "$HOOK_TARGET" ] || [ -L "$HOOK_TARGET" ]; then
	echo -e "${YELLOW}⚠️  Pre-commit hook already exists${NC}"
	read -p "Overwrite existing hook? [y/N] " -n 1 -r
	echo ""
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo -e "${YELLOW}Skipping pre-commit hook installation${NC}"
		exit 0
	fi
	rm -f "$HOOK_TARGET"
fi

# Create symlink
echo -e "${BLUE}Creating symlink for pre-commit hook...${NC}"
ln -sf "../../scripts/pre-commit-hook.sh" "$HOOK_TARGET"

# Make executable
chmod +x "$HOOK_SOURCE"
chmod +x "$HOOK_TARGET"

# Verify installation
if [ -L "$HOOK_TARGET" ]; then
	echo -e "\n${GREEN}✅ Pre-commit hook installed successfully!${NC}\n"
	echo -e "${BLUE}The hook will run automatically on 'git commit' and check:${NC}"
	echo "  1. Lint checks (luacheck, eslint, ruff, rubocop, markdownlint, shellcheck)"
	echo "  2. Type checks (TypeScript, Python)"
	echo "  3. Format checks (stylua, prettier, shfmt)"
	echo ""
	echo -e "${BLUE}To bypass the hook (not recommended):${NC}"
	echo "  git commit --no-verify"
	echo ""
	echo -e "${BLUE}To manually fix formatting issues:${NC}"
	echo "  ./scripts/auto-fix.sh"
	echo ""
else
	echo -e "${RED}❌ Failed to install pre-commit hook${NC}"
	exit 1
fi
