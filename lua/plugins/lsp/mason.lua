--[[============================================================================
#  mason.lua — Unified Mason Plugin Spec + Full LSP/Tool Management

This single file:
  1. Declares the Mason plugin (for lazy.nvim or similar managers).
  2. Manages installation of LSP servers, linters, and formatters.
  3. Sets up each LSP server with shared `on_attach` + capabilities.
  4. Auto-installs everything (servers + extra tools) via mason-tool-installer.
  5. Applies a safety net to run `on_attach` for non‑Mason LSP clients (e.g. jdtls).

==============================================================================
##  How to Use
Place this file at:  lua/plugins/lsp/mason.lua

lazy.nvim will auto-pick it up (because it returns a plugin spec).
If you are using another manager (like packer), adapt the returned table accordingly.
- lua/plugins/lsp/mason.lua returns a plugin spec table
===============================================================================
## Responsibilities
1. Initialize Mason, mason-lspconfig, mason-tool-installer.
2. Define the list of LSP servers + per-server overrides.
3. Define extra non-LSP tools (formatters / linters).
4. Merge global capabilities (blink.cmp + folding).
5. Provide custom commands for certain servers (e.g. Ruff).
6. Attach proper root_dir logic where needed.
7. Guarantee everything is installed automatically.
8. Keep config resilient (pcall guards + notifications).

===============================================================================
## Customization Quick Reference
Edit these tables below:
  - servers: add/remove LSP servers or override settings/root_dir/on_attach/capabilities.
  - extra_tools: add binaries (formatter, linter, etc.) supported by Mason.
  - ensure_installed: auto-computed (servers + extra_tools) but you can append more manually.

===============================================================================
## Testing / Debugging
  :Mason              → Inspect registry and install status
  :LspInfo            → Active servers
  :MasonToolsInstall  → Force re-run installer
  :checkhealth        → General diagnostics

===============================================================================
## Safe Behavior
If any dependency is missing, configuration gracefully aborts with a warning
(no hard errors during startup).

===============================================================================
--]]

-- ╭────────────────────────────────────╮
-- │ Module Table                       │
-- ╰────────────────────────────────────╯
-- Purpose: Provide a namespace for the config function.
-- Responsibilities:
--   • Hold the main configuration entry point invoked by the plugin spec.
local M = {}

