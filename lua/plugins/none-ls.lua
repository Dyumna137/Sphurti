--[[
Null-ls
==============================

Purpose:
--------
Provide a flexible formatting setup in Neovim using none-ls (null-ls).
- Supports both auto-format-on-save and manual formatting.
- Allows easy toggling between automation and manual control.
- Keeps formatting/linting unified through a single configuration.

Design Decisions:
-----------------
1. Autoformat toggle via a global flag (`vim.g.autoformat_enabled`):
   - Default ON (formats on save).
   - User can disable globally at any time with a command/keymap.
2. Manual formatting always available with <leader>F.
3. Uses augroups and autocmds to attach formatting cleanly per buffer.
4. Keeps sources (formatters/linters) explicitly declared for clarity,
   rather than hidden behind Mason-auto-install magic.

Responsibilities:
-----------------
- Register and configure formatters/linters (Black, isort, stylua, prettier, clang-format, etc.).
- Attach formatting functionality to buffers where supported.
- Expose a user command `:ToggleAutoFormat` and keymap <leader>tf for toggling.
- Ensure formatting is consistent and easy to use across multiple filetypes.

Possible Improvements:
----------------------
- Add per-project overrides (e.g., detect `.editorconfig` or project-local settings).
- Integrate with Mason-null-ls to auto-install tools if missing.
- Provide more granular toggles (per buffer, per filetype, per client).
- Add async notifications or statusline indicators to show formatting status.
- Extend diagnostic sources (e.g., Ruff, eslint_d) for linting in addition to formatting.

]]



-- File: ~/.config/nvim/lua/plugins/none-ls.lua
return {
  "nvimtools/none-ls.nvim",
  event = "BufReadPre",
  config = function()
    local null_ls = require("null-ls")
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    -- Global flag for autoformat
    vim.g.autoformat_enabled = true

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    null_ls.setup({
      sources = {
        -- Python
        formatting.black.with({ extra_args = { "--fast" } }),
        formatting.isort,
        diagnostics.flake8,

        -- Lua
        formatting.stylua,

        -- JS/TS
        formatting.prettier,

        -- C/C++
        formatting.clang_format,
      },

      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- Manual keymap
          vim.keymap.set("n", "<leader>F", function()
            vim.lsp.buf.format({
              async = true,
              filter = function(c) return c.name == "null-ls" end,
              callback = function()
                vim.notify("Buffer formatted ✅", vim.log.levels.INFO)
              end,
            })
          end, { buffer = bufnr, desc = "Format buffer manually" })

          -- Autoformat on save (toggleable)
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              if vim.g.autoformat_enabled then
                vim.lsp.buf.format({ async = false })
              end
            end,
          })
        end
      end,
    })

    -- Toggle command & keymap
    vim.api.nvim_create_user_command("ToggleAutoFormat", function()
      vim.g.autoformat_enabled = not vim.g.autoformat_enabled
      vim.notify("Autoformat on save: " .. (vim.g.autoformat_enabled and "ON ⚡" or "OFF 💤"))
    end, {})

    vim.keymap.set("n", "<leader>tf", ":ToggleAutoFormat<CR>", { desc = "Toggle autoformat on save" })
  end,
}
