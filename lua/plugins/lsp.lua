--[[============================================================================
# lsp.lua — Global LSP Orchestration Layer

Scope:
  • Global (non server-specific) LSP UX policies: diagnostics, autocommands.
  • Delegates server installation + per-server config to mason.lua.
  • Delegates buffer-local keymaps/formatting to on_attach.lua.

Not Owned Here:
  • Server definitions (→ mason.lua)
  • Tool installation lists (→ mason.lua)
  • Buffer-local mappings (→ on_attach.lua)
  • Completion source definitions (→ completion plugin config)

Extension Points:
  • Adjust diagnostics appearance.
  • Inject or override global LSP handlers (hover, signatureHelp).
  • Add cross-server features (e.g., semantic token styling).

Change Log (manual):
  • 2025-10-04: Synced with documented mason.lua style.
  • lsp.lua becomes “global orchestration” and mason.lua is the real worker.
  • Potential race:
    - If Mason plugin spec loads later than this lsp.lua (because of different events), diagnostics/autocmd here will work, but servers may attach only after Mason loads. That’s ok—but ensure Mason loads early enough (BufReadPre is a good shared trigger).

============================================================================]]


return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      -- Pull in the Mason spec so server setup runs (auto-discovered).
      { import = "plugins.lsp.mason" },

      -- Completion engine (choose ONE; remove if handled elsewhere)

      -- Java (lazy-loaded)
      { "mfussenegger/nvim-jdtls", ft = "java" },

      -- Lua library enrichments
      {
      -- │ Diagnostic Sign Icons              │
      -- ╰────────────────────────────────────╯
      -- Purpose: Define gutter sign glyphs once (clear & consistent).
      local diag_icons = {
        Error = "[E]",
        Warn  = "[W]",
        Hint  = "[H]",
        Info  = "[I]",
      }
      for severity, icon in pairs(diag_icons) do
        local hl = "DiagnosticSign" .. severity
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- ╭────────────────────────────────────╮
      -- │ Global Diagnostic Behavior         │
      -- ╰────────────────────────────────────╯
      -- Purpose: Control visual noise & clarity.
      vim.diagnostic.config({
        virtual_text = false, -- cleaner editing surface
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
        signs = true,
      })

      -- ╭────────────────────────────────────╮
      -- │ LspAttach Autocommand              │
      -- ╰────────────────────────────────────╯
      -- Purpose: Invoke shared on_attach for every new client.
      local on_attach = require("plugins.lsp.on_attach").on_attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end
            -- Idempotent attach; errors suppressed.
          pcall(on_attach, client, ev.buf)
        end,
      })

      -- ╭────────────────────────────────────╮
      -- │ Optional Handler Overrides         │
      -- ╰────────────────────────────────────╯
      -- Purpose: Customize global LSP UI (uncomment to use).
      -- Example (uncomment if desired):
      -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      --   vim.lsp.handlers.hover,
      --   { border = "rounded", max_width = 80 }
      -- )
    end,
  },
}
