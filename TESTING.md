# Testing Guide

This document describes the testing methodology, structure, and best practices for this NeoVim configuration.

## Philosophy

This project follows **Test-Driven Development (TDD)** with a clear separation between unit and integration tests:

- **Unit Tests**: Fast, isolated tests for individual functions and modules
- **Integration Tests**: Slower tests that verify interactions between multiple components

## Directory Structure

```
lua/spec/
├── unit/                          # Fast unit tests
│   └── nvim/core/
│       ├── module_loader_spec.lua
│       └── event_bus_spec.lua
├── integration/                   # Slower integration tests
│   └── nvim/core/
│       └── event_bus_integration_spec.lua
└── spec_helper.lua               # Shared test utilities and mocks
```

## Test Tagging Convention

All test suites are tagged with either `#unit` or `#integration`:

```lua
-- Unit test example
describe('module_name #unit', function()
  -- Fast, isolated tests
end)

-- Integration test example
describe('module_name #integration', function()
  -- Tests involving multiple components
end)
```

### When to Use Each Type

**Unit Tests (`#unit`):**
- Testing individual functions in isolation
- No external dependencies
- Fast execution (< 100ms per test suite)
- Mock all external interactions
- Run frequently during development

**Integration Tests (`#integration`):**
- Testing interactions between modules
- Complex workflows involving multiple components
- May be slower (seconds)
- Use real implementations where possible
- Run less frequently (before commits, in CI)

## Running Tests

### All Tests (Default)
```bash
busted
./scripts/test.sh
```

### Unit Tests Only (Fast TDD)
```bash
# By directory:
busted lua/spec/unit
./scripts/test.sh lua/spec/unit

# By tag:
busted --tags=unit
./scripts/test.sh --tags=unit
```

### Integration Tests Only
```bash
# By directory:
busted lua/spec/integration
./scripts/test.sh lua/spec/integration

# By tag:
busted --tags=integration
./scripts/test.sh --tags=integration
```

### Exclude Slow Tests (Rapid TDD)
```bash
busted --exclude-tags=integration
./scripts/test.sh --exclude-tags=integration
```

### Specific Test File
```bash
busted lua/spec/unit/nvim/core/module_loader_spec.lua
./scripts/test.sh lua/spec/unit/nvim/core/module_loader_spec.lua
```

### Pattern Matching
```bash
busted --filter="module loader"
./scripts/test.sh --filter="event emission"
```

## Debugging Failed Tests

### Test Shuffling
By default, tests run in random order to catch test interdependencies. When a test fails:

1. Note the seed value from the output
2. Re-run with that seed:
   ```bash
   busted --seed=1234567890
   ```
3. Or disable shuffling for debugging:
   ```bash
   busted --no-shuffle lua/spec/unit
   ```

### Verbose Output
```bash
busted --verbose
```

### Coverage Report
```bash
busted --coverage
```

## TDD Workflow

### Red-Green-Refactor Cycle

1. **RED**: Write failing tests first
   ```bash
   # Run unit tests to see them fail
   ./scripts/test.sh --tags=unit
   ```

2. **GREEN**: Implement minimal code to pass tests
   ```bash
   # Re-run frequently during implementation
   ./scripts/test.sh --tags=unit
   ```

3. **REFACTOR**: Improve code while keeping tests green
   ```bash
   # Ensure tests still pass after refactoring
   ./scripts/test.sh
   ```

### Recommended Development Flow

```bash
# 1. Start with fast unit tests during development
./scripts/test.sh --tags=unit

# 2. Once unit tests pass, run integration tests
./scripts/test.sh --tags=integration

# 3. Before committing, run all tests
./scripts/test.sh

# 4. Optional: Run with coverage
./scripts/test.sh --coverage
```

## Writing Tests

### Test Structure

```lua
--[[
Module Name Tests
=================

Brief description of what this module does.

Test Categories:
1. Category 1
2. Category 2
3. Category 3
--]]

local spec_helper = require('spec.spec_helper')

describe('module_name #unit', function()
  local module_under_test

  before_each(function()
    spec_helper.setup()
    -- Clear module cache for clean state
    package.loaded['nvim.module.path'] = nil
    module_under_test = require('nvim.module.path')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  describe('initialization', function()
    it('should create an instance', function()
      assert.is_not_nil(module_under_test)
      assert.is_table(module_under_test)
    end)
  end)

  describe('functionality', function()
    it('should do something', function()
      local result = module_under_test.do_something()
      assert.is_true(result)
    end)
  end)
end)
```

### Assertion Syntax

We use standard luassert assertions:

```lua
-- Type checks
assert.is_nil(value)
assert.is_not_nil(value)
assert.is_true(value)
assert.is_false(value)
assert.is_string(value)
assert.is_number(value)
assert.is_table(value)
assert.is_function(value)

-- Equality
assert.equals(expected, actual)
assert.are.equal(expected, actual)
assert.are.same(expected, actual)  -- Deep equality

-- Pattern matching
assert.matches('pattern', string)
assert.is_not_nil(string:match('pattern'))

-- Custom counters (preferred over spies for simple tests)
local call_count = 0
local callback = function()
  call_count = call_count + 1
end
-- ... trigger callback ...
assert.equals(1, call_count)
```

