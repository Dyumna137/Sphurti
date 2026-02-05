return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSUpdate", "TSInstall" },
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    -- Register additional file extensions BEFORE setup
    vim.filetype.add({
      extension = {
        tf = 'terraform',
        tfvars = 'terraform',
        pipeline = 'groovy',
        multibranch = 'groovy',
      }
    })

    ---@diagnostic disable-next-line: missing-fields
    local status_ok, treesitter_config = pcall(require, 'nvim-treesitter.configs')
    if not status_ok then
      status_ok, treesitter_config = pcall(require, 'nvim-treesitter.config')
    end
    
    if not status_ok then
      vim.notify("Treesitter config not found", vim.log.levels.ERROR)
      return
    end
    
    treesitter_config.setup {
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        -- Primary languages (C/C++, Python, Rust, Lua, Java only)
        "c",
        "cpp",
        "python",
        "rust",
        "lua",
        "java",
        
        -- Essential
        "vim",
        "vimdoc",
        "bash",
        
        -- Build systems
        "make",
        "cmake",
        
        -- Documentation
        "markdown",
        "markdown_inline",
      },
      -- Autoinstall languages that are not installed
      auto_install = false, -- Changed to false to prevent startup stalls
      sync_install = false,
      ignore_install = { "phpdoc", "haskell" },
      modules = {},
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    }
  end,
}
