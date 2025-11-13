# Keymap Reference

Quick reference for all keybindings. Leader key: `,`

## Core Editing

| Key | Mode | Action |
|-----|------|--------|
| `<leader><space>` | n | Clear search highlight |
| `<space>` | n | Toggle fold |
| `>` | v | Indent right (keep selection) |
| `<` | v | Indent left (keep selection) |
| `=` | v | Auto indent (keep selection) |
| `<C-X>` | v | Cut to system clipboard |
| `<C-C>` | v | Copy to system clipboard |
| `<leader>v` | n | Paste from system clipboard |
| `<leader>nw` | n | Remove trailing whitespace |
| `<leader>spl` | n | Toggle spell checking |

## LSP

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gr` | n | Go to references |
| `gi` | n | Go to implementation |
| `gt` | n | Go to type definition |
| `K` | n | Show hover documentation |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n | Code actions |
| `<leader>f` | n | Format document |
| `[d` | n | Previous diagnostic |
| `]d` | n | Next diagnostic |
| `<leader>d` | n | Show line diagnostics |

## Navigation (Telescope)

| Key | Mode | Action |
|-----|------|--------|
| `<C-p>g` | n | Find files (all) |
| `<C-p>p` | n | Find files (git) |
| `<C-p>h` | n | Recent files |
| `<C-p>b` | n | Find buffers |
| `<leader>rg` | n | Live grep |
| `<C-p>w` | n | Grep word under cursor |
| `<C-p>c` | n | Git commits |
| `<C-p>s` | n | Git status |
| `<leader>fb` | n | File browser |

## File Explorer (nvim-tree)

| Key | Mode | Action |
|-----|------|--------|
| `<C-t>` | n | Toggle tree |
| `<C-B>t` | n | Find current file |
| `<leader>e` | n | Focus tree |

## Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gs` | n | Git status (fugitive) |
| `<leader>gc` | n | Git commit |
| `<leader>gp` | n | Git push |
| `<leader>gl` | n | Git pull |
| `<leader>gb` | n | Git blame |
| `<leader>gd` | n | Git diff |
| `<leader>gh` | n | Preview hunk |
| `<leader>gH` | n | Reset hunk |
| `[h` | n | Previous hunk |
| `]h` | n | Next hunk |

## Debug (DAP)

| Key | Mode | Action |
|-----|------|--------|
| `<F5>` | n | Continue/Start debugging |
| `<F10>` | n | Step over |
| `<F11>` | n | Step into |
| `<F12>` | n | Step out |
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Conditional breakpoint |
| `<leader>dr` | n | Open REPL |
| `<leader>dl` | n | Run last configuration |
| `<leader>dt` | n | Terminate session |
| `<leader>du` | n | Toggle debug UI |

## Testing (neotest)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tn` | n | Test nearest |
| `<leader>tf` | n | Test file |
| `<leader>ts` | n | Test suite |
| `<leader>tl` | n | Test last |
| `<leader>to` | n | Toggle test output |
| `<leader>tS` | n | Toggle test summary |

## AI (sidekick.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>aa` | n | Accept NES suggestion |
| `<leader>an` | n | Next NES hunk |
| `<leader>ap` | n | Previous NES hunk |
| `<leader>ar` | n | Reject NES suggestion |
| `<leader>at` | n | Open AI terminal |
| `<leader>ac` | n | AI chat |
| `<leader>as` | v | Send selection to AI |
| `<leader>aq` | n | Close AI terminal |
| `<leader>ai` | n | Toggle sidekick |

## Editor Enhancements

### Auto-pairs
| Key | Mode | Action |
|-----|------|--------|
| `<M-e>` | i | Fast wrap |

### Surround
| Key | Mode | Action |
|-----|------|--------|
| `ys{motion}{char}` | n | Add surround |
| `yss{char}` | n | Surround line |
| `ds{char}` | n | Delete surround |
| `cs{old}{new}` | n | Change surround |
| `S{char}` | v | Surround selection |

### Comment
| Key | Mode | Action |
|-----|------|--------|
| `gcc` | n | Toggle line comment |
| `gbc` | n | Toggle block comment |
| `gc{motion}` | n | Comment motion |
| `gb{motion}` | n | Block comment motion |
| `gc` | v | Comment selection |

### Sessions & Projects
| Key | Mode | Action |
|-----|------|--------|
| `<leader>sr` | n | Restore last session |
| `<leader>sl` | n | Load session for cwd |
| `<leader>ss` | n | Stop session |
| `<leader>fp` | n | Find projects |

## Window/Buffer Management

| Key | Mode | Action |
|-----|------|--------|
| `<C-h>` | n | Move to left window |
| `<C-j>` | n | Move to down window |
| `<C-k>` | n | Move to up window |
| `<C-l>` | n | Move to right window |
| `<leader>bd` | n | Delete buffer |
| `<leader>bn` | n | Next buffer |
| `<leader>bp` | n | Previous buffer |
