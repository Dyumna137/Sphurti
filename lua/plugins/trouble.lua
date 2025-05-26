return {
  "folke/trouble.nvim",

  -- 🔁 Lazy-load only when :TroubleToggle is called
  cmd = { "Trouble" },

  -- 🧱 Dependencies (icons)
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- ⚙ Plugin options
  opts = {
    position = "bottom", -- "bottom", "top", "left", "right"
    height = 12,
    width = 50,
    icons = true,
    fold_open = "",
    fold_closed = "",
    group = true,
    padding = true,
    cycle_results = true,
    use_diagnostic_signs = true,
  },

  -- ⌨ Keybindings (should NOT be inside opts!)
  keys = {
    -- Document diagnostics (current file)
    { "<leader>xd", "<cmd>Trouble toggle document_diagnostics<cr>", desc = "Document Diagnostics" },

    -- Workspace diagnostics (all files)
    { "<leader>xw", "<cmd>Trouble toggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },

    -- References for symbol under cursor
    { "gr", "<cmd>Trouble toggle lsp_references<cr>", desc = "LSP References (Trouble)" },

    { "<leader>xl", "<cmd>Trouble toggle loclist<cr>", desc = "Location List" },
    { "<leader>xq", "<cmd>Trouble toggle quickfix<cr>", desc = "Quickfix List" },
  }
}

