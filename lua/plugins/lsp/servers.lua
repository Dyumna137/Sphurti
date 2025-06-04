--[[
### 3. **`servers.lua`** — *Configuring each language server*

* This file says **how each language server should behave** and **connects it with your `on_attach.lua` functions**.
* You tell it which servers you want to use (Python, Lua, etc.).
* For each server, you give settings (like "in Lua, recognize `vim` as a global variable").
* You also say:

  * "When this server attaches, use the `on_attach` behavior"
  * "Use this set of capabilities" (features your completion plugin supports)
--]]
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
