# Documentation: `markdown-preview.nvim` Lazy Plugin Specification

## 1. Overview

This document explains what the provided Lua plugin specification does. It configures the Neovim plugin [`iamcco/markdown-preview.nvim`](https://github.com/iamcco/markdown-preview.nvim) for on-demand, lazy loading. The configuration supports two installation strategies:

1. Prebuilt mode (no local `yarn`/`npm` required) – downloads prepared assets.
2. Source build mode (uses `yarn` to install and build the web app locally).

Only one strategy will activate automatically based on whether `yarn` is available on your system.

---

## 2. File Placement

Place the Lua file (the code you have) at:

```
lua/plugins/markdown-preview.lua
```

Assuming your Neovim config loads plugins via:

```lua
require("lazy").setup("plugins")
```

Lazy.nvim will automatically discover and process this specification.

---

## 3. High-Level Flow

1. Detect if `yarn` is installed (`vim.fn.executable("yarn") == 1`).
2. Define shared `init_globals()` to set global variables before the plugin loads.
3. Define two plugin spec tables:
   - `prebuilt` (uses the plugin’s internal installer function)
   - `from_source` (runs a shell build command with `yarn`)
4. Add a `cond` field to each spec so only one activates.
5. Add a small `config` function to register a keymap after the chosen spec loads.
6. Return a list containing both specs; Lazy.nvim filters them using `cond`.

---

## 4. Key Components Explained

### 4.1 Yarn Detection

```lua
local has_yarn = vim.fn.executable("yarn") == 1
```

Returns `true` if `yarn` is found in `$PATH`. This controls which spec is active.

### 4.2 Global Initialization (`init` callback)

```lua
init = init_globals
```

`init` runs before the plugin is actually loaded. Inside `init_globals()`:

```lua
vim.g.mkdp_filetypes = { "markdown" }
```

This limits activation to Markdown buffers and ensures the plugin only attaches where relevant. Other optional globals (commented out) let you control theme, browser, auto-closing, custom CSS, port behavior, etc.

### 4.3 Lazy-Loading Triggers

Both specs include:

```lua
ft = { "markdown" },
cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
```

That means the plugin loads when:
- You open a file whose detected filetype is `markdown`, OR
- You run one of the listed commands manually.

If you removed `ft`, the plugin would load strictly on command execution.

### 4.4 Prebuilt Spec (`prebuilt`)

```lua
build = function()
  local ok, err = pcall(function()
    vim.fn["mkdp#util#install"]()
  end)
  if not ok then
    vim.notify("[markdown-preview] Prebuilt install failed: " .. tostring(err), vim.log.levels.WARN)
  end
end
```

This calls the plugin’s own installer which:
- Downloads precompiled static assets (HTML/JS/CSS)
- Avoids installing `node_modules` locally

The `pcall` prevents the entire plugin setup from crashing if the network is down; it shows a warning instead.

### 4.5 Source Build Spec (`from_source`)

```lua
build = "cd app && yarn install --frozen-lockfile"
```

This:
1. Enters the plugin’s `app/` directory
2. Installs dependencies via `yarn install`
3. Uses `--frozen-lockfile` to ensure deterministic dependency resolution (if `yarn.lock` is present)

You could switch to `npm ci` by replacing the command.

### 4.6 Conditional Activation

```lua
prebuilt.cond = function() return not has_yarn end
from_source.cond = function() return has_yarn end
```

Lazy.nvim evaluates `cond` before loading/building a spec. Only the spec whose `cond` returns `true` proceeds. This prevents duplicate installations.

### 4.7 Post-Load Configuration (`config`)

```lua
local function add_keymaps()
  vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Markdown Preview Toggle" })
end

prebuilt.config = add_keymaps
from_source.config = add_keymaps
```

After the chosen plugin spec loads, the keymap is registered:
- Normal mode: `<leader>mp` toggles the preview window.

### 4.8 Return Value

```lua
return {
  prebuilt,
  from_source,
}
```

Even though both are returned, only one becomes active due to the `cond` logic.

---

## 5. Command Summary

| Command                       | Purpose                               |
|------------------------------|----------------------------------------|
| `:MarkdownPreview`           | Open preview in browser                |
| `:MarkdownPreviewToggle`     | Toggle preview on/off                  |
| `:MarkdownPreviewStop`       | Explicitly stop preview server         |

---

## 6. Common Global Options (All Optional)

You can place any of these (uncommented) inside `init_globals()`:

```lua
vim.g.mkdp_theme = "dark"            -- Force dark theme
vim.g.mkdp_auto_close = 1            -- Auto-close when buffer is hidden
vim.g.mkdp_browser = "firefox"       -- Force specific browser
vim.g.mkdp_page_title = "${name}"    -- Customize page title
vim.g.mkdp_markdown_css = "/path/to/custom.css"
vim.g.mkdp_port = "8888"             -- Use fixed port
vim.g.mkdp_open_to_the_world = 0     -- Restrict to localhost
```

---

## 7. Typical Workflow

1. Open a Markdown file: `nvim notes.md`
2. Start preview:
   - Use keymap: `<leader>mp`
   - Or run `:MarkdownPreview`
3. Edit buffer; preview auto-refreshes.
4. Stop preview:
   - `<leader>mp` again (toggle)
   - Or `:MarkdownPreviewStop`

---

## 8. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| No browser opens | Command issued before plugin loaded | Ensure filetype is markdown or use command to trigger load |
| Build failure using yarn | Missing yarn | Install yarn or rely on prebuilt mode |
| Preview shows stale content | Very old plugin version / caching | Update plugin, clear browser cache |
| Port conflict | Fixed port already used | Remove `vim.g.mkdp_port` setting or change port |
| Keymap not working | Leader not set early | Set `mapleader` before plugin setup in `init.lua` |

---

## 9. Switching Strategies Manually

If you always want prebuilt (even with yarn installed), remove the `cond` logic and just return `prebuilt`. Example:

```lua
return prebuilt
```

Or for source build:

```lua
return from_source
```

---

## 10. Extending

### Auto-open Preview on Markdown Entry

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    if vim.fn["mkdp#util#is_previewing"]() == 0 then
      vim.cmd("MarkdownPreview")
    end
  end,
})
```

### Close Preview When Leaving Neovim

```lua
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.fn["mkdp#util#is_previewing"]() == 1 then
      vim.cmd("MarkdownPreviewStop")
    end
  end,
})
```

---

## 11. Security / Network Notes

- The plugin serves a local HTTP server for the preview.
- `vim.g.mkdp_open_to_the_world = 0` (default) keeps it bound to localhost.
- If you enable external access, ensure no sensitive documents are exposed.

---

## 12. FAQs

**Q: Why two specs instead of one `build` branch?**  
A: Using `cond` keeps Lazy’s UI explicit—both strategies are visible but only one activates.

**Q: Does the prebuilt version lag behind source?**  
A: Occasionally; source builds can provide the very latest web assets.

**Q: Can I use `npm` instead of `yarn`?**  
A: Yes. Replace the build line with:  
`build = "cd app && npm ci"` (or `npm install` if no lockfile).

**Q: Do I need to clean anything after switching strategies?**  
A: Run `:Lazy clean` to prune leftover build artifacts if you change approach.

---

## 13. Summary

The code provides a resilient, flexible configuration for `markdown-preview.nvim`:
- Smart strategy selection
- Safe installation (protected build)
- Lazy loading for performance
- Simple keybinding for ergonomics
- Easy customization via globals

You can simplify it (single spec) or extend it (autostart, CSS, browser choice) depending on your workflow.

---

Feel free to request a Packer version, a Mason-like wrapper, or further automation snippets.