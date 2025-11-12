#!/bin/bash
#
# Test Runner Script
# ==================
# Runs busted tests with proper environment setup.
#
# Usage:
#   ./scripts/test.sh                              # Run all tests
#   ./scripts/test.sh lua/spec/nvim/core/module_loader_spec.lua  # Run specific test
#   ./scripts/test.sh --coverage                   # Run with coverage
#   ./scripts/test.sh --no-shuffle                 # Disable test shuffling
#
# This script ensures:
# - Lua path includes ./lua directory for requires
# - mise environment is activated
# - luarocks path is configured
#

set -euo pipefail

# Activate mise environment
eval "$(mise activate bash)"

# Configure luarocks path
eval "$(luarocks path)"

# Add project lua directory to LUA_PATH
export LUA_PATH="./lua/?.lua;./lua/?/init.lua;${LUA_PATH:-}"
export LUA_CPATH="./lua/?.so;${LUA_CPATH:-}"

# Run busted with all arguments passed through
exec busted "$@"
