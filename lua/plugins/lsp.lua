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


-- ╭──────────────────────────────────────────────────────────────╮
-- │ LSP Core Configuration (nvim-lspconfig + global behavior)    │
-- ╰──────────────────────────────────────────────────────────────╯
--
-- This file does THREE things only:
--   1. Declare the LSP plugin and its dependencies
--   2. Define global diagnostic visuals (once, for all servers)
--   3. Attach a shared on_attach() to every LSP client automatically
--
-- It does NOT configure individual language servers.
-- That responsibility belongs to mason.lua / server setup files.
--
-- Mental model:
--   mason.lua  -> installs & starts servers
--   on_attach  -> keymaps, buffer behavior
--   this file  -> UI, diagnostics, lifecycle glue
--

return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",

    -- These are "data only" plugin dependencies.
    dependencies = {
      { import = "plugins.lsp.mason" },         -- Mason auto server setup
      { "mfussenegger/nvim-jdtls", ft = "java" } -- Java LSP (lazy loaded)
    },

    -- All executable logic must live here.
    config = function()
      -----------------------------------------------------------------------
      -- 1) Diagnostic Sign Icons (gutter symbols)
      -----------------------------------------------------------------------
      -- Define once, reused by every LSP server.
      -- Using ASCII keeps compatibility with all fonts.
      -- IMPORTANT: Neovim 0.9.5 requires signs to be max 2 chars (E239 error if 3+)
      local diag_icons = {
        Error = "E ",
        Warn  = "W ",
        Hint  = "H ",
        Info  = "I ",
      }

      for severity, icon in pairs(diag_icons) do
        local hl = "DiagnosticSign" .. severity
        vim.fn.sign_define(hl, {
          text = icon,
          texthl = hl,
          numhl = "",
        })
      end

      -----------------------------------------------------------------------
      -- 2) Global Diagnostic Behavior
      -----------------------------------------------------------------------
      -- These settings affect how diagnostics are rendered everywhere.
      -- Goal: low visual noise, high signal clarity.
      vim.diagnostic.config({
        virtual_text = false,  -- Avoid inline clutter
        signs = true,          -- Use gutter icons instead
        underline = {
          severity = { min = vim.diagnostic.severity.WARN }
        },
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
      })

      -----------------------------------------------------------------------
      -- 3) LspAttach Autocommand
      -----------------------------------------------------------------------
      -- This runs every time ANY LSP client attaches to ANY buffer.
      -- Instead of configuring on_attach per server, we centralize it here.
      --
      -- This guarantees:
      --   - Idempotent behavior
      --   - Consistent keymaps across languages
      --   - No repetition in server configs
      --
      local on_attach = require("plugins.lsp.on_attach").on_attach

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end

          -- Protected call prevents rare race-condition crashes
          pcall(on_attach, client, ev.buf)
        end,
      })

      -----------------------------------------------------------------------
      -- 4) Optional: Global LSP UI Overrides
      -----------------------------------------------------------------------
      -- Uncomment if you want prettier hover windows everywhere.
      --
      -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      --   vim.lsp.handlers.hover,
      --   { border = "rounded", max_width = 80 }
      -- )
    end,
  },
}

