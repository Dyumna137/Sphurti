return { -- Fuzzy Finder plugin for Neovim using Telescope
  'nvim-telescope/telescope.nvim',
  cmd = "Telescope",
  keys = {
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "[S]earch [H]elp" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "[S]earch [K]eymaps" },
    { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "[S]earch [F]iles" },
    { "<leader>ss", "<cmd>Telescope builtin<cr>", desc = "[S]earch [S]elect Telescope" },
    { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "[S]earch current [W]ord" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "[S]earch by [G]rep" },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "[S]earch [D]iagnostics" },
    { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "[S]earch [R]esume" },
    { "<leader>s.", "<cmd>Telescope oldfiles<cr>", desc = "[S]earch Recent Files" },
    { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "[ ] Find existing buffers" },
    { "<leader>/", desc = "[/] Fuzzily search in current buffer" },
    { "<leader>s/", desc = "[S]earch [/] in Open Files" },
    { "<leader>sn", desc = "[S]earch [N]eovim files" },
  },
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required dependency for many Neovim plugins
    {                        -- Optional FZF native extension to speed up fuzzy finding, requires `make`
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',        -- Build native C extension when installing/updating
      cond = function()
        -- Only load if 'make' executable is available on the system
        return vim.fn.executable('make') == 1
      end,
    },

    { 'nvim-telescope/telescope-ui-select.nvim' }, -- Enables Telescope UI for vim.ui.select

    {
      -- Provides file icons in Telescope UI, requires Nerd Font installed & enabled
      'nvim-tree/nvim-web-devicons',
      enabled = vim.g.have_nerd_font,
    },
  },

  config = function()
    -- Import Telescope's actions for key mappings
    local actions = require('telescope.actions')
    
    -- Telescope configuration
    require('telescope').setup {
      defaults = {
        -- Default key mappings for insert (i) and normal (n) modes inside Telescope prompt
        mappings = {
          i = {
            ['<C-k>'] = actions.move_selection_previous, -- Move selection up
            ['<C-j>'] = actions.move_selection_next,     -- Move selection down
            ['<C-l>'] = actions.select_default,          -- Confirm selection (open file)
          },
          n = {
            ['q'] = actions.close,    -- Press 'q' to close Telescope window
          },
        },

        -- Display file paths: show filename only, shorten directories for readability
        path_display = {
          filename = true,
          shorten = 3,
          filename_first = true,
        },

        -- Glob patterns of files/directories to ignore in all pickers by default
        file_ignore_patterns = { 'node_modules', '.git', '.venv' },
      },

      pickers = {
        -- Customize 'find_files' picker
        find_files = {
          hidden = true,                                              -- Show hidden files by default
          file_ignore_patterns = { 'node_modules', '.git', '.venv' }, -- Ignore these dirs
          -- search_dirs = {
          --   vim.fn.stdpath("config") .. "/lua",                       -- your config files
          --   vim.fn.stdpath("data") .. "/lazy",                        -- lazy.nvim plugins
          -- }
          find_command = { "fd", "--type", "f", "--hidden", "--no-ignore" },
        },

        -- Customize 'buffers' picker to manage open buffers
        buffers = {
          initial_mode = 'normal', -- Start in normal mode (not insert)
          sort_lastused = true,    -- Sort buffers by last used time
          mappings = {
            n = {
              ['d'] = actions.delete_buffer,  -- Press 'd' to delete buffer
              ['l'] = actions.select_default, -- Press 'l' to open buffer
            },
          },
        },

        -- Configure 'live_grep' picker for searching inside files
        live_grep = {
          additional_args = function()
            -- Include hidden files in live grep search
            return { '--hidden' }
          end,
          file_ignore_patterns = { 'node_modules', '.git', '.venv' },
        },

        -- Git files picker: disable preview for faster performance
        git_files = {
          previewer = false,
        },
      },

      extensions = {
        -- Setup for UI-select extension to use dropdown theme
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Load Telescope extensions safely (don't error if not installed)
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- Custom keymaps with complex logic (can't be in keys spec)
    local builtin = require('telescope.builtin')

    -- Search inside current buffer with dropdown theme, no preview window
    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- Live grep limited to open files with a custom prompt title
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Quickly find files in Neovim config directory
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath('config') }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
