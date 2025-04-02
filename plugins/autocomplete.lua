return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "l3mon4d3/luasnip"
    },
    config = function() require("custom.configs.cmp") end
  }
}

