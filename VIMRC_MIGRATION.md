# Vimrc Migration Session Context

**Last Updated:** 2025-11-15
**Status:** In Progress - Phase 1 (Folding) Complete

## Overview

Migrating configuration from `~/.config/dotfiles/vim/vimrc` (1300+ lines VimScript) to modern Neovim Lua config.

### Old Config Highlights

- **Size:** 1300+ lines of VimScript
- **Plugin Manager:** vim-plug with 50+ plugins
- **Focus:** Ruby/Rails, JavaScript/TypeScript, Python, web development
- **Notable Features:** Custom fold text, extensive mappings, CoC + ALE setup

### New Config Status

- **Structure:** Modular Lua architecture
- **Plugin Manager:** lazy.nvim
- **LSP:** Native nvim-lsp (replaces CoC)
- **Already Has:** Telescope, nvim-tree, treesitter, git integration, testing

---

## What We've Completed

### ✅ Phase 1: Folding Implementation (DONE)

**Created:** `lua/modules/editor/folding.lua`

- Treesitter-aware fold text with icons
- Hybrid icons: Nerd fonts + emojis (📦 classes, 📥 imports, 🧪 tests)
- 30+ node type mappings
- Smart fallback for non-treesitter files

**Decision Made:** Chose treesitter folding over marker-based

- More intelligent (understands code structure)
- No manual markers needed
- Medium complexity implementation

---

## Migration Plan: Remaining Phases

### Phase 2: Core Settings (NEXT PRIORITY)

**Location:** `lua/modules/core/options.lua`

Port missing settings from vimrc lines 625-764:

- [ ] Fold column configuration (currently 0)
- [ ] Wild menu settings (already mostly done)
- [ ] Confirm, shiftround options
- [ ] History and undo levels (1000)
- [ ] Split behavior (already done)
- [ ] Backup/swap/undo directories (custom paths)
- [ ] Viminfo/shada settings
- [ ] Match pairs (`<:>` for HTML)
- [ ] Keywords settings (`iskeyword`)
- [ ] Report setting
- [ ] Mouse hide option
- [ ] Autoread
- [ ] Fillchars and listchars
- [ ] Showbreak character
- [ ] Textwidth (79)
- [ ] Format program (par)
- [ ] Encoding settings (mostly done)
- [ ] File formats (unix,mac,dos)

### Phase 3: Mappings Migration

**Location:** Create `lua/modules/core/custom_keymaps.lua`

Port custom mappings from vimrc lines 1005-1087:

- [ ] `<leader><space>` - Clear search highlighting
- [ ] `<Space>` - Toggle fold (already done)
- [ ] Visual mode indent (already done: `>gv`, `<gv`, `=gv`)
- [ ] `<leader>syn` - Show syntax groups under cursor
- [ ] `<leader>nw` - Strip trailing whitespace
- [ ] `<leader>h1`, `<leader>h2` - Documentation headers
- [ ] `<C-X>`, `<C-C>` - Cut/copy to system clipboard
- [ ] `<leader>v` - Smart paste with auto-indent
- [ ] `<leader>spl` - Toggle spell checking
- [ ] Spell correction shortcuts

### Phase 4: Plugin Migration

**Status:** Partial - many already replaced

