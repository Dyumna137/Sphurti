 -- 🖌 ui enhancements
return {
  { "folke/tokyonight.nvim" }, -- Colorscheme
  { "nvim-lualine/lualine.nvim", config = function() require("lualine").setup() end }, -- Statusline
  { "akinsho/bufferline.nvim", config = function() require("bufferline").setup() end }, -- Buffer tabs
}

