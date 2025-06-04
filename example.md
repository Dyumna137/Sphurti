## Preface:
Thank you for reading this, hope this helps you in your neovim journey !!!.

### 🎛️ What Are We Doing?

In Neovim, **plugins** are like apps you install to add features (like themes, file explorers, etc.).  
Using `lazy.nvim`, we **tell Neovim what plugins to load, when, and how to configure them.**


---
### Under `config` function what we can do using `require("...")` , `vim.cmd("...") ,

---

##  `config = function() ... end`

###  Think of it like:

> "Hey `Neovim`, once you load this plugin, run this setup code to make it work properly."

#### 🔧 What Can You Do in the `config = function()` Block?

You can use:

- `require("...")`: Load a Lua module or plugin setup file.
- `vim.cmd("...")`: Run any command as if you typed it in the `:` prompt in Neovim.
###  In plain words:

You use `config` when you want to **customize** how the plugin behaves after it loads.

###  Example:

```lua
{
  "nvim-lualine/lualine.nvim",
  config = function()
    require("lualine").setup()  -- tell Neovim to use this plugin's settings
  end
}
```

---

##  `require("...")`

###  Think of it like:

> "Go get this Lua file or plugin and use it."

###  In plain words:

This is like importing a plugin or your own config file so Neovim can use it.

###  Example:

```lua
require("telescope").setup()
```

This tells `Neovim` to **start the Telescope plugin** with default settings.


##  `vim.cmd("...")`

###  Think of it like:

> "Type this Vim command for me."

###  In plain words:

This runs a command just like you'd type in `:` in Neovim.

###  Example:

```lua
vim.cmd("colorscheme catppuccin")
```

Same as typing `:colorscheme catppuccin` in `Neovim` to apply the theme.

---


```lua
return {
  'owner/repo',               -- GitHub repo of the plugin
  lazy = true or false,       -- Whether to lazy-load the plugin (true = lazy, false = load at startup)
  priority = 1000,            -- Priority to load plugins (higher loads earlier)
  event = "InsertEnter",      -- Autoload plugin on this Neovim event
  keys = { "<leader>u" },     -- Load plugin on key press
  cmd = "UndotreeToggle",     -- Load plugin when this command is called
  opts = {},                  -- Table of options passed to plugin’s setup() function (if supported)
  config = function()         -- Function to configure plugin after loading
    require('plugin_name').setup({
      -- custom config here
    })
    -- additional setup code if needed
  end
}

```
### `Neovim`'s native activation method  For ` lazy.nvim ` :

| Field      | Description                                                                      | When to Use / Notes                                                                                     |
| ---------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `lazy`     | Boolean. `true` means load plugin only when triggered, `false` loads at startup. | Use `false` if plugin is essential and must load immediately; `true` to speed startup by loading later. |
| `priority` | Integer. Controls order of loading when multiple plugins load on startup.        | Higher priority loads earlier. Important for themes or plugins that other plugins depend on.            |
| `event`    | String. Autoload plugin when this Neovim event occurs.                           | Use for event-based lazy loading (e.g., `"BufRead"`, `"InsertEnter"`).                                  |
| `keys`     | Table of keybindings. Load plugin when one of these keys is pressed.             | Use for on-demand loading via specific key mappings.                                                    |
| `cmd`      | String. Load plugin when this command is executed.                               | Useful for plugins like `undotree` that activate on specific commands (`:UndotreeToggle`).              |
| `opts`     | Table. Passed directly to `plugin.setup(opts)` if supported by plugin.           | Use for simple configuration tables without needing a full config function.                             |
| `config`   | Function. Runs after plugin loads for custom setup or complex configuration.     | Use when configuration requires multiple steps, conditional logic, or loading your own config modules.  |

**You do not need to use all of this use What you prefers the most .**


---

##  `name = "..."` (like in `"catppuccin/nvim"`)

###  Think of it like:

> "Call this plugin by a specific name so Lua can find it."

###  In plain words:

