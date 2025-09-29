-- plugins/lsp/mason.lua
--[[
### 2. **`mason.lua`** — Installing and managing language servers

**Purpose:**  
Automatically installs, manages, and keeps track of **LSP servers, linters, and formatters**.  
Think of Mason as a **package manager for LSP tools**.

**Responsibilities:**
1. Install and configure LSP servers (e.g., `pyright`, `lua_ls`, `tsserver`).
2. Install additional tools like formatters and linters via `mason-tool-installer`.
3. Connect installed servers to Neovim via `mason-lspconfig`.
4. Ensure `on_attach` runs for servers that may not be managed by Mason (e.g., `jdtls`, typescript-tools).

**Benefits:**
- Eliminates manual installation of language servers.
- Ensures consistent LSP setup across machines.
- Centralizes all LSP server management in one file.

**Future Improvements:**
- Add version pinning for reproducibility.
- Auto-update servers or tools on startup.
- Allow conditional server installation based on project type.
- Integrate pre- and post-install hooks for custom setup.
]]

-- Mason base setup (UI, registry, paths)
require("mason").setup()
require("mason-lspconfig").setup()

local on_attach = require("plugins.lsp.on_attach").on_attach

-- NOTE: Blink.cmp's get_lsp_capabilities function includes the built-in LSP capabilities by default.
-- To merge with your own capabilities, use the first argument, which acts as an override.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

-- Add folding support to all servers
capabilities = vim.tbl_deep_extend("force", capabilities, {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
})

-- 🔍 Helper: find project root by walking upward until a `.git` folder is found
local function get_root_dir(startpath)
  local git_dir = vim.fs.find("*.git", { upward = true, path = startpath })[1]
  return vim.fs.dirname(git_dir) or vim.fs.dirname(startpath)
end
--[[
✅ This works like `util.find_git_ancestor()` (now deprecated).
It finds the `.git` folder; if not found, falls back to the file’s dir.
--]]

local lspconfig = require("lspconfig")

-- 🛠️ Define all LSP servers with optional custom settings
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
          globals = { "vim" }, -- Tell the server about global `vim`
          disable = { "missing-fields" },
        },
      },
    },
    root_dir = get_root_dir,
  },

  -- Ruff: Python linter/formatter
  ruff = {
    commands = {
      RuffAutofix = {
        function()
          vim.lsp.buf_request(0, "workspace/executeCommand", {
            command = "ruff.applyAutofix",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          }, function(_, _, _, _) end)
        end,
        description = "Ruff: Fix all auto-fixable problems",
      },
      RuffOrganizeImports = {
        function()
          vim.lsp.buf_request(0, "workspace/executeCommand", {
            command = "ruff.applyOrganizeImports",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          }, function(_, _, _, _) end)
        end,
        description = "Ruff: Format imports",
      },
    },
  },

  pyright = {},                             -- Python type checker
  clangd = require("plugins.lsp.ft.clang"), -- C/C++ server with custom config
  jsonls = {},
  sqls = {},
  yamlls = {},   -- YAML LSP (GitHub Actions, Kubernetes configs, etc.)
  bashls = {},   -- Bash LSP
  marksman = {}, -- Markdown LSP
}

-- 🧹 Non-LSP tools (formatters, linters) to install via mason-tool-installer
local extra_tools = {
  "stylua",       -- Lua formatter
  "clang-format", -- C/C++ formatter
  "markdownlint", -- Markdown linter
  -- Add others like prettier, eslint_d, black, etc.
}

-- 📌 Autocommands for filetype-specific setups (e.g. Java)
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "java" },
--   callback = function()
--     require("plugins.lsp.ft.java").setup()
--   end,
-- })

-- 🧩 Combine LSP servers and tools into one install list
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, extra_tools)

-- 🔄 Ensure everything is installed
require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
})

-- 🚀 Setup each LSP server with merged config
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
  handlers = {
    function(server_name)
      local server_opts = servers[server_name] or {}

      -- Merge on_attach and capabilities into each server config
      server_opts.on_attach = server_opts.on_attach or on_attach or function() end
      server_opts.capabilities = vim.tbl_extend("force", capabilities or {}, server_opts.capabilities or {})

      lspconfig[server_name].setup(server_opts)
    end,
  },
})

-- 🛡️ Safety net: run on_attach for *any* LSP that attaches,
-- even those not managed by mason-lspconfig (like jdtls, dartls, etc.)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf
    if client and bufnr then
      on_attach(client, bufnr)
    end
  end,
})
