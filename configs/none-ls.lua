return {
  "nvimtools/none-ls.nvim",  -- Correct package name
  dependencies = { "nvim-lua/plenary.nvim" },  -- Required dependency
  config = function()
    local none_ls = require("none-ls")  -- Correct way to require

    none_ls.setup({
      sources = {
        -- Formatters
        none_ls.builtins.formatting.prettier,    -- JavaScript, HTML, CSS
        none_ls.builtins.formatting.black,       -- Python
        none_ls.builtins.formatting.clang_format, -- C/C++

        -- Linters
        none_ls.builtins.diagnostics.flake8,     -- Python Linter
        none_ls.builtins.diagnostics.eslint_d,   -- JS/TS Linter
      },
    })

    -- Keymap to format files with <leader>f
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true }) -- Async formatting
    end, { desc = "Format file", noremap = true, silent = true })
  end,
}

