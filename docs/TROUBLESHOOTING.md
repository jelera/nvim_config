# Troubleshooting Guide

## Plugin Issues

### Plugins not loading
```vim
" Check lazy.nvim status
:Lazy

" Force plugin update
:Lazy sync
```

```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
nvim
```

### Plugin errors on startup
```vim
" Check health
:checkhealth

" View startup log
:messages
```

## LSP Issues

### LSP not attaching
```vim
" Check LSP status
:LspInfo

" Check available servers
:Mason

" Restart LSP
:LspRestart
```

### LSP server not found
```vim
" Install via Mason
:Mason
" Find server and press 'i' to install

" Or auto-install on file open (configured by default)
```

### Slow LSP performance
```lua
-- Disable features in module config
require('modules.lsp').setup({
  diagnostics = {
    update_in_insert = false  -- Disable diagnostic updates in insert mode
  }
})
```

## Completion Issues

### Completion not working
1. Check nvim-cmp is loaded: `:Lazy load nvim-cmp`
2. Check LSP is attached: `:LspInfo`
3. Verify sources in `:CmpStatus`

### Wrong completion source
Check source priority in `modules/completion/completion.lua` - LSP should be first.

## TreeSitter Issues

### Syntax highlighting broken
```vim
" Update parsers
:TSUpdate

" Check installed parsers
:TSInstallInfo

" Reinstall specific parser
:TSInstall <language>
```

### TreeSitter errors
```bash
# Clear cache and reinstall
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
```

```vim
:Lazy sync
:TSUpdate
```

## Performance Issues

### Slow startup (>500ms)
```vim
" Profile startup
:StartupTime

" Profile plugins
:Lazy profile
```

### Common fixes
1. Reduce LSP workspace folders
2. Disable unused modules in config
3. Use `event = 'VeryLazy'` for non-critical plugins
4. Disable TreeSitter indent for large files

### Slow editing
```lua
-- Disable features for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function()
    if vim.fn.getfsize(vim.fn.expand('%')) > 1000000 then
      vim.cmd('syntax off')
      vim.cmd('TSBufDisable highlight')
    end
  end
})
```

## Git Integration

### Git signs not showing
1. Check git repository: `git status`
2. Verify gitsigns loaded: `:Lazy load gitsigns.nvim`
3. Restart: `:Gitsigns refresh`

### Fugitive commands not working
```vim
" Check vim-fugitive is loaded
:Lazy load vim-fugitive

" Verify git executable
:echo executable('git')
```

## Testing

### Tests not running
1. Check adapter installed: `:Lazy load neotest-<adapter>`
2. Verify test file pattern matches adapter config
3. Check test command: `:Neotest output`

### Wrong test adapter
Check adapter priority in `modules/test/adapters/` - language-specific adapters should load first.

## Debug (DAP)

### Debugger not starting
1. Check DAP adapter installed: `:Mason`
2. Verify adapter config for language
3. Check `:DapShowLog`

### Breakpoints not hit
1. Verify source maps for JS/TS
2. Check file paths match in DAP config
3. Use `:DapContinue` not `:DapToggleBreakpoint` to start

## Common Error Messages

### "module 'X' not found"
Plugin not loaded - check `:Lazy` or module disabled in config.

### "LSP client quit with exit code 1"
```vim
" Server crashed - check logs
:LspLog
```

```vim
" Reinstall server via Mason
:Mason
" Uninstall (X) then reinstall (i)
```

### "treesitter parser not found"
```vim
:TSInstall <language>
```

## Getting More Help

1. Check `:checkhealth`
2. Read plugin docs: `:help <plugin-name>`
3. View messages: `:messages`
4. Check logs:
   - LSP: `~/.local/state/nvim/lsp.log`
   - Mason: `:MasonLog`
   - DAP: `:DapShowLog`

## Reset Everything

```bash
# Nuclear option - fresh start
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
nvim
```
