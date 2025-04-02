 -- 🖥️ terminal integration
return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 20,  -- size of the terminal window
        open_mapping = [[<leader>t]],  -- toggle terminal with leader + t
        direction = "float",  -- floating terminal
      })
      vim.keymap.set("t", "<leader>q", "<c-\\><c-n>:q<cr>", { noremap = true, silent = true })  -- quit terminal with leader + q
    end
  }}

