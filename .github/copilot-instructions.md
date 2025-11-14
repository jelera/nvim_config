# GitHub Copilot Instructions

> **Note:** For complete project context, architecture, and development guidelines, see [`AGENTS.md`](../AGENTS.md) at the repository root.

## Quick Reference

This NeoVim IDE configuration is:

- ✅ **Production-ready** with 786 passing tests
- ✅ **Test-Driven Development** (TDD) - always write tests first
- ✅ **Modular architecture** - keep files under ~130 lines
- ✅ **Strict conventions** - see AGENTS.md for details

## Essential Commands

```bash
./scripts/test.sh              # Run all tests
./scripts/lint-check.sh        # Lint code
./scripts/auto-fix.sh          # Fix formatting
```

## Key Patterns

- Use `utils.merge_config()` for configuration merging
- Module structure: `init.lua` (orchestrator) + sub-modules
- Tests must have `#unit` or `#integration` tags
- LSP servers in `modules/lsp/servers/<language>/`

**For detailed information, refer to [`AGENTS.md`](../AGENTS.md)**
