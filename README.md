# Sphurti - My Neovim Setup

My personal Neovim configuration, built over time for C/C++ and embedded systems work. Nothing fancy, just what I need to get stuff done.

## Why This Exists

I got tired of VS Code eating my RAM, so I decided to learn Neovim properly. This config is the result of a lot of trial and error, reading docs, and stealing ideas from other people's configs. 

It's optimized for:
- C/C++ development (that's what I do most)
- Embedded systems programming
- Working with makefiles and build systems
- Not wasting time waiting for plugins to load

## What's Inside

**Core stuff:**
- `lazy.nvim` - Plugin manager (fast and doesn't get in the way)
- `oil.nvim` - File explorer that actually makes sense
- `telescope` - Fuzzy finder for everything
- `treesitter` - Better syntax highlighting

**LSP & Completion:**
- Language servers for C/C++, Python, Lua, etc.
- Autocompletion that doesn't slow things down
- Inline diagnostics and error checking
- Function signatures (super helpful)

**Code Quality:**
- Auto-formatting (clang-format for C/C++)
- Linting
- Git integration (see changes inline)

**Dev Tools:**
- DAP debugger (because print statements only get you so far)
- Floating terminal (no need to alt-tab constantly)
- Live preview for markdown/HTML

**UI:**
- Kanagawa colorscheme (easy on the eyes)
- Bufferline (because I always have 20 files open)
- Lualine status bar
- Minimalist icons (no emoji bloat)

## Installation

**Requirements:**
```bash
# You need these:
neovim >= 0.9.0
git
gcc or clang (for treesitter)
ripgrep (for telescope grep)
fd (optional, makes telescope faster)

# On Ubuntu/Debian:
sudo apt install neovim git build-essential ripgrep fd-find

# Node.js for some LSP servers:
sudo apt install nodejs npm
```

**Setup:**

```bash
# Backup your current config if you have one
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this repo
git clone https://github.com/Dyumna137/Sphurti.git ~/.config/nvim

# Start nvim (plugins will auto-install, takes a minute)
nvim

# Check if everything works
:checkhealth
```

**LSP Setup:**

First time you open a C/C++ file, install the language server:
```vim
:Mason
```
Then install:
- `clangd` (C/C++)
- `lua_ls` (Lua)
- `pyright` (Python)
- Whatever else you need

## How I Use It

**Finding files:**
- `<leader>ff` - Find files (I use this constantly)
- `<leader>fg` - Grep through files (super fast with ripgrep)
- `<leader>fb` - List open buffers
- `<leader>fh` - Search help docs

**LSP stuff:**
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show documentation
- `<leader>ca` - Code actions (fix imports, etc.)
- `<leader>rn` - Rename symbol
- `[d` / `]d` - Jump between errors

**Building/Debugging:**
- `<leader>mm` - Run make
- `<leader>mc` - Run make clean
- `<F5>` - Start debugger
- `<F9>` - Toggle breakpoint
- `<F10>` - Step over
- `<F11>` - Step into

**Terminal:**
- `<leader>tt` - Floating terminal (opens in current file's directory)
- `<leader>tw` - Floating terminal (opens in project root)
- `<Esc><Esc>` - Close terminal

**Other:**
- `<leader>e` - File explorer (oil.nvim)
- `gcc` - Comment/uncomment line
- `<leader>xx` - Show all errors/warnings (trouble.nvim)

## File Structure

```
~/.config/nvim/
├── init.lua                    # Main config (start here)
├── lua/
│   ├── core/
│   │   ├── options.lua        # Vim options
│   │   └── keymaps.lua        # Keybindings
│   └── plugins/
│       ├── lsp.lua            # LSP config
│       ├── autocompletion.lua # Completion setup
│       ├── telescope.lua      # Fuzzy finder
│       ├── debug.lua          # DAP debugger
│       └── ...                # Other plugins
└── lazy-lock.json             # Plugin versions (keep this)
```

## Customization

**Change colorscheme:**
Edit `lua/plugins/colortheme.lua`, replace "kanagawa" with your preferred theme.

**Add a plugin:**
Create a new file in `lua/plugins/` or add to existing ones. Check `:help lazy.nvim` for syntax.

**Add keymaps:**
Edit `lua/core/keymaps.lua`. Use this format:
```lua
vim.keymap.set('n', '<leader>key', function()
  -- your code
end, { desc = "What it does" })
```

**LSP servers:**
Edit `lua/plugins/lsp/servers.lua` to add/remove language servers.

## Performance

Startup time is around 45-50ms on my machine. If yours is slower:

```bash
# Profile startup
nvim --startuptime startup.log +qa
tail -1 startup.log

# Check what's slow
:Lazy profile
```

Most plugins are lazy-loaded, so they only activate when you actually need them.

## Common Issues

**LSP not working:**
1. Check `:LspInfo` to see if server attached
2. Run `:Mason` and install the language server
3. Check `:checkhealth lsp`

**Telescope not finding files:**
- Make sure `ripgrep` is installed
- Check if you're in a git repo (or use `<leader>fa` for all files)

**Slow startup:**
- Run `:Lazy profile` to see what's taking time
- Check if treesitter is compiling parsers (first time only)

**Colors look wrong:**
- Make sure your terminal supports 24-bit color
- Check `$TERM` variable (should be `xterm-256color` or similar)

## Things I Learned Building This

- Less is more. I removed like 5 plugins I never used and startup got faster.
- Lazy-loading everything makes a huge difference.
- The default LSP keybinds are actually pretty good, don't overcomplicate.
- Telescope is amazing once you learn to use it properly.
- You don't need a file tree open all the time (oil.nvim is better).
- Commenting out debug code beats using a debugger 90% of the time, but that 10% though...

## Resources That Helped

- [Neovim docs](https://neovim.io/doc/) (actually pretty good)
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (borrowed some ideas)
- [lazy.nvim docs](https://github.com/folke/lazy.nvim)
- Random YouTube videos at 2AM when things broke

## Contributing

If you find bugs or have suggestions, open an issue. PRs welcome if they:
- Don't slow down startup
- Are actually useful for C/C++ development
- Come with a reason WHY (not just "I like it this way")

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## License

MIT - Do whatever you want with it. If it breaks your system, that's on you though.

## Acknowledgments

Stole ideas from:
- kickstart.nvim
- ThePrimeagen's config
- TJ DeVries' streams
- Various Reddit threads at 3AM

Built with frustration, caffeine, and the Neovim docs.

---

**Status:** Works on my machine ✓  
**Startup:** ~48ms  
**Coffee consumed during creation:** Too much
