return {
  'nvim-lualine/lualine.nvim',
  event = "VeryLazy",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Mode component with custom icon and formatting
    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str -- Add an icon in front of mode text
      end,
    }

    -- File name component
    local filename = {
      'filename',
      file_status = true,   -- Show readonly / modified status
      path = 0,             -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    -- Helper: show only on wide enough screens
    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    -- Diagnostics (errors, warnings)
    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = {
        error = '[E] ',
        warn = '[W] ',
        info = '[I] ',
        hint = '[H] ',
      },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    -- Git diff (added/changed/removed)
    local diff = {
      'diff',
      colored = false,
      symbols = {
        added = '[+] ',
        modified = '[~] ',
        removed = '[-] ',
      },
      cond = hide_in_width,
    }

    -- Setup lualine
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = kanagawa_theme, --themes[env_var_nvim_theme],   -- dynamically chosen theme
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' },   -- skip lualine in these filetypes
        always_divide_middle = true,
      },

      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = {
          diagnostics,
          diff,
          { 'encoding', cond = hide_in_width },
          { 'filetype', cond = hide_in_width },
        },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },

      tabline = {},                  -- tabline is unused, configure here if needed
      extensions = { 'fugitive' },   -- lualine extension support
    }
  end

}
