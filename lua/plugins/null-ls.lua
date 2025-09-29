-- NOTE: Purpose:
-- ➡️ This sets up the tools (like Black, isort, stylua, prettier) that will do the actual formatting.
--
-- NOTE: Think of this as:
--  “Configure formatters and linters for each filetype”

-- require("custom.plugins.none-ls")       -- sets up formatters
-- require("custom.autoformat").setup_autosave()  -- sets up auto-format-on-save


-- local null_ls = require("null-ls")
--
-- null_ls.setup({
--   sources = {
--     null_ls.builtins.formatting.black,
--     null_ls.builtins.formatting.isort,
--     null_ls.builtins.formatting.stylua,
--     null_ls.builtins.formatting.prettier,
--     null_ls.builtins.formatting.clang_format,
--   },
-- })


-- File: ~/.config/nvim/lua/plugins/null-ls.lua
return {
  "nvimtools/none-ls.nvim",
  enable = true,
  event = "BufReadPre",
  opts = function()
    local null_ls = require("null-ls")

    return {
      sources = {
        -- Python
        null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,

        -- Lua
        null_ls.builtins.formatting.stylua,

        -- C/C++
        null_ls.builtins.formatting.clang_format,

        -- Rust
        null_ls.builtins.formatting.rustfmt,

        -- C# (via dotnet format)
        null_ls.builtins.formatting.dotnet_format,
      },

      -- Disable autoformat-on-save; manual only
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>F", function()
          vim.lsp.buf.format({
            async = true,
            filter = function(client)
              return client.name == "null-ls"
            end,
            callback = function()
              vim.notify("Buffer formatted successfully ✅", vim.log.levels.INFO)
            end,
          })
        end, { buffer = bufnr, desc = "Format buffer manually" })
      end,
    }   
  end,
}  
