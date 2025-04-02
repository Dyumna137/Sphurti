require("toggleterm").setup({
  size = 20,
  open_mapping = [[<leader>t]],
  direction = "float"
})
vim.keymap.set("t", "<leader>q", "<c-\\><c-n>:q<cr>", { noremap = true, silent = true })

