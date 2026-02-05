-- Mason LSP setup - runs AFTER lspconfig is loaded
return {
  "williamboman/mason.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  config = function()
    require("mason").setup()
    
    -- LSP servers to install
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
          },
        },
      },
      pyright = {},
      clangd = {},
      rust_analyzer = {},
      jdtls = {},
      bashls = {},
    }
    
    -- Setup mason-lspconfig
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = true,
    })
    
    -- Get capabilities from cmp
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
    end
    
    -- Get on_attach
    local ok_attach, on_attach_module = pcall(require, "plugins.lsp.on_attach")
    local on_attach = (ok_attach and on_attach_module.on_attach) or nil
    
    -- Setup each server
    local lspconfig = require("lspconfig")
    for server_name, server_config in pairs(servers) do
      local opts = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = on_attach,
      }, server_config or {})
      
      lspconfig[server_name].setup(opts)
    end
    
    -- Mason tool installer (formatters/linters)
    require("mason-tool-installer").setup({
      ensure_installed = {
        "stylua",
        "clang-format",
        "black",
        "isort",
      },
    })
    
    vim.notify("[mason] LSP setup complete", vim.log.levels.INFO)
  end,
}
