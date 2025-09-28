--[[
### **`lsp.lua`** — Central LSP orchestration

**Purpose:**  
Acts as the **central entry point** for all LSP-related configuration in Neovim.  
Orchestrates server setup, diagnostics, buffer-local behavior, and integration with optional plugins.

**Responsibilities:**
1. Load Mason and ensure required servers are installed.
2. Configure **global diagnostic behavior** (`vim.diagnostic.config`) for all buffers.
3. Create an `LspAttach` autocmd:
   - Calls `on_attach.lua` to set buffer-local keymaps and behavior.
   - Sets up **document highlights**.
   - Enables **autoformat-on-save** for clients supporting formatting.
4. Optionally integrate plugins like `fidget.nvim`, `lspsaga.nvim`, or `trouble.nvim`.
5. Serve as a central place to add **future LSP enhancements**, like custom per-client behavior or auto-completion hooks.

**Key Points:**
- Diagnostics configuration is **global**, runs once at startup.
- Buffer-local behavior is delegated to `on_attach`.
- Completion (nvim-cmp) can be added in a separate module (`autocompletion.lua`) to keep concerns separated.
- Centralized orchestration ensures modularity, maintainability, and future scalability.

**Future Improvements:**
- Integrate nvim-cmp or other completion engines here via a separate module.
- Add per-client customizations (e.g., `clangd` specific keymaps).
- Support which-key groups for organized LSP keymaps.
- Add logging or debugging hooks for LSP attach/detach events.
- Add lazy-loading mechanisms for LSP plugins and servers.
]]


