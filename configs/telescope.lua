return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
  config = function()
    require("telescope").setup()
  end,
}

