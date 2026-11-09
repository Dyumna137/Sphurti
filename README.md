# Sphurti - Personal Neovim Configuration

A lightweight, fast Neovim setup optimized for C/C++ and embedded systems development. Built over time through experimentation and focused on performance and usability.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Key Mappings](#key-mappings)
- [Plugin List](#plugin-list)
- [Configuration Structure](#configuration-structure)
- [Customization](#customization)
- [Performance](#performance)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This configuration focuses on C/C++ and embedded systems development with an emphasis on:

- Fast startup time (under 50ms)
- Focused plugin set for editing, diagnostics, and debugging
- Proper LSP integration
- Smart lazy-loading
- No Nerd Font dependency (uses minimalist text icons)

The config started as a way to move away from VS Code's memory usage and has evolved into a focused development environment.

---

## Features

### Core Functionality

- **Plugin Management:** lazy.nvim for fast, lazy-loaded plugins
- **File Explorer:** Built-in netrw navigation with no extra dependency
- **Fuzzy Finding:** Telescope with smart git-aware file searching
- **Syntax:** Treesitter for accurate syntax highlighting

### Language Support

- **LSP Integration:** Full language server support via nvim-lspconfig and Mason
- **Autocompletion:** Fast completion with nvim-cmp and LuaSnip
- **Diagnostics:** Real-time error checking with trouble.nvim
- **Formatting:** Auto-formatting with none-ls (null-ls successor)

### Development Tools

- **Debugger:** nvim-dap with UI for visual debugging
- **Git Integration:** Inline git changes with gitsigns
- **Terminal:** Built-in project/file terminal split with no extra plugin
- **Substitution preview:** Neovim shows an incremental split preview for substitutions

### UI Components

- **Colorscheme:** Kanagawa (soft colors, easy on eyes)
- **Statusline:** lualine with diagnostic and git info
- **Icons:** Minimalist text icons (works without Nerd Fonts)

---

## Installation

### Prerequisites

**Required:**
```bash
neovim >= 0.11.3
git
gcc or clang (for treesitter compilation)
```

**Recommended:**
```bash
ripgrep (for fast file searching)
fd (for improved file finding)
nodejs and npm (for LSP servers)
```

**Installation on Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install neovim git build-essential ripgrep fd-find nodejs npm
```

### Setup

1. **Backup existing config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone repository:**
   ```bash
   git clone https://github.com/Dyumna137/Sphurti.git ~/.config/nvim
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```
   Plugins will automatically install on first launch (takes 1-2 minutes).

4. **Install language servers:**
   ```vim
   :Mason
   ```
   Install the servers you need:
   - `clangd` for C/C++
   - `lua_ls` for Lua
   - `pyright` for Python
   - `rust_analyzer` for Rust
   - `jdtls` for Java
   - `bashls` for Bash

5. **Verify installation:**
   ```vim
   :checkhealth
   ```

---

## Key Mappings

Leader key is `<Space>`.

### File Operations

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>sf` | Find files | Search project files |
| `<leader>gf` | Git files | Search tracked Git files |
| `<leader>sl` | Lua files | Search only Neovim Lua configuration |
| `<leader>fg` | Live grep | Search text in files |
| `<leader>fb` | Find buffers | List open buffers |
| `<leader>e` | File explorer | Open built-in file browser |

### LSP Operations

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>F` | Format buffer | Format through an attached formatting client |
| `<leader>tf` | Toggle format on save | Toggle the buffer-local autoformat setting |
| `<leader>ld` | Diagnostics report | Show LSP, root, and buffer diagnostic state |

The configuration registers the three mappings above when a suitable LSP
client attaches. Neovim and the LSP client may also provide their own default
mappings; use `:map <buffer>` in an attached buffer to inspect the effective
set rather than treating generic LSP shortcuts as configuration-owned.

### Git

| Keymap | Action |
|--------|--------|
| `<leader>gs` | Fugitive Git status |
| `<leader>gd` | Diff current file |
| `<leader>gl` | Git log |
| `<leader>gb` | Git blame |

### Diagnostics

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>xx` | Toggle diagnostics | Show all errors/warnings (Trouble) |
| `<leader>xX` | Buffer diagnostics | Show errors in current file |
| `<leader>sd` | Search diagnostics | Fuzzy find diagnostics |
| `<leader>cs` | Symbols | Show document/workspace symbols |

### Build and Debug

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>mm` | Make | Run make command |
| `<leader>mc` | Make clean | Run make clean |
| `<F5>` | Start/Continue | Start or continue debugging |
| `<F1>` | Step into | Debug step into |
| `<F2>` | Step over | Debug step over |
| `<F3>` | Step out | Debug step out |
| `<leader>b` | Toggle breakpoint | Set or remove a breakpoint |
| `<leader>B` | Conditional breakpoint | Prompt for a breakpoint condition |

### Embedded Workflow

These commands detect the current project and use the first supported workflow:

| Keymap | Command | Action |
|--------|---------|--------|
| `<leader>eb` | `:EmbeddedBuild` | Build with PlatformIO, ESP-IDF, CMake, or Make |
| `<leader>ef` | `:EmbeddedFlash` | Flash with PlatformIO, ESP-IDF, or a project flash script |
| `<leader>em` | `:EmbeddedMonitor` | Open PlatformIO, ESP-IDF, or pyserial monitor |
| `<leader>ed` | `:EmbeddedDebug` | Check embedded debugger prerequisites |

The commands do not install toolchains automatically. If a required executable is
missing, Neovim reports the exact prerequisite instead of failing silently.

Run the small configuration smoke test from PowerShell:

```powershell
nvim --headless -u init.lua -l tests/smoke.lua
```

### Terminal

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>tt` | Toggle terminal | Open in file directory |
| `<leader>tc` | Toggle terminal | Open in project root |
| `<Esc><Esc>` | Close terminal | Exit terminal mode |

### Editor

| Keymap | Action | Description |
|--------|--------|-------------|
| `<Esc>` | Clear search | Remove search highlights |
| `<C-s>` | Save | Save current file |
| `gcc` | Comment line | Toggle line comment |
| `gc` | Comment selection | Toggle comment (visual mode) |

### Window Management

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>vv` | Vertical split | Split window vertically |
| `<leader>hh` | Horizontal split | Split window horizontally |
| `<C-h/j/k/l>` | Navigate splits | Move between windows |
| `<leader>se` | Equalize splits | Make all splits equal size |

---

## Plugin List

### Core Utilities
- **lazy.nvim** - Plugin manager
- **netrw** - Built-in file explorer
- **telescope.nvim** - Fuzzy finder
- **bufdelete.nvim** - Safe buffer deletion

### UI & Appearance
- **kanagawa.nvim** - Colorscheme
- **lualine.nvim** - Statusline

### Code Intelligence
- **nvim-treesitter** - Syntax highlighting
- **nvim-lspconfig** - LSP client
- **mason.nvim** - LSP installer
- **nvim-cmp** - Autocompletion
- **lsp_signature.nvim** - Function signatures
- **nvim-autopairs** - Auto-close brackets

### Code Quality
- **none-ls.nvim** - Formatting and linting
- **trouble.nvim** - Diagnostics list

### Development Tools
- **nvim-dap** - Debugger
- **nvim-dap-ui** - Debug UI
- **gitsigns.nvim** - Git integration

### Supported language servers

The active Mason configuration preserves servers for Lua, C/C++, Python, Rust,
Java, and Bash. They are configured when Mason/LSP loads and attach only when
you open a matching filetype.

---

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/
│   ├── core/
│   │   ├── options.lua     # Editor settings (tab width, etc.)
│   │   └── keymaps.lua     # Keybindings
│   └── plugins/
│       ├── lsp.lua         # LSP configuration
│       ├── lsp/
│       │   ├── mason.lua   # LSP server installation
│       │   └── on_attach.lua # LSP keymaps
│       ├── autocompletion.lua
│       ├── treesitter.lua
│       ├── telescope.lua
│       ├── trouble.lua
│       ├── debug.lua
│       └── ...
└── lazy-lock.json          # Plugin version lock file
```

**Key files:**
- **init.lua** - Loads core modules and plugins
- **core/options.lua** - Vim options (indentation, line numbers, etc.)
- **core/keymaps.lua** - All keybindings
- **plugins/** - Each plugin in its own file

---

## Customization

### Change Colorscheme

Edit `lua/plugins/colortheme.lua`:
```lua
return {
  "rebelot/kanagawa.nvim",  -- Change this line
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("kanagawa")  -- And this line
  end,
}
```

Popular alternatives:
- `"folke/tokyonight.nvim"` with `colorscheme("tokyonight")`
- `"catppuccin/nvim"` with `colorscheme("catppuccin")`
- `"EdenEast/nightfox.nvim"` with `colorscheme("carbonfox")`

### Add Language Server

1. Open Mason:
   ```vim
   :Mason
   ```

2. Search and install your LSP server

3. Add to the `servers` table in `lua/plugins/lsp/mason.lua`:
   ```lua
   ["rust_analyzer"] = {},  -- Example for Rust
   ```

### Add Keybinding

Edit `lua/core/keymaps.lua`:
```lua
vim.keymap.set('n', '<leader>key', function()
  -- Your action here
end, { desc = "Description shown in which-key" })
```

### Add Plugin

Create new file in `lua/plugins/` or add to existing file:
```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- Lazy load
  opts = {
    -- Plugin options
  },
}
```

---

## Performance

**Current metrics:**
- Startup time: **47.6ms average** across five Windows headless runs
- Plugin specifications: 37
- Initially loaded plugins: 2 (`lazy.nvim`, Kanagawa)
- Lua configuration: 1,932 lines

The measured startup is fast enough for daily editing. The plugin specification
count includes lazy-loaded dependencies; most are not loaded during startup.

**Performance tips:**
- Most plugins are lazy-loaded
- Use `:Lazy profile` to see load times
- Use `nvim --startuptime startup.log +qa` to profile startup

**If startup is slow:**
```bash
# Profile startup
nvim --startuptime startup.log +qa
tail -20 startup.log

# Check what's taking time
:Lazy profile
```

---

## Troubleshooting

### LSP Not Working

**Check if server is running:**
```vim
:LspInfo
```

**Install language server:**
```vim
:Mason
```

**Check health:**
```vim
:checkhealth lsp
```

### Telescope Not Finding Files

**Make sure ripgrep is installed:**
```bash
which rg
```

**In git repo, use:**
- `<leader>sf` for project files (uses `fd` when available and Git fallback otherwise)

### Slow Startup

**Profile startup:**
```bash
nvim --startuptime startup.log +qa
tail -30 startup.log
```

**Check plugin load times:**
```vim
:Lazy profile
```

### Terminal Colors Wrong

**Ensure 24-bit color support:**
```bash
echo $TERM
# Should be: xterm-256color or similar
```

**Add to shell config:**
```bash
export TERM=xterm-256color
```

### Diagnostics Not Showing

**Check if LSP is attached:**
```vim
:LspInfo
```

**Manually trigger diagnostics:**
```vim
:lua vim.diagnostic.open_float()
```

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

**Quick guidelines:**
- Keep it minimal (no unnecessary plugins)
- Focus on C/C++/embedded development
- Maintain fast startup time
- Test changes locally
- Follow existing code style

---

## License

MIT License - See LICENSE file for details.

---

## Acknowledgments

Built with inspiration from:
- kickstart.nvim
- ThePrimeagen's config
- Various community configs

Resources used:
- Neovim documentation
- lazy.nvim docs
- Community plugins and their documentation

---

**Status:** Stable and actively used  
**Startup Time:** ~48ms  
**Last Updated:** 2026-02-04
