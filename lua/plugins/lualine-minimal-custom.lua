-- Minimal Custom Icons Version (No Nerd Fonts, No AI-common symbols)
-- Uses unique Unicode geometric/technical characters that work everywhere

return {
  'nvim-lualine/lualine.nvim',
  event = "VeryLazy",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Mode component (clean text only)
    local mode = {
      'mode',
      fmt = function(str)
        return str
      end,
    }

    -- File name component
    local filename = {
      'filename',
      file_status = true,
      path = 0,
    }

    -- Helper: show only on wide screens
    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    -- Diagnostics with CUSTOM GEOMETRIC ICONS
    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = {
        error = '■ ',   -- Filled square (solid/blocking error)
        warn = '△ ',    -- Triangle (warning/caution)
        info = '○ ',    -- Circle (information)
        hint = '◇ ',    -- Diamond (hint/suggestion)
      },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    -- Git diff with MATHEMATICAL SYMBOLS
    local diff = {
      'diff',
      colored = false,
      symbols = {
        added = '⊕ ',      -- Circled plus (mathematical addition)
        modified = '⊙ ',   -- Circled dot (modification)
        removed = '⊖ ',    -- Circled minus (mathematical subtraction)
      },
      cond = hide_in_width,
    }

    -- Setup lualine with custom minimal theme
    require('lualine').setup {
      options = {
        icons_enabled = false,  -- No file icons, pure text
        theme = 'auto',
        -- Box drawing characters for separators (technical look)
        section_separators = { left = '┃', right = '┃' },
        component_separators = { left = '┃', right = '┃' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' },
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

      tabline = {},
      extensions = { 'fugitive' },
    }
  end
}
