--[[============================================================================
# 📄 `on_attach.lua` — Buffer-local behavior for Neovim LSP clients

## 🔎 Purpose
Defines **all buffer-local behavior** for Neovim’s LSP clients.  
Ensures that keymaps, formatting, and highlights are active **only** in buffers
where an LSP is attached.  

This is the single entrypoint used in your `LspAttach` callback.

---

## 🧩 Responsibilities
1. Provide **buffer-local keymaps** for core LSP features:
   - Hover, signature help, rename, code actions.
   - Navigation (with Telescope if available).
   - Diagnostics (jump, float, loclist).
2. Configure **formatting**:
   - `<leader>F` → Manual format (always available).
   - `<leader>tf` → Toggle autoformat-on-save (per buffer).
   - Autoformat runs only if supported by the client.
3. Apply **client-specific overrides**:
   - Disable formatting for unwanted servers (`tsserver`, `lua_ls`).
4. Enable **document highlights**:
   - Highlights references under the cursor, clears on movement.
5. Expose **statusline helper**:
   - `format_status()` → returns `" fmt:on"` or `" fmt:off"` per buffer.

---

## 🎯 Design Decisions
- **Per-buffer toggle** → formatting state is stored in `vim.b[bufnr]`.
- **Clear augroups** → each buffer gets its own `LspFormat.<bufnr>` group.
- **Separation of concerns**:
  - Manual formatting (`<leader>F`) is always available.
  - Autoformat is opt-in and toggleable.
- **Minimal dependencies** → Telescope is optional, rest is native LSP.
- **Statusline integration** → quick visual feedback of format state.

---

## 🔧 Example Usage
```lua
-- Inside LspAttach autocmd:
local on_attach = require("plugins.lsp.on_attach").on_attach
on_attach(client, bufnr)

-- In lualine config:
lualine_x = {
  require("plugins.lsp.on_attach").format_status,
  "encoding", "filetype"
}


============================================================================]]


local M = {}

-- ╭──────────────────────────────╮
-- │ Helper: buffer-local keymap  │
-- ╰──────────────────────────────╯
local function bufmap(bufnr, key, func, desc, mode)
  mode = mode or "n"
  if type(mode) == "table" then
    for _, m in ipairs(mode) do
      vim.keymap.set(m, key, func, { buffer = bufnr, desc = desc })
    end
  else
    vim.keymap.set(mode, key, func, { buffer = bufnr, desc = desc })
  end
end

-- ╭──────────────────────────────╮
-- │ Client-specific overrides    │
-- ╰──────────────────────────────╯
local client_specific = {
  tsserver = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end,
  lua_ls = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end,
}

-- ╭──────────────────────────────╮
-- │ Main on_attach entrypoint    │
-- ╰──────────────────────────────╯
M.on_attach = function(client, bufnr)
  -- 🔒 Prevent native LSP completion popup
  vim.bo[bufnr].omnifunc = ""

  -- ╭───────────────────────╮
  -- │ 📝 Formatting toggle  │
  -- ╰───────────────────────╯
  if client.server_capabilities.documentFormattingProvider then
    -- Store toggle state per buffer
    vim.b[bufnr].format_enabled = true

    -- Manual formatting
    bufmap(bufnr, "<leader>F", function()
      vim.lsp.buf.format({
        bufnr = bufnr,
        async = true,
        filter = function(c)
          return c.name == "null-ls" or c.name == client.name
        end,
      })
      vim.notify("Formatted buffer with " .. client.name, vim.log.levels.INFO)
    end, "Format buffer manually")

    -- Toggle autoformat
    bufmap(bufnr, "<leader>tf", function()
      vim.b[bufnr].format_enabled = not vim.b[bufnr].format_enabled
      vim.notify("Format on save: " ..
        (vim.b[bufnr].format_enabled and "ENABLED ✅" or "DISABLED ⛔"))
    end, "Toggle Format on Save")

    -- Autoformat before save
    local group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      buffer = bufnr,
      callback = function()
        if vim.b[bufnr].format_enabled then
          vim.lsp.buf.format({ bufnr = bufnr, async = false })
        end
      end,
      desc = "Autoformat before save",
    })
  end

  -- ╭───────────────────────╮
  -- │ ✨ Document Highlight │
  -- ╰───────────────────────╯
  if client.server_capabilities.documentHighlightProvider then
    local hl_grp = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_grp,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = hl_grp,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- ╭──────────────────────────────╮
-- │ Statusline integration       │
-- ╰──────────────────────────────╯
function M.format_status()
  if vim.b.format_enabled == nil then return "" end
  return vim.b.format_enabled and " fmt:on" or " fmt:off"
end

return M