Some plugins need to be called by a **different name** than their GitHub repo. This tells Neovim what to call it internally.

###  Example:

```lua
{
  "catppuccin/nvim",
  name = "catppuccin",  -- now you can do require("catppuccin")
}
```

---

##  `dependencies = { ... }`

###  Think of it like:

> "Before using this plugin, make sure these other plugins are loaded."

###  In plain words:

Some plugins need helpers to work (like icons or libraries). `dependencies` loads those first.

###  Example:

```lua
{
  "lualine.nvim",
  dependencies = { "nvim-web-devicons" }  -- needed for pretty icons in status line
}
```

---

##  `opts = { ... }`

###  Think of it like:

> "Here’s a simple settings table—automatically pass it to the plugin."

###  In plain words:

If a plugin supports a simple settings table, you can just use `opts` instead of writing a full config function.

###  Example:

```lua
{
  "indent-blankline.nvim",
  opts = {
    char = "|",
    show_trailing_blankline_indent = false,
  }
}
```

That’s like saying:

> "Set the indent character to `|`, and don’t show it at the end of a line."


---
### You now may have doubt about  `require(" ").setup()` and `opts = {}`
### When to use `opts = {}`

- Use `opts` when the plugin **provides a `.setup()` function that accepts a simple Lua table as configuration**. you can know it while checking their GitHub repository.
- This is the cleanest and most concise way to pass configuration options.
-  You don't need to explicitly use  `require("plugin_name").setup(opts)`. `lazy.nvim` will automatically call `require("plugin_name").setup(opts)` behind the scenes.
    

**Example:**

```lua
{
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    char = "|",
    show_trailing_blankline_indent = false,
  }
}
```

Here, you don’t have to write a `config` function yourself because the plugin’s `.setup()` just takes a table of options.

---

### When to use `require()` (inside `config = function()`)

- Use `require()` inside a `config` function when you need to:
    - Run **custom setup code** that can’t be expressed just by passing a table. Keep in mind that you config should match the attributes of setup function of the plugins you're configuring.
    - Load your **own Lua configuration module** (e.g., `require("config.lualine")`). when your
    - skill level in intermediate level.
    - Perform additional commands or setup steps beyond just calling `.setup()` (like setting keymaps, commands, or other side effects).
- This gives you full control over the plugin’s initialization process.
    

**Example:**

```lua
{
  "nvim-lualine/lualine.nvim",
  config = function()
    require("lualine").setup({
      options = { theme = "gruvbox" }
    })
    -- maybe additional setup here
  end
}
```

Or loading your own config file:

```lua
config = function()
  require("config.lualine")
end
```

---

### Summary

| Use case                                                                  | Use `opts = {}` | Use `require()` inside `config` |
| ------------------------------------------------------------------------- | --------------- | ------------------------------- |
| Plugin setup is a simple `.setup()` call with options                     | Yes             | No                              |
| Complex setup with additional code (keymaps, commands, conditional logic) | No              | Yes                             |
| Loading your own Lua config files                                         | No              | Yes                             |

---

**In short:**

- If a plugin's configuration is just a table of options, prefer `opts = {}` for simplicity.
- If you need custom logic or more control, use a `config` function and call `require()` inside it.
    

---


## Keymaps

this is under `lua/core/keymaps.lua`
```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.o.updatetime = 500  -- Optional: reduces delay for CursorHold events
```

### Explanation

- `vim.g.mapleader = " "`  
    Sets the **global leader key** to the spacebar. The leader key acts as a prefix for custom keybindings across Neovim.
- `vim.g.maplocalleader = " "`  
    Sets the **local leader key** to space as well. This key is used for buffer-local mappings, meaning mappings that only apply in the current buffer.
- `local keymap = vim.keymap.set`  
    Creates a shorter alias for the key mapping function to avoid repeating long calls when defining keymaps.
- `local opts = { noremap = true, silent = true }`  
    Defines default options for keymaps:
    - `noremap = true` prevents recursive mapping.
    - `silent = true` suppresses command echo when keys are pressed.
