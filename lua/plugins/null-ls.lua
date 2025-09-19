-- NOTE: Purpose:
-- ➡️ This sets up the tools (like Black, isort, stylua, prettier) that will do the actual formatting.
--
-- NOTE: Think of this as:
-- 🧰 “Configure formatters and linters for each filetype”

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
  enable = false,
  event = "BufReadPre", -- load only when opening a file
  opts = function()
    local null_ls = require("plugins.null-ls")

    return {
      sources = {
        -- 🔧 Python
        null_ls.builtins.formatting.black.with({
          extra_args = { "--fast" },
        }),
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,

        -- 🌙 Lua
        null_ls.builtins.formatting.stylua,

        -- 🌐 Web (JS/TS/HTML/CSS)
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "javascript", "typescript", "html", "css", "json" },
        }),

        -- 📝 Markdown
        null_ls.builtins.formatting.markdownlint,
        null_ls.builtins.diagnostics.markdownlint,

        -- 🧪 Shell
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.diagnostics.shellcheck,
      },
      -- Format on save support (optional)
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = "LspFormatting", buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
            desc = "[null-ls] Format on Save",
          })
        end
      end,
    }
  end,
}
