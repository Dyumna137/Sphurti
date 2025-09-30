--[[
==============================================================================
📄 on_attach.lua — Buffer-local behavior for Neovim LSP clients

🔎 Purpose
----------
Defines all buffer-local behavior when an LSP client attaches to a buffer.
Formatting is fully delegated to your null-ls hybrid config, but this module
still exposes a `format_status()` helper for your statusline, wired to the
global toggle.

🧩 Responsibilities
-------------------
1. Set up buffer-local keymaps for LSP features.
2. Apply client-specific overrides (disable formatting, etc.).
3. Enable document highlights when supported.
4. Provide a statusline helper `format_status()` to reflect the
   current formatting toggle state (from null-ls).

🎯 Design Decisions
-------------------
- Single responsibility: no formatting logic in on_attach.
- Global formatting control lives in null-ls, shared everywhere.
- Keep `format_status()` here to make lualine integration simple.
- Each buffer gets isolated autocmd groups (no leaks).

🔧 Example Usage
---------------
-- In LspAttach autocmd:
local on_attach = require("plugins.lsp.on_attach").on_attach
on_attach(client, bufnr)

-- In lualine:
lualine_x = {
  require("plugins.lsp.on_attach").format_status,
  "encoding", "filetype"
}

==============================================================================
]]

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
  -- Disable LSP omnifunc completion (prefer cmp or other sources)
  vim.bo[bufnr].omnifunc = ""

  -- Apply client-specific overrides if defined
  if client_specific[client.name] then
    client_specific[client.name](client, bufnr)
  end

  -- Example: keymaps for core LSP functions (expand as you like)
  bufmap(bufnr, "K", vim.lsp.buf.hover, "LSP Hover")
  bufmap(bufnr, "gd", vim.lsp.buf.definition, "Goto Definition")
  bufmap(bufnr, "gr", vim.lsp.buf.references, "Goto References")
  bufmap(bufnr, "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
  bufmap(bufnr, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

  -- Document highlights
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
  local ok, fmt = pcall(require, "plugins.lsp.null-ls-format")
  if ok and fmt.is_enabled() then
    return "fmt:on"
  else
    return "fmt:off"
  end
end

return M
