require("lazy").setup({
  require("custom.configs.lspconfig"),
  require("custom.configs.none-ls"),
  require("custom.configs.gitsigns"),
  require("custom.plugins.ui"),
  require("custom.plugins.file_navigation"),
  require("custom.plugins.syntax_highlighting"),
  require("custom.plugins.lsp"),
  require("custom.plugins.autocomplete"),
  require("custom.plugins.treesitter"),
  require("custom.plugins.terminal"),
  require("custom.plugins.dependencies"),
  require("custom.plugins.debugging"),
})


