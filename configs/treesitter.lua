require("nvim-treesitter.configs").setup({
  ensure_installed = {
        "c",
        "cpp",
        "python",
        "lua",
        "bash",
        "css",
        "json",
        "query",
        "comment",
        "css",
		"graphql",
		"html",
		"javascript",
		"json",
		"lua",
		"regex",
		"tsx",
		"typescript",
		"vim",
		"yaml",
},
  highlight = { enable = true },
  indent = { enable = true },
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  callback = function()
    vim.cmd("TSEnable highlight")
  end,
})

