# 🚀 Sphurti - Optimized Neovim Configuration

> **A fast, minimal, and powerful Neovim configuration for C/C++ embedded development, server programming, and electronics coding.**

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.9%2B-green.svg?style=flat-square&logo=neovim" alt="Neovim 0.9+"/>
  <img src="https://img.shields.io/badge/Lua-5.1%2B-blue.svg?style=flat-square&logo=lua" alt="Lua 5.1+"/>
  <img src="https://img.shields.io/badge/Startup-~48ms-brightgreen.svg?style=flat-square" alt="Fast Startup"/>
  <img src="https://img.shields.io/badge/Plugins-24-orange.svg?style=flat-square" alt="24 Plugins"/>
</p>

---

## ✨ Features

- ⚡ **Fast Startup**: ~48ms startup time (75% improvement from baseline)
- 🎯 **Embedded Development Focus**: Optimized for C/C++, firmware, and embedded systems
- 🔧 **Async Builds**: Non-blocking make integration with quickfix support
- 🐛 **GDB Debugging**: Full DAP support with cppdbg adapter
- 📝 **Comprehensive Documentation**: Every change explained with WHY reasoning
- 🔒 **Security Hardened**: `exrc=false`, `noremap` everywhere
- 🎨 **Modern UI**: Clean statusline, buffer tabs, diagnostics viewer
- 🔍 **Powerful Search**: Telescope fuzzy finder with LSP integration
- 📦 **Lazy Loading**: All plugins lazy-loaded for optimal performance

---

## 📋 Table of Contents

