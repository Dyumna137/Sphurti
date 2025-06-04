return {
  'akinsho/bufferline.nvim',
  event = "VimEnter",
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    local bufferline = require("bufferline")

    bufferline.setup {
      options = {

        -- ▼ Mode: "buffers" = show open buffers, "tabs" = show tab pages
        mode = "buffers",

        -- ▼ Visual style of the bufferline
        style_preset = bufferline.style_preset.default, -- or minimal

        -- ▼ Buffer name and icon behavior
        themable = true,
        numbers = "none", -- options: "ordinal", "buffer_id", "both", or function

        -- ▼ Buffer close/mouse commands
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        -- ▼ Buffer indicator (e.g., ▎ for active buffer)
        indicator = {
          icon = '▎',
          style = 'icon', -- options: 'icon', 'underline', 'none'
        },

        -- ▼ Icons for various UI parts
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        icon_pinned = '󰐃',

        -- ▼ Optional buffer name formatting, Now i do not want to change any buffer name.
        -- name_formatter = function(buf)
        --   -- Return custom names for certain filetypes/buffers here
        --   return nil  -- not override the default naming behavior of bufferline.
        -- end,
        --
        -- ▼ if you want to change buffer name according to filetypes/buffers then
        -- ---@param bufnr integer
        -- name_formatter = function(bufnr)
        --   local name = vim.api.nvim_buf_get_name(bufnr)
        --   local filename = vim.fn.fnamemodify(name, ":t")
        --   local filetype = vim.bo[bufnr].filetype
        --   local buftype = vim.bo[bufnr].buftype
        --
        --   -- Handle special buffer types
        --   if buftype == "help" then
        --     return "📖 Help"
        --   elseif buftype == "terminal" then
        --     return " Terminal"
        --   elseif filetype == "NvimTree" then
        --     return "🌲 File Explorer"
        --   elseif filetype == "TelescopePrompt" then
        --     return "🔍 Telescope"
        --   elseif filetype == "lazy" then
        --     return "💤 Lazy"
        --   end
        --
        --   -- Handle normal files by filetype
        --   if filetype == "markdown" then
        --     return "📘 " .. filename:gsub("%.md$", "")
        --   elseif filetype == "lua" then
        --     return "🌙 " .. filename
        --   elseif filetype == "python" then
        --     return "🐍 " .. filename
        --   elseif filetype == "html" then
        --     return "🌐 " .. filename
        --   elseif filetype == "javascript" then
        --     return "🟨 " .. filename
        --   elseif filetype == "typescript" then
        --     return "🟦 " .. filename
        --   elseif filetype == "json" then
        --     return "🗂️ " .. filename
        --   elseif filetype == "sh" then
        --     return "💻 " .. filename
        --   end
        --
        --   -- Fallback to just filename
        --   return filename
        -- end,

        -- ▼ Buffer name layout and length settings
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 0, -- 0 = auto-size based on name

        -- ▼ Diagnostics support (like LSP errors)
        diagnostics = false, -- "nvim_lsp", or "coc", false to disable
        diagnostics_update_in_insert = false,
        diagnostics_update_on_event = true,
        diagnostics_indicator = function(count)
          return "(" .. count .. ")"
        end,

        -- ▼ Filter out buffers you don’t want to show
        custom_filter = function(buf_number, _buf_numbers)
          local filetype = vim.bo[buf_number].filetype
          local name = vim.fn.bufname(buf_number)

          -- Filter by filetype or name if needed
          if filetype == "qf" or name:match(".*%.log$") then
            return false
          end
          return true
        end,

        -- ▼ Offsets for specific filetypes (e.g. NvimTree)
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },

        -- ▼ Icon and highlight control
        color_icons = true,
        get_element_icon = function(element)
          local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = true })
          return icon, hl
        end,

        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,

        -- ▼ How duplicates and buffer sorting behave
        duplicates_across_groups = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = true,

        -- ▼ Separators between buffers
        separator_style = "thick", -- Options: "slant", "slope", "thin", "thick", or custom {"|", "|"}

        -- ▼ Bufferline always visible and auto-hide options
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = false,

        -- ▼ Hover behavior (e.g. reveal close button on hover)
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' },
        },

        -- ▼ Sorting rule
        sort_by = 'insert_at_end', -- or: 'insert_after_current', 'id', etc.

        -- ▼ Buffer padding control
        minimum_padding = 1,
        maximum_padding = 5,

        -- ▼ Max length of each buffer tab (name)
        maximum_length = 15,

        -- ▼ Pinned buffers sorting and icon
        -- You can pin a buffer using `:BufferLineTogglePin`
        -- and this icon will show up for pinned buffers
        -- sorting makes sure pinned buffers stay in place
        -- when other buffers are moved or sorted
      }
    }

    -- ▼ Keymaps for BufferLine
    vim.keymap.set("n", "<leader>bp", ":BufferLineTogglePin<CR>",
      { desc = "Toggle pin on buffer", noremap = true, silent = true })
    -- vim.keymap.set("n", "<leader>bn", ":BufferLineMoveNext<CR>",
    -- { desc = "Move buffer right", noremap = true, silent = true })
    -- vim.keymap.set("n", "<leader>bb", ":BufferLineMovePrev<CR>",
    -- { desc = "Move buffer left", noremap = true, silent = true })
    vim.keymap.set("n", "<leader>bs", ":BufferLineSortByExtension<CR>",
      { desc = "Sort buffers by extension", noremap = true, silent = true })
    vim.keymap.set("n", "<leader>bd", ":BufferLineSortByDirectory<CR>",
      { desc = "Sort buffers by directory", noremap = true, silent = true })
  end
}
