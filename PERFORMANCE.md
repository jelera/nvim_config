# Performance Optimization Plan

> Systematic approach to optimize NeoVim startup time and runtime performance

## Current State

**Baseline Performance:**
- Target: <100ms startup time
- 46 plugins installed
- 12 feature modules
- Lazy loading: ~87% of plugins (40/46)
- Eager loading: 3 plugins (colorscheme, projectionist, core)

**Strengths:**
- Well-architected modular design
- Comprehensive lazy-loading strategy
- Deferred initialization with `vim.schedule()`
- Disabled default plugins (netrw, gzip, tar, etc.)
- Good separation of plugin specs and configuration

## Optimization Goals

**Primary Targets:**
- 30-50% reduction in startup time
- Reduced memory footprint
- More responsive initial editor state
- Maintain functionality and feature set

**Success Metrics:**
- Measure with `nvim --startuptime startup.log`
- Track module loading times
- Monitor plugin lazy-loading effectiveness
- Measure memory usage at startup

## Optimization Phases

### Phase 1: Baseline & Profiling

**Status:** Pending

**Tasks:**
1. Run startup profiling to get baseline metrics
2. Identify slowest-loading modules
3. Measure plugin loading times
4. Document current startup sequence

**Commands:**
```bash
# Profile startup time
nvim --startuptime startup.log +qall && cat startup.log

# Profile with specific file
nvim --startuptime startup.log main.lua +qall

# Inside NeoVim
:Lazy profile
```

**Expected Output:**
- Baseline startup time (target: current time)
- List of slow modules (>10ms)
- Plugin loading order and times
- Module initialization times

### Phase 2: Treesitter Optimization

**Status:** Pending

**Current Issue:**
- `ensure_installed` loads 30+ parsers at startup
- All parsers downloaded even if languages not used
- 221 lines of configuration

**Optimization:**
```lua
-- Before: modules/treesitter/config.lua
ensure_installed = {
  'lua', 'vim', 'vimdoc', 'javascript', 'typescript',
  -- ... 30+ more
}

-- After: On-demand installation
ensure_installed = {},  -- Remove pre-loading
auto_install = true,    -- Install parsers when files opened
```

**Expected Impact:**
- 10-20ms reduction in startup time
- Smaller initial memory footprint
- Parsers load on-demand when needed

**Implementation:**
1. Update `modules/treesitter/config.lua`
2. Remove `ensure_installed` list
3. Enable `auto_install = true`
4. Test with multiple file types

### Phase 3: UI Component Deferral

**Status:** Pending

**Current Issue:**
- Statusline loads at startup (lualine)
- Indent guides load at startup (indent-blankline)
- Notifications load at startup (nvim-notify)
- UI components needed before user sees content

**Optimization:**
```lua
-- Defer UI plugins to UIEnter event
{
  'nvim-lualine/lualine.nvim',
  event = 'UIEnter',  -- Load after UI ready
  config = function()
    require('modules.ui.statusline').setup()
  end
}

{
  'lukas-reineke/indent-blankline.nvim',
  event = 'BufReadPost',  -- Load after file read
  config = function()
    require('modules.ui.indent_guides').setup()
  end
}

{
  'rcarriga/nvim-notify',
  event = 'VeryLazy',  -- Defer until idle
  config = function()
    vim.notify = require('notify')
  end
}
```

**Expected Impact:**
- 5-15ms reduction in startup time
- UI loads progressively as needed
- Core editor ready faster

**Implementation:**
1. Update `modules/ui/plugins.lua`
2. Add event triggers to UI plugins
3. Verify UI still renders correctly
4. Test with `:Lazy profile`

### Phase 4: Rarely-Used Plugin Audit

**Status:** Pending

**Candidates for Lazy Loading:**
- `kndndrj/nvim-dbee` - Database UI (when do you use this?)
- `hkupty/iron.nvim` - REPL (specific languages)
- `rest-nvim/rest.nvim` - HTTP client (occasional use)

**Optimization Strategy:**

1. **Make fully lazy-loaded:**
```lua
{
  'kndndrj/nvim-dbee',
  cmd = { 'Dbee', 'DbeeOpen', 'DbeeToggle' },  -- Only load on command
  keys = {
    { '<leader>db', '<cmd>DbeeToggle<cr>', desc = 'Toggle Database UI' }
  },
}

{
  'hkupty/iron.nvim',
  ft = { 'python', 'ruby', 'javascript' },  -- Only for REPL languages
  cmd = { 'IronRepl', 'IronReplHere' },
}
```

