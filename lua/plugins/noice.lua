return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {},
  vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<CR>", { desc = "Noice: Show message history" }),
  vim.keymap.set("n", "<leader>nl", "<cmd>Noice last<CR>", { desc = "Noice: Show last message" })

}
