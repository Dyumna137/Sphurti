-- (custom)this where main nvchad configuration will live,
-- chadrc.lua file is basially entry point for configuration within nvchad
---@type ChadrcConfig

local M = {}
M.ui = {
  theme = 'catppuccin'
}

M.plugins = "custom.plugins"  -- Ensure your custom plugins load

M.mappings = require("custom.mappings")  -- Load keymaps

-- 🚀 Make sure Neovim loads your LSP config
require("custom.configs.lspconfig")  -- Load custom configurations


M.plugins = {
    user = {
           ["nvim-tree.lua"] = {
                 override_options = require("custom.configs.nvimtree"),
       },
           ["telescope.nvim"] = {
                override_options = require("custom.configs.telescope"),
       },
   },
}

-- 🛠️ General Settings

local opt = vim.opt  -- Shorter alias for convenience

-- UI Settings
opt.number = true       -- Show line numbers
opt.relativenumber = true  -- Relative line numbers
opt.signcolumn = "yes"  -- Always show the sign column (for git, diagnostics)
opt.cursorline = true   -- Highlight the current line

-- Tabs & Indentation
opt.expandtab = true    -- Use spaces instead of tabs
opt.shiftwidth = 4      -- Number of spaces for indentation
opt.tabstop = 4         -- Number of spaces for a tab
opt.softtabstop = 4     -- Spaces per Tab when pressing backspace

-- Searching
opt.ignorecase = true   -- Ignore case when searching
opt.smartcase = true    -- But respect case if uppercase letters are used
opt.hlsearch = true     -- Highlight search results

-- Performance
opt.updatetime = 250    -- Faster completion (default: 4000ms)
opt.timeoutlen = 500    -- Time to wait for a mapped sequence

-- Splits
opt.splitright = true   -- Open vertical splits to the right
opt.splitbelow = true   -- Open horizontal splits below

-- Clipboard
opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.opt.colorcolumn = "100"

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.bo.modifiable = true
  end,
})


return M

