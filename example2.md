
### ✅ **Core Plugins** (essential for IDE-like behavior)

These improve editing, language support, formatting, and file navigation:

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

### 🔄 **Semi-Core Plugins** (nice-to-have, often loaded lazily)

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

Can be safely lazy-loaded or even removed depending on your needs:

| Plugin File             | Purpose                                             |
| ----------------------- | --------------------------------------------------- |
| `alpha.lua`             | Startup dashboard                                   |
| `misc.lua`              | Likely minor utility functions                      |
| `databse.lua` *(typo?)* | Probably meant to be `database.lua` – unclear usage |

---

### 📁 Others

* `core/keymaps.lua` and `core/options.lua`: Your **Neovim config core files** (not plugins).
* `init.lua`: Entrypoint, should lazy-load everything using `require(...)`.


🧩 How They Work Together:

|Component       |Role	                   |Feeds Into                   |
|----------------|-------------------------|-----------------------------|  
|LSP (lua_ls)    |Smart code help          |cmp, diagnostics             |
|Linter (eslint) |Code quality/style check |null-ls, diagnostics         |
|cmp	         |Autocompletion plugin    |Uses LSP, buffer, path, etc. |


🔄 cmp = Autocompletion display engine
It collects suggestions from multiple sources and shows them in the popup.

| Source Plugin  | What It Suggests                        |
| -------------- | --------------------------------------- |
| `cmp-nvim-lsp` | Suggestions from your **LSP server** 🧠 |
| `cmp-buffer`   | Words from the **current buffer** 📝    |
| `cmp-path`     | **Filesystem paths** 📁                 |
| `cmp-cmdline`  | Commands in `:` or `/` line             |
| `cmp_luasnip`  | **Snippets** from LuaSnip ⚡            |



🧠 Who gives smart suggestions like functions, types, variables, etc?
That would be your LSP server — like pyright, lua_ls, clangd, etc.

🔗 LSP → talks to language backend
🔌 cmp-nvim-lsp → connects LSP to cmp

So in short:

[LSP server] → (cmp-nvim-lsp) → [cmp] → shows popup


| Task                      | Who Handles It             |
| ------------------------- | -------------------------- |
| Understand language logic | LSP server (e.g., pyright) |
| Provide completions       | LSP, buffer, path, etc.    |
| Show popup in Neovim      | `cmp` plugin               |
| Connect LSP to `cmp`      | `cmp-nvim-lsp`             |
