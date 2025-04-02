return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },  -- Loads only when opening a file
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "python", "lua", "bash", "html", "css", "javascript", "json", "vim", "query" },
        highlight = { enable = true },  -- Syntax highlighting
        indent = { enable = true },  -- Better indentation
        incremental_selection = { enable = true },  -- Select code in stages
      })
    end,
  }
}

