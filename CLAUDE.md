# NeoVim IDE Configuration - Development Plan

## Project Overview

Building a modern, IDE-like NeoVim configuration from scratch using:
- **Pure Lua** for all configuration
- **Test-Driven Development (TDD)** with busted
- **Modular architecture** with dependency injection
- **Extensible framework** for easy customization
- **Comprehensive documentation** (user is learning Lua)

## Technology Stack (2025 - Most Popular & Actively Maintained)

### Core Infrastructure
- **Plugin Manager**: `lazy.nvim` (by folke) - Modern, fast, automatic lazy-loading
  - Replaces archived `packer.nvim`
  - Built-in profiling and UI
  - Automatic byte-compilation

### Language Support
- **LSP Configuration**: `nvim-lspconfig` (official)
- **LSP Installer**: `mason.nvim` + `mason-lspconfig.nvim`
  - Replaces deprecated `nvim-lsp-installer`
  - Manages LSP servers, DAP servers, linters, formatters
- **Syntax Highlighting**: `nvim-treesitter` with `nvim-treesitter-textobjects`

### Completion & Snippets
- **Completion Engine**: `nvim-cmp` (most popular)
  - Sources: `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`
- **Snippet Engine**: `LuaSnip` + `friendly-snippets`
  - Pure Lua, fast, extensible

### Navigation & Search
- **Fuzzy Finder**: `telescope.nvim` (most popular, highly extensible)
  - Alternative: `fzf-lua` (faster but less extensible)
- **File Explorer**: `oil.nvim` (modern, buffer-based) or `nvim-tree.lua` (traditional)
- **Quick Navigation**: `flash.nvim` or `leap.nvim` (motion plugins)

### UI & Visual
- **Statusline**: `lualine.nvim` (most popular, highly configurable)
- **Bufferline**: `bufferline.nvim` (tab-like buffer display)
- **Colorscheme**: `gruvbox.nvim` (modern Lua port of gruvbox)
- **Icons**: `nvim-web-devicons` (required by many plugins)
- **Indent Guides**: `indent-blankline.nvim`
- **Git Signs**: `gitsigns.nvim`
- **Notifications**: `nvim-notify`

