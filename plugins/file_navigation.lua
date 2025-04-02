  -- 📂 file navigation
return {
  { "nvim-tree/nvim-tree.lua", config = function() require("nvim-tree").setup() end },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("custom.configs.telescope") -- Keep configs separate
    end
  },
}