### Future: Custom Assertions

We plan to add namespaced custom assertions for NeoVim-specific testing:

```lua
-- Planned (not yet implemented):
assert.vim.has_keymap('n', '<leader>ff')
assert.module.is_loaded('nvim.core.module_loader')
assert.buffer.has_content('expected text')
assert.notification.was_sent('message', vim.log.levels.INFO)
```

## Test Utilities

### spec_helper.lua

Provides test utilities and mocks:

```lua
local spec_helper = require('spec.spec_helper')

-- Setup/teardown
spec_helper.setup()     -- Call in before_each
spec_helper.teardown()  -- Call in after_each

-- Notification checking
spec_helper.assert_notification('pattern', vim.log.levels.DEBUG)
spec_helper.get_notifications()
spec_helper.clear_notifications()

-- Command checking
spec_helper.assert_command('pattern')
spec_helper.get_commands()
spec_helper.clear_commands()

-- Test doubles
local fn, spy = spec_helper.create_spy(return_value)
local stub = spec_helper.create_stub({ method1 = value1, method2 = value2 })

-- Utilities
local copy = spec_helper.deep_copy(object)
local fixture = spec_helper.load_fixture('fixture_name')
```

## CI/CD Integration

Tests run automatically on:
- Pull requests
- Commits to main branch

CI runs both unit and integration tests:

```yaml
# .github/workflows/test.yml (example)
- name: Run unit tests
  run: ./scripts/test.sh --tags=unit

- name: Run integration tests
  run: ./scripts/test.sh --tags=integration
```

## Configuration Files

### .busted

Main test configuration:

```lua
return {
  _all = {
    ROOT = { 'lua/spec/unit', 'lua/spec/integration' },
    pattern = '_spec%.lua$',
    shuffle = true,
    seed = os.time(),
    verbose = true,
    defer_print = false,
    output = 'utfTerminal',
    lua = 'luajit',
  },
}
```

### scripts/test.sh

Test runner that properly sets up Lua environment:

```bash
#!/bin/bash
eval "$(mise activate bash)"
eval "$(luarocks path)"
export LUA_PATH="./lua/?.lua;./lua/?/init.lua;${LUA_PATH:-}"
exec busted "$@"
```

## Best Practices

### DO:
- ✅ Tag all tests with `#unit` or `#integration`
- ✅ Keep unit tests fast (< 100ms per suite)
- ✅ Use `before_each`/`after_each` for test isolation
- ✅ Clear module cache with `package.loaded[module] = nil`
- ✅ Use descriptive test names: "should do X when Y"
- ✅ Run `--exclude-tags=integration` during rapid development
- ✅ Test error conditions and edge cases
- ✅ Write tests before implementation (TDD)

### DON'T:
- ❌ Mix unit and integration tests in same file
- ❌ Let unit tests depend on external systems
- ❌ Write slow unit tests (> 100ms)
- ❌ Share state between tests
- ❌ Test implementation details (test behavior)
- ❌ Skip writing tests for error paths
- ❌ Commit code with failing tests

## Troubleshooting

### Module Not Found
```
Error: module 'nvim.core.module_name' not found
```
- Ensure `LUA_PATH` includes `./lua/?.lua;./lua/?/init.lua`
- Use `./scripts/test.sh` instead of `busted` directly
- Check module file exists at correct path

### Tests Pass Individually But Fail Together
- Likely test interdependency
- Check for shared state
- Ensure `before_each` properly resets state
- Run with `--no-shuffle` to debug

### Spy Not Working
- Use simple counters instead of spies when possible
- luassert spies can interfere with `type()` checks
- See `module_loader_spec.lua` for counter pattern

## Examples

### Unit Test Example
```lua
describe('calculator #unit', function()
  local calculator

  before_each(function()
    spec_helper.setup()
    package.loaded['lib.calculator'] = nil
    calculator = require('lib.calculator')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  it('should add two numbers', function()
    local result = calculator.add(2, 3)
    assert.equals(5, result)
  end)

  it('should handle negative numbers', function()
    local result = calculator.add(-1, 1)
    assert.equals(0, result)
  end)
end)
```

### Integration Test Example
```lua
describe('plugin_loader #integration', function()
  local module_loader
  local plugin_system

  before_each(function()
    spec_helper.setup()
    package.loaded['nvim.core.module_loader'] = nil
    package.loaded['nvim.core.plugin_system'] = nil
    module_loader = require('nvim.core.module_loader')
    plugin_system = require('nvim.core.plugin_system')
  end)

  after_each(function()
    spec_helper.teardown()
  end)

  it('should load plugin through module loader', function()
    plugin_system.register('test-plugin', { ... })
    local plugin = module_loader.load('plugins.test-plugin')
    assert.is_not_nil(plugin)
    assert.is_true(plugin.loaded)
  end)
end)
```

## Resources

- [Busted Documentation](https://lunarmodules.github.io/busted/)
- [luassert Assertions](https://lunarmodules.github.io/luassert/)
- [TDD Best Practices](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Test Doubles](https://martinfowler.com/bliki/TestDouble.html)

## Questions?

For testing questions or issues:
1. Check this guide first
2. Review example tests in `lua/spec/unit/`
3. Check `.busted` configuration
4. Ask in project discussions
