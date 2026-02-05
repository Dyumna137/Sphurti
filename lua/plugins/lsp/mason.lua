--[[----------------------------------------------------------------------------
mason.lua  —  Unified Mason + LSP setup
-------------------------------------------------------------------------------

Purpose
  - Configure mason, mason-lspconfig and an installer for extra tools.
  - Provide a single place to declare LSP servers, server overrides,
    and extra tools (formatters/linters) to ensure across machines.
  - Merge shared capabilities and attach a shared `on_attach`.
  - Be defensive: if a dependency is missing, abort gracefully with a notification.

Where to put it
  - lua/plugins/lsp/mason.lua
  - When used with lazy.nvim return the plugin spec (this file does that).

Customization points
  - `servers` table: add/remove LSP servers, or add per-server fields:
      settings, on_attach, capabilities, root_dir, commands
  - `extra_tools`: add binaries (mason tool names) to auto-install
-------------------------------------------------------------------------------]]

local M = {}

local function warn(msg)
  vim.notify(("[mason.lua] %s"):format(msg), vim.log.levels.WARN)
end

local function info(msg)
  vim.notify(("[mason.lua] %s"):format(msg), vim.log.levels.INFO)
end

function M.config()
  -- ---------- Protected requires ----------
  local ok_mason, mason = pcall(require, "mason")
  if not ok_mason then
    warn("mason.nvim not available; skipping Mason setup")
    return
  end

  local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
  if not ok_mason_lsp then
    warn("mason-lspconfig not available; skipping LSP bridging")
    return
  end

  local ok_installer, mason_tool_installer = pcall(require, "mason-tool-installer")
  if not ok_installer then
    warn("mason-tool-installer not available; extra tool auto-install disabled")
    -- We continue because LSPs may still be installed separately.
  end

  local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
  if not ok_lspconfig then
    warn("nvim-lspconfig not available; aborting LSP setup")
    return
  end

  -- ---------- Mason base setup ----------
  mason.setup() -- keep default UI; override here if you like
  -- (mason-lspconfig handlers are registered below)

  -- ---------- shared on_attach ----------
  local ok_on_attach, on_attach = pcall(require, "plugins.lsp.on_attach")
  if not ok_on_attach or type(on_attach.on_attach) ~= "function" then
    warn("plugins.lsp.on_attach not found or invalid; on_attach will be nil")
    on_attach = nil
  else
    on_attach = on_attach.on_attach
  end

  -- ---------- capabilities (nvim-cmp aware) ----------
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp and type(cmp_nvim_lsp.default_capabilities) == "function" then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end
  -- Add foldingRange capability (conservative).
  capabilities.textDocument = capabilities.textDocument or {}
  capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

  -- ---------- robust root detection ----------
  -- tries git root first, then common project markers, then buffer dir
  local function get_root_dir(startpath)
    if type(startpath) ~= "string" or startpath == "" then
      startpath = vim.api.nvim_buf_get_name(0)
    end
    local candidates = vim.fs.find({ ".git", "pyproject.toml", "package.json", "Cargo.toml" }, {
      upward = true,
      path = startpath,
    })
    if candidates and #candidates > 0 then
      return vim.fs.dirname(candidates[1])
    end
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname and bufname ~= "" then
      return vim.fs.dirname(bufname)
    end
    return vim.loop.cwd()
  end

  -- ---------- server definitions (edit this) ----------
  -- Each key is the mason-lspconfig server name.
  -- Per-server keys you can use: settings, on_attach, capabilities, root_dir, commands
  -- The `commands` table supports two shapes:
  --   commands = { MyCmd = { fn = function() ... end, desc = "desc" } }
  --   or  commands = { MyCmd = function() ... end }   -- desc optional
  local servers = {
    -- Lua/Neovim
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
      root_dir = get_root_dir,
    },

    -- Python: pyright + optional Ruff commands (if using ruff-lsp)
    pyright = {},

    -- Ruff LSP (server name may differ depending on mason package; adjust if needed)
    ruff = {
      commands = {
        RuffAutofix = {
          fn = function()
            vim.lsp.buf_request(0, "workspace/executeCommand", {
              command = "ruff.applyAutofix",
              arguments = { { uri = vim.uri_from_bufnr(0) } },
            })
          end,
          desc = "Ruff: apply autofix",
        },
        RuffOrganizeImports = {
          fn = function()
            vim.lsp.buf_request(0, "workspace/executeCommand", {
              command = "ruff.applyOrganizeImports",
              arguments = { { uri = vim.uri_from_bufnr(0) } },
            })
          end,
          desc = "Ruff: organize imports",
        },
      },
    },

    -- C/C++
    clangd = require("plugins.lsp.ft.clang"), -- example: returns a table with settings for clangd

    -- Rust
    rust_analyzer = {},

    -- Java (jdtls is often setup separately as it requires special initialization)
    jdtls = {},

    -- Shell
    bashls = {},
  }

  -- ---------- extra tools (formatters/linters) ----------
  -- Names should match mason package names; edit as required.
  local extra_tools = {
    "clang-format",
    "black",
    "isort",
    "ruff",
    "stylua",
    "flake8",
    "prettier",
  }

  -- ---------- aggregate ensure_installed ----------
  local ensure_installed = vim.tbl_keys(servers)
  if extra_tools and #extra_tools > 0 then
    vim.list_extend(ensure_installed, extra_tools)
  end

  -- ---------- mason-tool-installer (optional) ----------
  if ok_installer then
    mason_tool_installer.setup({
      ensure_installed = ensure_installed,
      -- run_on_start = true, -- enable if you want it to run automatically
      -- start_delay = 3000,  -- ms, useful if you want to wait for UI to settle
    })
  end

  -- ---------- mason-lspconfig handler ----------
  mason_lsp.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false, -- mason-tool-installer handles external binaries
    handlers = {
      -- default handler used for any server not explicitly listed in handlers
      function(server_name)
        local template = servers[server_name] or {}
        -- deep-copy template so we don't mutate the original table stored above
        local server_opts = vim.deepcopy(template)

        -- attach shared on_attach unless the server defines its own
        server_opts.on_attach = server_opts.on_attach or on_attach

        -- merge capabilities; server-specific capabilities override the shared ones
        server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

        -- provide root_dir fallback if not set
        server_opts.root_dir = server_opts.root_dir or get_root_dir

        -- register user commands declared in server_opts.commands (buffer-local)
        if server_opts.commands and type(server_opts.commands) == "table" then
          local commands = server_opts.commands
          local original_on_attach = server_opts.on_attach
          server_opts.on_attach = function(client, bufnr)
            if original_on_attach then
              pcall(original_on_attach, client, bufnr)
            end
            for name, spec in pairs(commands) do
              local fn, desc
              if type(spec) == "function" then
                fn = spec
              elseif type(spec) == "table" and type(spec.fn) == "function" then
                fn = spec.fn
                desc = spec.desc
              elseif type(spec) == "table" and type(spec[1]) == "function" then
                fn = spec[1]
                desc = spec.description or spec.desc
              end
              if type(fn) == "function" then
                vim.api.nvim_buf_create_user_command(bufnr, name, function()
                  -- protect execution to avoid crashing on user command
                  local ok, err = pcall(fn)
                  if not ok then
                    vim.notify(("Command %s failed: %s"):format(name, tostring(err)), vim.log.levels.ERROR)
                  end
                end, { desc = desc or ("LSP command: " .. name) })
              end
            end
          end
          -- remove commands from setup table so lspconfig doesn't see a non-native key
          server_opts.commands = nil
        end

        -- Finally, call lspconfig setup for the server
        local ok_setup, err = pcall(function()
          lspconfig[server_name].setup(server_opts)
        end)
        if not ok_setup then
          warn(("Failed to setup LSP %s: %s"):format(server_name, tostring(err)))
        end
      end,
    },
  })

  info("Mason LSP setup complete")
end

-- Plugin spec return for lazy.nvim (this file acts as the plugin descriptor)
return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonToolsInstall", "MasonUpdate" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- add your completion engine here if you want to advertise it (e.g. "hrsh7th/nvim-cmp")
  },
  config = M.config,
}
