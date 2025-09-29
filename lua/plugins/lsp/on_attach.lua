--[[============================================================================
# 📄 `on_attach.lua` — Buffer-local behavior for Neovim LSP clients

## 🔎 Purpose
This module defines **all buffer-local behavior** for Neovim’s LSP clients.  
It ensures keymaps, formatting, and highlights are only active in buffers where
an LSP is actually attached.

Neovim’s `LspAttach` autocmd calls this file’s `on_attach` function, passing in
the `client` and `bufnr`. From there, everything configured here applies only
to that buffer.

---

## 🧩 Responsibilities
1. Define **buffer-local keymaps** for LSP actions:
   - Hover docs, rename, code actions, diagnostics navigation, etc.
   - Telescope-powered navigation if Telescope is installed.
2. Configure **autoformat-on-save** for clients that support formatting.
3. Disable formatting for specific servers (e.g., `tsserver`, `lua_ls`).
4. Set up **document highlights** (references under cursor).
5. Provide helpers:
   - `supports(client, method)` → checks if the client supports a capability.
   - `bufmap(bufnr, key, func, desc, mode)` → clean buffer-local keymapping.

---

## 🔧 Example usage:
```lua
-- Inside LspAttach callback
local on_attach = require("plugins.lsp.on_attach").on_attach
on_attach(client, bufnr)
 
]]

local M = {}

-- helper: multi-mode buffer keymap
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

-- client-specific overrides
-- This avoids hardcoding "textDocument/" everywhere.
local client_specific = {
  tsserver = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end,
  lua_ls = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end,
}

M.on_attach = function(client, bufnr)
  -- 🔒 Prevent native LSP completion popup
  vim.bo[bufnr].omnifunc = ""

  -- ╭───────────────────────────╮
  -- │🛠️ Core LSP actions        │
  -- ╰───────────────────────────╯
  if client.server_capabilities.hoverProvider then
    bufmap(bufnr, "K", vim.lsp.buf.hover, "Hover Documentation")
  end
  if client.server_capabilities.signatureHelpProvider then
    bufmap(bufnr, "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
  end

  bufmap(bufnr, "<leader>rn", vim.lsp.buf.rename, "Rename")
  bufmap(bufnr, "<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "v" })

  -- ╭────────────────────────────╮
  -- │🔭 Navigation (Telescope)   │
  -- ╰────────────────────────────╯
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    bufmap(bufnr, "grr", telescope.lsp_references, "[G]oto [R]eferences")
    bufmap(bufnr, "grd", telescope.lsp_definitions, "[G]oto [D]efinition")
    bufmap(bufnr, "gri", telescope.lsp_implementations, "[G]oto [I]mplementation")
    bufmap(bufnr, "grt", telescope.lsp_type_definitions, "[G]oto [T]ype Definition")
    bufmap(bufnr, "gO", telescope.lsp_document_symbols, "Document Symbols")
    bufmap(bufnr, "gW", telescope.lsp_dynamic_workspace_symbols, "Workspace Symbols")
    bufmap(bufnr, "<leader>xx", telescope.diagnostics, "Workspace Diagnostics")
    bufmap(bufnr, "<leader>xd", function()
      telescope.diagnostics({ bufnr = 0 })
    end, "Document Diagnostics")
  else
    bufmap(bufnr, "grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  end

  -- ╭─────────────────╮
  -- │🚨 Diagnostics   │
  -- ╰─────────────────╯
  -- Cleaner diagnostic maps with a loop.
  for _, d in ipairs({
    { "[d", -1, "Previous" },
    { "]d", 1, "Next" },
  }) do
    bufmap(bufnr, d[1], function()
      vim.diagnostic.jump({ count = d[2], float = true })
    end, d[3] .. " Diagnostic")
  end
  bufmap(bufnr, "<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
  bufmap(bufnr, "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Loclist")

  -- ╭────────────────────────────╮
  -- │⚙️ Client-specific settings │
  -- ╰────────────────────────────╯
  if client_specific[client.name] then
    client_specific[client.name](client, bufnr)
  end

  -- ╭───────────────────────╮
  -- │ Autoformat (toggle)   │
  -- ╰───────────────────────╯
  local format_enabled = true
  bufmap(bufnr, "<leader>tf", function()
    format_enabled = not format_enabled
    vim.notify("Format on save: " .. (format_enabled and "enabled" or "disabled"))
  end, "Toggle Format on Save")

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if format_enabled then
          vim.lsp.buf.format({ bufnr = bufnr })
        end
      end,
    })
  end

  -- ╭───────────────────────╮
  -- │ Document Highlight    │
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

return M

