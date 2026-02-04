-- trouble.lua - Better diagnostics list with auto-refresh
return {
  {
    "folke/trouble.nvim",
    event = "VeryLazy", -- Load early, not on command (fixes slow activation)
    dependencies = { "nvim-tree/nvim-web-devicons" },
    
    opts = {
      focus = true,              -- Auto-focus when opened
      auto_refresh = true,       -- Auto-refresh when diagnostics change
      auto_close = false,        -- Don't auto-close when no diagnostics
      auto_open = false,         -- Don't auto-open (manual control)
      restore = true,            -- Restore last position
      follow = true,             -- Follow cursor in current buffer
      indent_guides = true,      -- Show indent guides
      max_items = 200,           -- Max items to show
      multiline = true,          -- Show multiline messages
      pinned = false,            -- Don't pin the window
    },

    -- Keymaps for quickly opening Trouble views
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / References (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    
    -- Ensure trouble loads after LSP
    config = function(_, opts)
      require("trouble").setup(opts)
      
      -- Auto-refresh trouble when diagnostics change
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = function()
          if require("trouble").is_open() then
            require("trouble").refresh()
          end
        end,
      })
    end,
  },
}
