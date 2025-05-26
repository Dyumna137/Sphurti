
-- lua/plugins/lsp/servers.lua
local lspconfig = require("lspconfig")
local on_attach = require("plugins.lsp.on_attach").on_attach

-- Add capabilities for nvim-cmp autocompletion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Example: Python (pyright)
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Example: Lua (lua_ls or sumneko)
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- Add more servers as needed
