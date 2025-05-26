-- plugins/lsp/mason.lua

require("mason").setup()
require("mason-lspconfig").setup()
-- require("mason-tool-installer").setup()

local on_attach = require("plugins.lsp.on_attach").on_attach
local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")

-- Define all LSP servers with optional settings
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          checkThirdParty = false,
          library = {
            "${3rd}/luv/library",
            unpack(vim.api.nvim_get_runtime_file("", true)),
          },
        },
        completion = { callSnippet = "Replace" },
        telemetry = { enable = false },
        diagnostics = { globals = { 'vim' }, -- Tell the server about global `vim`,
                        disable = { "missing-fields" }
        },
      },
    },
  },
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          autopep8 = { enabled = false },
          yapf = { enabled = false },
          mccabe = { enabled = false },
          pylsp_mypy = { enabled = false },
          pylsp_black = { enabled = false },
          pylsp_isort = { enabled = false },
        },
      },
    },
  },
  ruff = {
    commands = {
      RuffAutofix = {
        function()
          vim.lsp.buf.buf_request({
            command = "ruff.applyAutofix",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          })
        end,
        description = "Ruff: Fix all auto-fixable problems",
      },
      RuffOrganizeImports = {
        function()
          vim.lsp.buf.buf_request({
            command = "ruff.applyOrganizeImports",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          })
        end,
        description = "Ruff: Format imports",
      },
    },
  },
  -- tsserver = {}, -- TypeScript Server (used for JavaScript and TypeScript).
  clangd = {},
  -- jdtls = {},    --  Java Development Tools Language Server.
  -- dart = {},   -- Dart Language Server. For flutter.
  jsonls = {},
  sqls = {},
  terraformls = {}, --  
  yamlls = {},   -- .yaml, .yml files (e.g., GitHub Actions, Kubernetes configs).YAML Language Server. 
  bashls = {},   -- Bash Language Server.
  -- dockerls = {}, -- Dockerfile Language Server. 
  -- docker_compose_language_service = {}, -- Docker Compose YAML language server.
  marksman = {},
  -- Pyright = {},
}

-- Non-LSP tools (formatters, linters)
local extra_tools = {
  "stylua",
  "clang-format",
  "markdownlint",
  -- Add others like prettier, eslint_d...
}

-- Combine server names and extra tools for mason-tool-installer
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, extra_tools)

require("mason-tool-installer").setup({
  ensure_installed = ensure_installed, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
})

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),     -- only LSP server names here!
  automatic_enable = true,
    handlers = {
    function(server_name)
      local server_opts = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for ts_ls)

      -- Merge your on_attach and capabilities into each server config
      server_opts.on_attach = on_attach
      server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

      lspconfig[server_name].setup(server_opts)
    end,
  },
})

