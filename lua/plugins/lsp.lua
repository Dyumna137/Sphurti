-- File: ~/.config/nvim/lua/plugins/lsp.lua
-- Purpose: Set up LSP servers, completion engine (cmp), and diagnostics.
-- Author: Dyumna, with help from ChatGPT, Kickstart
-- Future-me, don't forget to run `:Mason` to install LSP servers!
-- ─ ╰ ─ ╯ ─ ╭ ─ ╮

return {
  { -- Main LSP Configuration
    'neovim/nvim-lspconfig',
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

        -- Set up autocommand group to safely manage floating diagnostics popup
        vim.api.nvim_create_augroup("FloatDiagnostics", { clear = true })

        vim.o.updatetime = 100 -- Faster CursorHold events (default is 4000ms)

        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          group = "FloatDiagnostics",
          callback = function()
            -- Avoid showing diagnostics float inside Trouble window
            if vim.bo.filetype == "Trouble" then
              return
            end
            vim.diagnostic.open_float(nil, {
              focusable = false,
              close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
              border = "rounded",
              source = "always",
              prefix = "",
              scope = "cursor",
            })
          end,
        })

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
            -- [Helper] Define buffer-local keymaps easily.
            -- This avoids repeating boilerplate for mode, buffer, and description.
            -- Later, you can extract this helper globally if you want to reuse it outside LSP.
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'        -- default to normal mode
              vim.keymap.set(mode, keys, func, {
                buffer = event.buf,     -- Only active in the LSP-attached buffer
                desc = 'LSP: ' .. desc, -- Helps show key descriptions in which-key or Telescope
              })
            end

            -- NOTE:        What should go inside LspAttach?
            --
            -- Buffer-local keymaps for LSP functions (go-to-def, hover, rename, code actions, etc.).
            -- Any client- or buffer-specific behavior that must happen per LSP attach.
            -- Per-client capability checks like client_supports_method.

            -- ╭───────────────────────────╮
            -- │🛠️ Core LSP actions        │
            -- ╰───────────────────────────╯

            -- Show hover documentation (e.g., function signature, comments)
            map('K', vim.lsp.buf.hover, 'Hover Documentation')

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

            -- ╭───────────────────────────────────────────╮
            -- │🧠 Future Improvements You Can Add Here    │
            -- ╰───────────────────────────────────────────╯

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
            -- NOTE:🧵 3. What is cmp (completion plugin)?
            -- 💡 Think of it as autocomplete magic inside Neovim.
            -- It gives:
            -- ✨ Suggestions as you type,  cmp shows the suggestions, but it doesn't generate them by itself.
            -- 🧠 Autocomplete from:
            -- LSP (cmp-nvim-lsp)
            -- Buffer (cmp-buffer)
            -- File paths (cmp-path)
            -- Snippets (cmp_luasnip)
            --
            -- INFO:It doesn't know code by itself — it pulls suggestions from sources like LSPs.
            -- Who gives smart suggestions like functions, types, variables, etc? 
            -- [LSP server] → (cmp-nvim-lsp) → [cmp] → shows popup
            require("lspkind").init() --For icon accordingly
            local cmp = require("cmp")
            cmp.setup({
              snippet = {
                expand = function(args)
                  require("luasnip").lsp_expand(args.body)
                end,
              },
              window = {
                documentation = cmp.config.window.bordered(),
                completion    = cmp.config.window.bordered(),
              },
              completion = {
                autocomplete = {
                  cmp.TriggerEvent.TextChanged,
                  cmp.TriggerEvent.InsertEnter,
                },
              },  formatting = {
                      format = function(entry, vim_item)
                        -- Add icons from lspkind
                        vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

                        -- Add source name at the end
                        vim_item.menu = ({
                          nvim_lsp = "[LSP]",
                          buffer = "[BUF]",
                          path = "[PATH]",
                          luasnip = "[SNIP]",
                          nvim_lua = "[API]",
                          cmp_tabnine = "[AI]",
                        })[entry.source.name]

                        return vim_item
                      end,
                    },
              mapping = cmp.mapping.preset.insert({
                ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ["<Tab>"]     = cmp.mapping.select_next_item(),
                ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"]      = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.confirm({
                      behavior = cmp.ConfirmBehavior.Replace,
                      select   = true,
                    })
                  else
                    fallback()
                  end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
              }),
            })

            -- Force diagnostics refresh in real-time (Insert & Normal)
            vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
              callback = function()
                vim.diagnostic.hide()
                vim.diagnostic.show(nil, nil, nil, { virtual_text = true })
              end,
            })
            -- ╭───────────────────────────╮
            -- │🖍️ Document Highlight      │
            -- ╰───────────────────────────╯
            -- Document Highlight if supported
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
              local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

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
          end,
        })
      end,
    },

  }

