-- ~/.nvim/lua/plugins/trouble.lua
return {
  {
    "folke/trouble.nvim",
    -- Lazy-load Trouble when the :Trouble command is used
    cmd = { "Trouble" },

    -- Optional dependency for nice icons in Trouble
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- Trouble.nvim configuration
    opts = {
      -- Make all Trouble modes open in floating windows
      modes = {
        diagnostics = { view = "float" },     -- LSP diagnostics
        loclist = { view = "float" },         -- Location list
        qflist = { view = "float" },          -- Quickfix list
        symbols = { view = "float" },         -- Workspace symbols
        lsp_definitions = { view = "float" }, -- LSP definitions / references
      },

      -- Floating window appearance
      float = {
        padding = 1,
        max_width = 50,
        max_height = 20,
        border = "rounded",
      },
      line_wrapping = true, -- enable wrapping of long lines
      -- Show diagnostic signs in the gutter
      use_diagnostic_signs = true,

      -- Group similar items together
      group = true,

      -- Add padding around items
      padding = true,

      -- Cycle through results when navigating past the last item
      cycle_results = true,
    },

    -- Config function runs after the plugin is loaded
    config = function()
      local trouble = require("trouble") -- require trouble once

      -- Override the :Trouble command to show a floating chooser
      vim.api.nvim_create_user_command("Trouble", function()
        local opts = {
          { name = "Document Diagnostics",         value = "document_diagnostics" },
          { name = "Workspace Diagnostics",        value = "workspace_diagnostics" },
          { name = "Location List",                value = "loclist" },
          { name = "Quickfix List",                value = "qflist" },
          { name = "Symbols",                      value = "symbols" },
          { name = "LSP Definitions / References", value = "lsp_definitions" },
        }

        -- Try to use Telescope if installed
        local has_telescope, telescope = pcall(require, "telescope.pickers")
        if has_telescope then
          local finders = require("telescope.finders")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          local conf = require("telescope.config").values

          telescope.new({}, {
            prompt_title = "Select Trouble view",
            finder = finders.new_table {
              results = opts,
              entry_maker = function(entry)
                return { value = entry.value, display = entry.name, ordinal = entry.name }
              end,
            },
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                trouble.open(selection.value)
              end)
              return true
            end,
          }):find()
        else
          -- Fallback to vim.ui.select (works in any Neovim setup)
          vim.ui.select(opts, {
            prompt = "Select Trouble view:",
            format_item = function(item) return item.name end,
          }, function(choice)
            if choice then
              trouble.open(choice.value)
            end
          end)
        end
      end, {})
    end,


    -- Keymaps for quickly opening Trouble views
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics<cr>",
        desc = "Open Diagnostics in Trouble (floating)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics filter.buf=0<cr>",
        desc = "Open Buffer Diagnostics in Trouble",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols<cr>",
        desc = "Open Symbols in Trouble",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp<cr>",
        desc = "Open LSP Definitions / References in Trouble",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist<cr>",
        desc = "Open Location List in Trouble",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist<cr>",
        desc = "Open Quickfix List in Trouble",
      },
    },
  },
}


-- NOTE: 'gr' for references is handled via Telescope (not needed here)