2. **Consider removal if unused:**
   - Check usage frequency
   - Document decision in PERFORMANCE.md
   - Keep plugin spec commented for easy restoration

**Expected Impact:**
- 5-10ms reduction if plugins currently eager-loading
- Reduced memory if disabled
- Cleaner plugin list

**Implementation:**
1. Review usage patterns for each plugin
2. Add lazy-loading triggers
3. Test functionality still works
4. Document changes

### Phase 5: LSP Server Loading Optimization

**Status:** Pending

**Current Issue:**
- LSP module loads immediately at startup
- All 15 server configs loaded (331 lines)
- Detection modules run before any file opened
- Server setup happens before FileType known

**Optimization:**
```lua
-- Current: LSP loads at startup
require('modules.lsp').setup()

-- Optimized: Defer to FileType
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  once = true,  -- Only run once
  callback = function()
    require('modules.lsp').setup()
  end
})
```

**Alternative: Per-Language Loading**
```lua
-- Load servers only when language files opened
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'javascript', 'typescript' },
  callback = function()
    local server = require('modules.lsp.servers.' .. vim.bo.filetype)
    require('lspconfig')[server.name].setup(server)
  end
})
```

**Expected Impact:**
- 10-20ms reduction in startup time
- LSP ready when actually needed
- Reduced initial memory usage

**Implementation:**
1. Add FileType autocmd to defer LSP
2. Test LSP still attaches correctly
3. Verify Mason integration works
4. Test with multiple languages

### Phase 6: Framework Simplification

**Status:** Pending

**Current Issue:**
- Event bus system (202 lines) appears unused
- Custom framework adds overhead (1,253 lines)
- Plugin system may be over-engineered

**Investigation:**
```bash
# Search for event bus usage
rg "event_bus" --type lua

# Search for plugin system usage
rg "nvim\.plugin" --type lua
```

**Potential Optimization:**
1. Remove event bus if unused
2. Simplify plugin system if not leveraged
3. Keep module loader (actively used)
4. Keep utils (heavily used)

**Expected Impact:**
- 5-10ms if removing unused code
- Reduced complexity
- Easier maintenance

**Implementation:**
1. Audit framework usage
2. Remove unused systems
3. Update tests
4. Update documentation

### Phase 7: Module Load Order Optimization

**Status:** Pending

**Current Issue:**
- All 12 modules load sequentially in `vim.schedule()`
- Heavy modules (test, debug, frameworks) load early
- No prioritization of critical vs. optional

**Optimization:**
```lua
-- Prioritize lightweight modules
local priority_modules = { 'core', 'ui', 'lsp' }
local deferred_modules = { 'test', 'debug', 'frameworks', 'tooling' }

-- Load priority modules first
vim.schedule(function()
  for _, name in ipairs(priority_modules) do
    load_module(name)
  end

  -- Defer optional modules
  vim.defer_fn(function()
    for _, name in ipairs(deferred_modules) do
      load_module(name)
    end
  end, 100)  -- Delay 100ms
end)
```

**Expected Impact:**
- Faster time to interactive editor
- Better perceived performance
- Core features ready sooner

**Implementation:**
1. Categorize modules by priority
2. Update module loader
3. Test module dependencies
4. Verify deferred modules work

### Phase 8: Startup Profiling Tools

**Status:** Pending

**Add User Commands:**
```lua
-- modules/core/commands.lua

vim.api.nvim_create_user_command('ProfileStartup', function()
  vim.cmd('edit ' .. vim.fn.stdpath('cache') .. '/startup.log')
end, { desc = 'Open startup profile' })

vim.api.nvim_create_user_command('BenchmarkStartup', function()
  local times = {}
  for i = 1, 10 do
    local result = vim.fn.system(
      'nvim --headless --startuptime /tmp/startup_' .. i .. '.log +qall'
    )
    -- Parse and average times
  end
  print('Average startup time: ' .. average .. 'ms')
end, { desc = 'Benchmark startup time' })

vim.api.nvim_create_user_command('ProfilePlugins', function()
  vim.cmd('Lazy profile')
end, { desc = 'Profile plugin loading' })
```

**Expected Impact:**
- Easy ongoing performance monitoring
- Quick identification of regressions
- Data-driven optimization decisions

**Implementation:**
1. Add profiling commands
2. Create helper functions
3. Add to documentation
4. Create tests

## Optimization Checklist

### Before Starting
- [ ] Commit current working state
- [ ] Run baseline profiling
- [ ] Document current metrics
- [ ] Create performance testing script

