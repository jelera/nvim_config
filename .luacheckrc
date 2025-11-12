-- Luacheck configuration for NeoVim Lua configuration
-- https://luacheck.readthedocs.io/

-- Lua standard library
std = 'luajit'  -- NeoVim uses LuaJIT (Lua 5.1 compatible)

-- Global settings
max_line_length = 100
max_code_line_length = 100
max_string_line_length = 120  -- Allow longer strings for documentation
max_comment_line_length = 120

-- Complexity limits
max_cyclomatic_complexity = 15  -- Default for modules and config

-- Ignore certain warning codes globally
ignore = {
  '212',  -- Unused argument (common in callbacks)
}

-- Global variables accessible in all files
globals = {
  'vim',  -- NeoVim Lua API
}

-- Read-only globals (can be accessed but not modified)
read_globals = {
  'vim',
}

-- Files to exclude from linting
exclude_files = {
  '.luarocks/',
  '.mise/',
  'lua_modules/',
  'node_modules/',
  '*.backup/',
  '*.backup.*/',
}

-- Different rule sets for different code areas

-- Framework core (lua/nvim/**) - Strictest rules
files['lua/nvim/'] = {
  max_cyclomatic_complexity = 10,  -- Stricter for core framework
  ignore = {},  -- No ignored warnings
  globals = {
    'vim',
  },
}

-- Feature modules (lua/modules/**) - Balanced rules
files['lua/modules/'] = {
  max_cyclomatic_complexity = 15,
  globals = {
    'vim',
  },
}

-- User configuration (lua/config/**) - More relaxed
files['lua/config/'] = {
  max_cyclomatic_complexity = 20,  -- Allow more complexity in config
  globals = {
    'vim',
  },
}

-- Test files (lua/spec/**) - Test-specific globals
files['lua/spec/'] = {
  max_line_length = 120,  -- Allow longer lines in tests
  globals = {
    'vim',
    -- Busted BDD-style functions
    'describe',
    'context',
    'it',
    'before_each',
    'after_each',
    'setup',
    'teardown',
    'pending',
    'insulate',
    'expose',
    -- Busted assertions
    'assert',
    'spy',
    'mock',
    'stub',
    -- Custom test helpers
    'spec_helper',
    'test_helper',
  },
  ignore = {
    '212',  -- Unused argument
    '213',  -- Unused loop variable
  },
}

-- Plugin specifications (lazy.nvim)
files['lua/plugins.lua'] = {
  globals = {
    'vim',
  },
}

files['lua/plugins/'] = {
  globals = {
    'vim',
  },
}

--[[
Usage Examples:
===============

Lint all Lua files:
  luacheck .

Lint specific directory:
  luacheck lua/nvim/

Lint specific file:
  luacheck lua/nvim/core/module_loader.lua

Show only errors (no warnings):
  luacheck . --no-warnings

Auto-fix some issues (be careful):
  luacheck . --fix

Integration with editor:
  - NeoVim: Use nvim-lint or null-ls
  - VSCode: Install Lua extension with luacheck support
  - CI/CD: Add to pre-commit hooks

Common warning codes:
  111 - Setting undefined variable
  112 - Mutating undefined variable
  113 - Accessing undefined variable
  211 - Unused local variable
  212 - Unused argument
  213 - Unused loop variable
  311 - Value assigned to variable is unused
  411 - Variable was previously defined as an argument
  412 - Variable was previously defined as a loop variable
  421 - Shadowing definition of variable
  422 - Shadowing definition of argument
  423 - Shadowing definition of loop variable
  431 - Shadowing upvalue
  432 - Shadowing upvalue argument
  433 - Shadowing upvalue loop variable

Ignore specific warnings in code:
  -- luacheck: ignore 212
  local function foo(unused_arg)
    -- ...
  end

  -- luacheck: push ignore 211
  local unused_var = 42
  -- luacheck: pop
--]]