-- ╭────────────────────────────────────╮
-- │ Main Config Entry Point            │
-- ╰────────────────────────────────────╯
-- Purpose: Orchestrate full Mason + LSP tooling setup when the plugin loads.
-- Responsibilities:
--   • Safely require dependencies.
--   • Initialize Mason ecosystems.
--   • Prepare capabilities, servers, and tool installer.
--   • Register handlers and safety autocommands.
function M.config()
  -- ╭────────────────────────────────────╮
  -- │ Protected Requires                 │
  -- ╰────────────────────────────────────╯
  -- Purpose: Avoid runtime errors if plugins are missing.
  -- Responsibilities:
  --   • Notify the user (non-fatal) and abort early when a core dependency is absent.
  local ok_mason, mason = pcall(require, "mason")
  if not ok_mason then
    vim.notify("[mason.lua] mason.nvim not available; skipping Mason setup", vim.log.levels.WARN)
    return
  end

  local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
  if not ok_mason_lsp then
    vim.notify("[mason.lua] mason-lspconfig not available; skipping", vim.log.levels.WARN)
    return
  end

  local ok_installer, mason_tool_installer = pcall(require, "mason-tool-installer")
  if not ok_installer then
    vim.notify("[mason.lua] mason-tool-installer not available; skipping extra tool install", vim.log.levels.WARN)
    return
  end

  -- ╭────────────────────────────────────╮
  -- │ Base Mason Setup                   │
  -- ╰────────────────────────────────────╯
  -- Purpose: Initialize core Mason registry + basic lsp bridge.
  -- Responsibilities:
  --   • Setup mason UI / paths.
  --   • Initialize mason-lspconfig (specific server handlers configured later).
  mason.setup()
  -- (Optional) mason_lsp.setup() bare call isn't necessary; the handler setup below re-calls it.

  -- ╭────────────────────────────────────╮
  -- │ Shared on_attach                   │
  -- ╰────────────────────────────────────╯
  -- Purpose: Reuse your keymaps / buffer customizations across all servers.
  -- Responsibilities:
  --   • Provide uniform behavior (keymaps, formatting bindings, etc.) for every LSP client.
  local on_attach = require("plugins.lsp.on_attach").on_attach

  -- ╭────────────────────────────────────╮
  -- │ Default LSP Capabilities           │
  -- ╰────────────────────────────────────╯
  -- Purpose: Advertise client feature support to language servers.
  -- Responsibilities:
  --   • Merge completion provider (blink.cmp) capabilities.
  --   • Add foldingRange support (static line folding).
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Use base capabilities (blink.cmp requires Neovim 0.10+)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Add nvim-cmp capabilities if available
  local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end
  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

  -- ╭────────────────────────────────────╮
  -- │ Project Root Helper                │
  -- ╰────────────────────────────────────╯
  -- Purpose: Determine project root for file-scoped language servers.
  -- Responsibilities:
  --   • Ascend directories to locate a .git folder.
  --   • Fallback to the directory containing the current buffer/file.
  local function get_root_dir(startpath)
    local git_dir = vim.fs.find(".git", { upward = true, path = startpath })[1]
    return git_dir and vim.fs.dirname(git_dir) or vim.fs.dirname(startpath)
  end

  -- ╭────────────────────────────────────╮
  -- │ Server Definitions                 │
  -- ╰────────────────────────────────────╯
  -- Purpose: Enumerate and customize per-LSP server configuration.
  -- Responsibilities:
  --   • Provide settings, root_dir overrides, and custom command injection.
  --   • Supply specialized modules (e.g., clangd config from a separate file).
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

    ruff = { -- Python lint/format integration (Ruff LSP)
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
          description = "Ruff: Organize imports",
        },
      },
    },


    pyright = {},
    clangd = require("plugins.lsp.ft.clang"),
    rust_analyzer = {},
    jdtls = {},
    bashls = {},






  }

  -- ╭────────────────────────────────────╮

  local extra_tools = {
    "clang-format",
    "black",
    "isort",
    "ruff",
    "stylua",
  }








    "black",
    "isort",
    "flake8",
    "prettier",
  }

  -- ╭────────────────────────────────────╮
  -- │ Aggregate Installation Set         │
  -- ╰────────────────────────────────────╯
  -- Purpose: Consolidate servers + external tools into a single list.
  -- Responsibilities:
  --   • Feed the mason-tool-installer with a unified ensure_installed table.
  local ensure_installed = vim.tbl_keys(servers)
  vim.list_extend(ensure_installed, extra_tools)
  -- table.insert(ensure_installed, "my-custom-cli") -- Example for manual additions.

  -- ╭────────────────────────────────────╮
  -- │ Mason Tool Installer Setup         │
  -- ╰────────────────────────────────────╯
  -- Purpose: Automatically install any missing servers/tools.
  -- Responsibilities:
  --   • Guarantee developer environment consistency across machines.
  mason_tool_installer.setup({
    ensure_installed = ensure_installed,
    -- run_on_start = true,
    -- start_delay = 3000,
  })

  -- ╭────────────────────────────────────╮
  -- │ Mason LSP Handlers                 │
  -- ╰────────────────────────────────────╯
  -- Purpose: Register a generic handler invoked for every Mason-managed server.
  -- Responsibilities:
  --   • Merge global capabilities + per-server overrides.
  --   • Wrap custom server commands into buffer-local user commands on attach.
  local lspconfig = require("lspconfig")

  mason_lsp.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false, -- Already handled by mason-tool-installer
    handlers = {
      function(server_name)
        local server_opts = servers[server_name] or {}

        -- Merge on_attach (server-specific override falls back to global)
        server_opts.on_attach = server_opts.on_attach or on_attach

        -- Merge capabilities (server-specific can override or add)
        server_opts.capabilities = vim.tbl_extend("force", capabilities, server_opts.capabilities or {})

        -- Inject user commands declared under server_opts.commands
        if server_opts.commands then
          local cmd_defs = server_opts.commands
          local original_on_attach = server_opts.on_attach
          server_opts.on_attach = function(client, bufnr)
            if original_on_attach then
              original_on_attach(client, bufnr)
            end
            for name, spec in pairs(cmd_defs) do
              if type(spec) == "table" and type(spec[1]) == "function" then
                vim.api.nvim_buf_create_user_command(bufnr, name, spec[1], {
                  desc = spec.description or ("LSP Command: " .. name),
                })
              end
            end
          end
          server_opts.commands = nil -- Remove non-native key
        end

        lspconfig[server_name].setup(server_opts)
      end,
    },
  })

  -- NOTE: LspAttach autocmd is handled in lua/plugins/lsp.lua
  -- No need for duplicate handler here - on_attach is already called via lsp.lua
end -- end M.config

-- ╭────────────────────────────────────╮
-- │ Plugin Specification Return         │
-- ╰────────────────────────────────────╯
-- Purpose: Export lazy.nvim plugin spec so this file alone controls Mason ecosystem.
-- Responsibilities:
--   • Declare dependencies.
--   • Define load triggers.
--   • Bind config function.
return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonToolsInstall", "MasonUpdate" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- "blink.cmp" -- Ensure your completion engine is installed if referenced.
  },
  config = M.config,
}
