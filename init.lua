-- ╭───────────────────────────╮
-- │ MANUAL DEBUGGING          │
-- ╰───────────────────────────╯
-- print("Current working dir: " .. vim.fn.getcwd())
-- print("Runtime path: " .. vim.o.runtimepath) e
-- :lua print(#vim.tbl_filter(vim.api.nvim_buf_is_loaded, vim.api.nvim_list_bufs()))
-- :lua vim.diagnostic.open_float(0, { scope = "line", focusable = false }) -- for checking diagnostics

vim.opt.shell = "pwsh"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
require("core.options")
require("core.keymaps")


--While creating a custom funnction and to made them global
--
--
require("plugins.floaterminal")

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- 🔒 Prevent native LSP completion popup for a specific filetype
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.bo.omnifunc = ""
--   end
-- })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
    -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    {
      'tpope/vim-sleuth',   -- Detect tabstop and shiftwidth automatically
      event = 'BufReadPre', -- will load when opening any file
    },
    {
      "famiu/bufdelete.nvim",
      cmd = "Bdelete",
    },
    require("plugins.neo-tree"),
    require("plugins.colortheme"),
    require("plugins.bufferline"),
    require("plugins.lualine"),
    require("plugins.treesitter"),
    require("plugins.telescope"),
    require("plugins.lsp"),
    -- require("plugins.autopairs"),
    -- require("plugins.debug"),
    -- require("plugins.lint"),
    require("plugins.gitsigns"),
    require("plugins.indent_line"),
    require("plugins.autocompletion"),
    require("plugins.alpha"),
    require("plugins.misc"),
    require("plugins.database"),
    require("plugins.trouble"),
    require("plugins.lsp_signature"),

    checker = { enabled = true },
  },
  {
    ui = {
      -- If you have a Nerd Font, set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
    },
  })
