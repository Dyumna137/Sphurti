-- plugins/lsp/mason.lua
--[[
### 2. **`mason.lua`** — *Installing and managing language servers*

* This file handles **installing the LSP servers automatically** on your machine.
* Mason is a tool that downloads and manages those LSP servers, so you don't install them manually.
* Here you tell Mason:

  * "Install pyright for Python,"
  * "Install lua_ls for Lua,"
  * and so on.
* Mason makes sure the servers exist on your computer.

mason.lua will do both work of mason and servers.lua.
--]]

require("mason").setup()
require("mason-lspconfig").setup()
-- require("mason-tool-installer").setup()

local on_attach = require("plugins.lsp.on_attach").on_attach

-- NOTE: Blink.cmp's get_lsp_capabilities function includes the built-in LSP capabilities by default.
-- To merge with your own capabilities, use the first argument, which acts as an override.
--
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))

capabilities = vim.tbl_deep_extend("force", capabilities, {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
  }
})

local function get_root_dir(startpath)
  local git_dir = vim.fs.find('*.git', { upward = true, path = startpath })[1]
  return vim.fs.dirname(git_dir) or vim.fs.dirname(startpath)
end
--[[

✅ What This Does
It searches upward from the current file’s directory to find a .git folder.
If .git is found, it returns the parent directory (i.e., project root).
If not, it falls back to the file’s own directory.

✅ No deprecation warnings, and works exactly like the old util.find_git_ancestor().

--]]
-- Disable LSP's built-in completion (nvim-cmp will handle it)
-- capabilities.textDocument.completion = nil

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
        diagnostics = {
          globals = { 'vim' }, -- Tell the server about global `vim`,
          disable = { "missing-fields" }
        },
      },
    },
    -- 👇 Add this!
    root_dir = get_root_dir,

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
          pylsp_black = { enabled = true },
          pylsp_isort = { enabled = false },
        },
      },
    },
  },
  ruff = {
    commands = {
      RuffAutofix = {
        function()
          vim.lsp.buf_request(0, "workspace/executeCommand", {
            command = "ruff.applyAutofix",
            arguments = { { uri = vim.uri_from_bufnr(0) } },
          }, function(_, _, _, _) end) -- function(_, result, ctx, config) end
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

  -- tsserver = {}, -- TypeScript Server (used for JavaScript and TypeScript).
  clangd = require("plugins.lsp.ft.clang"),
  -- jdtls = require("plugins.lsp.ft.java"),
  -- java_language_server = {},
  -- dart = {},   -- Dart Language Server. For flutter.
  jsonls = {},
  sqls = {},
  yamlls = {}, -- .yaml, .yml files (e.g., GitHub Actions, Kubernetes configs).YAML Language Server.
  bashls = {}, -- Bash Language Server.
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
-- autocommands
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "java" },
  callback = function()
    require("plugins.lsp.ft.java").setup()
  end,
})

-- Combine server names and extra tools for mason-tool-installer
local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, extra_tools)

require("mason-tool-installer").setup({
  ensure_installed = ensure_installed, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
})

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers), -- only LSP server names here!
  automatic_enable = true,
  handlers = {
    function(server_name)
      local server_opts = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for ts_ls)

      -- Merge your on_attach and capabilities into each server config
      server_opts.on_attach = server_opts.on_attach or on_attach or
          function() end -- Add fallback for missing on_attach or capabilities
      server_opts.capabilities = vim.tbl_extend("force", capabilities or {}, server_opts.capabilities or {})
      lspconfig[server_name].setup(server_opts)
    end,
  },
})