return {
  { -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      { "saghen/blink.cmp" },

      -- Mason: only load when you need to install servers
      { "williamboman/mason.nvim",                  cmd = { "Mason", "MasonInstall" }, opts = {} },
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },

      -- Status updates for LSP
      { "j-hui/fidget.nvim",                        event = "LspAttach",               opts = {} },

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

      -- Java LSP
      { "mfussenegger/nvim-jdtls", ft = "java" },

      -- Lazy load only for Lua files
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },


    config = function()
          -- ╭──────────────────────────────────────╮
          -- │  Global Diagnostics Configuration    │
          -- ╰──────────────────────────────────────╯
      -- Diagnostic config (single call, merging signs floating and other settings)
      vim.diagnostic.config({
        virtual_text = false, -- disable inline virtual text
        float = {
          border = "rounded", -- 🔵 Rounded border
          source = true,      -- show source like [clangd]
          header = "",        -- show source like [clangd]
          prefix = "",        -- Optional: no bullet points
        },
        underline = {
          severity = {
            min = vim.diagnostic.severity.WARN, -- underline WARN and ERROR only
          },
        },
        update_in_insert = true, -- real-time diagnostics
        severity_sort = true,
        signs = {                -- enable signs in gutter
          active = true,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
      })
      -- For python formatting

          -- ╭─────────────────────────────────╮
          -- │ Load Mason (server installer)   │
          -- ╰─────────────────────────────────╯


      require("plugins.lsp.mason") -- Setup Mason and install servers
      -- require("plugins.lsp.servers")  -- Configure and start language servers -- WARN: Remember here i donot include server for lsp configurations

      -- NOTE: Brief aside: **What is LSP?**
      --
      -- 🧠LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- It gives your editor smart features like: think of it a language assistance
      --
      -- 🔍 Go to definition
      -- ℹ️ Hover for documentation
      -- 🚨 Show diagnostics (errors, warnings)
      -- 🧹 Auto-fix code (formatting, etc.)
      -- 🧠 Code completion (works with cmp)
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --

      -- This autocmd runs only when an LSP client attaches to a buffer.
      -- It's more efficient than setting global keymaps because it ensures
      -- that keymaps are only active when an LSP is actually present.
      -- Cache this once, outside the function
      local has_nvim_011 = vim.fn.has("nvim-0.11") == 1
      ---@param client vim.lsp.Client
      ---@param method vim.lsp.protocol.Method
      ---@param bufnr? integer
      ---@return boolean
      local function client_supports_method(client, method, bufnr)
        if type(client) ~= "table" or (not client.supports_method and not client["supports_method"]) then
          vim.schedule(function()
            vim.notify("Invalid LSP client passed to client_supports_method", vim.log.levels.WARN)
          end)
          return false
        end

        if has_nvim_011 then
          -- Newer Neovim supports method call
          if bufnr then
            -- If buf-specific check is needed and supported
            -- (this depends on the LSP client impl, so safe fallback below)
            local ok, result = pcall(client.supports_method, client, method, bufnr)
            if ok and type(result) == "boolean" then
              return result
            end
          end
          -- Fallback: call without bufnr
          return client:supports_method(method)
        else
          -- Older Neovim: pass client explicitly, no bufnr param expected
          return client.supports_method(client, method)
        end
      end

      -- NOTE: Should diagnostic config be inside LspAttach?
      --
      -- No, mostly not.
      -- The vim.diagnostic.config() call applies globally — it sets how diagnostics behave across all buffers and all LSP clients.
      -- This means it should run once on startup, not inside an LspAttach autocmd that triggers every time an LSP client attaches to a buffer.

      -- On LSP attach, configure keymaps and behaviors
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            -- print("No client found on attach")
            return -- client is nil, so do nothing
            --[[
              event.data.client_id always exists in LspAttach event.
              Use vim.lsp.get_client_by_id to get the client object.
              If that returns nil, bail early.
              Then safely access server_capabilities and documentFormattingProvider.
            --]]
          end
          local bufnr = event.buf


          -- Delegate keymaps and buffer-local behaviors to on_attach.lua
           require("plugins.lsp.on_attach").on_attach(client, bufnr)
          --
          -- NOTE:        What should go inside LspAttach?
          --
          -- Buffer-local keymaps for LSP functions (go-to-def, hover, rename, code actions, etc.).
          -- Any client- or buffer-specific behavior that must happen per LSP attach.
          -- Per-client capability checks like client_supports_method.
          -- cmp dono got under LspAttach cause cm work individaully yes it takes helps from LSPs for that it's has no need to attach.
          -- ╭───────────────────────────╮
          -- │🛠️ Core LSP actions        │
          -- ╰───────────────────────────╯
          -- it's empty for now if want anything to attacah you can
          -- ╭───────────────────────────────────────────╮
          -- │🧠 Future Improvements You Can Add Here    │
          -- ╰───────────────────────────────────────────╯
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false }),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(fmt_client)
                    return fmt_client.name == "null-ls" or fmt_client.id == client.id
                  end,
                  timeout_ms = 2000,
                })
              end,
            })
          end
          -- ╭───────────────────────────────╮
          -- │🤖⚙️AUTOCOMPLETION (nvim-cmp)  │
          -- ╰───────────────────────────────╯
          -- a better completion is there in autocompletion.lua under lua\plugins folder,


          -- ╭───────────────────────────╮
          -- │🖍️Document Highlight       │
          -- ╰───────────────────────────╯
          -- Document Highlight if supported
          -- local client = vim.lsp.get_client_by_id(event.data.client_id) -- already defined ` local client ` at 209 line
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false }) -- vim.api lets you interact with Neovim — like manipulating buffers, windows, or getting/setting options — through Lua scripts.

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl_group,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl_group,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-highlight-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = hl_group, buffer = event2.buf })
              end,
            })
          end
          -- 🔧 Disable underline for LSP highlights
          vim.api.nvim_set_hl(0, "LspReferenceText", { underline = false, bg = "#3c3836" })
          vim.api.nvim_set_hl(0, "LspReferenceRead", { underline = false, bg = "#3c3836" })
          vim.api.nvim_set_hl(0, "LspReferenceWrite", { underline = false, bg = "#3c3836" })
        end,
      })
    end,
  },

}
