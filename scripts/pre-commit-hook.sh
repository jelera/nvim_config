#!/bin/bash
#
# Git Pre-Commit Hook
# ===================
# Automatically runs lint and type checks on staged files before commit.
#
# Installation:
#   ln -sf ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Or use manually:
#   ./scripts/pre-commit-hook.sh
#
# This hook will:
#   1. Run lint checks on all staged files
#   2. Run type checks on all staged files
#   3. Run format checks on all staged files
#   4. Block the commit if any checks fail
#

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Running pre-commit checks...${NC}"

# Get the project root directory
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Run lint checks
echo -e "${BLUE}📋 Step 1: Lint checks${NC}"
if ! "$PROJECT_ROOT/scripts/lint-check.sh"; then
	echo -e "${RED}❌ Pre-commit checks failed: Lint errors found${NC}"
	echo -e "${RED}Fix the errors above or use 'git commit --no-verify' to bypass${NC}"
	exit 1
fi

# Run type checks
echo -e "${BLUE}🔍 Step 2: Type checks${NC}"
if ! "$PROJECT_ROOT/scripts/type-check.sh"; then
	echo -e "${RED}❌ Pre-commit checks failed: Type errors found${NC}"
	echo -e "${RED}Fix the errors above or use 'git commit --no-verify' to bypass${NC}"
	exit 1
fi

# Run format checks
echo -e "${BLUE}🎨 Step 3: Format checks${NC}"
if ! "$PROJECT_ROOT/scripts/auto-fix.sh" --check; then
	echo -e "${RED}❌ Pre-commit checks failed: Files are not properly formatted${NC}"
	echo -e "${RED}Run './scripts/auto-fix.sh' to fix formatting, then try again${NC}"
	echo -e "${RED}Or use 'git commit --no-verify' to bypass${NC}"
	exit 1
fi

echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
exit 0
