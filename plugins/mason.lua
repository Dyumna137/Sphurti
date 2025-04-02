-- If you want to automatically install LSP servers, use mason.nvim.
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "clangd",     -- LSP for C++
      "codelldb",   -- Debug adapter for C, C++
      "debugpy",    -- Debug adapter for Python
      "pyright",    -- LSP for Python
      "eslint",     -- Linter for JS/TS
      "prettier",   -- Formatter

      "lua-language-server",
	  "stylua",
     -- web dev
	  "css-lsp",
	  "deno",
	  "emmet-ls",
	  "eslint-lsp",
	  "html-lsp",
	  "json-lsp",
	  "typescript-language-server",
	  "yaml-language-server",
      -- shell
	  "shellcheck",

    "help",
    },
  },
}

