--[[============================================================================
#  `lsp.lua` — Central LSP Orchestration for Neovim

##  Purpose
Acts as the **central entry point** for all LSP-related configuration.
It orchestrates:
- Global diagnostics setup
- LSP server installation and configuration
- Buffer-local behavior delegation
- Optional plugin integration (status, completion, etc.)

This file ensures modularity: all buffer-local details are delegated to
`on_attach.lua`, while Mason handles installation.

##  Responsibilities
1. Configure global diagnostics for all buffers.
2. Load Mason and ensure required LSP servers, formatters, and linters are installed.
3. Set up LspAttach autocmd to call `on_attach` for buffer-local behaviors.
4. Optionally integrate plugins like `fidget.nvim` or `nvim-cmp`.
5. Provide a single place to extend LSP behavior or capabilities.

##  Design Decisions
- Diagnostics are global; buffer-local features are in `on_attach.lua`.
- Avoid duplication: highlights and formatting only set per buffer.
- Lazy load plugins by filetype or event to improve startup time.
- Maintain clean separation of concerns for future scalability.

##  How to Use
1. Place this file under `lua/plugins/lsp/lsp.lua`.
2. Include it in your plugin manager (LazyVim, Packer, etc.).
3. Mason will auto-install servers and formatters defined in `mason.lua`.
4. `on_attach.lua` handles all buffer-local keymaps, formatting, and highlights.
5. Optional: integrate `null-ls` separately for formatters/linters.

============================================================================
--]]

return {
  { 
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "saghen/blink.cmp",  -- Enhances capabilities for cmp

      -- Mason: Install servers, formatters, linters
      { "williamboman/mason.nvim", cmd = { "Mason", "MasonInstall" }, opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Status updates for LSP progress
      { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

      -- Autocompletion
      {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "onsails/lspkind.nvim",
        },
      },

      -- Java LSP (lazy load)
      { "mfussenegger/nvim-jdtls", ft = "java" },

      -- Lua dev library
      { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },
    },
    config = function()
      -- ╭──────────────────────────────────────╮
      -- │  Global Diagnostics Configuration    │
      -- ╰──────────────────────────────────────╯
      -- Purpose: Set how diagnostics are displayed in all buffers.
      -- Responsibilities: Floating windows, gutter signs, severity sorting.
      -- Design Decisions: Virtual text disabled, real-time update in insert mode.
      vim.diagnostic.config({
        virtual_text = false,
        float = { border = "rounded", source = true, header = "", prefix = "" },
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
        update_in_insert = true,
        severity_sort = true,
        signs = {
          active = true,
          severity = { min = vim.diagnostic.severity.HINT, max = vim.diagnostic.severity.ERROR },
          icons = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
      })

      -- ╭──────────────────────────────────────╮
      -- │  Load Mason and install LSP servers  │
      -- ╰──────────────────────────────────────╯
      -- Purpose: Ensure all required servers, formatters, and linters are installed.
      -- Responsibilities: Install missing tools and configure servers.
      -- Design Decisions: Centralized installation, lazy-loading for efficiency.
      require("plugins.lsp.mason") 

      -- ╭──────────────────────────────────────╮
      -- │  Setup null-ls (none-ls)             │
      -- ╰──────────────────────────────────────╯
      -- local status_ok, null_ls = pcall(require, "plugins.none-ls")
      -- if status_ok then
      --     null_ls.config()  -- Calls the M.config() function in none-ls.lua or none_ls.setup(on_attach, capabilities) if you pass params
      -- else
      --     vim.notify("none-ls plugin not found", vim.log.levels.WARN)
      -- end

      local on_attach = require("plugins.lsp.on_attach").on_attach

      -- Merge default capabilities with cmp capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
      capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

      local lspconfig = require("lspconfig")

      -- ╭──────────────────────────────────────╮
      -- │  LspAttach autocmd                   │
      -- ╰──────────────────────────────────────╯
      -- Purpose: Run `on_attach` for every buffer that attaches to any LSP client.
      -- Responsibilities: Set buffer-local keymaps, highlights, and formatting toggle.
      -- Design Decisions: Avoid duplicating code, delegate all buffer-local logic to `on_attach`.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            local bufnr = event.buf 
            if client.name == "null-ls" then
                vim.notify("null-ls attached to buffer " .. bufnr)
            end
            on_attach(client, bufnr)
          end
        end,
      })
    end,
  },
  -- Lazy.nvim will load none-ls automatically
  -- { "plugins.none-ls" },
}

