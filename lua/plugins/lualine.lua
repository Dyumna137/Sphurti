return{
    'nvim-lualine/lualine.nvim',
    event = "BufWinEnter",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
  -- Custom theme colors (based on OneDark)
  local colors = {
    blue    = '#61afef',
    green   = '#98c379',
    purple  = '#c678dd',
    cyan    = '#56b6c2',
    red1    = '#e06c75',
    red2    = '#be5046',
    yellow  = '#e5c07b',
    fg      = '#abb2bf',
    bg      = '#282c34',
    gray1   = '#828997',
    gray2   = '#2c323c',
    gray3   = '#3e4452',
  }

  -- Custom OneDark lualine theme
  local onedark_theme = {
    normal = {
      a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
      b = { fg = colors.fg, bg = colors.gray3 },
      c = { fg = colors.fg, bg = colors.gray2 },
    },
    insert = { a = { fg = colors.bg, bg = colors.blue, gui = 'bold' } },
    visual = { a = { fg = colors.bg, bg = colors.purple, gui = 'bold' } },
    replace = { a = { fg = colors.bg, bg = colors.red1, gui = 'bold' } },
    command = { a = { fg = colors.bg, bg = colors.yellow, gui = 'bold' } },
    terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = 'bold' } },
    inactive = {
      a = { fg = colors.gray1, bg = colors.bg, gui = 'bold' },
      b = { fg = colors.gray1, bg = colors.bg },
      c = { fg = colors.gray1, bg = colors.gray2 },
    },
  }

  -- Dynamically choose theme based on environment variable `NVIM_THEME`
  local env_var_nvim_theme = os.getenv("NVIM_THEME") or "nord"
  local themes = {
    onedark = onedark_theme,
    nord = "nord", -- fallback to default theme string
  }

  -- Mode component with custom icon and formatting
  local mode = {
    'mode',
    fmt = function(str)
      return ' ' .. str  -- Add an icon in front of mode text
    end,
  }

  -- File name component
  local filename = {
    'filename',
    file_status = true, -- Show readonly / modified status
    path = 0,           -- 0 = just filename, 1 = relative path, 2 = absolute path
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
      error = ' ',
      warn = ' ',
      info = ' ',
      hint = ' ',
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
      added = ' ',
      modified = ' ',
      removed = ' ',
    },
    cond = hide_in_width,
  }

  -- Setup lualine
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = themes[env_var_nvim_theme], -- dynamically chosen theme
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' }, -- skip lualine in these filetypes
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

    tabline = {}, -- tabline is unused, configure here if needed
    extensions = { 'fugitive' }, -- lualine extension support
  }
end

}
