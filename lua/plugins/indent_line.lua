return {
  {                        -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,       -- disables the plugin completely
    event = "BufReadPost", -- event = "BufReadPre",   -- loads before buffer read (first file)
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = {
        char = "│", -- or any char you like
        -- highlight = "IblIndent",
      },
      scope = {
        enabled = true,
        show_start = true, -- corresponds to old `show_current_context_start`
        show_end = false,
        -- highlight = "IblScope",
      },
    },
  },
}
