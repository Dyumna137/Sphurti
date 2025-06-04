# It's a temporary file for now if see its use make it different for beginers
# But i still insist to read `:help` to understand better
## 🛠️ Neovim Plugin and LSP Setup Guide

A comprehensive guide for setting up, understanding, and teaching modern Neovim as an IDE using Lua.

---

### ✅ **Core Plugins** (Essential for IDE-like behavior)

| Plugin File          | Purpose                             |
| -------------------- | ----------------------------------- |
| `autocompletion.lua` | LSP autocompletion (nvim-cmp, etc.) |
| `autopairs.lua`      | Auto close brackets/quotes          |
| `bufferline.lua`     | Tab/buffer line UI                  |
| `colortheme.lua`     | Color scheme settings               |
| `indent_line.lua`    | Indentation guides                  |
| `lsp.lua`            | LSP setup and logic                 |
| `lualine.lua`        | Statusline                          |
| `mason.lua`          | LSP/DAP installer                   |
| `on_attach.lua`      | `on_attach` function for LSP        |
| `servers.lua`        | LSP servers config                  |
| `treesitter.lua`     | Syntax parsing/highlighting         |
| `autoformatting.lua` | Format on save                      |

---

### 🔄 **Semi-Core Plugins** (Nice-to-have, often lazy-loaded)

| Plugin File     | Purpose                              |
| --------------- | ------------------------------------ |
| `neo-tree.lua`  | File explorer (alternative to netrw) |
| `telescope.lua` | Fuzzy finder                         |
| `trouble.lua`   | Diagnostics list UI                  |
| `gitsigns.lua`  | Git line markers                     |
| `debug.lua`     | Debugger support (DAP)               |
| `lint.lua`      | Linting                              |

---

### 🧩 **Non-Core / Optional / UI Enhancers**

| Plugin File             | Purpose                                             |
| ----------------------- | --------------------------------------------------- |
| `alpha.lua`             | Startup dashboard                                   |
| `misc.lua`              | Likely minor utility functions                      |
| `database.lua`          | SQL                                                 |

---

### 📁 Others

* `core/keymaps.lua` and `core/options.lua`: Your **Neovim config core files** (not plugins).
* `init.lua`: Entrypoint, should lazy-load everything using `require(...)`.

---

### 🧩 How Components Work Together

| Component       | Role               | Feeds Into                   |
| --------------- | ------------------ | ---------------------------- |
| LSP (lua\_ls)   | Smart code help    | cmp, diagnostics             |
| Linter (eslint) | Code style checker | null-ls, diagnostics         |
| cmp             | Autocompletion UI  | Uses LSP, buffer, path, etc. |

---

### 🔄 `cmp` = Completion Engine

| Source Plugin  | Suggests From            |
| -------------- | ------------------------ |
| `cmp-nvim-lsp` | LSP server 🧠            |
| `cmp-buffer`   | Current buffer 📝        |
| `cmp-path`     | Filesystem paths 📁      |
| `cmp-cmdline`  | Command-line suggestions |
| `cmp_luasnip`  | LuaSnip snippets ⚡       |

**Smart Suggestions Source** → LSP (e.g., `pyright`, `clangd`, `lua_ls`)

```lua
-- LSP → cmp-nvim-lsp → cmp → popup suggestions
```

| Task                   | Handler             |
| ---------------------- | ------------------- |
| Code logic             | LSP (e.g., pyright) |
| Completion suggestions | LSP, buffer, path   |
| UI popup               | `cmp` plugin        |
| LSP ↔ cmp connector    | `cmp-nvim-lsp`      |

---

### ⚠️ Omnifunc Behavior

| Purpose                                     | Code                                                |
| ------------------------------------------- | --------------------------------------------------- |
| ❌ Enable LSP-native completion (not needed) | `vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'` |
| ✅ Disable (recommended with `nvim-cmp`)     | `vim.bo[bufnr].omnifunc = ''`                       |

---

### 🧠 Common LSP Capabilities

| Capability           | Description                     |
| -------------------- | ------------------------------- |
| `completion`         | Code autocompletion             |
| `hover`              | Info on hover (`K`)             |
| `signatureHelp`      | Function parameter hints        |
| `definition`         | Go to definition (`gd`)         |
| `references`         | List references (`gr`)          |
| `documentHighlight`  | Highlight usage in file         |
| `documentSymbol`     | Show symbols in file            |
| `formatting`         | Format whole file               |
| `rangeFormatting`    | Format a selected area          |
| `rename`             | Rename variable/function        |
| `codeAction`         | Lightbulb/quick fixes           |
| `semanticTokens`     | Token-based syntax highlighting |
| `publishDiagnostics` | Lint errors/warnings            |

---

### 🧪 Plugin Configuration Options

| Goal                       | Code Snippet                                        |
| -------------------------- | --------------------------------------------------- |
| Simple override            | `opts = {}`                                         |
| Conditional/dynamic config | `opts = function() return {...} end`                |
| Post-setup logic           | `opts = {...}, config = function(_, opts) ... end`  |
| Full control               | `config = function() require('...').setup(...) end` |

---

### 📌 Type-safe `name_formatter` in Bufferline

If `name_formatter` returns `nil`, it **works**, but **isn’t type-safe**. Lua LSP expects a `string`, not `nil`. So return an empty string `""` or fallback instead.

---

### 📋 `vim.bo.buftype` — Buffer Type Values

| Value      | Meaning                                     |
| ---------- | ------------------------------------------- |
| `""`       | Normal file buffer                          |
| `nofile`   | Not tied to a file (scratch)                |
| `nowrite`  | Can't write to file                         |
| `acwrite`  | Autocommand write                           |
| `terminal` | Terminal buffer                             |
| `prompt`   | Interactive prompt buffer (e.g., Telescope) |
| `help`     | Help file                                   |

---

### 📚 25 Mini Lessons for Neovim Beginners

1. Install Neovim and explore it
2. Learn modal editing via `:Tutor`
3. Basic Lua config: options, keymaps
4. Plugin manager setup
5. Filetype detection
6. Treesitter basics
7. LSP: install + keymaps
8. Autoformat on save
9. Telescope setup
10. Telescope advanced usage (ripgrep)
11. Window nav (`<C-w>`, splits)
12. Quickfix and `:cdo`
13. Terminals and floating terms
14. Completion config (nvim-cmp)
15. File browser (e.g. oil.nvim)
16. Mouse support setup
17. Snippet integration
18. mini.nvim text objects
19. Tree-sitter textobjects
20. Per-language config
21. System clipboard access
22. Debug adapter setup (DAP)
23. Git integration (gitsigns)
24. Linter setup (null-ls/lint)
25. Final touches: startup UI, dashboard

---

### 📌 Lua File Execution in Neovim

* `:source %` → **only for Vimscript**
* `:luafile %` → ✅ for executing `.lua` files

To make it permanent:

```lua
-- ~/.config/nvim/lua/myfloat.lua
function OpenFloatingWindow()
  -- implementation here
end
```

In `init.lua`:

```lua
require("myfloat")
```

Then run:

```vim
:lua OpenFloatingWindow()
```

