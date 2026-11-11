-- Editor-wide options. Keep project-specific behavior in ftplugins or project tools.
local opt = vim.opt

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.fileencoding = "utf-8"
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true

local undo_dir = vim.fn.stdpath("data") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end
opt.undodir = undo_dir

opt.cmdheight = 1
opt.updatetime = 250
opt.timeout = true
opt.timeoutlen = 500
opt.termguicolors = true

-- Interface
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes:1"
opt.cursorline = true
opt.showmode = false
opt.showtabline = 2
opt.pumheight = 10
opt.conceallevel = 0
opt.laststatus = 3
opt.fillchars = { eob = " " }

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Indentation defaults. Use project .editorconfig or ftplugins for exceptions.
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Windows and splits
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Wrapping and scrolling
opt.wrap = true
opt.linebreak = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.whichwrap:append("b,s,h,l")
opt.virtualedit = "block"

-- Completion and formatting
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")
opt.wildmode = "longest:full,full"
opt.iskeyword:append("-")
opt.formatoptions:remove({ "c", "r", "o" })

-- Security: do not source project-local exrc files automatically.
opt.exrc = false

-- Use ripgrep for :grep when available. Exclude common generated directories.
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Leave Neovim's built-in errorformat intact; it already understands common
-- compiler formats. Build panel output is passed to quickfix with this format.
