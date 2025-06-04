-- File: ~/.config/nvim/lua/plugins/lsp.lua
-- Purpose: Set up LSP servers, completion engine (cmp), and diagnostics.
-- Author: Dyumna, with help from ChatGPT, Kickstart
-- Future-me, don't forget to run `:Mason` to install LSP servers!
-- ─ ╰ ─ ╯ ─ ╭ ─ ╮

return {
  { -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { "InsertEnter", "BufReadPost" },
    dependencies = {
      -- Mason and related plugins for automatic LSP and tool installation
      { 'saghen/blink.cmp' },
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      { 'mason-org/mason.nvim', event = "BufReadPre", opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Status updates for LSP
      { 'j-hui/fidget.nvim',   opts = {} },
      { "hrsh7th/cmp-nvim-lsp" }, -- recommended if using nvim-cmp
      -- nvim-cmp (Autocompletion)
      {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter", -- event = { "BufReadPre", "BufNewFile", "InsertEnter" },
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "L3MON4D3/LuaSnip",         -- snippets engine
          "saadparwaiz1/cmp_luasnip", -- for LuaSnip completion
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
        },
        { "onsails/lspkind.nvim" },
      },
    },

    config = function()
      -- Diagnostic config (single call, merging signs floating and other settings)
      vim.diagnostic.config({
        virtual_text = true,  -- disable inline virtual text
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
        signs = {
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
      vim.api.nvim_create_user_command("RuffAutofix", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local params = {
          command = "ruff.applyAutofix",
          arguments = {
            {
              uri = vim.uri_from_bufnr(bufnr),
              version = vim.lsp.util.buf_versions[bufnr] or 0,
            }
          }
        }
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", params, function(_, _, _, _) end)
      end, { desc = "Ruff: Fix all auto-fixable problems" })

      vim.api.nvim_create_user_command("RuffOrganizeImports", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local params = {
          command = "ruff.applyOrganizeImports",
          arguments = {
            {
              uri = vim.uri_from_bufnr(bufnr),
              version = vim.lsp.util.buf_versions[bufnr] or 0,
            }
          }
        }
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", params, function(_, _, _, _) end)
      end, { desc = "Ruff: Organize imports" })



      -- -- Set up autocommand group to safely manage floating diagnostics popup
      -- vim.api.nvim_create_augroup("FloatDiagnostics", { clear = true })
      --
      -- vim.api.nvim_create_autocmd("CursorHold", {
      --
      --   group = "FloatDiagnostics",
      --   callback = function()
      --     -- Avoid showing diagnostics float inside Trouble window
      --     if vim.bo.filetype == "Trouble" then
      --       return
      --     end
      --
      --     if vim.fn.mode() == "n" then
      --       vim.diagnostic.open_float(nil, {
      --         focusable = false,
      --         close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      --         border = "rounded",
      --         source = "always",
      --         prefix = "",
      --         scope = "cursor",
      --         win_opts = {
      --           winblend = 50, -- 0 = opaque, 100 = fully transparent
      --         },
      --       })
      --     end
      --   end,
      -- })


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
            print("No client found on attach")
            return -- client is nil, so do nothing
            --[[
              event.data.client_id always exists in LspAttach event.
              Use vim.lsp.get_client_by_id to get the client object.
              If that returns nil, bail early.
              Then safely access server_capabilities and documentFormattingProvider.
            --]]
          end
          local bufnr = event.buf


          -- -- [Helper] Define buffer-local keymaps easily.
          -- -- This avoids repeating boilerplate for mode, buffer, and description.
          -- -- Later, you can extract this helper globally if you want to reuse it outside LSP.
          -- local map = function(keys, func, desc, mode)
          --   mode = mode or 'n'        -- default to normal mode
          --   vim.keymap.set(mode, keys, func, {
          --     buffer = event.buf,     -- Only active in the LSP-attached buffer
          --     desc = 'LSP: ' .. desc, -- Helps show key descriptions in which-key or Telescope
          --   })
          -- end
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
          -- You can setup your keymaps here (example)
          -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
          print("LSP client attached: " .. client.name)
          -- Set up autoformat on save for clients that support formatting
          if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
            print("Client supports formatting")
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = vim.api.nvim_create_augroup('LspFormatOnSave', { clear = false }),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(fmt_client)
                    -- Optionally restrict formatting to specific clients, e.g., null-ls only
                    return fmt_client.name == "null-ls" or fmt_client.id == client.id
                  end,
                  timeout_ms = 2000,
                })
              end,
            })
          else
            print("Formatting not supported by client")
          end
          -- 1. Extract `map` to a global utility file (e.g., `lua/utils/keymap.lua`)
          -- 2. Add formatting keymap:
          --    map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Format Code')
          -- 3. Integrate plugins like `lspsaga`, `trouble`, or `fidget.nvim` for enhanced UX
          -- 4. Add client-specific conditions:
          --    if client.name == 'clangd' then ... (custom C/C++ behaviors)
          -- 5. Add which-key support to organize LSP keymaps under a `+lsp` group

          -- Setup nvim-cmp completion mapping inside LSP attach if needed
          -- ╭───────────────────────────────╮
          -- │🤖⚙️AUTOCOMPLETION (nvim-cmp)  │
          -- ╰───────────────────────────────╯
          -- a better completion is there in autocompletion.lua under lua\plugins folder,
          -- ╭───────────────────────────╮
          -- │🖍️Document Highlight       │
          -- ╰───────────────────────────╯
          -- Document Highlight if supported
          local client = vim.lsp.get_client_by_id(event.data.client_id)
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
