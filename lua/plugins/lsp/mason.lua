--[[============================================================================
# 📄 `mason.lua` — Installing and Managing Language Servers

## 🧩 Purpose
Automatically install and manage **LSP servers, linters, and formatters**.
Think of Mason as a **package manager for Neovim LSP tools**.

## 🎯 Responsibilities
1. Install and configure LSP servers (pyright, lua_ls, clangd, etc.).
2. Install additional tools like formatters and linters via `mason-tool-installer`.
3. Connect installed servers to Neovim via `mason-lspconfig`.
4. Ensure `on_attach` is run for clients not managed by Mason (jdtls, dartls, etc.).

## 💡 Design Decisions
- Centralized management: all LSP servers and tools defined here.
- Merge `on_attach` and capabilities automatically into server configs.
- Allow per-server custom settings (e.g., lua_ls workspace, clangd custom config).
- Auto-install missing servers to avoid manual setup.
- Separation: Mason only handles installation, server setup delegated to LspAttach.

## 🚀 How to Use
1. Place this file under `lua/plugins/lsp/mason.lua`.
2. Include it in `lsp.lua` using `require("plugins.lsp.mason")`.
3. Define your servers and tools in `servers` and `extra_tools`.
4. Mason will auto-install and configure them with `on_attach` and capabilities.

============================================================================
--]]

-- ╭─────────────────────────────────╮
-- │ Base Mason Setup                │
-- ╰─────────────────────────────────╯
-- Purpose: initialize Mason UI, registry, paths for server management
-- Responsibilities: provides Mason API for installing and managing LSP tools
require("mason").setup()
require("mason-lspconfig").setup()

-- Attach function for when LSP client attaches to a buffer
local on_attach = require("plugins.lsp.on_attach").on_attach

-- ╭────────────────────────────────────╮
-- │ Default LSP Capabilities           │
-- ╰────────────────────────────────────╯
-- Purpose: define capabilities that LSP servers support (completion, folding, etc.)
-- Design: Merge blink.cmp capabilities for autocompletion + foldingRange support
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

local lspconfig = require("lspconfig")

-- ╭──────────────────────────────╮
-- │ Project Root Helper          │
-- ╰──────────────────────────────╯
-- Purpose: Determine project root by searching for .git folder
-- Responsibilities: Used by servers that need a root directory
local function get_root_dir(startpath)
  local git_dir = vim.fs.find("*.git", { upward = true, path = startpath })[1]
  return vim.fs.dirname(git_dir) or vim.fs.dirname(startpath)
end

-- ╭──────────────────────────────────────╮
-- │ Define LSP Servers                   │
-- ╰──────────────────────────────────────╯
-- Purpose: List all LSP servers and their custom settings
-- Design: Servers can override on_attach, capabilities, root_dir, or settings
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
        diagnostics = {
          globals = { "vim" },
          disable = { "missing-fields" },
        },
      },
    },
    root_dir = get_root_dir,
  },

  ruff = {  -- Python linter/formatter
    commands = {
      RuffAutofix = {
        function()
          vim.lsp.buf_request(0, "workspace/executeCommand", {
            command = "ruff.applyAutofix",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          })
        end,
        description = "Ruff: Fix all auto-fixable problems",
      },
      RuffOrganizeImports = {
        function()
          vim.lsp.buf_request(0, "workspace/executeCommand", {
            command = "ruff.applyOrganizeImports",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          })
        end,
        description = "Ruff: Format imports",
      },
    },
  },

  pyright = {},
  clangd = require("plugins.lsp.ft.clang"),
  jsonls = {},
  sqls = {},
  yamlls = {},
  bashls = {},
  marksman = {},
}

-- ╭──────────────────────────────────────╮
-- │ Extra Tools (formatters, linters)    │
-- ╰──────────────────────────────────────╯
-- Purpose: Define non-LSP tools to install (formatters, linters)
local extra_tools = { "stylua", "clang-format", "markdownlint" }

-- ╭──────────────────────────────────────╮
-- │ Combine All Tools for Installation   │
-- ╰──────────────────────────────────────╯
-- Purpose: Ensure everything is installed automatically
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, extra_tools)

-- ╭──────────────────────────────────────╮
-- │ Mason-Tool-Installer Setup           │
-- ╰──────────────────────────────────────╯
-- Purpose: auto-install all servers and tools defined above
require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
})

-- ╭──────────────────────────────────────╮
-- │ Setup Each LSP Server                │
-- ╰──────────────────────────────────────╯
-- Responsibilities:
--   1. Setup LSP servers with default and custom settings
--   2. Attach on_attach and capabilities automatically
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
  handlers = {
    function(server_name)
      local server_opts = servers[server_name] or {}
      server_opts.on_attach = server_opts.on_attach or on_attach
      server_opts.capabilities = vim.tbl_extend("force", capabilities, server_opts.capabilities or {})
      lspconfig[server_name].setup(server_opts)
    end,
  },
})

-- ╭──────────────────────────────────────╮
-- │ Safety Net for Non-Mason Clients     │
-- ╰──────────────────────────────────────╯
-- Purpose: Run on_attach for any LSP client that Mason didn't manage (e.g., jdtls)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf
    if client and bufnr then
      on_attach(client, bufnr)
    end
  end,
})

