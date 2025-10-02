--[[============================================================================
-- lua/plugins/lsp/on_attach.lua
--[[
Module: plugins.lsp.on_attach
Purpose:
  Provide a single, well-documented on_attach handler for LSP clients.
Responsibilities:
  - Configure buffer-local keymaps and behaviors when an LSP client attaches.
  - Provide toggleable and manual formatting (prefer null-ls when present).
  - Create document highlight autocmds and a small status helper for statuslines.
Design decisions:
  - Prefer null-ls for formatting if available; otherwise use any client that
    advertises formatting support (coerce formatting capability to boolean).
  - Use buffer-local vars (via nvim_buf_get_var / nvim_buf_set_var) to keep
    state per-buffer and avoid global leakage.
  - Keep the module side-effect free (only returns table); caller should call
    require("plugins.lsp.on_attach").on_attach in lspconfig/mason handlers.
============================================================================
]]

local M = {}

-- ╭──────────────────────────────────────╮
-- │ Helper: Buffer-local Keymaps         │
-- ╰──────────────────────────────────────╯
-- Purpose: Sets keymaps for a specific buffer only
-- Responsibilities:
--   - Map normal or insert mode keys to LSP functions
--   - Optional description for which-key or documentation
-- Design: Flexible mode support; works for single or multiple modes

--- Set a buffer-local keymap (works for single or multiple modes).
--- @param bufnr number buffer id
--- @param key string key sequence
--- @param func function callback
--- @param desc string|nil description for which-key or docs
--- @param mode string|table|nil mode or list of modes (defaults to "n")
local function bufmap(bufnr, key, func, desc, mode)
  mode = mode or "n"
  if type(mode) == "table" then
    for _, m in ipairs(mode) do
      vim.keymap.set(m, key, func, { buffer = bufnr, desc = desc })
    end
  else
    vim.keymap.set(mode, key, func, { buffer = bufnr, desc = desc })
  end
end

-- ╭──────────────────────────────────────╮
-- │ Client-specific Overrides            │
-- ╰──────────────────────────────────────╯
-- Purpose: Apply per-client custom behavior (e.g., disable server formatting)
-- Responsibilities:
--   - Provide small overrides for LSP clients that conflict with null-ls

--- Table of per-client override functions. Add entries here to tweak client.capabilities.
local client_specific = {
  tsserver = function(client) client.server_capabilities.documentFormattingProvider = false end,
  lua_ls   = function(client) client.server_capabilities.documentFormattingProvider = false end,
}

-- ╭──────────────────────────────────────╮
-- │ Buffer var helpers (minimal & safe)  │
-- ╰──────────────────────────────────────╯
-- Purpose: Read / write buffer-local vars safely without throwing errors.

--- Safe get buffer var
--- @param bufnr number
--- @param name string
--- @return any|nil
local function buf_get_var_safe(bufnr, name)
  local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr, name)
  if ok then return val end
  return nil
end

--- Safe set buffer var (pcall to avoid errors)
--- @param bufnr number
--- @param name string
--- @param value any
local function buf_set_var_safe(bufnr, name, value)
  pcall(vim.api.nvim_buf_set_var, bufnr, name, value)
end

-- ╭──────────────────────────────────────╮
-- │ Helper: normalize formatting support │
-- ╰──────────────────────────────────────╯
-- Purpose: documentFormattingProvider can be boolean or table; coerce to boolean

--- Coerce a client's documentFormattingProvider to a boolean.
--- Accepts either the client table or the direct capability value.
--- @param client_or_cap table|boolean|nil
--- @return boolean
local function supports_formatting_bool(client_or_cap)
  local val
  if type(client_or_cap) == "table" and client_or_cap.server_capabilities ~= nil then
    val = client_or_cap.server_capabilities.documentFormattingProvider
  else
    val = client_or_cap
  end
  if type(val) == "boolean" then return val end
  if type(val) == "table" then return true end
  return false
end

-- ╭──────────────────────────────────────╮
-- │ Main on_attach Function              │
-- ╰──────────────────────────────────────╯
-- Purpose: Called when an LSP client attaches to a buffer
-- Responsibilities:
--   1. Configure completion/omnifunc
--   2. Apply client-specific overrides
--   3. Setup manual + autoformatting (toggleable)
--   4. Setup keymaps
--   5. Setup document highlights

--- Main handler called from lspconfig when a client attaches.
--- Usage: on_attach = require("plugins.lsp.on_attach").on_attach
--- @param client table LSP client
--- @param bufnr number buffer number
function M.on_attach(client, bufnr)
  if not (client and bufnr) then return end

  -- Set buffer-local omnifunc (non-deprecated API)
  -- Uncomment to use LSP omnifunc: vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  pcall(function() vim.bo[bufnr].omnifunc = "" end)

  -- Apply small per-client overrides (e.g., turn off server formatting if desired)
  if client_specific[client.name] then client_specific[client.name](client) end

  -- ╭──────────────────────────────────────╮
  -- │ Formatting Setup                     │
  -- ╰──────────────────────────────────────╯
  if client.server_capabilities and supports_formatting_bool(client) then
    if buf_get_var_safe(bufnr, "format_enabled") == nil then
      buf_set_var_safe(bufnr, "format_enabled", true)
    end

    -- Manual format (prefer null-ls)
    bufmap(bufnr, "<leader>F", function()
      vim.lsp.buf.format({
        bufnr = bufnr,
        async = true,
        filter = function(c)
          if c.name == "null-ls" then return true end
          return supports_formatting_bool(c)
        end,
      })
    end, "Format buffer manually")

    -- Toggle autoformat on save
    bufmap(bufnr, "<leader>tf", function()
      local cur = buf_get_var_safe(bufnr, "format_enabled")
      if cur == nil then cur = true end
      buf_set_var_safe(bufnr, "format_enabled", not cur)
      vim.notify("Format on save: " .. (not cur and "ENABLED " or "DISABLED "))
    end, "Toggle Format on Save")

    -- Create autoformat autocmd only once per buffer
    if not buf_get_var_safe(bufnr, "format_augroup_created") then
      local group_name = "LspFormat." .. bufnr
      local aug = vim.api.nvim_create_augroup(group_name, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = aug,
        buffer = bufnr,
        callback = function()
          local enabled = buf_get_var_safe(bufnr, "format_enabled")
          if enabled == nil then enabled = true end
          if enabled then
            vim.lsp.buf.format({
              bufnr = bufnr,
              async = false,
              filter = function(c)
                if c.name == "null-ls" then return true end
                return supports_formatting_bool(c)
              end,
            })
          end
        end,
        desc = "Autoformat before save",
      })
      buf_set_var_safe(bufnr, "format_augroup_created", true)
    end
  end

  -- ╭───────────────────────────────╮
  -- │ Document Highlights           │
  -- ╰───────────────────────────────╯
  if client.server_capabilities and client.server_capabilities.documentHighlightProvider then
    local hl_group_name = "lsp_document_highlight_" .. bufnr
    local hl_grp = vim.api.nvim_create_augroup(hl_group_name, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_grp,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = hl_grp,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })

    -- Styling for reference highlights (safe pcall)
    pcall(vim.api.nvim_set_hl, 0, "LspReferenceText", { underline = false, bg = "#3c3836" })
    pcall(vim.api.nvim_set_hl, 0, "LspReferenceRead", { underline = false, bg = "#3c3836" })
    pcall(vim.api.nvim_set_hl, 0, "LspReferenceWrite", { underline = false, bg = "#3c3836" })
  end
end

-- ╭───────────────────────────────╮
-- │ Statusline Helper             │
-- ╰───────────────────────────────╯
-- Purpose: Small helper exported for statusline integration.

--- Return small per-buffer format-on-save indicator for statusline.
--- @param bufnr number|nil
--- @return string
function M.format_status(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, enabled = pcall(vim.api.nvim_buf_get_var, bufnr, "format_enabled")
  if not ok then return "" end
  return enabled and " fmt:on" or " fmt:off"
end

return M