### Git Integration
- **Git Operations**: `vim-fugitive` (Tim Pope's classic, still best)
- **Git Signs**: `gitsigns.nvim` (blame, hunk operations)
- **Diff View**: `diffview.nvim`

### Debugging (DAP)
- **Core**: `nvim-dap` + `nvim-dap-ui`
- **Virtual Text**: `nvim-dap-virtual-text`
- **Language Adapters**: Language-specific DAP adapters via Mason

### Testing
- **Test Runner**: `neotest` (modern, async, multi-language)
- **Adapters**: Language-specific neotest adapters

### AI Integration
- **Copilot**: `copilot.lua` (official, maintained)
- **Copilot Chat**: `CopilotChat.nvim`

### Utilities
- **Commenting**: `comment.nvim` (modern Lua version)
- **Auto Pairs**: `nvim-autopairs`
- **Surround**: `nvim-surround` (modern Lua version)
- **Project Management**: `project.nvim`
- **Session Management**: `persistence.nvim`
- **Tmux Integration**: `vim-tmux-navigator`

## Project Structure

```
nvimconfig/
├── init.lua                          # Entry point - bootstraps the framework
├── CLAUDE.md                         # This file - context for future sessions
├── README.md                         # User documentation
├── .busted                           # Test runner configuration
├── .luacheckrc                       # Lua linter configuration
├── .github/
│   └── workflows/
│       └── test.yml                  # CI/CD for automated testing
│
├── lua/
│   ├── nvim/                         # Core Framework (NEW)
│   │   ├── init.lua                 # Framework entry point
│   │   ├── bootstrap.lua            # Plugin manager bootstrap
│   │   ├── module_loader.lua        # Module loading with dependency injection
│   │   ├── plugin_system.lua        # Extension/plugin hook system
│   │   ├── event_bus.lua            # Event-driven architecture
│   │   ├── config_schema.lua        # Configuration validation
│   │   └── utils.lua                # Shared utilities
│   │
│   ├── config/                       # User Configuration
│   │   ├── init.lua                 # Main config (user edits this)
│   │   ├── options.lua              # Vim options override
│   │   ├── keymaps.lua              # Custom keymaps
│   │   └── plugins.lua              # Plugin configurations
│   │
│   ├── modules/                      # Feature Modules
│   │   ├── core/                    # Core Vim Settings
│   │   │   ├── init.lua            # Module entry point
│   │   │   ├── options.lua         # Vim options (set, opt, g, etc.)
│   │   │   ├── keymaps.lua         # Core keymaps
│   │   │   ├── autocmds.lua        # Autocommands
│   │   │   └── commands.lua        # User commands
│   │   │
│   │   ├── ui/                      # User Interface
│   │   │   ├── init.lua            # UI orchestrator
│   │   │   ├── colorscheme.lua     # Theme configuration
│   │   │   ├── statusline.lua      # Lualine setup
│   │   │   ├── bufferline.lua      # Buffer tabs
│   │   │   ├── icons.lua           # Icon configuration
│   │   │   ├── indent.lua          # Indent guides
│   │   │   └── notifications.lua   # Notification system
│   │   │
│   │   ├── treesitter/              # Syntax Highlighting
│   │   │   ├── init.lua            # TreeSitter entry point
│   │   │   ├── parsers.lua         # Parser installation
│   │   │   ├── highlight.lua       # Syntax highlighting
│   │   │   ├── indent.lua          # Indentation
│   │   │   ├── folding.lua         # Code folding
│   │   │   └── textobjects.lua     # Text objects
│   │   │
│   │   ├── lsp/                     # Language Server Protocol
│   │   │   ├── init.lua            # LSP orchestrator
│   │   │   ├── mason.lua           # Mason installer setup
│   │   │   ├── config.lua          # LSP client configuration
│   │   │   ├── handlers.lua        # Custom LSP handlers
│   │   │   ├── formatting.lua      # Format on save
│   │   │   ├── diagnostics.lua     # Diagnostic configuration
│   │   │   ├── keymaps.lua         # LSP keymaps
│   │   │   └── servers/            # Per-language configurations
│   │   │       ├── lua_ls.lua      # Lua language server
│   │   │       ├── tsserver.lua    # TypeScript/JavaScript
│   │   │       ├── rust_analyzer.lua
│   │   │       ├── pyright.lua     # Python
│   │   │       └── solargraph.lua  # Ruby
│   │   │
│   │   ├── completion/              # Auto-completion
│   │   │   ├── init.lua            # Completion orchestrator
│   │   │   ├── cmp.lua             # nvim-cmp setup
│   │   │   ├── sources.lua         # Completion sources
│   │   │   ├── snippets.lua        # LuaSnip configuration
│   │   │   ├── keymaps.lua         # Completion keymaps
│   │   │   └── formatting.lua      # Completion menu formatting
│   │   │
│   │   ├── navigation/              # File Navigation & Search
│   │   │   ├── init.lua            # Navigation orchestrator
│   │   │   ├── telescope.lua       # Telescope setup
│   │   │   ├── pickers.lua         # Custom Telescope pickers
│   │   │   ├── explorer.lua        # File explorer (oil.nvim)
│   │   │   ├── motions.lua         # Quick motions (flash.nvim)
│   │   │   └── keymaps.lua         # Navigation keymaps
│   │   │
│   │   ├── git/                     # Git Integration
│   │   │   ├── init.lua            # Git orchestrator
│   │   │   ├── signs.lua           # Gitsigns setup
│   │   │   ├── fugitive.lua        # Fugitive configuration
│   │   │   ├── diffview.lua        # Diff viewer
│   │   │   └── keymaps.lua         # Git keymaps
│   │   │
│   │   ├── debug/                   # Debugging (DAP)
│   │   │   ├── init.lua            # Debug orchestrator
│   │   │   ├── dap.lua             # Core DAP setup
│   │   │   ├── ui.lua              # Debug UI
│   │   │   ├── keymaps.lua         # Debug keymaps
│   │   │   └── adapters/           # Language-specific adapters
│   │   │       ├── javascript.lua  # JS/TS (node-debug2)
│   │   │       ├── python.lua      # Python (debugpy)
│   │   │       ├── ruby.lua        # Ruby (ruby-debug)
│   │   │       ├── go.lua          # Go (delve)
│   │   │       └── rust.lua        # Rust (lldb)
│   │   │
│   │   ├── test/                    # Testing Framework
│   │   │   ├── init.lua            # Test orchestrator
│   │   │   ├── neotest.lua         # Neotest setup
│   │   │   ├── adapters.lua        # Test adapters
│   │   │   ├── coverage.lua        # Coverage visualization
│   │   │   ├── keymaps.lua         # Test keymaps
│   │   │   └── commands.lua        # Test commands
│   │   │
│   │   ├── ai/                      # AI Integration
│   │   │   ├── init.lua            # AI orchestrator
│   │   │   ├── copilot.lua         # GitHub Copilot
│   │   │   ├── chat.lua            # Copilot Chat
│   │   │   └── keymaps.lua         # AI keymaps
│   │   │
│   │   └── editor/                  # Editor Enhancements
│   │       ├── init.lua            # Editor orchestrator
│   │       ├── autopairs.lua       # Auto-pairs setup
│   │       ├── surround.lua        # Surround motions
│   │       ├── comment.lua         # Commenting
│   │       └── project.lua         # Project management
│   │
│   ├── extensions/                   # User Extensions (Custom Modules)
│   │   ├── README.md               # How to create extensions
│   │   └── example/                # Example extension
│   │       ├── init.lua
│   │       └── spec.lua
│   │
│   └── spec/                         # Test Suite (Busted)
│       ├── spec_helper.lua          # Test utilities & mocks
│       ├── nvim/                    # Framework tests
│       │   ├── module_loader_spec.lua
│       │   ├── plugin_system_spec.lua
│       │   ├── event_bus_spec.lua
│       │   └── config_schema_spec.lua
│       ├── modules/                 # Module tests
│       │   ├── core_spec.lua
│       │   ├── ui_spec.lua
│       │   ├── treesitter_spec.lua
│       │   ├── lsp_spec.lua
│       │   ├── completion_spec.lua
│       │   ├── navigation_spec.lua
│       │   ├── git_spec.lua
│       │   ├── debug_spec.lua
│       │   ├── test_spec.lua
│       │   ├── ai_spec.lua
│       │   └── editor_spec.lua
│       └── integration/             # Integration tests
│           ├── startup_spec.lua
│           ├── lsp_completion_spec.lua
│           └── plugin_loading_spec.lua
│
└── docs/                            # Documentation
    ├── ARCHITECTURE.md              # System architecture
    ├── MODULES.md                   # Module development guide
    ├── EXTENSIONS.md                # Extension development guide
    ├── TESTING.md                   # Testing guide
    ├── KEYMAPS.md                   # Complete keymap reference
    └── TROUBLESHOOTING.md           # Common issues

```

## Development Phases

### Phase 1: Foundation & TDD Infrastructure ✅ COMPLETE
**Goal**: Set up testing framework and core module system

**310 tests passing** - All framework components implemented and tested.

---

### Phase 2: Core Module ✅ COMPLETE
**Goal**: Basic Vim configuration and behavior

**170 tests passing** - Options, keymaps, autocmds, commands all implemented.

---

### Phase 3: UI & Visual ✅ COMPLETE
**Goal**: Make NeoVim look good and provide visual feedback

**11 tests passing** - Unified UI module with colorscheme, statusline, icons, indent guides, notifications.

---

### Phase 4: TreeSitter ✅ COMPLETE
**Goal**: Modern syntax highlighting and code understanding

**37 tests passing** - Full TreeSitter with highlighting, indent, folding, text objects, incremental selection.

---

### Phase 5: LSP System ✅ COMPLETE
**Goal**: Full language server support

**47 tests passing** - Mason + lspconfig with 9 language servers (Lua, TypeScript, Python, Ruby, Go, Rust, Bash, SQL, Markdown).

Split into focused modules: init, config, event_handlers, keymaps, diagnostics. Per-language configs in `servers/<language>/`.

---

### Phase 6: Completion ⏳ CURRENT
**Goal**: Intelligent auto-completion

Tasks:
1. Set up nvim-cmp
2. Configure completion sources (LSP, buffer, path, snippets)
3. Set up LuaSnip
4. Add snippet library (friendly-snippets)
5. Configure completion keymaps
6. Customize completion menu appearance

**Testing Strategy**:
- Test source registration
- Test completion triggering
- Test snippet expansion
- Test keymap integration

---

### Phase 7: Navigation & Search ⏸️ PENDING
**Goal**: Fast file navigation and code search

Tasks:
1. Set up Telescope
2. Configure file finder
3. Configure live grep
4. Add custom pickers
5. Set up file explorer (oil.nvim)
6. Add quick motion plugin (flash.nvim)
7. Configure navigation keymaps

**Testing Strategy**:
- Test picker functionality
- Test file operations
- Test search accuracy

---

### Phase 8: Git Integration ⏸️ PENDING
**Goal**: Seamless git operations

Tasks:
1. Set up gitsigns
2. Configure vim-fugitive
3. Add diffview
4. Configure git keymaps
5. Test git operations

---

### Phase 9: Debugging (DAP) ⏸️ PENDING
**Goal**: Full debugging support

Tasks:
1. Set up nvim-dap
2. Configure nvim-dap-ui
3. Add debug adapters (via Mason)
4. Configure per-language debugging
5. Add debug keymaps
6. Test debugging workflow

**Languages to Support**:
- JavaScript/TypeScript (node-debug2)
- Python (debugpy)
- Ruby (ruby-debug-ide)
- Go (delve)
- Rust (lldb)

---

### Phase 10: Testing Framework ⏸️ PENDING
**Goal**: Run tests from within NeoVim

Tasks:
1. Set up neotest
2. Configure language adapters
3. Add test keymaps
4. Configure coverage display
5. Test test execution (meta!)

---

### Phase 11: AI Integration ⏸️ PENDING
**Goal**: AI-assisted coding

Tasks:
1. Set up copilot.lua
2. Configure CopilotChat.nvim
3. Add AI keymaps
4. Test AI suggestions

---

### Phase 12: Editor Enhancements ⏸️ PENDING
**Goal**: Quality of life improvements

Tasks:
1. Set up autopairs
2. Configure surround motions
3. Add commenting plugin
4. Set up project management
5. Configure session management

---

### Phase 13: Documentation & Polish ⏸️ PENDING
**Goal**: Comprehensive documentation

Tasks:
1. Write architecture documentation
2. Create module development guide
3. Write extension guide
4. Document all keymaps
5. Create troubleshooting guide
6. Add inline code documentation
7. Generate API documentation

---

### Phase 14: CI/CD & Distribution ⏸️ PENDING
**Goal**: Automated testing and easy installation

Tasks:
1. Set up GitHub Actions
2. Run tests on commit
3. Create installation script
4. Package for distribution
5. Write migration guide

---

## Key Design Principles

### 1. Test-Driven Development (TDD)
- Write tests BEFORE implementation
- Achieve 80%+ code coverage
- Use mocks for NeoVim APIs
- Test in isolation (unit) and integration

### 2. Modular Architecture
- Each module is self-contained
- Clear interfaces and dependencies
- Lazy loading for performance
- Easy to enable/disable modules

### 3. Extensibility
- Plugin/extension hook system
- Event bus for inter-module communication
- Clear extension API
- Example extensions provided

### 4. Documentation First
- Every function has docstring
- Every module has explanation
- Examples for complex features
- User-friendly for Lua beginners

### 5. Performance
- Lazy loading by default
- Async operations where possible
- Minimal startup time (<100ms)
- Efficient memory usage

### 6. IDE-like Experience
- Smart completion
- Inline diagnostics
- Integrated debugging
- Built-in testing
- Git integration
- Project management

---

## Code Style Guidelines

### Lua Conventions
```lua
-- Module structure (every module follows this pattern)
--[[
Module Name
===========

Brief description of what this module does.

Features:
- Feature 1
- Feature 2

Dependencies:
- List required modules

Usage:
```lua
local module = require('modules.example')
module.setup({
  option = value
})
```

API:
- setup(config) - Initialize the module
- enable() - Enable module features
- disable() - Disable module features
--]]

local M = {} -- Module table (always use M)

-- Private variables (local scope)
local private_var = 'not exported'

-- Private functions (local scope)
---Internal helper function
---@param arg string The argument description
---@return boolean success Whether operation succeeded
local function private_helper(arg)
  -- Implementation
  return true
end

-- Public functions (exported in M)
---Setup the module with configuration
---@param config table Configuration options
---@param config.option1 string Description of option1
---@param config.option2 boolean Description of option2
---@return boolean success Whether setup succeeded
function M.setup(config)
  -- Validate config
  if not config then
    vim.notify('Config required', vim.log.levels.ERROR)
    return false
  end

  -- Setup logic
  private_helper(config.option1)

  return true
end

---Enable module functionality
function M.enable()
  -- Enable logic
end

---Disable module functionality
function M.disable()
  -- Disable logic
end

return M
```

### Testing Conventions

> **📖 See [TESTING.md](./TESTING.md) for comprehensive testing guide**, including:
> - Unit vs Integration test separation
> - Test tagging with `#unit` and `#integration`
> - Running tests by directory or tag
> - TDD workflow and best practices

```lua
-- Test structure (for every module)
describe('modules.example', function()
  -- Setup before each test
  before_each(function()
    -- Reset state
    package.loaded['modules.example'] = nil
  end)

  -- Test group
  describe('setup()', function()
    it('should initialize with valid config', function()
      local module = require('modules.example')
      local result = module.setup({ option1 = 'value' })
      assert.is_true(result)
    end)

    it('should fail with invalid config', function()
      local module = require('modules.example')
      local result = module.setup(nil)
      assert.is_false(result)
    end)
  end)

  describe('enable()', function()
    it('should enable module features', function()
      -- Test implementation
    end)
  end)
end)
```

### Documentation Annotations (LuaLS)
```lua
---@class ModuleConfig Configuration for the module
---@field option1 string Description of option1
---@field option2? boolean Optional option2 (defaults to true)

---@param config ModuleConfig The configuration table
---@return boolean success Whether operation succeeded
function M.setup(config)
  -- Implementation
end
```

---

## Keymap Design (IDE-like)

### Leader Key: `,` (comma)

### Core Editing
- `<leader><space>` - Clear search highlighting
- `<leader>w` - Save file
- `<leader>q` - Quit window
- `<leader>Q` - Quit all

### File Navigation (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fh` - Find help tags
- `<leader>fr` - Recent files
- `<leader>fc` - Git commits
- `<leader>fs` - Git status
- `<C-p>` - Quick file finder (alias for ff)

### File Explorer
- `<leader>e` - Toggle file explorer
- `-` - Open parent directory

### LSP
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Go to references
- `gi` - Go to implementation
- `gt` - Go to type definition
- `K` - Show hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format document
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>d` - Show line diagnostics

### Completion
- `<C-Space>` - Trigger completion
- `<Tab>` - Next item / expand snippet
- `<S-Tab>` - Previous item
- `<CR>` - Confirm selection
- `<C-e>` - Close completion

### Git
- `<leader>gs` - Git status
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gl` - Git pull
- `<leader>gb` - Git blame
- `<leader>gd` - Git diff
- `<leader>gh` - Preview hunk
- `<leader>gH` - Reset hunk
- `[h` - Previous hunk
- `]h` - Next hunk

### Debugging
- `<F5>` - Continue / Start debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<leader>db` - Toggle breakpoint
- `<leader>dB` - Set conditional breakpoint
- `<leader>dr` - Open REPL
- `<leader>dl` - Run last configuration
- `<leader>dt` - Terminate session

### Testing
- `<leader>tt` - Run nearest test
- `<leader>tf` - Run file tests
- `<leader>ts` - Run test suite
- `<leader>tl` - Run last test
- `<leader>td` - Debug test
- `<leader>to` - Toggle test output
- `<leader>tc` - Show coverage

### AI (Copilot)
- `<C-g><C-g>` - Accept suggestion (insert mode)
- `<leader>ai` - Toggle Copilot
- `<leader>ac` - Open Copilot chat
- `<leader>ae` - Explain code
- `<leader>af` - Fix code

### Window Management
- `<C-h>` - Move to left window
- `<C-j>` - Move to down window
- `<C-k>` - Move to up window
- `<C-l>` - Move to right window
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<leader>se` - Make splits equal size
- `<leader>sx` - Close current split

---

## Testing Strategy

### Unit Tests
- Test each function in isolation
- Mock external dependencies (vim APIs, plugins)
- Test edge cases and error handling
- Aim for 80%+ coverage per module

### Integration Tests
- Test module interactions
- Test plugin loading
- Test LSP + completion integration
- Test debugging workflow

### Performance Tests
- Measure startup time
- Profile plugin loading
- Test with large files
- Memory usage checks

### Manual Testing Checklist
- [ ] NeoVim starts without errors
- [ ] All plugins load successfully
- [ ] LSP attaches to buffers
- [ ] Completion works
- [ ] File navigation works
- [ ] Git integration works
- [ ] Debugging works
- [ ] Testing framework works
- [ ] All keymaps function

---

## Dependencies & Installation

### Required
- NeoVim 0.9.5+ (latest stable)
- Git 2.30+
- Node.js 18+ (for LSP servers)
- Python 3.9+ (for Python LSP)
- Lua 5.1 (bundled with NeoVim)
- Luarocks (for installing busted)

### Optional but Recommended
- ripgrep (for faster Telescope grep)
- fd (for faster file finding)
- A Nerd Font (for icons)
- lazygit (for git TUI)

### Installation Commands
```bash
# Install busted (testing framework)
luarocks install busted

# Install luacheck (linter)
luarocks install luacheck

# Install required tools (macOS)
brew install neovim ripgrep fd lazygit

# Install required tools (Ubuntu)
sudo apt install neovim ripgrep fd-find

# Clone this repository
git clone <repo-url> ~/.config/nvim

# Start NeoVim (plugins will auto-install)
nvim

# Run tests
busted
```

---

## Current Progress Tracker

### Completed ✅
- [x] Phase 1: Foundation & TDD Infrastructure (310 tests)
- [x] Phase 2: Core Module (170 tests)
- [x] Phase 3: UI & Visual (11 tests)
- [x] Phase 4: TreeSitter (37 tests)
- [x] Phase 5: LSP System (47 tests)

**Total: 575 tests passing (100% success rate)**

### In Progress ⏳
- [ ] Phase 6: Completion (nvim-cmp + LuaSnip)

### Pending ⏸️
- [ ] Phase 7-14: Navigation, Git, Debugging, Testing, AI, Editor Enhancements, Documentation

---

## Notes for Future Sessions

### Context Preservation
- This file (`CLAUDE.md`) contains the complete project context
- Always read this file at the start of each session
- Update progress tracker after completing tasks
- Add notes about decisions and changes

### Code Quality Standards
- Every function must have docstring
- Every module must have explanation
- Every feature must have tests
- 80%+ test coverage required
- Code must pass luacheck linting

### Learning Resources (for user)
- [Learn Lua in Y minutes](https://learnxinyminutes.com/docs/lua/)
- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)
- [LuaLS Annotations](https://luals.github.io/wiki/annotations/)

### Key Decisions Made
1. **Plugin Manager**: lazy.nvim (most popular, packer archived)
2. **Testing**: busted (most mature Lua testing framework)
3. **LSP**: nvim-lspconfig + mason.nvim (standard stack)
4. **Completion**: nvim-cmp (most popular, best maintained)
5. **Fuzzy Finder**: telescope.nvim (most extensible)
6. **Statusline**: lualine.nvim (most popular)

### Architecture Decisions
1. **Modular Design**: Each feature is a separate module
2. **Dependency Injection**: Modules declare dependencies explicitly
3. **Event Bus**: Inter-module communication via events
4. **Configuration Schema**: Validate user config with schema
5. **Extension System**: Users can add custom modules via hooks

### Gotchas & Pitfalls
1. **Lua Indexing**: Tables are 1-indexed, not 0-indexed
2. **Global Scope**: Always use `local` unless explicitly global
3. **Module Caching**: `require()` caches modules, reload with `package.loaded[name] = nil`
4. **Async APIs**: Use vim.schedule() for delayed execution
5. **Plugin Loading**: lazy.nvim loads on-demand, test with :Lazy load <plugin>

---

## Version History

- **v0.1.0** (2025-11-12): Initial project setup and planning
  - Created project structure
  - Researched plugin ecosystem
  - Defined development phases
  - Established coding standards

---

*End of Development Plan*