| Old Plugin | Modern Alternative | Status | Notes |
|------------|-------------------|---------|-------|
| ✅ CoC.nvim | Native LSP + nvim-cmp | Done | Verify keymaps match workflow |
| ⚠️ ALE | conform.nvim | **TODO** | Need formatter setup |
| ❌ vim-airline | lualine/feline | **TODO** | No statusline currently |
| ✅ NERDTree | nvim-tree | Done | Port NERDTree keymaps |
| ✅ FZF | Telescope | Done | Port FZF keymaps |
| ✅ vim-fugitive | vim-fugitive | Done | Keep using it |
| ✅ UltiSnips | LuaSnip | Done | Verify snippets, triggers |
| ❓ indentLine | indent-blankline | **CHECK** | May already be there |
| ✅ vim-surround | nvim-surround | Done | |
| ✅ vim-commentary | Comment.nvim | Done | |
| ✅ auto-pairs | nvim-autopairs | Done | |
| ✅ vim-test | neotest | Done | Port test keymaps |
| ❓ GitHub Copilot | copilot.lua | **CHECK** | Verify AI config |
| ⚠️ vim-projectionist | rails.vim + custom | **TODO** | Port projectionist configs |
| ✅ vim-unimpaired | Port mappings | **TODO** | Port specific mappings |
| ✅ vim-repeat | Already works | Done | Plugin support built-in |
| ❓ vim-devicons | nvim-web-devicons | **CHECK** | Likely already there |
| ⚠️ emmet-vim | Needs config | **TODO** | Check if LSP provides this |
| ⚠️ vim-closetag | Needs config | **TODO** | Auto-close HTML tags |
| ⚠️ MatchTagAlways | Needs check | **TODO** | Highlight enclosing tags |
| ⚠️ committia.vim | Check modern alt | **TODO** | Better git commit editing |
| ⚠️ git-messenger | Check modern alt | **TODO** | Show git blame popup |
| ⚠️ conflict-marker | Check modern alt | **TODO** | Highlight merge conflicts |
| ⚠️ vista.vim | aerial.nvim? | **TODO** | Tag/symbol viewer |
| ✅ vim-slim | treesitter | Done | If parser available |
| ✅ vim-ruby-fold | treesitter | Done | Treesitter handles this |

**Priority Plugins to Add:**

1. **statusline** (lualine or feline) - Currently missing
2. **conform.nvim** - For formatting (replaces ALE fixers)
3. **indent-blankline** - If not already present
4. **aerial.nvim** - Outline/symbol viewer (replaces vista)

### Phase 5: Filetype-Specific Settings

**Location:** Create `lua/modules/core/filetype_settings.lua`

Port autocmds from vimrc lines 1235-1342:

- [ ] Markdown (spell, textwidth, tabs)
- [ ] HTML/XML/CSS (textwidth=0, tab settings)
- [ ] JavaScript/TypeScript (tab settings, json conceal)
- [ ] CSS/SCSS (smartindent, prettier equalprg)
- [ ] Ruby/ERB (fold method, tabs, standardrb mapping)
- [ ] YAML (tab settings)
- [ ] Slim (filetype detection, fold indent)
- [ ] Python (PEP8: tabs, textwidth, nocindent)
- [ ] SQL (tabs, fold marker, comment string)
- [ ] Nginx conf (filetype detection)
- [ ] PKGBUILD (syntax detection)

### Phase 6: Quality of Life Features

**Locations:** Various modules

- [ ] Conflict marker highlighting (vimrc:744)
- [ ] Jump to next conflict marker (`<leader>c`)
- [ ] Problematic whitespace highlighting
- [ ] Auto-create parent directories on save (vimrc:1189-1199)
- [ ] Save on focus lost (vimrc:1184)
- [ ] Open at last edit position (vimrc:1187)
- [ ] Help window setup function (vimrc:1172-1176)
- [ ] Comment banners (`<leader>hr`, `<leader>cb`)
- [ ] Syntax group inspector (already in mappings)

### Phase 7: Abbreviations

**Location:** Create `lua/modules/core/abbreviations.lua`

Port from vimrc lines 1092-1144:

- [ ] Date abbreviations (rdate, pxdate, ldate, sdate)
- [ ] Common typo corrections (retunr→return, sefl→self, etc.)
- [ ] Signatures (ssig, lsig)
- [ ] Placeholders (lorem ipsum)

### Phase 8: Specialized Workflows