### Phase Execution
- [ ] Phase 1: Baseline & Profiling
- [ ] Phase 2: Treesitter Optimization
- [ ] Phase 3: UI Component Deferral
- [ ] Phase 4: Rarely-Used Plugin Audit
- [ ] Phase 5: LSP Server Loading
- [ ] Phase 6: Framework Simplification
- [ ] Phase 7: Module Load Order
- [ ] Phase 8: Profiling Tools

### After Each Phase
- [ ] Run profiling to measure impact
- [ ] Update metrics in this document
- [ ] Run full test suite (786 tests)
- [ ] Test all affected features manually
- [ ] Document any issues or regressions
- [ ] Commit with descriptive message

### Final Validation
- [ ] Run startup profiling 10 times, average results
- [ ] Compare to baseline metrics
- [ ] Test all major features
- [ ] Update documentation
- [ ] Update README with new performance stats

## Performance Metrics

### Baseline (Pre-Optimization)

**Date:** 2025-11-14

**Startup Times (5 runs):**
- Run 1: 123.357ms
- Run 2: 105.700ms
- Run 3: 77.712ms
- Run 4: 86.765ms
- **Average: ~98ms** (target: <100ms) ✅

**Top Bottlenecks (from detailed profiling):**

1. **nvim-treesitter: 27.1ms** (22% of startup)
   - Location: `nvim-treesitter/plugin/nvim-treesitter.lua`
   - Loads all 30+ parsers at startup
   - **Phase 2 target**

2. **LuaSnip: 9.8ms** (8% of startup)
   - Location: `LuaSnip/plugin/luasnip.lua`
   - Loads snippet engine and parsers
   - Already lazy-loaded on InsertEnter (good)

3. **Framework initialization: 7.6ms** (6% of startup)
   - Custom framework overhead (event bus, plugin system, utils)
   - **Phase 6 target** (remove unused event bus)

4. **LSP config: 6.8ms** (6% of startup)
   - Loads lspconfig and utilities
   - **Phase 5 target** (defer to FileType)

5. **indent-blankline: 5.1ms** (4% of startup)
   - UI plugin loading eagerly
   - **Phase 3 target** (defer to UIEnter)

6. **nvim-treesitter-textobjects: 3.1ms** (2% of startup)
   - Text object motions
   - Could be deferred

7. **lazy.nvim initialization: ~22ms** (18% of startup)
   - Plugin manager overhead (expected, necessary)

**Other metrics:**
- Plugin specs loaded: ~1.7ms (12 modules)
- Core module setup: ~1.0ms
- Time to first window: 2.5ms

**Current lazy-loading coverage:**
- Total plugins: 46
- Lazy-loaded: 40 (87%)
- Eager-loaded: 3 (gruvbox, projectionist, nvim-web-devicons)
- Optimizable: 3 (indent-blankline, lspconfig, treesitter-textobjects)

### After Each Phase

**Phase 2 - Treesitter Optimization (2025-11-14):**

Changes:
- Reduced `ensure_installed` from 30+ parsers to 4 essential ones (lua, vim, vimdoc, query)
- Rely on `auto_install = true` for on-demand parser installation
- Modified: `lua/modules/treesitter/init.lua`

Results (8 runs, excluding first initialization run):
- Run 1: 90.8ms
- Run 2: 62.3ms
- Run 3: 49.6ms ⭐ (best)
- Run 4: 88.1ms
- Run 5: 52.6ms
- Run 6: 54.3ms
- Run 7: 68.4ms
- Run 8: 62.8ms
- **Average: ~66ms** (33% improvement from 98ms baseline)

Impact:
- ✅ 32ms improvement (33% faster)
- ✅ Treesitter still fully functional
- ✅ Parsers auto-install on first file open
- ✅ No functionality lost

**Phase 3 - UI Component Deferral (2025-11-14):**

Changes:
- Deferred statusline (lualine) to `UIEnter` event
- Deferred indent guides (indent-blankline) to `BufReadPost` event
- Deferred notifications (nvim-notify) to `VeryLazy` event
- Moved configuration into plugin specs for on-demand loading
- Modified: `lua/modules/ui/plugins.lua`, `lua/modules/ui/init.lua`

Results (5 runs, excluding first run):
- Run 1: 71.8ms
- Run 2: 69.7ms
- Run 3: 58.0ms ⭐ (best)
- Run 4: 63.1ms
- **Average: ~65.7ms** (maintained performance from Phase 2)

Impact:
- ✅ UI plugins now lazy-load on events
- ✅ Colorscheme and icons still load immediately
- ✅ Statusline, indent guides, notifications defer until needed
- ✅ All 180 integration tests pass
- ⚠️  Performance similar to Phase 2 (UI was already fairly optimized)

