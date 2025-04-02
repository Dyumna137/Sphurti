local function open_nvim_tree()
  if vim.fn.argc() == 0 then
    require("nvim-tree.api").tree.open()
  end
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")


  -- Ensure buffer is modifiable and not read-only
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))  -- Fix delete keybind
  vim.keymap.set("n", "D", api.fs.trash, opts("Move to Trash"))
  vim.keymap.set("n", "r", api.fs.rename, opts("Rename File"))
  vim.keymap.set("n", "a", api.fs.create, opts("Create File or Folder"))
  vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
  vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
  vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy File"))
  vim.keymap.set("n", "q", api.tree.close, opts("Close NvimTree"))


    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "a", api.fs.create, opts("Create File or Folder"))
    vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
    vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
    vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
    vim.keymap.set("n", "q", api.tree.close, opts("Close NvimTree"))
    vim.keymap.set("n", "<leader>fp", ":Telescope find_files<CR>", { noremap = true, silent = true })
end

require("nvim-tree").setup {
  on_attach = my_on_attach, -- Attach custom key mappings
  hijack_cursor = false,
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  root_dirs = {},
  prefer_startup_root = false,
  sync_root_with_cwd = false,
  reload_on_bufenter = true,
  respect_buf_cwd = false,
  select_prompts = false,
  sort = {
    sorter = "name",
    folders_first = true,
    files_first = false,
  },
 view = {
    centralize_selection = false, -- Don't force selected file to center
    cursorline = true, -- Highlight cursor line
    debounce_delay = 15, -- Update delay in milliseconds
    preserve_window_proportions = false, -- Allow resizing dynamically
    number = false, -- No line numbers in NvimTree
    relativenumber = false, -- No relative line numbers
    signcolumn = "yes", -- Always show Git/diagnostic signs    
    float = {
      enable = true,
      quit_on_focus_loss = true, -- Closes NvimTree when clicking outside
      open_win_config = {
        relative = "editor",
        border = "rounded",  -- Border around the floating window
        width = 50,          -- Adjust width as needed
        height = 30,         -- Adjust height as needed
        row = math.floor((vim.o.lines - 30) / 2),  -- Centers vertically
        col = math.floor((vim.o.columns - 50) / 2), -- Centers horizontally
      },
    },
    width = 50, -- This is required even for floating mode
  },
    renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
        modified = true,
        hidden = false,
        diagnostics = true,
        bookmarks = true,
      },
      glyphs = {
        default = "",
        symlink = "",
        bookmark = "󰆤",
        modified = "●",
        hidden = "󰜌",
        folder = {
          arrow_closed = "",
          arrow_open = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          untracked = "★",
          deleted = "",
          ignored = "◌",
        },
      },
    },
  },
  actions = {
    open_file = {
      quit_on_open = true, -- Auto-close NvimTree after opening a file
      eject = true,
      resize_window = true,
    },
  },
}
