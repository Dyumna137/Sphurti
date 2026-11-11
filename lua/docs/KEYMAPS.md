# Neovim Keymap Reference

Leader key: `Space` (`<leader>`). The leader should be assigned at the top of `init.lua` before Lazy.nvim setup.

## Find and files

Your existing `plugins/telescope.lua` owns file-search mappings. Keep those definitions and use `:verbose nmap <Space>f` or `:Telescope` to inspect the actual shortcuts. The core keymap file does not overwrite those mappings.

| Shortcut | Action |
|---|---|
| `Space e` | Open built-in netrw in current window |
| `Space E` | Toggle netrw left explorer |

## Buffers

| Shortcut | Action |
|---|---|
| `Tab` | Next buffer |
| `Shift-Tab` | Previous buffer |
| `Space bb` | Choose an open buffer with Telescope |
| `Space bd` | Delete current buffer |
| `Space bn` | New scratch buffer |
| `Space bc` | Close hidden, unmodified buffers only |

## Windows and tabs

| Shortcut | Action |
|---|---|
| `Space wv` | Vertical split |
| `Space ws` | Horizontal split |
| `Space we` | Equalise split sizes |
| `Space wc` | Close current split |
| `Space wo` | Keep only current split |
| `Ctrl-h/j/k/l` | Move between windows |
| `Ctrl-Arrow` | Resize current split |
| `Space to` | New tab page |
| `Space tx` | Close tab page |
| `Space tn/tp` | Next/previous tab page |

Use buffers for ordinary file switching. Use tab pages for separate workspace layouts.

## Terminal and output panels

| Shortcut | Action |
|---|---|
| `Space tt` | Toggle persistent project terminal |
| `Esc Esc` (terminal mode) | Leave terminal input mode |
| `Ctrl-h/j/k/l` (terminal mode) | Move between windows |
| `Space pp` | Toggle current output panel |
| `Space pb` | Show build output |
| `Space pr` | Show run output |
| `Space pt` | Show test output |
| `Space p+` / `Space p-` | Increase/decrease panel height |
| `:IDEPanel git` | Show Git output panel |
| `:IDEPanel serial` | Show serial panel |
| `:ProjectTerminal` | Open persistent terminal |

## Build and embedded work

| Shortcut | Action |
|---|---|
| `Space mb` | Build project |
| `Space mr` | Run executable (asks for path) |
| `Space mt` | Run tests |
| `Space mf` | Flash firmware |
| `Space mm` | Start serial monitor |
| `Space md` | Check common debugging tools |
| `Space ch` | clangd switch source/header |

## Git

| Shortcut | Action |
|---|---|
| `Space gs` | Git status (Fugitive if installed, otherwise output panel) |
| `Space gd` | Working-tree diff |
| `Space gD` | Staged diff |
| `Space gl` | Recent commit graph |
| `Space gb` | Blame current file |

The keymaps intentionally do not stage, commit, reset or push automatically. Use the Git CLI in the terminal for those operations so the exact changes remain visible and deliberate.

## Diagnostics and quickfix

| Shortcut | Action |
|---|---|
| `Space dd` | Put diagnostics in quickfix and open it |
| `Space dl` | Show LSP/diagnostics report |
| `Space df` | Show diagnostic float on current line |
| `]d` / `[d` | Next/previous diagnostic |
| `Space qo` / `Space qc` | Open/close quickfix |
| `]q` / `[q` | Next/previous quickfix item |

## Notes and editing

| Shortcut | Action |
|---|---|
| `Ctrl-s` | Save if changed (normal/insert mode) |
| `Space wf` | Write without autocommands |
| `Space nd` | Insert date |
| `Space nt` | Insert time |
| `Space nn` | New temporary Markdown scratch buffer |
| `Space tw` | Toggle line wrapping |
| `Space y` + motion | Yank to system clipboard |
| `Space Y` | Yank line to system clipboard |
| `Space +` / `Space -` | Increment/decrement number |

## Core Vim motions worth practising

| Motion | Action |
|---|---|
| `w`, `b`, `e` | Word navigation |
| `W`, `B`, `E` | WORD navigation (whitespace-delimited) |
| `0`, `^`, `$` | Line start, first nonblank, line end |
| `gg`, `G` | File start/end |
| `f<char>`, `t<char>` | Find/till character on current line |
| `;`, `,` | Repeat character search forward/reverse |
| `%` | Matching bracket |
| `{`, `}` | Previous/next paragraph-like block |
| `*`, `#` | Search word under cursor forward/backward |
| `Ctrl-o`, `Ctrl-i` | Older/newer jump location |
| `ma`, `'a` | Set mark `a`, jump to mark `a` |
| `ciw`, `diw`, `yiw` | Change/delete/yank inside word |
| `ci(`, `ci{`, `ci"` | Change inside parentheses/braces/quotes |
| `va{`, `vi{` | Select around/inside braces |

## Keymap inspection

```vim
:map                  " All mappings
:nmap                 " Normal-mode mappings
:imap                 " Insert-mode mappings
:tmap                 " Terminal-mode mappings
:verbose nmap <Space>mb
:verbose nmap <Space>tt
:verbose nmap <Space>gs
```

`:verbose nmap` shows where a mapping was last defined. Use it to find plugin/config collisions.
