return { -- Fuzzy Finder plugin for Neovim using Telescope
  'nvim-telescope/telescope.nvim',
  -- event = 'VimEnter',  -- Load plugin when Neovim starts (VimEnter event)
  cmd = "Telescope",
  keys = { "<leader>ff" },
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required dependency for many Neovim plugins
    "folke/trouble.nvim",    -- keep this if you want integration
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
    local trouble = require("trouble.sources.telescope")
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
            ["<c-t>"] = trouble.open, -- open in trouble from Telescope
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

    -- Define convenient keymaps for common Telescope pickers

    local builtin = require('telescope.builtin')

    -- Search Neovim help tags
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })

    -- Search all keymaps
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

    -- Find files (including hidden files)
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })

    -- Open Telescope builtin picker selector
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })

    -- Search for the word under cursor in the project
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

    -- Search with live grep (project-wide)
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })

    -- Search diagnostics (like LSP errors and warnings)
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

    -- Resume last Telescope picker session
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

    -- Show recently opened files
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

    -- List open buffers for quick switching
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

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
