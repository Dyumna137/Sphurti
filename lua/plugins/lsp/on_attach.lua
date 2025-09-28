--[[
### 1. **`on_attach.lua`** — *What to do when the LSP starts working on a file*

* This file contains **the stuff that runs when the language server connects to a file**.
* Usually, here you put **keybindings** for things like "go to definition", "hover help", "rename symbol".
* Think of it as "What shortcuts do I want only when LSP is active in this buffer?"

**Example**:
* Pressing `K` shows documentation.
* Pressing `<leader>rn` renames a symbol.

🔍 What Should Go Inside on_attach
- All LSP-specific mappings should go inside on_attach.
- Any behavior depending on the capabilities of the attached client (like client.server_capabilities.hoverProvider) belongs here.
- Any logic that customizes how an LSP behaves in a specific buffer (e.g., disabling formatting for tsserver) also belongs here.
- UI tweaks like disabling handlers (textDocument/hover, etc.) can also be inside on_attach if they're per-client or per-buffer.
--]]

local M = {}

M.on_attach = function(client, bufnr)
  -- 🔒 Prevent native LSP completion popup
  vim.bo[bufnr].omnifunc = ""

  -- Optional: Disable hover popup from LSP (but keep manual `K` key)
  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  --   vim.lsp.handlers.hover, { border = "none" }
  -- )

  -- Optional: Disable auto signature help popup from LSP (cmp handles it)
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  --   vim.lsp.handlers.signature_help, { border = "none" }
  -- )

  -- Smarter keymap helper: auto-prepend "LSP:" to desc if provided
  local function map(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, {
      buffer = bufnr,
      desc = desc and ("LSP: " .. desc) or nil,
    })
  end

  -- Capability checker: safer and more readable
  local function supports(client, method)
    return client.supports_method("textDocument/" .. method)
  end

  -- ╭───────────────────────────╮
  -- │🛠️ Core LSP actions        │
  -- ╰───────────────────────────╯
  if supports(client, "hover") then
    map("K", vim.lsp.buf.hover, "Hover Documentation")
  end
  if supports(client, "signatureHelp") then
    map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")
  end
  map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
  map("gra", vim.lsp.buf.code_action, "[Code] [Action]", { "n", "v" })

  -- ╭─────────────────────────────────────────────╮
  -- │🔭 Navigation (using Telescope if available) │
  -- ╰─────────────────────────────────────────────╯
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    map("grr", telescope.lsp_references, "[G]oto [R]eferences")
    map("grd", telescope.lsp_definitions, "[G]oto [D]efinition")
    map("gri", telescope.lsp_implementations, "[G]oto [I]mplementation")
    map("grt", telescope.lsp_type_definitions, "[G]oto [T]ype Definition")
    map("gO", telescope.lsp_document_symbols, "Document Symbols")
    map("gW", telescope.lsp_dynamic_workspace_symbols, "Workspace Symbols")
    map("<leader>xx", telescope.diagnostics, "Workspace Diagnostics")
    map("<leader>xd", function()
      telescope.diagnostics({ bufnr = 0 })
    end, "Document Diagnostics")
  else
    -- fallback: non-telescope mappings could be added here if desired
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  end

  -- ╭─────────────────╮
  -- │🚨 Diagnostics   │
  -- ╰─────────────────╯
  map("[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, "Previous Diagnostic")
  map("]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, "Next Diagnostic")
  map("<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
  map("<leader>lq", vim.diagnostic.setloclist, "Diagnostics to Loclist")

  -- ╭────────────────────────────╮
  -- │⚙️ Client-specific settings │
  -- ╰────────────────────────────╯
  -- Disable formatting for some servers (use external formatter instead)
  if supports(client, "formatting") then
    if client.name == "tsserver" or client.name == "lua_ls" then
      client.server_capabilities.documentFormattingProvider = false
    end
  end
end

return M
