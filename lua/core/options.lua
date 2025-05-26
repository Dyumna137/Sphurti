
-- File: ~/.config/nvim/lua/core/options.lua

-- ╭────────────────────────────╮
-- │ GENERAL                    │
-- ╰────────────────────────────╯
local opt = vim.opt
local g = vim.g

opt.mouse = 'a'                        -- Enable mouse support
opt.clipboard = 'unnamedplus'         -- Sync Neovim clipboard with system
opt.fileencoding = 'utf-8'            -- Set file encoding to UTF-8
opt.swapfile = false                  -- Don't use swap files
opt.backup = false                    -- Don't create backup files
opt.writebackup = false              -- Disable backup before overwriting files
opt.undofile = true                   -- Enable persistent undo
opt.cmdheight = 1                     -- Command-line height for messages
opt.updatetime = 250                  -- Faster completion & update time
vim.opt.timeout = true               -- Enable timeout for mappings
vim.opt.timeoutlen = 1000            -- Time (in ms) to wait for a mapped sequence to complete
opt.termguicolors = true              -- Enable 24-bit colors

-- ╭────────────────────────────╮
-- │ UI / INTERFACE             │
-- ╰────────────────────────────╯
opt.number = true                     -- Show absolute line numbers
opt.relativenumber = true            -- Show relative numbers
opt.numberwidth = 4                  -- Width of the number column
opt.signcolumn = 'yes'               -- Always show the sign column
opt.cursorline = false               -- Don't highlight the current line
opt.showmode = false                 -- Don't show --INSERT-- mode
opt.showtabline = 2                  -- Always show the tab line
opt.pumheight = 10                   -- Max number of items in completion popup
opt.conceallevel = 0                 -- Show `` in markdown

-- ╭────────────────────────────╮
-- │ SEARCHING                  │
-- ╰────────────────────────────╯
opt.hlsearch = false                 -- Disable search highlight
opt.ignorecase = true                -- Ignore case when searching...
opt.smartcase = true                 -- ...unless capital letters are used

-- ╭────────────────────────────╮
-- │ INDENTATION & TABS         │
-- ╰────────────────────────────╯
opt.autoindent = true               -- Auto-indent new lines
opt.smartindent = true              -- Smart indentation
opt.breakindent = true              -- Keep indentation on wrapped lines
opt.tabstop = 4                     -- A tab is 4 spaces
opt.shiftwidth = 4                  -- Indent by 4 spaces
opt.softtabstop = 4                 -- Backspace deletes 4 spaces
opt.expandtab = true                -- Convert tabs to spaces

-- ╭────────────────────────────╮
-- │ SPLITS & WINDOWS           │
-- ╰────────────────────────────╯
opt.splitbelow = true               -- Horizontal splits open below
opt.splitright = true               -- Vertical splits open to the right

-- ╭────────────────────────────╮
-- │ WRAPPING & SCROLLING       │
-- ╰────────────────────────────╯
opt.wrap = false                    -- Don't wrap long lines
opt.linebreak = true                -- Wrap at word boundaries when wrapping
opt.scrolloff = 4                   -- Minimum lines above/below cursor
opt.sidescrolloff = 8               -- Columns to keep left/right of cursor
opt.whichwrap:append('b,s,<,>,[,],h,l') -- Allow certain keys to move to the next line

-- ╭────────────────────────────╮
-- │ COMPLETION                 │
-- ╰────────────────────────────╯
opt.completeopt = { 'menuone', 'noselect' } -- Better autocompletion experience
opt.shortmess:append('c')                  -- No completion menu messages

-- ╭────────────────────────────╮
-- │ FORMATTING / TEXT          │
-- ╰────────────────────────────╯
opt.iskeyword:append('-')           -- Treat `foo-bar` as one word
opt.formatoptions:remove { 'c', 'r', 'o' } -- Disable auto comment insertion

-- ╭────────────────────────────╮
-- │ RUNTIME                    │
-- ╰────────────────────────────╯
opt.runtimepath:remove('/usr/share/vim/vimfiles') -- Don't load Vim-specific paths

-- Optional: return options for use in other modules
return {}