- [Screenshots](#-screenshots)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Key Features](#-key-features)
- [Keymaps](#-keymaps)
- [Plugins](#-plugins)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)

---

## 📸 Screenshots



---

## 📦 Prerequisites

### Required

- **Neovim** ≥ 0.9.0
  ```bash
  # Check version
  nvim --version
  ```

- **Git** ≥ 2.19.0
  ```bash
  git --version
  ```

- **C/C++ Compiler** (for native extensions)
  - GCC or Clang
  - Build tools (make, cmake)

### Highly Recommended

- **ripgrep** (fast grep alternative - 10-100x faster)
  ```bash
  # Ubuntu/Debian
  sudo apt install ripgrep
  
  # macOS
  brew install ripgrep
  
  # Arch
  sudo pacman -S ripgrep
  ```

- **Node.js** ≥ 16.0 (for LSP servers)
  ```bash
  # Check version
  node --version
  ```

- **Nerd Font** (for icons)
  - Download: [Nerd Fonts](https://www.nerdfonts.com/)
  - Recommended: JetBrainsMono Nerd Font, FiraCode Nerd Font

### Optional (Embedded Development)

- **GDB** (for debugging)
  ```bash
  sudo apt install gdb
  ```

- **OpenOCD** (for hardware debugging)
  ```bash
  sudo apt install openocd
  ```

- **Clang Tools** (for formatting and linting)
  ```bash
  sudo apt install clang-format clang-tidy
  ```

---

## 🚀 Installation

### 1. Backup Existing Config

```bash
# Backup your current Neovim config (if exists)
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup
```

### 2. Clone Repository

```bash
# Clone to Neovim config directory
git clone https://github.com/Dyumna137/Sphurti.git ~/.config/nvim

# Or use SSH
git clone git@github.com:Dyumna137/Sphurti.git ~/.config/nvim
```

### 3. Install Plugins

```bash
# Open Neovim (plugins will auto-install)
nvim

# Or manually trigger installation
nvim +Lazy +qa
```

### 4. Install LSP Servers

```bash
# Open Neovim and run
:Mason

# Install C/C++ LSP (inside Mason):
# - clangd
# - cpptools (for debugging)

# Or use command
:MasonInstall clangd cpptools
```

### 5. Verify Installation

```bash
# Check health
nvim +checkhealth

# Test startup time
nvim --startuptime startup.log +qa && tail -1 startup.log
# Expected: ~48-50ms
```

---

## ⚡ Quick Start

### First-Time Setup

1. **Open Neovim**
   ```bash
   nvim
   ```

2. **Wait for Plugins to Install** (automatic on first launch)

3. **Configure LSP** (if needed)
   ```vim
   :Mason
   ```
   Install: `clangd`, `cpptools`

4. **Test Basic Functionality**
   ```vim
   :Telescope find_files
   :Telescope live_grep
   :Trouble diagnostics
   ```

### Basic Usage

```bash
# Open a file
nvim main.c

# Open with file explorer
nvim .

# Open and jump to line
nvim +42 file.c
```

### Common Workflows

**Editing C/C++ Code:**
```vim
<leader>ff  - Find files
<leader>fg  - Grep in files
gd          - Go to definition
gr          - Find references
K           - Show documentation
<leader>ca  - Code actions
```

**Building Projects:**
```vim
<leader>mm  - Run make
<leader>mc  - Run make clean
<leader>mr  - Run make run
[q / ]q     - Navigate errors
<leader>qo  - Open quickfix
```

**Debugging:**
```vim
F5          - Continue/Start
F10         - Step over
F11         - Step into
F12         - Step out
<leader>b   - Toggle breakpoint
```

---

## 🎯 Key Features

### Performance

- **~48ms startup time** (optimized lazy-loading)
- **Async operations** (builds, LSP, search)
- **Minimal plugin footprint** (24 essential plugins)
- **Smart caching** (treesitter, LSP)

### Embedded Development

- **C/C++ LSP** (clangd with embedded project support)
- **GDB Integration** (via nvim-dap + cppdbg)
- **Build System Integration** (async make, error parsing)
- **Hardware Debugging** (OpenOCD ready)
- **Serial Monitor** (via floating terminal)

### Code Intelligence

- **Autocompletion** (nvim-cmp with snippets)
- **Diagnostics** (real-time error checking)
- **Code Actions** (refactoring, quick fixes)
- **Formatting** (clang-format on save)
- **Linting** (integrated with LSP)

### Developer Experience

- **Fuzzy Finding** (files, buffers, symbols via Telescope)
- **Git Integration** (fugitive + gitsigns)
- **Floating Terminal** (quick command execution)
- **Diagnostics Viewer** (Trouble.nvim)
- **File Explorer** (oil.nvim - fast and minimal)

---

## ⌨️ Keymaps

### Leader Key

The leader key is **Space** (`<Space>`)

### Essential Keymaps

#### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<C-h/j/k/l>` | Normal | Navigate splits |
| `<Tab>` | Normal | Next buffer |
| `<S-Tab>` | Normal | Previous buffer |
| `<leader>e` | Normal | Toggle file explorer |

#### Search

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Find help |
| `<leader>fw` | Normal | Find word under cursor |

#### LSP

| Key | Mode | Action |
|-----|------|--------|
| `gd` | Normal | Go to definition |
| `gD` | Normal | Go to declaration |
| `gr` | Normal | Find references |
| `gi` | Normal | Go to implementation |
| `K` | Normal | Hover documentation |
| `<C-k>` | Insert | Signature help |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>ca` | Normal | Code actions |
| `<leader>f` | Normal | Format code |

#### Build & Debug

| Key | Mode | Action |
|-----|------|--------|
| `<leader>mm` | Normal | Make build |
| `<leader>mc` | Normal | Make clean |
| `<leader>mr` | Normal | Make run |
| `<leader>mt` | Normal | Make test |
| `[q` / `]q` | Normal | Previous/next error |
| `<leader>qo` | Normal | Open quickfix |
| `<leader>qc` | Normal | Close quickfix |
| `F5` | Normal | Debug: Continue |
| `F10` | Normal | Debug: Step over |
| `F11` | Normal | Debug: Step into |
| `F12` | Normal | Debug: Step out |
| `<leader>b` | Normal | Toggle breakpoint |

#### Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gs` | Normal | Git status |
| `<leader>gb` | Normal | Git blame |
| `<leader>gd` | Normal | Git diff |
| `[c` / `]c` | Normal | Previous/next hunk |
| `<leader>hs` | Normal/Visual | Stage hunk |
| `<leader>hr` | Normal/Visual | Reset hunk |

#### Utility

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tt` | Normal/Terminal | Toggle terminal (file dir) |
| `<leader>tc` | Normal/Terminal | Toggle terminal (cwd) |
| `<leader>tw` | Normal | Toggle line wrap |
| `<leader>tn` | Normal | Toggle line numbers |
| `<leader>nd` | Normal | Insert date |
| `<leader>nt` | Normal | Insert time |
| `<leader>nn` | Normal | New scratch buffer |

#### Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `<leader>xx` | Normal | Toggle diagnostics |
| `<leader>xX` | Normal | Buffer diagnostics |
| `[d` / `]d` | Normal | Previous/next diagnostic |
| `<leader>e` | Normal | Show diagnostic error |

### Custom Keymaps

See [lua/core/keymaps.lua](lua/core/keymaps.lua) for all keymaps.

---

## 🔌 Plugins

### Core

- **[lazy.nvim](https://github.com/folke/lazy.nvim)** - Plugin manager
- **[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)** - Lua utility functions

### LSP & Completion

- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** - LSP client configurations
- **[mason.nvim](https://github.com/williamboman/mason.nvim)** - LSP/DAP/Linter installer
- **[mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)** - Mason + lspconfig integration
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - Completion engine
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)** - Snippet engine
- **[none-ls.nvim](https://github.com/nvimtools/none-ls.nvim)** - Formatting and linting

### Debugging

- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)** - Debug Adapter Protocol client
- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)** - UI for nvim-dap

### Syntax & Treesitter

- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** - Syntax highlighting
- **[nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)** - Textobjects based on treesitter

### Navigation

- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** - Fuzzy finder
- **[oil.nvim](https://github.com/stevearc/oil.nvim)** - File explorer

### UI

- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** - Statusline
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)** - Buffer tabs
- **[trouble.nvim](https://github.com/folke/trouble.nvim)** - Diagnostics viewer
- **[which-key.nvim](https://github.com/folke/which-key.nvim)** - Keymap hints
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** - Git decorations

### Editing

- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)** - Auto-close brackets
- **[Comment.nvim](https://github.com/numToStr/Comment.nvim)** - Smart commenting

### Git

- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** - Git integration
- **[vim-rhubarb](https://github.com/tpope/vim-rhubarb)** - GitHub integration

### Utilities

- **[todo-comments.nvim](https://github.com/folke/todo-comments.nvim)** - Highlight TODO/FIXME
- **[nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)** - Color preview

### Colorscheme

- **[kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)** - Colorscheme (default)

---

## 🎨 Customization

### Changing Colorscheme

Edit `lua/plugins/colortheme.lua`:

```lua
return {
  "rebelot/kanagawa.nvim",  -- Change this
  priority = 1000,
  config = function()
    require("kanagawa").setup({ ... })
    vim.cmd("colorscheme kanagawa")  -- Change this
  end,
}
```

Popular alternatives:
- `catppuccin/nvim` - Catppuccin
- `folke/tokyonight.nvim` - Tokyo Night
- `EdenEast/nightfox.nvim` - Nightfox

### Adding Keymaps

Edit `lua/core/keymaps.lua`:

```lua
-- Add your custom keymaps
vim.keymap.set('n', '<leader>custom', '<cmd>echo "Custom"<CR>', {
  noremap = true,
  silent = true,
  desc = "Custom keymap description"
})
```

### Configuring LSP

Edit `lua/plugins/lsp/servers.lua`:

```lua
servers = {
  clangd = {
    cmd = { "clangd", "--background-index" },
    -- Add your custom settings
  },
}
```

### Adding Plugins

Edit `init.lua` and add to plugin list:

```lua
require("plugins.your-plugin"),
```

Create `lua/plugins/your-plugin.lua`:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- Lazy load
  config = function()
    -- Setup here
  end,
}
```

---

## 🐛 Troubleshooting

### Slow Startup

```bash
# Profile startup time
nvim --startuptime startup.log +qa
cat startup.log

# Check plugin load times
nvim
:Lazy profile
```

**Common causes:**
- Too many plugins loading at startup (should be lazy-loaded)
- Large treesitter parsers (limit to needed languages)
- Network issues (plugin updates)

### LSP Not Working

```bash
# Check LSP status
:LspInfo

# Check Mason installations
:Mason

# Check health
:checkhealth lsp
```

**Common fixes:**
```vim
" Reinstall LSP server
:MasonUninstall clangd
:MasonInstall clangd

" Restart LSP
:LspRestart
```

### Treesitter Errors

```bash
# Update treesitter parsers
:TSUpdate

# Reinstall specific parser
:TSInstall c cpp

# Check health
:checkhealth nvim-treesitter
```

### Git Issues

```bash
# Check remote
git remote -v

# Test SSH connection
ssh -T git@github.com

# Re-add remote
git remote set-url origin git@github.com:Dyumna137/Sphurti.git
```

### Plugin Errors

```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Reinstall plugins
nvim +Lazy sync +qa
```

---

## 📚 Documentation

### Available Docs

- **[REFACTOR_LOG.md](REFACTOR_LOG.md)** - Complete refactor history with WHY explanations
- **[BLOAT_REMOVAL_LOG.md](BLOAT_REMOVAL_LOG.md)** - Bloat removal session details
- **[REFACTOR_SUMMARY.md](REFACTOR_SUMMARY.md)** - Quick reference guide
- **[REFACTOR_DIAGRAM.md](REFACTOR_DIAGRAM.md)** - Visual architecture diagrams
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

### Key Learnings

All configuration changes are documented with:
- ✅ **WHAT** changed (specific code/files)
- ✅ **WHY** it changed (technical reasoning)
- ✅ **HOW** it improves (performance/reliability)

### Configuration Files

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── core/
│   │   ├── options.lua      # Editor options (17 improvements)
│   │   └── keymaps.lua      # Key mappings (11 fixes)
│   └── plugins/
│       ├── lsp/             # LSP configuration
│       ├── *.lua            # Individual plugin configs
│       └── ...
├── lazy-lock.json           # Plugin versions (lockfile)
└── README.md                # This file
```

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development

```bash
# Clone your fork
git clone git@github.com:YOUR_USERNAME/Sphurti.git
cd Sphurti

# Create branch
git checkout -b feature/your-feature

# Make changes
# ... edit files ...

# Test
nvim

# Commit
git add .
git commit -m "feat: add your feature"

# Push
git push origin feature/your-feature
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📊 Performance Metrics

### Startup Time

```
Original config:  ~150ms
After refactor:   ~53ms  (65% improvement)
After bloat removal: ~48ms  (75% improvement)
```

### Plugin Count

```
Before optimization: 30+ plugins
After optimization:  24 plugins (minimal footprint)
```

### Code Quality

```
Lines removed:  -400+ lines of bloat
Security fixes: 10+ (noremap, exrc, etc.)
Conflicts fixed: 3 (keymaps, options)
```

---

## 🙏 Acknowledgments

- **Neovim Team** - For the amazing editor
- **Plugin Authors** - For the excellent plugins
- **Community** - For inspiration and best practices

### Built With

- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Modern plugin manager
- [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [LSP](https://microsoft.github.io/language-server-protocol/) - Language Server Protocol

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Dyumna137/Sphurti/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Dyumna137/Sphurti/discussions)

---

## 🎯 Roadmap

- [ ] Add more language support (Python, Rust, Go)
- [ ] Improve documentation (video tutorials)
- [ ] Add snippets collection
- [ ] Create wiki for advanced usage
- [ ] Performance monitoring tools

---

<p align="center">
  <b>⭐ Star this repo if you find it helpful!</b>
</p>

<p align="center">
  Made with ❤️ for embedded developers
</p>