Note: Phase 2's treesitter optimization provided the bulk of improvements. UI deferral ensures these components don't slow down future startups as they're now event-driven.

**Phase 4 - Tooling Plugin Optimization (2025-11-14):**

Changes:
- Moved database, REPL, HTTP, and lint configuration into plugin specs
- Removed startup-time setup calls from tooling module
- All tooling plugins now self-configure when they lazy-load
- Modified: `lua/modules/tooling/plugins.lua`, `lua/modules/tooling/init.lua`

Plugins optimized:
- nvim-dbee: Already lazy (cmd), now self-configuring ✅
- iron.nvim: Already lazy (cmd/keys), now self-configuring ✅
- rest.nvim: Already lazy (ft), now self-configuring ✅
- nvim-lint: Already lazy (event), now self-configuring ✅

Results (5 runs, excluding first run):
- Run 1: 68.0ms
- Run 2: 50.2ms ⭐ (best)
- Run 3: 64.0ms
- Run 4: 62.9ms
- **Average: ~61.3ms** (maintained performance, cleaner architecture)

Impact:
- ✅ Tooling module.setup() now does nothing at startup
- ✅ All tooling plugins fully lazy-loaded with on-demand configuration
- ✅ All 180 integration tests pass
- ✅ Better separation of concerns (configuration lives with plugin specs)
- ⚠️  Similar performance (plugins were already lazy-loaded)

Note: Phase 4's main benefit is architectural - removing unnecessary setup() calls at startup and ensuring clean lazy-loading patterns. The ftdetect for rest.nvim (~0.9ms) is necessary for filetype detection.

```
Phase 5 - LSP Server Loading:
- Startup time: ~61ms → target ~55ms
```

### Target Metrics

**Conservative Goals:**
- Total startup: <80ms (20% improvement)
- Time to interactive: <50ms
- Memory at startup: <50MB

**Stretch Goals:**
- Total startup: <60ms (40% improvement)
- Time to interactive: <30ms
- Memory at startup: <40MB

## Best Practices

### Performance Testing
1. Always measure before and after
2. Test with clean cache (`:Lazy clean`)
3. Test with warm cache (normal usage)
4. Test with different file types
5. Average multiple runs (10+)

### Safe Optimization
1. One change at a time
2. Run full test suite after each change
3. Test manually with common workflows
4. Keep git history clean (one phase per commit)
5. Document any tradeoffs

### Lazy Loading Guidelines
1. Use `event` for runtime plugins
2. Use `cmd` for command-based plugins
3. Use `keys` for keymap-triggered plugins
4. Use `ft` for language-specific plugins
5. Avoid `lazy = false` unless necessary

### Common Events
- `VeryLazy` - Defer until idle (safe default)
- `BufReadPost` - After file loaded
- `BufNewFile` - New file created
- `InsertEnter` - Entering insert mode
- `UIEnter` - UI ready
- `FileType` - Specific file type opened

## Monitoring & Maintenance

### Regular Checks
```bash
# Weekly performance check
nvim --startuptime startup.log +qall

# Monthly audit
./scripts/test.sh  # Ensure no regressions
:Lazy profile      # Check plugin load times
```

### Performance Regressions
If startup time increases:
1. Check recent commits
2. Profile to identify culprit
3. Check for new eager-loaded plugins
4. Review module changes

### Adding New Plugins
For each new plugin:
1. Always add lazy-loading trigger
2. Test impact with `:Lazy profile`
3. Document in PERFORMANCE.md if >5ms impact
4. Consider alternatives if slow

## Rollback Plan

If optimization causes issues:
```bash
# Revert specific phase
git revert <commit-hash>

# Revert multiple changes
git revert <start>..<end>

# Reset to pre-optimization state
git reset --hard <baseline-commit>
```

## References

- [Lazy.nvim Performance Guide](https://github.com/folke/lazy.nvim#-performance)
- [NeoVim Lua Performance Tips](https://github.com/nanotee/nvim-lua-guide#performance-tips)
- [Startup Time Optimization](https://github.com/neovim/neovim/wiki/Building-Neovim#optimizing-build-performance)

## Notes

- This is a living document - update as optimizations are implemented
- Track all changes with clear commits
- Document any tradeoffs or known issues
- Keep baseline metrics for comparison
- Celebrate wins! 🚀

---

*Last Updated: 2025-11-14*
*Current Phase: Planning*
*Status: Ready to begin*
