
# 🌀 Neovim Configuration – Powered by Kickstart

This is my personal Neovim setup, built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). It’s designed to be **minimal**, **performant**, and **modular**, customized using Lua as I continue to explore and master the Neovim ecosystem.

> 🌱 Inspired by productivity, performance, and aesthetics.

---

### 🚀 Why I Built This

I created this configuration to develop a fast, clean, and scalable Neovim environment tailored to my needs as a developer. It started as a learning project and evolved into a daily driver that enhances my coding experience.

---

### ✅ Key Features

- **Language Support:** Lua, Python, C/C++, JavaScript (easily extendable)
- **LSP Integration:** Automatically managed via `mason.nvim` and `nvim-lspconfig`
- **Autocompletion:** Smooth code suggestions with `nvim-cmp`
- **Syntax Highlighting:** High-performance treesitter-based parsing
- **File Explorer:** Modern UI with `neo-tree.nvim`
- **Fuzzy Finder:** Fast searching using `telescope.nvim`
- **UI Enhancements:** Custom `lualine`, `bufferline`, and `tokyonight` theme
- **Diagnostics & Linting:** Clear error tracking with `trouble.nvim` and linting integrations
    

---

### 👤 Who This Is For

- **Beginners** looking for a structured and documented Neovim setup
- **Intermediate users** wanting a customizable foundation
- **Advanced users** seeking modular design and clean architecture

> 🔧 Fork and adapt this setup to suit your workflow.

---

## 📁 Project Structure

```
~/.config/nvim/
├── init.lua                  -- Main entry point
├── README.md                 -- Project overview
├── example.md                -- Tips, customizations, keymaps
└── lua/
    ├── core/                 -- Basic options & keymaps
    ├── plugins/              -- Plugin-specific configuration
    └── user/                 -- Custom overrides
```

> Every plugin and setting is logically separated for clarity and easy expansion.

---

## 🧩 Plugin Management

All plugins are managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

### 🔌 Adding Plugins

1. Create a new Lua file in `lua/plugins/`
2. Return a table describing the plugin

#### Example:

```lua
return {
  "mbbill/undotree",
  keys = { "<leader>u" },
  config = function()
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
  end,
}
```

#### Plugin Tips

- Always `return` the plugin table.
- Use lazy-loading strategies like `event`, `cmd`, or `keys` to reduce startup time.
- Declare dependencies if needed.
- Extract complex config into separate `require("...")` modules when necessary.

> ℹ️ See `example.lua` for more plugin configuration examples.

---

## 🌟 Frequently Used Plugins

|Plugin|Purpose|
|---|---|
|`nvim-treesitter`|Syntax highlighting and parsing|
|`telescope.nvim`|Fuzzy finding and live grep|
|`nvim-cmp`|Autocompletion engine|
|`mason.nvim`|LSP and tool installer|
|`lualine.nvim`|Statusline|
|`which-key.nvim`|Keybinding hints|
|`neo-tree.nvim`|File explorer|
|`trouble.nvim`|Diagnostics viewer|

> 📚 Be sure to read the README for each plugin to unlock its full potential.

---

## ⌨️ Keybindings

All key mappings are defined in:  
📄 `lua/core/keymaps.lua`

For additional custom bindings and examples, check:  
📄 `example.md`

---

## ⚙️ LSP & Language Setup

- **LSPs** are configured via `nvim-lspconfig`
- **Installed automatically** using `mason.nvim`
- **Keybindings and behaviors** are handled in `plugins/lsp/on_attach.lua`

### Supported Languages

- Lua (`lua_ls`)
- Python (`ruff`)
- C/C++ (`clangd`)
- JavaScript (`prettier`)

### Add New LSPs

Run:

```vim
:Mason
```

Then search and install the desired LSP.

> ⚠️ Prefer defining them in `plugins/lsp/mason.lua` for consistency and automation.

---

## 🎨 Themes & UI

Current theme:

```lua
vim.cmd("colorscheme kanagawa")
```

### UI Plugins

- `lualine.nvim`: Statusline
- `colortheme` : Neovim theme
- `bufferline.nvim`: Tabline
- `alpha-nvim`: Welcome dashboard

To switch themes, modify `lua/plugins/colortheme.lua`.

---

## 🧠 Tips & Best Practices

- Use `:help <topic>` to explore features
- Run `:checkhealth` for debugging setup issues
- Use `:LspInfo` to view LSP status
- Press `gf` to jump to files under the cursor (handy in config files)
- Keep `example.md` updated with shortcuts, patterns, and notes

---

## ➕ Adding More Plugins

Create a new file in `lua/plugins/`. For example:

```lua
return {
  "github/copilot.vim",
  event = "InsertEnter",
}
```

Reload Neovim or run `:Lazy sync`.

> If you're not managing plugin lists directly, make sure `plugins/` is auto-imported in your `init.lua`.

---

## 🛠 Installation

```bash
# Clone the repository
git clone https://github.com/Dyumna137/nvimbox.git
cd nvimbox

# (Optional) Install dependencies
pip install -r requirements.txt
```

---

## ✅ Conclusion

This configuration is:

- Beginner-friendly
- Modular and clean
- Performance-focused

I’ll continue improving it as I learn and experiment. Feel free to explore, fork, and enhance it to suit your needs.

> 🚀 Stay tuned for future updates!

---

## 📝 License

This configuration is available under the [MIT License](./LICENSE).

