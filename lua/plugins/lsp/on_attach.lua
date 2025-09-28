--[[
### 1. **`on_attach.lua`** — Buffer-local behavior for LSP clients

**Purpose:**  
Defines behavior that only applies to a specific buffer **when a language server attaches**.  
This ensures that keymaps, autoformatting, and document highlights are only active for buffers with an LSP client.

**Responsibilities:**
1. Define buffer-local keymaps for LSP actions:
   - `K` → hover documentation
   - `<leader>rn` → rename symbol
   - `<leader>ca` → code actions
   - Navigation mappings (`gd`, `grd`, `gri`, `grt`, etc.)
2. Set up **document highlights** if supported by the client.
3. Configure **autoformat on save** for clients that support formatting.
4. Disable certain capabilities selectively (e.g., formatting for `tsserver` or `lua_ls`).
5. Provide helpers for safe, readable buffer-local keymaps and capability checks.

**Example Usage:**
```lua
-- Inside on_attach function
- bufmap(bufnr, "K", vim.lsp.buf.hover, "Hover Documentation")
- bufmap(bufnr, "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
- All LSP-specific mappings should go inside `on_attach`.
- Any behavior depending on the capabilities of the attached client (like `hoverProvider`) belongs here.
- Any logic that customizes how an LSP behaves in a specific buffer (e.g., disabling formatting for tsserver) belongs here.
- UI tweaks like disabling handlers (`textDocument/hover`, etc.) can also be inside `on_attach` if they're per-client or per-buffer.
]]

local M = {}

-- helper: check if the LSP client supports a method
local function supports(client, method)
  return client.supports_method("textDocument/" .. method)
end

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

M.on_attach = function(client, bufnr)
  -- 🔒 Prevent native LSP completion popup
  vim.bo[bufnr].omnifunc = ""

  -- ╭───────────────────────────╮
  -- │🛠️ Core LSP actions        │
  -- ╰───────────────────────────╯
  if supports(client, "hover") then
    bufmap(bufnr, "K", vim.lsp.buf.hover, "Hover Documentation")
  end
  if supports(client, "signatureHelp") then
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
  bufmap(bufnr, "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous Diagnostic")
  bufmap(bufnr, "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
  bufmap(bufnr, "<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
  bufmap(bufnr, "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Loclist")

  -- ╭────────────────────────────╮
  -- │⚙️ Client-specific settings │
  -- ╰────────────────────────────╯
  if supports(client, "formatting") then
    if client.name == "tsserver" or client.name == "lua_ls" then
      client.server_capabilities.documentFormattingProvider = false
    end
  end

  -- ╭───────────────────────╮
  -- │ Autoformat (optional) │
  -- ╰───────────────────────╯
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, async = true })
      end,
    })
  end

  -- ╭───────────────────────╮
  -- │ Document Highlight    │
  -- ╰───────────────────────╯
  if supports(client, "documentHighlight") then
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