- [ ] Git commit message formatting (vimrc:376-387)
- [ ] Rails projections (if using Rails)
- [ ] Angular settings (if using Angular)
- [ ] REPL integration (reply.vim equivalent)
- [ ] Terraform support
- [ ] Markdown preview settings

---

## Key Decisions Made

1. **Folding:** Treesitter-based (not marker) - More intelligent, automatic
2. **Icon Style:** Hybrid nerd fonts + emojis (📦, 📥, 🧪 for visual pop)
3. **Fold Complexity:** Medium - Good balance of info vs maintenance

---

## Old Vimrc Key Features to Preserve

### Essential Mappings

- `<leader>,` = `,` (set in vimrc:48)
- `<leader><space>` - Clear search
- `<leader>nw` - Strip whitespace
- `<leader>v` - Smart paste
- Test mappings: `<leader>tf/tl/tn/ts`

### Linting/Formatting (ALE config)

```vim
let g:ale_fixers = {
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'javascript': ['prettier', 'eslint'],
  \ 'ruby': ['standardrb'],
  \ 'eruby': ['erblint']
\}
let g:ale_fix_on_save = 1
```

### Test Mappings (vim-test)

```vim
<leader>tf - TestFile
<leader>tl - TestLast
<leader>tn - TestNearest
<leader>ts - TestSuite
```

### FZF Mappings (need Telescope equivalents)

```vim
<C-p>   - GFiles (git files)
<C-p>g  - Rg (ripgrep search)
<C-p>h  - History
<C-p>c  - Commits
<C-p>a  - Commands
<C-p>b  - NERDTreeToggle
```

---

## Current Nvim Config Structure

```text
lua/
├── nvim/
│   ├── core/          # Framework core
│   └── lib/           # Utilities
└── modules/
    ├── core/          # Options, keymaps, autocmds, commands
    ├── ui/            # Colorscheme, statusline (TODO)
    ├── completion/    # nvim-cmp, snippets
    ├── treesitter/    # Syntax, folding
    ├── lsp/           # Native LSP
    ├── navigation/    # Telescope, nvim-tree
    ├── git/           # Fugitive, gitsigns
    ├── editor/        # Autopairs, surround, comment, folding ✅
    ├── test/          # Neotest
    ├── debug/         # DAP
    ├── frameworks/    # Rails, Angular
    ├── ai/            # Copilot/AI
    └── tooling/       # REPLs, HTTP, database
```

---

## Next Steps (Recommended Order)

1. **Phase 4 (Plugins)** - Add statusline and formatter immediately
   - Add lualine.nvim for statusline
   - Add conform.nvim for formatting

2. **Phase 3 (Mappings)** - Port essential keybindings
   - Critical: `<leader>nw`, `<leader>v`, test mappings
   - FZF → Telescope mapping conversions

3. **Phase 2 (Settings)** - Fine-tune vim options
   - Less urgent, but needed for exact match

4. **Phase 5 (Filetype)** - Add as you work with each language
   - Ruby/Rails settings (likely most used)
   - JavaScript/TypeScript settings

5. **Phase 6-8** - Quality of life (as needed)
   - Add when you miss specific features

---

## Testing Checklist

When resuming:

- [ ] Test folding with various file types
- [ ] Verify LSP keymaps match old CoC workflow
- [ ] Check if snippets work like UltiSnips
- [ ] Test git integration (fugitive commands)
- [ ] Verify telescope replaces FZF functionality
- [ ] Check test runner keymaps work
- [ ] Verify formatters run on save

---

## Files to Reference

- **Old config:** `~/.config/dotfiles/vim/vimrc` (1344 lines)
- **Current config:** `~/.config/nvim/`
- **Migration doc:** `~/.config/nvim/VIMRC_MIGRATION.md` (this file)

---

## Notes

- Your old vimrc is well-organized with fold markers and comments
- Many plugins have modern replacements that are faster/better
- The new config is more modular and testable
- Treesitter replaces many old syntax plugins
- Native LSP is more powerful than CoC for most use cases