- `vim.o.updatetime = 500`  
    Sets the time (in milliseconds) of inactivity before Neovim triggers events like `CursorHold`. This can improve responsiveness for plugins relying on this event but is optional.
    

---

## ✅ Example Key Mappings Using `keymap` and `opts`

Assuming this is already declared:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
```

---

### 1. **Saving Files Quickly**

```lua
keymap("n", "<C-s>", ":w<CR>", opts)
```

- **Mode**: Normal (`"n"`)
- **Key**: `<C-s>w` (Ctrl + s )
- **Action**: Saves the file
- **Why**: Faster than typing `:w`
    

---

### 2. **Quit Neovim**

```lua
keymap("n", "<leader>q", ":q<CR>", opts)
```

- Quits the current window
    

---

### 3. **Toggle File Explorer (e.g., NvimTree)**

```lua
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
```

- Opens or closes the file explorer
    

---

### 4. **Clear Search Highlights**

```lua
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)
```

- Clears search highlights after using `/` or `?`
    

---

### 5. **Window Navigation**

```lua
keymap("n", "<C-h>", "<C-w>h", opts)  -- move left
keymap("n", "<C-l>", "<C-w>l", opts)  -- move right
keymap("n", "<C-j>", "<C-w>j", opts)  -- move down
keymap("n", "<C-k>", "<C-w>k", opts)  -- move up
```

- Allows you to move between split windows using Ctrl + arrow keys
    

---

### 6. **Buffer Navigation**

```lua
keymap("n", "<S-l>", ":bnext<CR>", opts)   -- next buffer
keymap("n", "<S-h>", ":bprevious<CR>", opts) -- previous buffer
```

---

### 7. **Mapping for Local Buffer Only (using `maplocalleader`)**

```lua
keymap("n", "<localleader>r", ":RunThisBuffer<CR>", opts)
```

- This would only make sense in the context of a plugin or config where `<localleader>` is used for buffer-specific actions.
    

---

## Tip

You can also define mappings for other modes:

- `"i"` — insert mode
- `"v"` — visual mode
- `"x"` — visual block mode
- `"t"` — terminal mode
- `"n"` — normal mode
    

Example:

```lua
keymap("i", "jj", "<Esc>", opts)  -- Exit insert mode by typing jj
```

---

## 🔧 What Are Plugin-Oriented Mappings?

Plugin-oriented mappings are keybindings that are specifically created to interact with a plugin — for example, using `<leader>ff` to trigger Telescope's file finder.

---

##  Step-by-Step: Plugin Mappings in Lua

### 1.  Organize Your Config

Put plugin-specific mappings **in the plugin config block**. This keeps things modular and avoids clutter.

### 2.  Example with `telescope.nvim`

Assume you're using `lazy.nvim` or `packer.nvim`:

```lua
-- with lazy.nvim
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})

    -- Mappings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
    keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
    keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
    keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
  end,
}
```


---

##  Best Practices

-  **Keep mappings inside the plugin's config block** to avoid pollution.
-  Use `vim.keymap.set()` instead of the older `vim.api.nvim_set_keymap()` for simplicity and safety.
-  Always use `{ noremap = true, silent = true }` unless you have a reason not to.
-  Use `<leader>` mappings for plugin-related functionality.
    

---

## 🛠 Tip: Use a Helper Function

Create a utility to streamline mapping:

```lua
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end
```

Then in plugins:

```lua
map("n", "<leader>tt", "<cmd>ToggleTerm<cr>")
```

---

### Here’s how you can find out **what a plugin does and what commands or functions it exposes**:

---

##  1. **Check the Plugin’s README**

Most plugins on GitHub (like [Telescope](https://github.com/nvim-telescope/telescope.nvim)) have a README with:

- **Usage instructions**
- **Key features**
- **Examples of mappings**
- **Commands (`:Telescope`, etc.) or Lua functions (`require("telescope").builtin`)**
    

 Just search for the plugin on GitHub and read the README first.

---

##  2. **Read the Plugin’s Docs (if available)**

Some plugins include `:help` documentation.

For example:

```vim
:help telescope.nvim
```

This will open documentation inside Neovim, assuming the plugin was installed correctly.

---

##  3. **Explore with `:Telescope` or `:WhichKey`**

If you have plugins like:

- [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim): Run `:Telescope commands` or `:Telescope keymaps` to explore available commands/keybindings.
- [`which-key.nvim`](https://github.com/folke/which-key.nvim): Shows all defined keybindings under `<leader>` and others in a menu.
    

This helps you discover existing keymaps and available plugin commands.

---

##  4. **Print Available Lua Functions**

In Neovim, you can open a Lua prompt:

```vim
:lua =require("telescope.builtin")
```

Or use `:lua print(vim.inspect(require("telescope.builtin")))`  
This prints a list of available functions you can call in mappings.

---

##  5. **Explore Installed Plugins Directory (Optional)**

You can read the plugin source code directly:

```sh
~/.local/share/nvim/lazy/
```

or wherever your plugins are installed (`~/.vim/plugged/`, etc.).

Look for:

- `init.lua`
- `commands.lua`
- `keymaps.lua`
- `README.md`
    

---

## LSP and Language Support

I have structured my LSP setup using three different Lua files:

- `lua/plugins/lsp/mason.lua`:  
    This handles downloading and installing all required LSPs using Mason. It also sets up built-in LSP capabilities, attaching them to buffers based on what each server can do.
- `lua/plugins/lsp/on_attach.lua`:  
    This file defines what happens when an LSP attaches to a buffer. It includes general keymaps for simplicity and kickstarts LSP functionality. These mappings are not specific to individual LSPs, keeping the setup generic.
- `lua/plugins/lsp.lua`:  
    This file pulls in the other two (`mason.lua` and `on_attach.lua`) to ensure everything is properly configured. It also redefines functionality using `vim.lsp.buf` and `vim.api` to make diagnostic and buffer-related functions globally available — meaning they work across all files and buffers, not just specific ones.
    

---

### Plugin: `'neovim/nvim-lspconfig'`

> "Hey Neovim, I want to **talk to language servers** (like Python, C++, Lua, etc.) — this plugin helps me **connect Neovim to them easily**."

#### In short:

It provides **ready-made configurations** for many language servers. This automates a lot of boilerplate, so you don’t need to write all the setup code manually. Once configured, it enables useful features like:

- Autocompletion
- Go to Definition
- Diagnostics
- Hover Information
    
**But Neovim doesn’t know** how to talk to these assistants **by default**.
### 💬 What does `nvim-lspconfig` do?

It **sets up the connection** between Neovim and each language’s server.

You can think of it like this:

> “I installed the Python assistant (ruff), now let `nvim-lspconfig` tell Neovim how to **use it**.”

---
### Plugin: `"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" `

Automatically helps to install LSPs by listing them instead of installing them manually in local server by terminal or `:MasonInstall lsp_name` .

You can think of it like this:

> " Hey I found out about this LSP (clangd), I listed it to you with prererqusits , maked sure to install it**. "

---

### `vim.api`: Neovim's Lua API

`vim.api` is Neovim’s Lua API, which gives you access to **core Neovim functionality** through Lua scripting.

#### In short:

It allows you to manipulate buffers, windows, options, and more — all from your Lua configuration.

#### Example:

```lua
vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Hello, world!"})
```

This replaces the contents of the current buffer with "Hello, world!".

#### Why it’s useful:

It gives you access to powerful functions like:

- `nvim_get_current_buf()` – Get the current buffer
- `nvim_set_option()` – Set editor options
- `nvim_command()` – Run Vim commands
- `nvim_buf_set_lines()` – Modify buffer contents

---

### Summary

By organizing LSP setup into modular files and using Neovim's Lua API (`vim.api`), you can create a powerful, reusable, and globally accessible LSP configuration that makes your Neovim setup both clean and scalable.

---
# Read `:help`
