--[[
### 1. **`on_attach.lua`** — *What to do when the LSP starts working on a file*

* This file contains **the stuff that runs when the language server connects to a file**.
* Usually, here you put **keybindings** for things like "go to definition", "hover help", "rename symbol".
* Think of it as "What shortcuts do I want only when LSP is active in this buffer?"

**Example**:

* Pressing `K` shows documentation.
* Pressing `<leader>rn` renames a symbol.

🔍 What Should Go Inside on_attach
Your inline comment is spot-on. To clarify:

All LSP-specific mappings should go inside on_attach.
Any behavior depending on the capabilities of the attached client (like client.server_capabilities.hoverProvider) belongs here.
Any logic that customizes how an LSP behaves in a specific buffer (e.g., disabling formatting for tsserver) also belongs here.
UI tweaks like disabling handlers (textDocument/hover, etc.) can also be inside on_attach if they're per-client or per-buffer.

--]]
local M = {}

M.on_attach = function(client, bufnr)
  -- 🔒 Prevent native LSP completion popup
  vim.bo[bufnr].omnifunc = ""

  -- Optional: Disable hover popup from LSP (but keep manual `K` key)
  --vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  --   vim.lsp.handlers.hover, { border = "none" }
  -- )

  -- Optional: Disable auto signature help popup from LSP (cmp handles it)
  --vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  --   vim.lsp.handlers.signature_help, { border = "none" }
  -- )

  local map = function(keys, func, desc, mode)
    mode = mode or 'n'        -- default to normal mode
    vim.keymap.set(mode, keys, func, {
      buffer = bufnr,         -- Only active in the LSP-attached buffer, buffer-local
      desc = 'LSP: ' .. desc, -- Helps show key descriptions in which-key or Telescope
    })
  end

  -- NOTE:        What should go inside LspAttach?
  --
  -- Buffer-local keymaps for LSP functions (go-to-def, hover, rename, code actions, etc.).
  -- Any client- or buffer-specific behavior that must happen per LSP attach.
  -- Per-client capability checks like client_supports_method.
  -- cmp dono got under LspAttach cause cm work individaully yes it takes helps from LSPs for that it's has no need to attach.
  -- ╭───────────────────────────╮
  -- │🛠️ Core LSP actions        │
  -- ╰───────────────────────────╯

  -- Show hover documentation (e.g., function signature, comments)
  -- map('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Show signature help (parameters of a function during a call)
  map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')

  -- Rename symbol under the cursor (variables, functions, etc.)
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

  -- Trigger code actions like "quick fix" (for errors, suggestions)
  -- Works in both normal and visual mode.
  map('gra', vim.lsp.buf.code_action, '[Code] [Action]', { 'n', 'v' })

  -- ╭─────────────────────────────────────────────╮
  -- │🔭 Navigation (using Telescope if available) │
  -- ╰─────────────────────────────────────────────╯


  -- Go to references (usages of the symbol under the cursor)
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

  -- Go to definition (function/variable definition)
  map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

  -- Go to implementation (e.g., concrete implementation of an interface)
  map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

  -- Go to type definition (type of a variable or return type of a function)
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

  -- Go to declaration (e.g., header file declaration in C/C++)
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- ╭──────────────────────────────────────╮
  -- │📄 Symbol search (local and global)   │
  -- ╰──────────────────────────────────────╯


  -- Fuzzy find all symbols in the current document (functions, vars, etc.)
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

  -- Fuzzy find all symbols in the entire workspace/project
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

  -- ╭─────────────────╮
  -- │🚨 Diagnostics   │
  -- ╰─────────────────╯


  -- Jump to previous and next diagnostics
  map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous Diagnostic')
  map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')

  -- Open diagnostic message in a floating window
  map('<leader>ld', vim.diagnostic.open_float, 'Line Diagnostics')

  -- Send diagnostics to location list (so you can see all in a list)
  map('<leader>lq', vim.diagnostic.setloclist, 'Diagnostics to Loclist')

  -- Disable LSP native completion item preview
  -- vim.opt.completeopt = { "menu", "menuone", "noselect" }


  -- This ensures you only map things the server can actually do:
  -- if client.server_capabilities.hoverProvider then
  --   map('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- end
  --
  if client.server_capabilities.signatureHelpProvider then
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
  end

  -- Disable formatting for some LSPs if needed
  if client.name == "tsserver" or client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end
  -- add more if needed
end

return M
